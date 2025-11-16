# Implementation Plan

- [x] 1. Update DiagnosisProvider to use real ModelArts inference





  - Remove the mock data generation code path for retinal model
  - Uncomment and activate the real ModelArts inference code
  - Remove the temporary 2-second delay that simulates processing
  - Remove the TODO comment about fixing ModelArts authentication
  - Ensure locale is passed to the inference service for multilingual support
  - _Requirements: 1.1, 1.2, 1.3, 10.1, 10.2, 10.3, 10.4, 10.5_

- [x] 2. Integrate AI second opinion from DeepSeek





  - Ensure the DeepSeek second opinion call is active in the analyzeImage method
  - Wrap the second opinion call in try-catch for graceful failure
  - Prepend the second opinion to recommendations if available
  - Verify the call passes image bytes and model probabilities correctly
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [x] 3. Verify severity mapping implementation






  - Confirm _mapSeverity method correctly maps "Normal" to "Normal" severity
  - Confirm confidence >= 0.9 maps to "High" severity
  - Confirm confidence 0.8-0.9 maps to "Medium" severity
  - Confirm confidence < 0.8 maps to "Low" severity
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 4. Verify recommendation generation






  - Ensure _generateRecommendations creates condition-specific recommendations
  - Verify recommendations include general eye health advice
  - Confirm recommendations are appropriate for each detected condition
  - _Requirements: 5.6_

- [x] 5. Test configuration loading






  - Verify env.json contains all required ModelArts fields
  - Test that missing configuration throws descriptive error with field names
  - Verify configuration validation in RetinaInferenceService initialization
  - Confirm error messages guide users to fix configuration issues
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 6. Test ModelArts inference end-to-end on web platform






  - Start the backend proxy server (node backend/server.js)
  - Run the Flutter web application
  - Upload a test retinal image
  - Verify the request goes through the backend proxy
  - Confirm IAM token is obtained and cached
  - Verify ModelArts API is called with correct headers
  - Confirm response is parsed correctly
  - Check that results display in the UI
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 9.1, 9.2, 9.3, 9.4_

- [x] 7. Test error handling scenarios






  - Test with image larger than 8MB (should show size error)
  - Test with missing configuration (should show config error)
  - Test with invalid credentials (should show auth error)
  - Test with network disconnection (should show network error)
  - Test with invalid service ID (should show service not found error)
  - Verify all error messages are user-friendly and actionable
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 8. Verify logging throughout the pipeline






  - Check DiagnosisProvider logs when using real inference
  - Check RetinaInferenceService logs initialization and response parsing
  - Check HuaweiModelArtsService logs API calls and responses
  - Check backend proxy logs IAM token acquisition and ModelArts forwarding
  - Verify logs include sufficient detail for troubleshooting
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 9. Test response parsing for multiple formats






  - Create test cases for format {"prediction": "...", "confidence": ...}
  - Create test cases for format {"result": {"class": "...", "confidence": ...}}
  - Create test cases for format {"predictions": [{"class": "...", ...}]}
  - Verify fallback parsing works for unexpected formats
  - Confirm uncertain predictions (confidence < 0.6) are handled correctly
  - _Requirements: 1.4, 4.4, 6.1, 6.2, 6.3, 6.4_

- [x] 10. Test IAM authentication flow






  - Verify first API call triggers IAM token request on 401
  - Confirm token is cached with correct expiry (24 hours - 5 min buffer)
  - Test that cached token is reused for subsequent requests
  - Verify token refresh works when expired
  - Test authentication failure handling
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 11. Perform manual testing across platforms






  - Test on web platform with backend proxy
  - Test on mobile platform with direct API calls (if applicable)
  - Test with various retinal images (normal and diseased)
  - Test in English locale
  - Test in Arabic locale (if supported)
  - Verify UI displays results correctly in all scenarios
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [ ] 12. Validate second opinion integration
  - Test with valid Huawei AI API key
  - Test without API key (should fail gracefully)
  - Verify second opinion appears in recommendations when available
  - Confirm diagnosis continues without second opinion on failure
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ] 13. Performance and optimization validation
  - Measure average response time for inference
  - Verify token caching reduces IAM API calls
  - Check that 8MB limit prevents unnecessary network usage
  - Monitor backend proxy performance under load
  - _Requirements: 4.1, 3.2_

- [ ] 14. Documentation and cleanup
  - Remove all mock data code and comments
  - Update code comments to reflect real inference
  - Document any configuration changes needed
  - Create troubleshooting guide for common errors
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
