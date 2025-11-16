const WebSocket = require('ws');

/**
 * SIS WebSocket Manager
 * Handles WebSocket communication with Huawei Speech Interaction Service (SIS)
 */
class SisWebSocketManager {
  constructor(endpoint, projectId, iamToken) {
    this.endpoint = endpoint;
    this.projectId = projectId;
    this.iamToken = iamToken;
    this.ws = null;
    this.connectionTimeout = 10000; // 10 seconds
  }

  /**
   * Construct WebSocket URL for SIS
   * @returns {string} WebSocket URL
   */
  getWebSocketUrl() {
    return `wss://${this.endpoint}/v1/${this.projectId}/rasr/sentence-stream`;
  }

  /**
   * Build START command for SIS
   * @param {string} audioFormat - Audio format (default: pcm16k16bit)
   * @param {string} property - ASR property (default: english_16k_general)
   * @returns {object} START command object
   */
  buildStartCommand(audioFormat = 'pcm16k16bit', property = 'english_16k_general') {
    return {
      command: 'START',
      config: {
        audio_format: audioFormat,
        property: property,
        add_punc: 'yes',
        interim_results: 'no',
      },
    };
  }

  /**
   * Build SEND command for audio chunk
   * @param {string} base64Audio - Base64 encoded audio data
   * @returns {object} SEND command object
   */
  buildSendCommand(base64Audio) {
    return {
      command: 'SEND',
      data: base64Audio,
    };
  }

  /**
   * Build END command
   * @returns {object} END command object
   */
  buildEndCommand() {
    return {
      command: 'END',
    };
  }

  /**
   * Connect to SIS WebSocket with IAM token authentication
   * @returns {Promise<WebSocket>} Connected WebSocket instance
   */
  connect() {
    return new Promise((resolve, reject) => {
      const url = this.getWebSocketUrl();
      const timestamp = new Date().toISOString();

      console.log(`[${timestamp}] Connecting to SIS WebSocket: ${url}`);

      // Create WebSocket with IAM token in headers
      this.ws = new WebSocket(url, {
        headers: {
          'X-Auth-Token': this.iamToken,
        },
      });

      // Set connection timeout
      const timeout = setTimeout(() => {
        if (this.ws.readyState !== WebSocket.OPEN) {
          this.ws.terminate();
          reject(new Error('WebSocket connection timeout'));
        }
      }, this.connectionTimeout);

      // Handle connection open
      this.ws.on('open', () => {
        clearTimeout(timeout);
        const timestamp = new Date().toISOString();
        console.log(`[${timestamp}] SIS WebSocket connected successfully`);
        resolve(this.ws);
      });

      // Handle connection error
      this.ws.on('error', (error) => {
        clearTimeout(timeout);
        const timestamp = new Date().toISOString();
        console.error(`[${timestamp}] SIS WebSocket error:`, error.message);
        reject(error);
      });
    });
  }

