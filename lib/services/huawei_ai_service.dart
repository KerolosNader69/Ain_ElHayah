import 'dart:convert';
import 'package:dio/dio.dart';

import 'api_key_loader.dart';

/// Minimal Huawei AI (DeepSeek/Qwen) client using Bearer API key.
/// Assumes OpenAI-style chat completions if base URL provided; otherwise we
/// call a generic /chat endpoint. Adjust once exact docs are provided.
class HuaweiAiService {
  final HuaweiAiConfig config;
  final Dio _dio;

  HuaweiAiService({required this.config, Dio? dio}) : _dio = dio ?? Dio();

  String get _baseUrl => (config.baseUrl ?? 'https://api.huawei-competition.ai').replaceAll(RegExp(r'/+$'), '');

  Future<String> chat({required List<Map<String, String>> messages, String? model}) async {
    final useOpenAiStyle = true; // assume compatibility
    final endpoint = useOpenAiStyle ? '/v1/chat/completions' : '/chat';
    final url = _baseUrl + endpoint;
    final payload = useOpenAiStyle
        ? {
            'model': model ?? config.model ?? 'deepseek-v3.1',
            'messages': messages,
            'temperature': 0.7,
          }
        : {
            'model': model ?? config.model ?? 'deepseek-v3.1',
            'messages': messages,
          };
    final res = await _dio.post(
      url,
      data: jsonEncode(payload),
      options: Options(headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      }),
    );

    // OpenAI style response
    final data = res.data;
    if (data is Map && data['choices'] != null && data['choices'] is List) {
      final first = data['choices'][0];
      final msg = first['message'] as Map<String, dynamic>?;
      final content = msg?['content']?.toString();
      if (content != null && content.isNotEmpty) return content;
    }
    // Fallback: try 'text'
    if (data is Map && data['text'] != null) {
      return data['text'].toString();
    }
    return 'No response';
  }
}


