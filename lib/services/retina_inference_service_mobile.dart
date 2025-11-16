import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:eye_wise_connect/services/huawei_modelarts_service.dart';
import 'package:eye_wise_connect/services/api_key_loader.dart';

class RetinaInferenceService {
  static const List<String> defaultClasses = [
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
  ];

  HuaweiModelArtsService? _modelArtsService;
  bool _initialized = false;
  // Confidence threshold below which we mark the result as uncertain
  static const double confidenceThreshold = 0.6;

  List<String>? _labels; // Optional labels loaded from assets/models/labels.txt

  Future<void> init() async {
    if (_initialized) return;

    print('[RetinaInferenceService] Initializing ModelArts service...');
    
    // Load ModelArts configuration
    final modelArtsConfig = await ApiKeyLoaderModelArts.loadHuaweiModelArtsConfig();
    if (modelArtsConfig == null || !modelArtsConfig.isComplete) {
      final missingFields = <String>[];
      if (modelArtsConfig == null) {
        missingFields.addAll([
          'MODELARTS_PROJECT_ID',
          'MODELARTS_ACCESS_KEY',
          'MODELARTS_SECRET_KEY',
          'MODELARTS_SERVICE_ID',
          'MODELARTS_REGION',
          'MODELARTS_INVOKE_URL',
        ]);
      } else {
        if (modelArtsConfig.projectId.isEmpty) missingFields.add('MODELARTS_PROJECT_ID');
        if (modelArtsConfig.accessKeyId.isEmpty) missingFields.add('MODELARTS_ACCESS_KEY');
        if (modelArtsConfig.secretAccessKey.isEmpty) missingFields.add('MODELARTS_SECRET_KEY');
        if (modelArtsConfig.serviceId.isEmpty) missingFields.add('MODELARTS_SERVICE_ID');
        if (modelArtsConfig.region.isEmpty) missingFields.add('MODELARTS_REGION');
        if (modelArtsConfig.invokeUrl.isEmpty) missingFields.add('MODELARTS_INVOKE_URL');
      }
      throw Exception(
          'ModelArts configuration is missing or incomplete.\n\n'
          'Missing fields: ${missingFields.join(", ")}\n\n'
          'Please add these to env.json in the project root:\n'
          '{\n'
          '  "MODELARTS_PROJECT_ID": "your-project-id",\n'
          '  "MODELARTS_ACCESS_KEY": "your-access-key",\n'
          '  "MODELARTS_SECRET_KEY": "your-secret-key",\n'
          '  "MODELARTS_SERVICE_ID": "your-service-id",\n'
          '  "MODELARTS_REGION": "ap-southeast-3",\n'
          '  "MODELARTS_INVOKE_URL": "https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>"\n'
          '}');
    }

    print('[RetinaInferenceService] ModelArts config loaded successfully');
    print('[RetinaInferenceService] Service ID: ${modelArtsConfig.serviceId}');
    print('[RetinaInferenceService] Region: ${modelArtsConfig.region}');
    
    _modelArtsService = HuaweiModelArtsService(config: modelArtsConfig);
    await _loadLabels();
    _initialized = true;
    print('[RetinaInferenceService] Initialization complete');
  }

  Future<void> _loadLabels() async {
    try {
      final labelsText = await rootBundle.loadString('assets/models/labels.txt');
      final lines = labelsText.split(RegExp(r'\r?\n'));
      final parsed = lines.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (parsed.isNotEmpty) {
        _labels = parsed;
      }
    } catch (_) {
      // ignore if not present
    }
  }

  Future<InferenceResult> predict(File imageFile) async {
    if (!_initialized) {
      await init();
    }

    final bytes = await imageFile.readAsBytes();
    return await predictBytes(bytes);
  }

