import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

void main() {
  group('Response Parsing Tests', () {
    // Helper function to simulate the parsing logic from RetinaInferenceService
    InferenceResult parseModelArtsResponse(Map<String, dynamic> result) {
      String predictedClass = 'Unknown';
      double confidence = 0.0;
      Map<String, double> probabilities = {};
      bool uncertain = false;
      const double confidenceThreshold = 0.6;

      // Format 1: {"prediction": "...", "confidence": ...}
      if (result.containsKey('prediction')) {
        predictedClass = result['prediction'].toString();
        confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;
        if (result['probabilities'] is Map) {
          final probs = result['probabilities'] as Map;
          probabilities = probs.map((k, v) => MapEntry(
              k.toString(), (v as num?)?.toDouble() ?? 0.0));
        }
      }
      // Format 2: {"result": {"class": "...", "confidence": ...}}
      else if (result.containsKey('result')) {
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
      }
      // Format 3: {"predictions": [{"class": "...", ...}]}
      else if (result.containsKey('predictions')) {
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
      }
      // Fallback: try to find any class/confidence fields
      else {
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

      return InferenceResult(
        predictedClass: uncertain ? 'Uncertain' : predictedClass,
        confidence: confidence,
        probabilities: probabilities,
        uncertain: uncertain,
      );
    }

    group('Format 1: {"prediction": "...", "confidence": ...}', () {
      test('Parses prediction format with high confidence', () {
        final response = {
          'prediction': 'Diabetic Retinopathy',
          'confidence': 0.92,
          'probabilities': {
            'Normal': 0.02,
            'Diabetic Retinopathy': 0.92,
            'Glaucoma': 0.06,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Diabetic Retinopathy');
        expect(result.confidence, 0.92);
        expect(result.uncertain, false);
        expect(result.probabilities['Diabetic Retinopathy'], 0.92);
        expect(result.probabilities['Normal'], 0.02);
        expect(result.probabilities['Glaucoma'], 0.06);
      });

      test('Parses prediction format with low confidence (uncertain)', () {
        final response = {
          'prediction': 'Glaucoma',
          'confidence': 0.45,
          'probabilities': {
            'Normal': 0.30,
            'Diabetic Retinopathy': 0.25,
            'Glaucoma': 0.45,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Uncertain');
        expect(result.confidence, 0.45);
        expect(result.uncertain, true);
        expect(result.probabilities['Glaucoma'], 0.45);
      });

      test('Parses prediction format without probabilities map', () {
        final response = {
          'prediction': 'Normal',
          'confidence': 0.88,
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Normal');
        expect(result.confidence, 0.88);
        expect(result.uncertain, false);
        expect(result.probabilities['Normal'], 0.88);
      });

      test('Handles confidence exactly at threshold (0.6)', () {
        final response = {
          'prediction': 'Diabetic Retinopathy',
          'confidence': 0.6,
          'probabilities': {
            'Normal': 0.20,
            'Diabetic Retinopathy': 0.60,
            'Glaucoma': 0.20,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Diabetic Retinopathy');
        expect(result.confidence, 0.6);
        expect(result.uncertain, false);
      });
    });

    group('Format 2: {"result": {"class": "...", "confidence": ...}}', () {
      test('Parses result format with class field', () {
        final response = {
          'result': {
            'class': 'Glaucoma',
            'confidence': 0.85,
            'probabilities': {
              'Normal': 0.05,
              'Diabetic Retinopathy': 0.10,
              'Glaucoma': 0.85,
            }
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Glaucoma');
        expect(result.confidence, 0.85);
        expect(result.uncertain, false);
        expect(result.probabilities['Glaucoma'], 0.85);
      });

      test('Parses result format with label field instead of class', () {
        final response = {
          'result': {
            'label': 'Normal',
            'confidence': 0.95,
            'probabilities': {
              'Normal': 0.95,
              'Diabetic Retinopathy': 0.03,
              'Glaucoma': 0.02,
            }
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Normal');
        expect(result.confidence, 0.95);
        expect(result.uncertain, false);
      });

      test('Parses result format with score field instead of confidence', () {
        final response = {
          'result': {
            'class': 'Diabetic Retinopathy',
            'score': 0.78,
            'probabilities': {
              'Normal': 0.12,
              'Diabetic Retinopathy': 0.78,
              'Glaucoma': 0.10,
            }
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Diabetic Retinopathy');
        expect(result.confidence, 0.78);
        expect(result.uncertain, false);
      });

      test('Parses result format with uncertain prediction', () {
        final response = {
          'result': {
            'class': 'Glaucoma',
            'confidence': 0.55,
            'probabilities': {
              'Normal': 0.25,
              'Diabetic Retinopathy': 0.20,
              'Glaucoma': 0.55,
            }
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Uncertain');
        expect(result.confidence, 0.55);
        expect(result.uncertain, true);
      });
    });

    group('Format 3: {"predictions": [{"class": "...", ...}]}', () {
      test('Parses predictions array format', () {
        final response = {
          'predictions': [
            {
              'class': 'Diabetic Retinopathy',
              'confidence': 0.89,
              'probabilities': {
                'Normal': 0.05,
                'Diabetic Retinopathy': 0.89,
                'Glaucoma': 0.06,
              }
            }
          ]
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Diabetic Retinopathy');
        expect(result.confidence, 0.89);
        expect(result.uncertain, false);
        expect(result.probabilities['Diabetic Retinopathy'], 0.89);
      });

      test('Parses predictions array with label field', () {
        final response = {
          'predictions': [
            {
              'label': 'Normal',
              'score': 0.97,
              'probabilities': {
                'Normal': 0.97,
                'Diabetic Retinopathy': 0.02,
                'Glaucoma': 0.01,
              }
            }
          ]
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Normal');
        expect(result.confidence, 0.97);
        expect(result.uncertain, false);
      });

      test('Parses predictions array with multiple predictions (uses first)', () {
        final response = {
          'predictions': [
            {
              'class': 'Glaucoma',
              'confidence': 0.72,
              'probabilities': {
                'Normal': 0.15,
                'Diabetic Retinopathy': 0.13,
                'Glaucoma': 0.72,
              }
            },
            {
              'class': 'Normal',
              'confidence': 0.15,
            }
          ]
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Glaucoma');
        expect(result.confidence, 0.72);
        expect(result.uncertain, false);
      });

      test('Handles empty predictions array', () {
        final response = {
          'predictions': []
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Uncertain');
        expect(result.confidence, 0.0);
        expect(result.uncertain, true);
      });
    });

    group('Fallback parsing for unexpected formats', () {
      test('Parses direct class and confidence fields', () {
        final response = {
          'class': 'Diabetic Retinopathy',
          'confidence': 0.81,
          'probabilities': {
            'Normal': 0.10,
            'Diabetic Retinopathy': 0.81,
            'Glaucoma': 0.09,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Diabetic Retinopathy');
        expect(result.confidence, 0.81);
        expect(result.uncertain, false);
      });

      test('Parses label and score fields', () {
        final response = {
          'label': 'Normal',
          'score': 0.93,
          'probabilities': {
            'Normal': 0.93,
            'Diabetic Retinopathy': 0.04,
            'Glaucoma': 0.03,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Normal');
        expect(result.confidence, 0.93);
        expect(result.uncertain, false);
      });

      test('Handles completely unexpected format with no recognizable fields', () {
        final response = {
          'data': 'some value',
          'status': 'ok',
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Uncertain');
        expect(result.confidence, 0.0);
        expect(result.uncertain, true);
        expect(result.probabilities['Normal'], 0.0);
      });

      test('Handles response with only probabilities', () {
        final response = {
          'probabilities': {
            'Normal': 0.20,
            'Diabetic Retinopathy': 0.65,
            'Glaucoma': 0.15,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Uncertain');
        expect(result.confidence, 0.0);
        expect(result.uncertain, true);
      });
    });

    group('Uncertain predictions (confidence < 0.6)', () {
      test('Marks prediction as uncertain when confidence is 0.59', () {
        final response = {
          'prediction': 'Glaucoma',
          'confidence': 0.59,
          'probabilities': {
            'Normal': 0.21,
            'Diabetic Retinopathy': 0.20,
            'Glaucoma': 0.59,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Uncertain');
        expect(result.confidence, 0.59);
        expect(result.uncertain, true);
      });

      test('Marks prediction as uncertain when confidence is 0.0', () {
        final response = {
          'prediction': 'Normal',
          'confidence': 0.0,
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Uncertain');
        expect(result.confidence, 0.0);
        expect(result.uncertain, true);
      });

      test('Marks prediction as certain when confidence is 0.61', () {
        final response = {
          'prediction': 'Diabetic Retinopathy',
          'confidence': 0.61,
          'probabilities': {
            'Normal': 0.19,
            'Diabetic Retinopathy': 0.61,
            'Glaucoma': 0.20,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Diabetic Retinopathy');
        expect(result.confidence, 0.61);
        expect(result.uncertain, false);
      });

      test('Handles uncertain prediction in result format', () {
        final response = {
          'result': {
            'class': 'Glaucoma',
            'confidence': 0.50,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Uncertain');
        expect(result.confidence, 0.50);
        expect(result.uncertain, true);
      });

      test('Handles uncertain prediction in predictions array format', () {
        final response = {
          'predictions': [
            {
              'class': 'Diabetic Retinopathy',
              'confidence': 0.58,
            }
          ]
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Uncertain');
        expect(result.confidence, 0.58);
        expect(result.uncertain, true);
      });
    });

    group('Edge cases and data type handling', () {
      test('Handles integer confidence values', () {
        final response = {
          'prediction': 'Normal',
          'confidence': 1,
          'probabilities': {
            'Normal': 1,
            'Diabetic Retinopathy': 0,
            'Glaucoma': 0,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Normal');
        expect(result.confidence, 1.0);
        expect(result.uncertain, false);
      });

      test('Handles null confidence gracefully', () {
        final response = {
          'prediction': 'Diabetic Retinopathy',
          'confidence': null,
        };

        final result = parseModelArtsResponse(response);

        expect(result.confidence, 0.0);
        expect(result.uncertain, true);
      });

      test('Handles missing probabilities map', () {
        final response = {
          'prediction': 'Glaucoma',
          'confidence': 0.75,
        };

        final result = parseModelArtsResponse(response);

        expect(result.predictedClass, 'Glaucoma');
        expect(result.confidence, 0.75);
        expect(result.probabilities['Glaucoma'], 0.75);
        expect(result.probabilities.length, 1);
      });

      test('Handles probabilities with mixed numeric types', () {
        final response = {
          'prediction': 'Normal',
          'confidence': 0.88,
          'probabilities': {
            'Normal': 0.88,
            'Diabetic Retinopathy': 0,
            'Glaucoma': 12,
          }
        };

        final result = parseModelArtsResponse(response);

        expect(result.probabilities['Normal'], 0.88);
        expect(result.probabilities['Diabetic Retinopathy'], 0.0);
        expect(result.probabilities['Glaucoma'], 12.0);
      });
    });
  });
}

// Helper class to match the InferenceResult from the service
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
