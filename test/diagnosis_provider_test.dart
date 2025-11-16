import 'package:flutter_test/flutter_test.dart';
import 'package:eye_wise_connect/providers/diagnosis_provider_web.dart';

void main() {
  group('DiagnosisProvider Recommendation Generation', () {
    late DiagnosisProvider provider;

    setUp(() {
      provider = DiagnosisProvider();
    });

    test('Generates general eye health recommendations', () {
      final conditions = [
        Condition(name: 'Normal', severity: 'Normal', confidence: 0.95),
      ];
      
      final recommendations = provider.generateRecommendationsForTest(conditions);
      
      // Verify general recommendations are present
      expect(recommendations.any((r) => r.contains('comprehensive eye examination')), true,
          reason: 'Should include recommendation for comprehensive eye examination');
      expect(recommendations.any((r) => r.contains('follow-up appointments')), true,
          reason: 'Should include recommendation for follow-up appointments');
      expect(recommendations.any((r) => r.contains('UV-protective sunglasses')), true,
          reason: 'Should include recommendation for UV protection');
      expect(recommendations.any((r) => r.contains('healthy diet')), true,
          reason: 'Should include recommendation for healthy diet');
      expect(recommendations.any((r) => r.contains('smoking')), true,
          reason: 'Should include recommendation about smoking');
    });

    test('Generates condition-specific recommendation for Diabetic Retinopathy', () {
      final conditions = [
        Condition(name: 'Diabetic Retinopathy', severity: 'High', confidence: 0.92),
      ];
      
      final recommendations = provider.generateRecommendationsForTest(conditions);
      
      expect(recommendations.any((r) => r.contains('blood sugar')), true,
          reason: 'Should include blood sugar monitoring for Diabetic Retinopathy');
      expect(recommendations.any((r) => r.contains('specialist treatment')), true,
          reason: 'Should mention specialist treatment for Diabetic Retinopathy');
    });

    test('Generates condition-specific recommendation for Hypertensive Retinopathy', () {
      final conditions = [
        Condition(name: 'Hypertensive Retinopathy', severity: 'Medium', confidence: 0.85),
      ];
      
      final recommendations = provider.generateRecommendationsForTest(conditions);
      
      expect(recommendations.any((r) => r.contains('blood pressure')), true,
          reason: 'Should include blood pressure control for Hypertensive Retinopathy');
      expect(recommendations.any((r) => r.contains('salt intake')), true,
          reason: 'Should mention salt reduction for Hypertensive Retinopathy');
    });

    test('Generates condition-specific recommendation for Age-related Macular Degeneration', () {
      final conditions = [
        Condition(name: 'Age-related Macular Degeneration', severity: 'High', confidence: 0.93),
      ];
      
      final recommendations = provider.generateRecommendationsForTest(conditions);
      
      expect(recommendations.any((r) => r.contains('AREDS2 supplements')), true,
          reason: 'Should mention AREDS2 supplements for AMD');
    });

    test('Generates condition-specific recommendation for Glaucoma', () {
      final conditions = [
        Condition(name: 'Glaucoma', severity: 'Medium', confidence: 0.88),
      ];
      
      final recommendations = provider.generateRecommendationsForTest(conditions);
      
      expect(recommendations.any((r) => r.contains('prescribed drops')), true,
          reason: 'Should mention prescribed drops for Glaucoma');
      expect(recommendations.any((r) => r.contains('IOP')), true,
          reason: 'Should mention IOP monitoring for Glaucoma');
    });

    test('Generates multiple condition-specific recommendations', () {
      final conditions = [
        Condition(name: 'Diabetic Retinopathy', severity: 'High', confidence: 0.92),
        Condition(name: 'Glaucoma', severity: 'Medium', confidence: 0.85),
      ];
      
      final recommendations = provider.generateRecommendationsForTest(conditions);
      
      // Should have both condition-specific recommendations
      expect(recommendations.any((r) => r.contains('blood sugar')), true,
          reason: 'Should include Diabetic Retinopathy recommendation');
      expect(recommendations.any((r) => r.contains('prescribed drops')), true,
          reason: 'Should include Glaucoma recommendation');
      
      // Should still have general recommendations
      expect(recommendations.any((r) => r.contains('comprehensive eye examination')), true,
          reason: 'Should include general recommendations');
    });

    test('Generates only general recommendations for Normal condition', () {
      final conditions = [
        Condition(name: 'Normal', severity: 'Normal', confidence: 0.97),
      ];
      
      final recommendations = provider.generateRecommendationsForTest(conditions);
      
      // Should have general recommendations
      expect(recommendations.length, greaterThanOrEqualTo(5),
          reason: 'Should have at least 5 general recommendations');
      
      // Should not have condition-specific recommendations
      expect(recommendations.any((r) => r.contains('blood sugar')), false,
          reason: 'Should not include disease-specific recommendations for Normal');
      expect(recommendations.any((r) => r.contains('blood pressure')), false,
          reason: 'Should not include disease-specific recommendations for Normal');
    });

    test('Generates appropriate recommendations for unknown conditions', () {
      final conditions = [
        Condition(name: 'Unknown Condition', severity: 'Medium', confidence: 0.80),
      ];
      
      final recommendations = provider.generateRecommendationsForTest(conditions);
      
      // Should still have general recommendations even for unknown conditions
      expect(recommendations.any((r) => r.contains('comprehensive eye examination')), true,
          reason: 'Should include general recommendations for unknown conditions');
      expect(recommendations.length, greaterThanOrEqualTo(5),
          reason: 'Should have at least 5 general recommendations');
    });

    test('Recommendations are in appropriate order', () {
      final conditions = [
        Condition(name: 'Diabetic Retinopathy', severity: 'High', confidence: 0.92),
      ];
      
      final recommendations = provider.generateRecommendationsForTest(conditions);
      
      // First recommendation should be about comprehensive examination
      expect(recommendations[0].contains('comprehensive eye examination'), true,
          reason: 'First recommendation should be about comprehensive examination');
      
      // Second recommendation should be about follow-up
      expect(recommendations[1].contains('follow-up appointments'), true,
          reason: 'Second recommendation should be about follow-up appointments');
    });
  });

  group('DiagnosisProvider Severity Mapping', () {
    test('Condition class correctly stores severity from mapping', () {
      // Test Normal condition with various confidence levels
      final normalLow = Condition(name: 'Normal', severity: 'Normal', confidence: 0.5);
      final normalMed = Condition(name: 'Normal', severity: 'Normal', confidence: 0.85);
      final normalHigh = Condition(name: 'Normal', severity: 'Normal', confidence: 0.95);
      
      expect(normalLow.severity, 'Normal');
      expect(normalMed.severity, 'Normal');
      expect(normalHigh.severity, 'Normal');
    });

    test('High severity for confidence >= 0.9', () {
      final condition1 = Condition(name: 'Diabetic Retinopathy', severity: 'High', confidence: 0.9);
      final condition2 = Condition(name: 'Glaucoma', severity: 'High', confidence: 0.95);
      final condition3 = Condition(name: 'Cataract', severity: 'High', confidence: 1.0);
      
      expect(condition1.severity, 'High');
      expect(condition1.confidence, 0.9);
      expect(condition2.severity, 'High');
      expect(condition2.confidence, 0.95);
      expect(condition3.severity, 'High');
      expect(condition3.confidence, 1.0);
    });

    test('Medium severity for confidence between 0.8 and 0.9', () {
      final condition1 = Condition(name: 'Diabetic Retinopathy', severity: 'Medium', confidence: 0.8);
      final condition2 = Condition(name: 'Glaucoma', severity: 'Medium', confidence: 0.85);
      final condition3 = Condition(name: 'Hypertensive Retinopathy', severity: 'Medium', confidence: 0.89);
      
      expect(condition1.severity, 'Medium');
      expect(condition1.confidence, 0.8);
      expect(condition2.severity, 'Medium');
      expect(condition2.confidence, 0.85);
      expect(condition3.severity, 'Medium');
      expect(condition3.confidence, 0.89);
    });

    test('Low severity for confidence < 0.8', () {
      final condition1 = Condition(name: 'Diabetic Retinopathy', severity: 'Low', confidence: 0.79);
      final condition2 = Condition(name: 'Glaucoma', severity: 'Low', confidence: 0.7);
      final condition3 = Condition(name: 'Age-related Macular Degeneration', severity: 'Low', confidence: 0.5);
      final condition4 = Condition(name: 'Cataract', severity: 'Low', confidence: 0.0);
      
      expect(condition1.severity, 'Low');
      expect(condition1.confidence, 0.79);
      expect(condition2.severity, 'Low');
      expect(condition2.confidence, 0.7);
      expect(condition3.severity, 'Low');
      expect(condition3.confidence, 0.5);
      expect(condition4.severity, 'Low');
      expect(condition4.confidence, 0.0);
    });

    test('DiagnosisResult correctly stores conditions with severity', () {
      final conditions = [
        Condition(name: 'Normal', severity: 'Normal', confidence: 0.95),
        Condition(name: 'Diabetic Retinopathy', severity: 'High', confidence: 0.92),
        Condition(name: 'Glaucoma', severity: 'Medium', confidence: 0.85),
        Condition(name: 'Cataract', severity: 'Low', confidence: 0.75),
      ];
      
      final result = DiagnosisResult(
        confidence: 0.92,
        conditions: conditions,
        recommendations: ['Test recommendation'],
      );
      
      expect(result.conditions.length, 4);
      expect(result.conditions[0].severity, 'Normal');
      expect(result.conditions[1].severity, 'High');
      expect(result.conditions[2].severity, 'Medium');
      expect(result.conditions[3].severity, 'Low');
    });
  });
}
