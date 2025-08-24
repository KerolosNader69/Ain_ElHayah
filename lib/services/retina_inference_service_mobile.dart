import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class RetinaInferenceService {
  static const List<String> classes = [
    'Cataract',
    'Diabetic Retinopathy',
    'Glaucoma',
    'Normal',
  ];

  tfl.Interpreter? _interpreter;

  Future<void> init() async {
    if (_interpreter != null) return;

    final buffer = await rootBundle.load('assets/models/model.tflite');
    final bytes = buffer.buffer.asUint8List(buffer.offsetInBytes, buffer.lengthInBytes);
    _interpreter = await tfl.Interpreter.fromBuffer(bytes);
  }

  Future<InferenceResult> predict(File imageFile) async {
    if (_interpreter == null) {
      await init();
    }

    final input = await _preprocess(imageFile);

    final inputTensor = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(224, (_) => List.filled(3, 0.0)),
      ),
    );

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final idx = (y * 224 + x) * 3;
        inputTensor[0][y][x][0] = input[idx + 0];
        inputTensor[0][y][x][1] = input[idx + 1];
        inputTensor[0][y][x][2] = input[idx + 2];
      }
    }

    final outputTensor = List.generate(1, (_) => List.filled(4, 0.0));
    _interpreter!.run(inputTensor, outputTensor);

    final probs = outputTensor[0];
    int bestIdx = 0;
    double bestProb = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > bestProb) {
        bestProb = probs[i];
        bestIdx = i;
      }
    }

    final Map<String, double> all = {
      for (int i = 0; i < probs.length; i++) classes[i]: probs[i],
    };

    return InferenceResult(
      predictedClass: classes[bestIdx],
      confidence: bestProb,
      probabilities: all,
    );
  }

  Future<InferenceResult> predictBytes(Uint8List bytes) async {
    if (_interpreter == null) {
      await init();
    }

    final input = await _preprocessBytes(bytes);

    final inputTensor = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(224, (_) => List.filled(3, 0.0)),
      ),
    );

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final idx = (y * 224 + x) * 3;
        inputTensor[0][y][x][0] = input[idx + 0];
        inputTensor[0][y][x][1] = input[idx + 1];
        inputTensor[0][y][x][2] = input[idx + 2];
      }
    }

    final outputTensor = List.generate(1, (_) => List.filled(4, 0.0));
    _interpreter!.run(inputTensor, outputTensor);

    final probs = outputTensor[0];
    int bestIdx = 0;
    double bestProb = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > bestProb) {
        bestProb = probs[i];
        bestIdx = i;
      }
    }

    final Map<String, double> all = {
      for (int i = 0; i < probs.length; i++) classes[i]: probs[i],
    };

    return InferenceResult(
      predictedClass: classes[bestIdx],
      confidence: bestProb,
      probabilities: all,
    );
  }

  Future<List<double>> _preprocess(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode image');
    }
    final resized = img.copyResize(decoded, width: 224, height: 224);

    final floatPixels = List<double>.filled(224 * 224 * 3, 0.0);
    int i = 0;
    for (final p in resized.getBytes(format: img.Format.rgb)) {
      floatPixels[i++] = p / 255.0;
    }
    return floatPixels;
  }

  Future<List<double>> _preprocessBytes(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode image');
    }
    final resized = img.copyResize(decoded, width: 224, height: 224);

    final floatPixels = List<double>.filled(224 * 224 * 3, 0.0);
    int i = 0;
    for (final p in resized.getBytes(format: img.Format.rgb)) {
      floatPixels[i++] = p / 255.0;
    }
    return floatPixels;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
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


