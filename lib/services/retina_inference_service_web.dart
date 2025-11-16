import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:eye_wise_connect/services/huawei_modelarts_service.dart';
import 'package:eye_wise_connect/services/api_key_loader.dart';
import 'dart:html' as html;

/// Web implementation uses ModelArts for inference.
class RetinaInferenceService {
  HuaweiModelArtsService? _modelArtsService;
  bool _initialized = false;
  // Confidence threshold below which we mark the result as uncertain
  static const double confidenceThreshold = 0.6;

  List<String>? _labels;

  Future<void> init() async {
    if (_initialized) return;

    print('[RetinaInferenceService-Web] Initializing ModelArts service...');
    
    // Load ModelArts configuration
    final modelArtsConfig = await ApiKeyLoaderModelArts.loadHuaweiModelArtsConfig();
    if (modelArtsConfig == null || !modelArtsConfig.isComplete) {
      // For web, we use the backend proxy which doesn't require client-side credentials
      // Create a minimal config that will trigger proxy usage
      print('[RetinaInferenceService-Web] No compile-time config found, using backend proxy mode');
      print('[RetinaInferenceService-Web] Backend proxy will handle authentication');
      
      // Create placeholder config - the actual values will come from backend
      final placeholderConfig = HuaweiModelArtsConfig(
        projectId: 'proxy',
        accessKeyId: 'proxy',
        secretAccessKey: 'proxy',
        serviceId: 'proxy',
        region: 'proxy',
        invokeUrl: 'proxy',
      );
      
      _modelArtsService = HuaweiModelArtsService(config: placeholderConfig);
      await _loadLabels();
      _initialized = true;
      print('[RetinaInferenceService-Web] Initialization complete (proxy mode)');
      return;
    }

    print('[RetinaInferenceService-Web] ModelArts config loaded successfully');
    print('[RetinaInferenceService-Web] Service ID: ${modelArtsConfig.serviceId}');
    print('[RetinaInferenceService-Web] Region: ${modelArtsConfig.region}');
    
    _modelArtsService = HuaweiModelArtsService(config: modelArtsConfig);
    await _loadLabels();
    _initialized = true;
    print('[RetinaInferenceService-Web] Initialization complete');
  }

  Future<void> _loadLabels() async {
    // On web, labels would need to be loaded from assets or network
    // For now, we'll skip this as it's optional
    _labels = null;
  }

  Future<InferenceResult> predictBytes(Uint8List bytes, {String model = 'retina', Locale? locale}) async {
    if (!_initialized) {
      await init();
    }

    if (_modelArtsService == null) {
      throw Exception(
          'ModelArts service not initialized. Please check your configuration.');
    }

    try {
      // Call ModelArts inference
      print('[RetinaInferenceService-Web] Calling ModelArts inference...');
      final result = await _modelArtsService!.inferImage(bytes);
      print('[RetinaInferenceService-Web] ModelArts response: $result');

      // Parse ModelArts response (same logic as mobile)
      String predictedClass = 'Unknown';
      double confidence = 0.0;
      Map<String, double> probabilities = {};
      bool uncertain = false;

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

      // If probabilities map is empty, use default
      if (probabilities.isEmpty) {
        if (predictedClass != 'Unknown' && confidence > 0) {
          probabilities[predictedClass] = confidence;
        } else {
          probabilities['Normal'] = 0.0;
          predictedClass = 'Normal';
          confidence = 0.0;
        }
      }

      uncertain = confidence < confidenceThreshold;

      // Log parsed results for debugging
      print('[RetinaInferenceService-Web] Parsed - Class: $predictedClass, Confidence: $confidence');
      print('[RetinaInferenceService-Web] Probabilities: $probabilities');

      // If we got Unknown or 0 confidence, the response format might be different
      if (predictedClass == 'Unknown' || confidence == 0.0) {
        print('[RetinaInferenceService-Web] ⚠️ WARNING: Could not parse ModelArts response properly.');
        print('[RetinaInferenceService-Web] Response keys: ${result.keys.toList()}');
        print('[RetinaInferenceService-Web] Full response: $result');
        
        // Try to find any numeric values that might be probabilities
        result.forEach((key, value) {
          print('[RetinaInferenceService-Web]   $key: $value (${value.runtimeType})');
          if (value is List && (value as List).isNotEmpty) {
            print('[RetinaInferenceService-Web]     List length: ${(value as List).length}');
            print('[RetinaInferenceService-Web]     First item: ${(value as List)[0]}');
          }
        });
        
        // Try alternative parsing - check if any value in the map is a list
        for (final entry in result.entries) {
          if (entry.value is List && (entry.value as List).isNotEmpty) {
            print('[RetinaInferenceService-Web] Found list in key: ${entry.key}');
            final list = entry.value as List;
            final firstItem = list[0];
            if (firstItem is Map) {
              predictedClass = (firstItem['class'] ?? firstItem['label'] ?? firstItem['prediction'] ?? 'Unknown').toString();
              confidence = (firstItem['confidence'] ?? firstItem['score'] ?? firstItem['probability'] ?? 0.0).toDouble();
              print('[RetinaInferenceService-Web] Parsed from list: $predictedClass, $confidence');
              if (confidence > 0) break; // Found valid result
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
      print('[RetinaInferenceService-Web] ModelArts error (status: $statusCode): $errorMsg');
      throw Exception(
          'ModelArts inference failed (status: $statusCode): $errorMsg\n\n'
          'Please check:\n'
          '1. ModelArts configuration (compile-time variables)\n'
          '2. Service ID is correct\n'
          '3. Model deployment is active\n'
          '4. Network connection');
    } catch (e) {
      print('[RetinaInferenceService-Web] Exception: $e');
      throw Exception('ModelArts inference error: $e\n\n'
          'Please check ModelArts configuration (compile-time variables)');
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
