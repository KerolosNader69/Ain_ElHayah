#!/usr/bin/env python3
"""
Test script for the transferred eye disease classification model
"""

import os
import sys
from model_loader import (
    load_eye_disease_model, 
    predict_disease, 
    get_model_info, 
    validate_model_compatibility
)

def test_model_loading():
    """Test if the model can be loaded successfully"""
    print("🔍 Testing model loading...")
    
    model = load_eye_disease_model('model.h5')
    
    if model is None:
        print("❌ Model loading failed!")
        return False
    
    print("✅ Model loading test passed!")
    return True

def test_model_architecture():
    """Test if the model has the correct architecture"""
    print("\n🔍 Testing model architecture...")
    
    model = load_eye_disease_model('model.h5')
    
    if model is None:
        return False
    
    # Validate architecture
    if not validate_model_compatibility(model):
        print("❌ Model architecture validation failed!")
        return False
    
    # Get model info
    info = get_model_info(model)
    if info:
        print(f"📊 Model Information:")
        print(f"   Input shape: {info['input_shape']}")
        print(f"   Output shape: {info['output_shape']}")
        print(f"   Total parameters: {info['total_params']:,}")
        print(f"   Trainable parameters: {info['trainable_params']:,}")
        print(f"   Non-trainable parameters: {info['non_trainable_params']:,}")
    
    print("✅ Model architecture test passed!")
    return True

def test_prediction():
    """Test if the model can make predictions"""
    print("\n🔍 Testing model predictions...")
    
    model = load_eye_disease_model('model.h5')
    
    if model is None:
        return False
    
    # Test with a sample image if available
    test_images = [
        'Image_Testing/Input_1.png',
        'Image_Testing/Input_2.png',
        'Image_Testing/Input_3.png',
        'Image_Testing/Input_4.png'
    ]
    
    for image_path in test_images:
        if os.path.exists(image_path):
            print(f"   Testing with: {image_path}")
            
            try:
                results = predict_disease(model, image_path)
                
                if results:
                    print(f"   ✅ Prediction successful!")
                    print(f"   Predicted: {results['predicted_class']}")
                    print(f"   Confidence: {results['confidence']:.2%}")
                    print(f"   All probabilities:")
                    for disease, prob in results['all_probabilities'].items():
                        print(f"     {disease}: {prob:.2%}")
                    print()
                else:
                    print(f"   ❌ Prediction failed for {image_path}")
                    return False
                    
            except Exception as e:
                print(f"   ❌ Error during prediction: {str(e)}")
                return False
    
    print("✅ Model prediction test passed!")
    return True

def test_with_custom_image(image_path):
    """Test the model with a custom image"""
    print(f"\n🔍 Testing with custom image: {image_path}")
    
    if not os.path.exists(image_path):
        print(f"❌ Image file not found: {image_path}")
        return False
    
    model = load_eye_disease_model('model.h5')
    
    if model is None:
        return False
    
    try:
        results = predict_disease(model, image_path)
        
        if results:
            print(f"✅ Prediction successful!")
            print(f"Predicted Disease: {results['predicted_class']}")
            print(f"Confidence: {results['confidence']:.2%}")
            print(f"\nAll Probabilities:")
            for disease, prob in results['all_probabilities'].items():
                print(f"  {disease}: {prob:.2%}")
            return True
        else:
            print("❌ Prediction failed!")
            return False
            
    except Exception as e:
        print(f"❌ Error during prediction: {str(e)}")
        return False

def main():
    """Main test function"""
    print("🚀 Starting Eye Disease Model Transfer Tests")
    print("=" * 50)
    
    # Check if model file exists
    if not os.path.exists('model.h5'):
        print("❌ model.h5 file not found in current directory!")
        print("Please copy the model.h5 file to this directory first.")
        return
    
    # Run all tests
    tests = [
        ("Model Loading", test_model_loading),
        ("Model Architecture", test_model_architecture),
        ("Model Prediction", test_prediction)
    ]
    
    passed_tests = 0
    total_tests = len(tests)
    
    for test_name, test_func in tests:
        try:
            if test_func():
                passed_tests += 1
            else:
                print(f"❌ {test_name} test failed!")
        except Exception as e:
            print(f"❌ {test_name} test failed with error: {str(e)}")
    
    print("\n" + "=" * 50)
    print(f"📊 Test Results: {passed_tests}/{total_tests} tests passed")
    
    if passed_tests == total_tests:
        print("🎉 All tests passed! Model transfer successful!")
        print("\nYou can now use the model in your new project.")
        print("Example usage:")
        print("""
from model_loader import load_eye_disease_model, predict_disease

# Load the model
model = load_eye_disease_model('model.h5')

# Make predictions
results = predict_disease(model, 'your_image.jpg')
print(results)
        """)
    else:
        print("⚠️ Some tests failed. Please check the errors above.")
        return False
    
    return True

if __name__ == "__main__":
    # Check for custom image argument
    if len(sys.argv) > 1:
        custom_image = sys.argv[1]
        if os.path.exists(custom_image):
            test_with_custom_image(custom_image)
        else:
            print(f"❌ Custom image not found: {custom_image}")
    else:
        main()