  /**
   * Send START command to SIS
   * @param {string} property - ASR property (e.g., english_16k_general)
   * @returns {Promise<void>}
   */
  sendStart(property = 'english_16k_general') {
    return new Promise((resolve, reject) => {
      if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
        return reject(new Error('WebSocket not connected'));
      }

      const startCommand = this.buildStartCommand('pcm16k16bit', property);
      const timestamp = new Date().toISOString();
      
      console.log(`[${timestamp}] Sending START command:`, JSON.stringify(startCommand));
      
      try {
        this.ws.send(JSON.stringify(startCommand));
        resolve();
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Send audio chunk to SIS
   * @param {Buffer} audioBuffer - Audio data buffer
   * @returns {Promise<void>}
   */
  sendAudioChunk(audioBuffer) {
    return new Promise((resolve, reject) => {
      if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
        return reject(new Error('WebSocket not connected'));
      }

      try {
        // Convert buffer to base64
        const base64Audio = audioBuffer.toString('base64');
        const sendCommand = this.buildSendCommand(base64Audio);
        
        this.ws.send(JSON.stringify(sendCommand));
        resolve();
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Send audio in chunks (max 10KB per chunk)
   * @param {Buffer} audioBuffer - Complete audio data buffer
   * @param {number} chunkSize - Size of each chunk in bytes (default: 10240)
   * @returns {Promise<void>}
   */
  async sendAudioInChunks(audioBuffer, chunkSize = 10240) {
    const totalChunks = Math.ceil(audioBuffer.length / chunkSize);
    const timestamp = new Date().toISOString();
    
    console.log(`[${timestamp}] Sending audio in ${totalChunks} chunks (${audioBuffer.length} bytes total)`);

    for (let i = 0; i < totalChunks; i++) {
      const start = i * chunkSize;
      const end = Math.min(start + chunkSize, audioBuffer.length);
      const chunk = audioBuffer.slice(start, end);
      
      await this.sendAudioChunk(chunk);
      
      // Small delay between chunks to avoid overwhelming the connection
      if (i < totalChunks - 1) {
        await new Promise(resolve => setTimeout(resolve, 10));
      }
    }

    const endTimestamp = new Date().toISOString();
    console.log(`[${endTimestamp}] All audio chunks sent successfully`);
  }

  /**
   * Send END command to SIS
   * @returns {Promise<void>}
   */
  sendEnd() {
    return new Promise((resolve, reject) => {
      if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
        return reject(new Error('WebSocket not connected'));
      }

      const endCommand = this.buildEndCommand();
      const timestamp = new Date().toISOString();
      
      console.log(`[${timestamp}] Sending END command`);
      
      try {
        this.ws.send(JSON.stringify(endCommand));
        resolve();
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Wait for transcription result from SIS
   * @param {number} timeout - Timeout in milliseconds (default: 30000)
   * @returns {Promise<object>} Transcription result
   */
  waitForResult(timeout = 30000) {
    return new Promise((resolve, reject) => {
      if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
        return reject(new Error('WebSocket not connected'));
      }

      const timer = setTimeout(() => {
        reject(new Error('Transcription timeout'));
      }, timeout);

      // Listen for messages
      const messageHandler = (data) => {
        try {
          const message = JSON.parse(data.toString());
          const timestamp = new Date().toISOString();
          
          console.log(`[${timestamp}] Received SIS message:`, JSON.stringify(message));

          // Check for error
          if (message.error_code || message.error_msg) {
            clearTimeout(timer);
            this.ws.off('message', messageHandler);
            reject(new Error(`SIS Error: ${message.error_code} - ${message.error_msg}`));
            return;
          }

          // Check for result
          if (message.result && message.result.text) {
            clearTimeout(timer);
            this.ws.off('message', messageHandler);
            resolve(message.result);
            return;
          }

          // Log other messages but continue waiting
          console.log(`[${timestamp}] Waiting for transcription result...`);
        } catch (error) {
          clearTimeout(timer);
          this.ws.off('message', messageHandler);
          reject(new Error(`Failed to parse SIS response: ${error.message}`));
        }
      };

      this.ws.on('message', messageHandler);
    });
  }

  /**
   * Close WebSocket connection
   */
  close() {
    if (this.ws) {
      const timestamp = new Date().toISOString();
      console.log(`[${timestamp}] Closing SIS WebSocket connection`);
      
      try {
        this.ws.close();
      } catch (error) {
        console.error(`[${timestamp}] Error closing WebSocket:`, error.message);
      }
      
      this.ws = null;
    }
  }

  /**
   * Complete transcription flow: connect, send audio, get result
   * @param {Buffer} audioBuffer - Audio data buffer
   * @param {string} property - ASR property (e.g., english_16k_general)
   * @returns {Promise<string>} Transcribed text
   */
  async transcribe(audioBuffer, property = 'english_16k_general') {
    try {
      // Connect to WebSocket
      await this.connect();

      // Send START command
      await this.sendStart(property);

      // Send audio in chunks
      await this.sendAudioInChunks(audioBuffer);

      // Send END command
      await this.sendEnd();

      // Wait for result
      const result = await this.waitForResult();

      // Close connection
      this.close();

      return result.text || '';
    } catch (error) {
      // Ensure connection is closed on error
      this.close();
      throw error;
    }
  }
}

module.exports = SisWebSocketManager;
