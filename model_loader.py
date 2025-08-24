import tensorflow as tf
from tensorflow import keras
import numpy as np
from PIL import Image
import cv2
import os

def load_eye_disease_model(model_path='model.h5'):
    """
    Load the trained eye disease classification model
    
    Args:
        model_path (str): Path to the model.h5 file
        
    Returns:
        model: Loaded Keras model
    """
    try:
        # Check if model file exists
        if not os.path.exists(model_path):
            print(f"❌ Model file not found at: {model_path}")
            return None
            
        model = tf.keras.models.load_model(model_path)
        print("✅ Model loaded successfully!")
        print(f"📊 Model summary:")
        model.summary()
        return model
    except Exception as e:
        print(f"❌ Error loading model: {str(e)}")
        return None

def preprocess_image(image_path, target_size=(224, 224)):
    """
    Preprocess image for model input
    
    Args:
        image_path (str): Path to the image file
        target_size (tuple): Target size (width, height)
        
    Returns:
        numpy.ndarray: Preprocessed image
    """
    try:
        # Load and resize image
        img = Image.open(image_path)
        img = img.resize(target_size)
        
        # Convert to numpy array and normalize
        img_array = np.array(img)
        img_array = img_array.astype('float32') / 255.0
        
        # Add batch dimension
        img_array = np.expand_dims(img_array, axis=0)
        
        return img_array
    except Exception as e:
        print(f"❌ Error preprocessing image: {str(e)}")
        return None

def predict_disease(model, image_path):
    """
    Predict eye disease from image
    
    Args:
        model: Loaded Keras model
        image_path (str): Path to the image file
        
    Returns:
        dict: Prediction results with confidence scores
    """
    try:
        # Preprocess image
        processed_image = preprocess_image(image_path)
        
        if processed_image is None:
            return None
        
        # Make prediction
        predictions = model.predict(processed_image, verbose=0)
        
        # Define class labels
        classes = ['Cataract', 'Diabetic Retinopathy', 'Glaucoma', 'Normal']
        
        # Get predicted class and confidence
        predicted_class = np.argmax(predictions[0])
        confidence = predictions[0][predicted_class]
        
        # Create results dictionary
        results = {
            'predicted_class': classes[predicted_class],
            'confidence': float(confidence),
            'all_probabilities': {
                classes[i]: float(predictions[0][i]) 
                for i in range(len(classes))
            }
        }
        
        return results
    except Exception as e:
        print(f"❌ Error during prediction: {str(e)}")
        return None

def get_model_info(model):
    """
    Get information about the loaded model
    
    Args:
        model: Loaded Keras model
        
    Returns:
        dict: Model information
    """
    try:
        info = {
            'input_shape': model.input_shape,
            'output_shape': model.output_shape,
            'total_params': model.count_params(),
            'trainable_params': sum([tf.keras.backend.count_params(w) for w in model.trainable_weights]),
            'non_trainable_params': sum([tf.keras.backend.count_params(w) for w in model.non_trainable_weights])
        }
        return info
    except Exception as e:
        print(f"❌ Error getting model info: {str(e)}")
        return None

def validate_model_compatibility(model):
    """
    Validate that the model has the expected architecture
    
    Args:
        model: Loaded Keras model
        
    Returns:
        bool: True if compatible, False otherwise
    """
    try:
        # Check input shape
        expected_input = (None, 224, 224, 3)
        if model.input_shape != expected_input:
            print(f"❌ Unexpected input shape: {model.input_shape}, expected: {expected_input}")
            return False
        
        # Check output shape
        expected_output = (None, 4)
        if model.output_shape != expected_output:
            print(f"❌ Unexpected output shape: {model.output_shape}, expected: {expected_output}")
            return False
        
        print("✅ Model architecture validation passed!")
        return True
    except Exception as e:
        print(f"❌ Error validating model: {str(e)}")
        return False
