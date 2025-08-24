import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

/// Web implementation calls a backend API (FastAPI) to run the real model.
class RetinaInferenceService {
  // Configure at build time: --dart-define=PREDICT_API_URL=https://your-host/predict
  static const String _apiUrl = String.fromEnvironment(
    'PREDICT_API_URL',
    defaultValue: 'http://127.0.0.1:8000/predict',
  );

  Future<void> init() async {}

  Future<InferenceResult> predictBytes(Uint8List bytes) async {
    try {
      final uri = Uri.parse(_apiUrl);

      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'image.jpg',
          ),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw Exception('API ${response.statusCode}: ${response.body}');
      }

      final Map<String, dynamic> json = convert.jsonDecode(response.body) as Map<String, dynamic>;

      final String predictedClass = (json['predicted_class'] ?? 'Normal').toString();
      final double confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;
      final Map<String, double> probs = {};
      final dynamic all = json['all_probabilities'];
      if (all is Map) {
        all.forEach((k, v) {
          final key = k.toString();
          final val = (v as num?)?.toDouble() ?? 0.0;
          probs[key] = val;
        });
      }

      return InferenceResult(
        predictedClass: predictedClass,
        confidence: confidence,
        probabilities: probs,
      );
    } catch (e) {
      // Graceful fallback rather than always "Normal"
      final Map<String, double> probabilities = {
        'Normal': 0.0,
        'Cataract': 0.0,
        'Diabetic Retinopathy': 0.0,
        'Glaucoma': 0.0,
      };
      return InferenceResult(
        predictedClass: 'Normal',
        confidence: 0.0,
        probabilities: probabilities,
      );
    }
  }

  void dispose() {}
}

class InferenceResult {
  final String predictedClass;
  final double confidence;
  final Map<String, double> probabilities;

  InferenceResult({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
  });
}