  Future<InferenceResult> predictBytes(Uint8List bytes) async {
    if (!_initialized) {
      await init();
    }

    if (_modelArtsService == null) {
      throw Exception(
          'ModelArts service not initialized. Please check your env.json configuration:\n'
          '- MODELARTS_PROJECT_ID\n'
          '- MODELARTS_ACCESS_KEY\n'
          '- MODELARTS_SECRET_KEY\n'
          '- MODELARTS_SERVICE_ID\n'
          '- MODELARTS_REGION\n'
          '- MODELARTS_INVOKE_URL');
    }

    try {
      // Call ModelArts inference
      print('[RetinaInferenceService] Calling ModelArts inference...');
      final result = await _modelArtsService!.inferImage(bytes);
      print('[RetinaInferenceService] ModelArts response: $result');

      // Parse ModelArts response
      // Adjust these fields based on your actual model output format
      String predictedClass = 'Unknown';
      double confidence = 0.0;
      Map<String, double> probabilities = {};
      bool uncertain = false;

      // Try to extract prediction from response
      // Common response formats:
      // 1. {"prediction": "class_name", "confidence": 0.95, "probabilities": {...}}
      // 2. {"result": {"class": "class_name", "score": 0.95}}
      // 3. {"predictions": [{"class": "class_name", "confidence": 0.95}]}

      if (result.containsKey('prediction')) {
        predictedClass = result['prediction'].toString();
        confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;
        if (result['probabilities'] is Map) {
          final probs = result['probabilities'] as Map;
          probabilities = probs.map((k, v) => MapEntry(
              k.toString(), (v as num?)?.toDouble() ?? 0.0));
        }
      } else if (result.containsKey('result')) {
        final resultData = result['result'];
        if (resultData is Map) {
          predictedClass = (resultData['class'] ?? resultData['label'] ?? 'Unknown').toString();
          confidence = (resultData['confidence'] ?? resultData['score'] ?? 0.0).toDouble();
          if (resultData['probabilities'] is Map) {
            final probs = resultData['probabilities'] as Map;
            probabilities = probs.map((k, v) => MapEntry(
                k.toString(), (v as num?)?.toDouble() ?? 0.0));
          }
        }
      } else if (result.containsKey('predictions')) {
        final predictions = result['predictions'];
        if (predictions is List && predictions.isNotEmpty) {
          final firstPred = predictions[0];
          if (firstPred is Map) {
            predictedClass = (firstPred['class'] ?? firstPred['label'] ?? 'Unknown').toString();
            confidence = (firstPred['confidence'] ?? firstPred['score'] ?? 0.0).toDouble();
            if (firstPred['probabilities'] is Map) {
              final probs = firstPred['probabilities'] as Map;
              probabilities = probs.map((k, v) => MapEntry(
                  k.toString(), (v as num?)?.toDouble() ?? 0.0));
            }
          }
        }
      } else {
        // Fallback: try to find any class/confidence fields
        predictedClass = (result['class'] ?? result['label'] ?? 'Unknown').toString();
        confidence = (result['confidence'] ?? result['score'] ?? 0.0).toDouble();
        if (result['probabilities'] is Map) {
          final probs = result['probabilities'] as Map;
          probabilities = probs.map((k, v) => MapEntry(
              k.toString(), (v as num?)?.toDouble() ?? 0.0));
        }
      }

      // If probabilities map is empty, try to build from labels
      if (probabilities.isEmpty && _labels != null && _labels!.isNotEmpty) {
        // If model returns a single prediction, set that class to confidence
        if (predictedClass != 'Unknown' && confidence > 0) {
          probabilities[predictedClass] = confidence;
          // Set other classes to low probabilities
          for (final label in _labels!) {
            if (label != predictedClass) {
              probabilities[label] = (1.0 - confidence) / (_labels!.length - 1);
            }
          }
        }
      }

      // If still empty, use default classes
      if (probabilities.isEmpty) {
        if (predictedClass != 'Unknown' && confidence > 0) {
          probabilities[predictedClass] = confidence;
        } else {
          // Default fallback
          for (final label in defaultClasses) {
            probabilities[label] = 1.0 / defaultClasses.length;
          }
          predictedClass = defaultClasses[0];
          confidence = 1.0 / defaultClasses.length;
        }
      }

      uncertain = confidence < confidenceThreshold;

      // Log parsed results for debugging
      print('[RetinaInferenceService] Parsed - Class: $predictedClass, Confidence: $confidence');
      print('[RetinaInferenceService] Probabilities: $probabilities');

      // If we got Unknown or 0 confidence, the response format might be different
      if (predictedClass == 'Unknown' || confidence == 0.0) {
        print('[RetinaInferenceService] ⚠️ WARNING: Could not parse ModelArts response properly.');
        print('[RetinaInferenceService] Response keys: ${result.keys.toList()}');
        print('[RetinaInferenceService] Full response: $result');
        print('[RetinaInferenceService] Response type: ${result.runtimeType}');
        
        // Try to find any numeric values that might be probabilities
        result.forEach((key, value) {
          print('[RetinaInferenceService]   $key: $value (${value.runtimeType})');
          if (value is List) {
            print('[RetinaInferenceService]     List length: ${value.length}');
            if (value.isNotEmpty) {
              print('[RetinaInferenceService]     First item: ${value[0]} (${value[0].runtimeType})');
            }
          }
        });
        
        // Try alternative parsing - check if any value in the map is a list
        for (final entry in result.entries) {
          if (entry.value is List && (entry.value as List).isNotEmpty) {
            print('[RetinaInferenceService] Found list in key: ${entry.key}');
            final list = entry.value as List;
            final firstItem = list[0];
            if (firstItem is Map) {
              predictedClass = (firstItem['class'] ?? firstItem['label'] ?? firstItem['prediction'] ?? 'Unknown').toString();
              confidence = (firstItem['confidence'] ?? firstItem['score'] ?? firstItem['probability'] ?? 0.0).toDouble();
              print('[RetinaInferenceService] Parsed from list: $predictedClass, $confidence');
              if (confidence > 0) break; // Found valid result
            } else if (firstItem is num) {
              // Maybe it's a direct probability array
              print('[RetinaInferenceService] Found numeric list, might be probabilities array');
            }
          }
        }
      }

      return InferenceResult(
        predictedClass: uncertain ? 'Uncertain' : predictedClass,
        confidence: confidence,
        probabilities: probabilities,
        uncertain: uncertain,
      );
    } on Map<String, dynamic> catch (error) {
      // Structured error from ModelArts service
      final statusCode = error['statusCode'] as int?;
      final body = error['body'] as Map<String, dynamic>?;
      final errorMsg = body?['error']?.toString() ?? 
                      body?['message']?.toString() ?? 
                      body?.toString() ?? 
                      'Unknown error';
      print('[RetinaInferenceService] ModelArts error (status: $statusCode): $errorMsg');
      throw Exception(
          'ModelArts inference failed (status: $statusCode): $errorMsg\n\n'
          'Please check:\n'
          '1. ModelArts configuration in env.json\n'
          '2. Service ID is correct\n'
          '3. Model deployment is active\n'
          '4. Network connection');
    } catch (e) {
      print('[RetinaInferenceService] Exception: $e');
      throw Exception('ModelArts inference error: $e\n\n'
          'Please check ModelArts configuration in env.json');
    }
  }

  void dispose() {
    _modelArtsService = null;
    _initialized = false;
  }
}

class InferenceResult {
  final String predictedClass;
  final double confidence;
  final Map<String, double> probabilities;
  final bool uncertain;

  InferenceResult({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
    this.uncertain = false,
  });
}
