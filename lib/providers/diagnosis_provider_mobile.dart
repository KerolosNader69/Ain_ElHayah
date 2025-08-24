import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:eye_wise_connect/services/retina_inference_service.dart';

class DiagnosisProvider extends ChangeNotifier {
  String? _selectedModel;
  File? _selectedImage; // mobile file
  Uint8List? _selectedImageBytes; // optional, unused on mobile
  bool _isAnalyzing = false;
  DiagnosisResult? _diagnosisResult;
  String? _error;
  final RetinaInferenceService _retina = RetinaInferenceService();

  String? get selectedModel => _selectedModel;
  File? get selectedImage => _selectedImage;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  bool get isAnalyzing => _isAnalyzing;
  DiagnosisResult? get diagnosisResult => _diagnosisResult;
  String? get error => _error;

  void selectModel(String? model) {
    _selectedModel = model;
    _error = null;
    notifyListeners();
  }

  void setImage(File image) {
    _selectedImage = image;
    _error = null;
    _diagnosisResult = null;
    notifyListeners();
  }

  void setImageBytes(Uint8List bytes) {
    _selectedImageBytes = bytes;
    _error = null;
    _diagnosisResult = null;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    _selectedImageBytes = null;
    _diagnosisResult = null;
    _error = null;
    notifyListeners();
  }

  Future<void> analyzeImage() async {
    final hasFile = _selectedImage != null;
    final hasBytes = _selectedImageBytes != null;
    if ((!hasFile && !hasBytes) || _selectedModel == null) {
      _error = 'Please select an image and model first';
      notifyListeners();
      return;
    }

    try {
      _isAnalyzing = true;
      _error = null;
      notifyListeners();

      if (_selectedModel == 'retinal') {
        final result = hasBytes
            ? await _retina.predictBytes(_selectedImageBytes!)
            : await _retina.predict(_selectedImage!);
        _diagnosisResult = DiagnosisResult(
          confidence: result.confidence,
          conditions: [
            Condition(
              name: result.predictedClass,
              severity: _mapSeverity(result.predictedClass, result.confidence),
              confidence: result.confidence,
            ),
          ],
          recommendations: _generateRecommendations([
            Condition(
              name: result.predictedClass,
              severity: _mapSeverity(result.predictedClass, result.confidence),
              confidence: result.confidence,
            )
          ]),
        );
      } else {
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
    _selectedImage = null;
    _selectedImageBytes = null;
    _isAnalyzing = false;
    _diagnosisResult = null;
    _error = null;
    notifyListeners();
  }

  DiagnosisResult _generateMockResult() {
    final isRetinal = _selectedModel == 'retinal';
    final conditions = isRetinal ? _generateRetinalConditions() : _generateExternalConditions();
    return DiagnosisResult(
      confidence: 0.9,
      conditions: conditions,
      recommendations: _generateRecommendations(conditions),
    );
  }

  List<Condition> _generateRetinalConditions() {
    final possibleConditions = [
      {'name': 'Diabetic Retinopathy', 'severity': 'Medium', 'confidence': 0.92},
      {'name': 'Hypertensive Retinopathy', 'severity': 'Low', 'confidence': 0.87},
      {'name': 'Age-related Macular Degeneration', 'severity': 'High', 'confidence': 0.95},
      {'name': 'Glaucoma', 'severity': 'Medium', 'confidence': 0.89},
      {'name': 'Retinal Detachment', 'severity': 'High', 'confidence': 0.98},
      {'name': 'Macular Edema', 'severity': 'Medium', 'confidence': 0.91},
      {'name': 'Retinal Vein Occlusion', 'severity': 'High', 'confidence': 0.94},
      {'name': 'Normal Retina', 'severity': 'Normal', 'confidence': 0.96},
    ];

    final random = DateTime.now().millisecondsSinceEpoch;
    final numConditions = (random % 3) + 1;
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


