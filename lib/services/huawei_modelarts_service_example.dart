// Example usage of HuaweiModelArtsService
//
// This file demonstrates how to use the ModelArts inference service.
// It is not meant to be imported - copy the relevant parts to your code.

import 'dart:typed_data';
import 'dart:io';
import 'package:eye_wise_connect/services/huawei_modelarts_service.dart';
import 'package:eye_wise_connect/services/api_key_loader.dart';

/// Example: Basic inference usage
Future<void> exampleBasicInference() async {
  // Load configuration from env.json or compile-time variables
  final config = await ApiKeyLoaderModelArts.loadHuaweiModelArtsConfig();
  
  if (config == null || !config.isComplete) {
    print('ModelArts configuration not found. Please check env.json or compile-time variables.');
    return;
  }

  // Create service instance
  final service = HuaweiModelArtsService(config: config);

  // Load image file
  final imageFile = File('path/to/your/image.jpg');
  final imageBytes = await imageFile.readAsBytes();

  try {
    // Call inference
    final result = await service.inferImage(imageBytes);
    
    // Process result
    print('Inference successful!');
    print('Result: $result');
    
    // Example: Extract prediction if your model returns specific fields
    // final prediction = result['prediction'];
    // final confidence = result['confidence'];
    
  } catch (e) {
    if (e is Map<String, dynamic>) {
      // Structured error response
      final statusCode = e['statusCode'] as int?;
      final body = e['body'] as Map<String, dynamic>?;
      print('Inference failed with status $statusCode');
      print('Error details: $body');
    } else {
      // Exception (e.g., image too large)
      print('Error: $e');
    }
  }
}

/// Example: Using with image picker (Flutter)
Future<void> exampleWithImagePicker(Uint8List imageBytes) async {
  final config = await ApiKeyLoaderModelArts.loadHuaweiModelArtsConfig();
  if (config == null || !config.isComplete) {
    throw Exception('ModelArts configuration missing');
  }

  final service = HuaweiModelArtsService(config: config);

  try {
    final result = await service.inferImage(imageBytes);
    
    // Handle successful inference
    // Your app logic here
    
  } on Map<String, dynamic> catch (error) {
    // Handle structured error
    final statusCode = error['statusCode'];
    final body = error['body'];
    // Show error to user
  } catch (e) {
    // Handle other exceptions (e.g., network, image size)
    // Show error to user
  }
}

/// Example: Manual configuration (for testing)
Future<void> exampleManualConfig() async {
  final config = HuaweiModelArtsConfig(
    projectId: 'your-project-id',
    accessKeyId: 'your-access-key',
    secretAccessKey: 'your-secret-key',
    serviceId: 'your-service-id',
    region: 'ap-southeast-3',
    invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
  );

  final service = HuaweiModelArtsService(config: config);
  final imageBytes = Uint8List.fromList([/* your image bytes */]);
  
  final result = await service.inferImage(imageBytes);
  print('Result: $result');
}

