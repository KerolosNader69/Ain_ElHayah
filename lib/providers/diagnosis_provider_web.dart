import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eye_wise_connect/services/retina_inference_service.dart';
import 'package:eye_wise_connect/services/ai_chat_service.dart';

class DiagnosisProvider extends ChangeNotifier {
  String? _selectedModel;
  Uint8List? _selectedImageBytes;
  bool _isAnalyzing = false;
  DiagnosisResult? _diagnosisResult;
  String? _error;
  final RetinaInferenceService _retina = RetinaInferenceService();

  String? get selectedModel => _selectedModel;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  bool get isAnalyzing => _isAnalyzing;
  DiagnosisResult? get diagnosisResult => _diagnosisResult;
  String? get error => _error;

  void selectModel(String? model) {
    _selectedModel = model;
    _error = null;
    notifyListeners();
  }

  void setImageBytes(Uint8List bytes) {
    _selectedImageBytes = bytes;
    _error = null;
    _diagnosisResult = null;
    notifyListeners();
  }

  void clearImage() {
    _selectedImageBytes = null;
    _diagnosisResult = null;
    _error = null;
    notifyListeners();
  }

  Future<void> analyzeImage() async {
    if (_selectedImageBytes == null || _selectedModel == null) {
      _error = 'Please select an image and model first';
      notifyListeners();
      return;
    }

    try {
      _isAnalyzing = true;
      _error = null;
      notifyListeners();

      if (_selectedModel == 'retinal') {
        print('[DiagnosisProvider] Attempting retinal analysis...');
        
        // Try mock API first (since ModelArts isn't working)
        try {
          print('[DiagnosisProvider] Calling mock retinal API...');
          final imageBase64 = base64Encode(_selectedImageBytes!);
          final response = await http.post(
            Uri.parse('http://localhost:3001/api/retinal/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'imageBase64': imageBase64}),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['success'] == true) {
              print('[DiagnosisProvider] Mock API returned result');
              
              final conditions = (data['conditions'] as List)
                  .map((c) => Condition(
                        name: c['name'],
                        severity: c['severity'],
                        confidence: (c['confidence'] as num).toDouble(),
                      ))
                  .toList();

              final recommendations = (data['recommendations'] as List)
                  .map((r) => r.toString())
                  .toList();

              _diagnosisResult = DiagnosisResult(
                confidence: (data['confidence'] as num).toDouble(),
                conditions: conditions,
                recommendations: recommendations,
              );
              
              _isAnalyzing = false;
              notifyListeners();
              return;
            }
          }
        } catch (e) {
          print('[DiagnosisProvider] Mock API failed: $e, trying ModelArts...');
        }

        // Fallback to real ModelArts if mock fails
        try {
          print('[DiagnosisProvider] Using real ModelArts inference for retinal model');
          
          final result = await _retina.predictBytes(_selectedImageBytes!);

          // Always request DeepSeek second opinion (handled gracefully if API key missing)
          print('[DiagnosisProvider] Requesting AI second opinion...');
          String? deepseekNote;
          try {
            deepseekNote = await AIChatService.reasonWithModelOutputs(
              imageBytes: _selectedImageBytes!,
              probabilities: result.probabilities,
            );
            if (deepseekNote.trim().isNotEmpty) {
              print('[DiagnosisProvider] Second opinion received (${deepseekNote.length} chars)');
            } else {
              print('[DiagnosisProvider] Second opinion returned empty');
            }
          } catch (e) {
            print('[DiagnosisProvider] Second opinion failed: $e');
          }

          final primaryCondition = Condition(
            name: result.predictedClass,
            severity: _mapSeverity(result.predictedClass, result.confidence),
            confidence: result.confidence,
          );
          final recs = _generateRecommendations([primaryCondition]);
          if (deepseekNote != null && deepseekNote.trim().isNotEmpty) {
            recs.insert(0, deepseekNote);
          }

          _diagnosisResult = DiagnosisResult(
            confidence: result.confidence,
            conditions: [primaryCondition],
            recommendations: recs,
          );
          
          print('[DiagnosisProvider] Diagnosis complete - Class: ${primaryCondition.name}, Confidence: ${result.confidence}, Recommendations: ${recs.length}');
        } catch (e) {
          print('[DiagnosisProvider] ModelArts also failed: $e');
          throw Exception('Both mock and ModelArts APIs failed');
        }
      } else {
        print('[DiagnosisProvider] Using mock data for external eye model');
        await Future.delayed(const Duration(seconds: 1));
        _diagnosisResult = _generateMockResult();
      }
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Analysis failed: $e';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedModel = null;
    _selectedImageBytes = null;
    _isAnalyzing = false;
    _diagnosisResult = null;
    _error = null;
    notifyListeners();
  }

  DiagnosisResult _generateMockResult() {
    // Mock data for external eye model (not yet implemented)
    final conditions = _generateExternalConditions();
    return DiagnosisResult(
      confidence: 0.9,
      conditions: conditions,
      recommendations: _generateRecommendations(conditions),
    );
  }

  List<Condition> _generateExternalConditions() {
    final possibleConditions = [
      {'name': 'Conjunctivitis', 'severity': 'Medium', 'confidence': 0.88},
      {'name': 'Dry Eye Syndrome', 'severity': 'Low', 'confidence': 0.85},
      {'name': 'Blepharitis', 'severity': 'Low', 'confidence': 0.82},
      {'name': 'Corneal Abrasion', 'severity': 'High', 'confidence': 0.93},
      {'name': 'Pterygium', 'severity': 'Medium', 'confidence': 0.89},
      {'name': 'Cataract', 'severity': 'High', 'confidence': 0.95},
      {'name': 'Normal External Eye', 'severity': 'Normal', 'confidence': 0.97},
    ];
    final random = DateTime.now().millisecondsSinceEpoch;
    final numConditions = (random % 2) + 1;
    final selectedConditions = <Condition>[];
    for (int i = 0; i < numConditions; i++) {
      final condition = possibleConditions[(random + i) % possibleConditions.length];
      selectedConditions.add(Condition(
        name: condition['name'] as String,
        severity: condition['severity'] as String,
        confidence: condition['confidence'] as double,
      ));
    }
    return selectedConditions;
  }

  List<String> _generateRecommendations(List<Condition> conditions) {
    final recommendations = <String>[];
    recommendations.add('Schedule a comprehensive eye examination with an ophthalmologist');
    recommendations.add('Maintain regular follow-up appointments as recommended');
    for (final condition in conditions) {
      switch (condition.name) {
        case 'Diabetic Retinopathy':
          recommendations.add('Monitor blood sugar and consider specialist treatment if advised');
          break;
        case 'Hypertensive Retinopathy':
          recommendations.add('Control blood pressure and reduce salt intake');
          break;
        case 'Age-related Macular Degeneration':
          recommendations.add('Discuss AREDS2 supplements with your doctor');
          break;
        case 'Glaucoma':
          recommendations.add('Use prescribed drops and monitor IOP');
          break;
      }
    }
    recommendations.add('Wear UV-protective sunglasses when outdoors');
    recommendations.add('Maintain a healthy diet rich in antioxidants and omega-3');
    recommendations.add('Quit smoking if applicable');
    return recommendations;
  }

  String _mapSeverity(String condition, double confidence) {
    if (condition == 'Normal') return 'Normal';
    if (confidence >= 0.9) return 'High';
    if (confidence >= 0.8) return 'Medium';
    return 'Low';
  }

  // Test-only method to expose _generateRecommendations for verification
  @visibleForTesting
  List<String> generateRecommendationsForTest(List<Condition> conditions) {
    return _generateRecommendations(conditions);
  }
}

class DiagnosisResult {
  final double confidence;
  final List<Condition> conditions;
  final List<String> recommendations;

  DiagnosisResult({
    required this.confidence,
    required this.conditions,
    required this.recommendations,
  });
}

class Condition {
  final String name;
  final String severity;
  final double confidence;

  Condition({
    required this.name,
    required this.severity,
    required this.confidence,
  });
}


