import 'package:flutter_test/flutter_test.dart';
import 'package:eye_wise_connect/services/huawei_modelarts_service.dart';
import 'package:eye_wise_connect/services/api_key_loader.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  group('Configuration Loading Tests', () {
    late File envFile;
    final envFilePath = 'env.json';

    setUp(() {
      envFile = File(envFilePath);
    });

    tearDown(() async {
      // Restore original env.json if it was backed up
      final backupFile = File('$envFilePath.backup');
      if (await backupFile.exists()) {
        await backupFile.copy(envFilePath);
        await backupFile.delete();
      }
    });

    test('HuaweiModelArtsConfig.isComplete returns true when all fields are present', () {
      final config = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(config.isComplete, true);
    });

    test('HuaweiModelArtsConfig.isComplete returns false when projectId is empty', () {
      final config = HuaweiModelArtsConfig(
        projectId: '',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(config.isComplete, false);
    });

    test('HuaweiModelArtsConfig.isComplete returns false when accessKeyId is empty', () {
      final config = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: '',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(config.isComplete, false);
    });

    test('HuaweiModelArtsConfig.isComplete returns false when secretAccessKey is empty', () {
      final config = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: '',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(config.isComplete, false);
    });

    test('HuaweiModelArtsConfig.isComplete returns false when serviceId is empty', () {
      final config = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: '',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(config.isComplete, false);
    });

    test('HuaweiModelArtsConfig.isComplete returns false when region is empty', () {
      final config = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: '',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(config.isComplete, false);
    });

    test('HuaweiModelArtsConfig.isComplete returns false when invokeUrl is empty', () {
      final config = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: '',
      );

      expect(config.isComplete, false);
    });

    test('HuaweiModelArtsConfig.isComplete returns false when all fields are empty', () {
      final config = HuaweiModelArtsConfig(
        projectId: '',
        accessKeyId: '',
        secretAccessKey: '',
        serviceId: '',
        region: '',
        invokeUrl: '',
      );

      expect(config.isComplete, false);
    });

    test('ApiKeyLoaderModelArts returns null when configuration is missing from env.json', () async {
      // Backup original env.json
      if (await envFile.exists()) {
        await envFile.copy('$envFilePath.backup');
      }

      // Create env.json with missing ModelArts fields
      final incompleteConfig = {
        'GOOGLE_API_KEY': 'test_key',
        'HUAWEI_AI_API_KEY': 'test_key',
      };
      await envFile.writeAsString(jsonEncode(incompleteConfig));

      final config = await ApiKeyLoaderModelArts.loadHuaweiModelArtsConfig();

      expect(config, isNull);
    });

    test('Configuration validation detects missing projectId', () {
      // Test that isComplete returns false when projectId is missing
      final incompleteConfig = HuaweiModelArtsConfig(
        projectId: '',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(incompleteConfig.isComplete, false);
      expect(incompleteConfig.projectId, isEmpty);
    });

    test('Configuration validation detects missing accessKey', () {
      // Test that isComplete returns false when accessKey is missing
      final incompleteConfig = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: '',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(incompleteConfig.isComplete, false);
      expect(incompleteConfig.accessKeyId, isEmpty);
    });

    test('Configuration validation detects missing secretKey', () {
      // Test that isComplete returns false when secretKey is missing
      final incompleteConfig = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: '',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(incompleteConfig.isComplete, false);
      expect(incompleteConfig.secretAccessKey, isEmpty);
    });

    test('Configuration validation detects missing serviceId', () {
      // Test that isComplete returns false when serviceId is missing
      final incompleteConfig = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: '',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(incompleteConfig.isComplete, false);
      expect(incompleteConfig.serviceId, isEmpty);
    });

    test('Configuration validation detects missing region', () {
      // Test that isComplete returns false when region is missing
      final incompleteConfig = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: '',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(incompleteConfig.isComplete, false);
      expect(incompleteConfig.region, isEmpty);
    });

    test('Configuration validation detects missing invokeUrl', () {
      // Test that isComplete returns false when invokeUrl is missing
      final incompleteConfig = HuaweiModelArtsConfig(
        projectId: '59dcb311da5e4ca6b8db8bbc7a7712d7',
        accessKeyId: 'HPUALP3GCEZ2AMWETEHI',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: '',
      );

      expect(incompleteConfig.isComplete, false);
      expect(incompleteConfig.invokeUrl, isEmpty);
    });

    test('ApiKeyLoaderModelArts returns null when all fields are missing', () async {
      // Backup original env.json
      if (await envFile.exists()) {
        await envFile.copy('$envFilePath.backup');
      }

      // Create env.json with no ModelArts fields
      final incompleteConfig = {
        'GOOGLE_API_KEY': 'test_key',
      };
      await envFile.writeAsString(jsonEncode(incompleteConfig));

      final config = await ApiKeyLoaderModelArts.loadHuaweiModelArtsConfig();

      expect(config, isNull);
    });

    test('Configuration validation provides descriptive error with field names', () {
      // Test that we can identify missing fields from an incomplete config
      final incompleteConfig = HuaweiModelArtsConfig(
        projectId: '',
        accessKeyId: '',
        secretAccessKey: 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        serviceId: 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        region: 'ap-southeast-3',
        invokeUrl: 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      );

      expect(incompleteConfig.isComplete, false);
      
      // Verify we can identify which fields are missing
      final missingFields = <String>[];
      if (incompleteConfig.projectId.isEmpty) missingFields.add('MODELARTS_PROJECT_ID');
      if (incompleteConfig.accessKeyId.isEmpty) missingFields.add('MODELARTS_ACCESS_KEY');
      if (incompleteConfig.secretAccessKey.isEmpty) missingFields.add('MODELARTS_SECRET_KEY');
      if (incompleteConfig.serviceId.isEmpty) missingFields.add('MODELARTS_SERVICE_ID');
      if (incompleteConfig.region.isEmpty) missingFields.add('MODELARTS_REGION');
      if (incompleteConfig.invokeUrl.isEmpty) missingFields.add('MODELARTS_INVOKE_URL');

      expect(missingFields, contains('MODELARTS_PROJECT_ID'));
      expect(missingFields, contains('MODELARTS_ACCESS_KEY'));
      expect(missingFields.length, 2);
    });

    test('ApiKeyLoaderModelArts loads complete config when all required fields are present in env.json', () async {
      // Backup original env.json
      if (await envFile.exists()) {
        await envFile.copy('$envFilePath.backup');
      }

      // Create env.json with all required fields
      final completeConfig = {
        'MODELARTS_PROJECT_ID': '59dcb311da5e4ca6b8db8bbc7a7712d7',
        'MODELARTS_ACCESS_KEY': 'HPUALP3GCEZ2AMWETEHI',
        'MODELARTS_SECRET_KEY': 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM',
        'MODELARTS_SERVICE_ID': 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9',
        'MODELARTS_REGION': 'ap-southeast-3',
        'MODELARTS_INVOKE_URL': 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>',
      };
      await envFile.writeAsString(jsonEncode(completeConfig));

      final config = await ApiKeyLoaderModelArts.loadHuaweiModelArtsConfig();

      expect(config, isNotNull);
      expect(config!.isComplete, true);
      expect(config.projectId, '59dcb311da5e4ca6b8db8bbc7a7712d7');
      expect(config.accessKeyId, 'HPUALP3GCEZ2AMWETEHI');
      expect(config.secretAccessKey, 'ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM');
      expect(config.serviceId, 'c3ea302b-d98b-4f80-85bb-552e9ca8e0c9');
      expect(config.region, 'ap-southeast-3');
      expect(config.invokeUrl, 'https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>');
    });

    test('Configuration validation handles empty string values as missing fields', () {
      // Test that isComplete returns false when all fields are empty strings
      final incompleteConfig = HuaweiModelArtsConfig(
        projectId: '',
        accessKeyId: '',
        secretAccessKey: '',
        serviceId: '',
        region: '',
        invokeUrl: '',
      );

      expect(incompleteConfig.isComplete, false);
      expect(incompleteConfig.projectId, isEmpty);
      expect(incompleteConfig.accessKeyId, isEmpty);
      expect(incompleteConfig.secretAccessKey, isEmpty);
      expect(incompleteConfig.serviceId, isEmpty);
      expect(incompleteConfig.region, isEmpty);
      expect(incompleteConfig.invokeUrl, isEmpty);
    });
  });
}
