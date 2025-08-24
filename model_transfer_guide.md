# 🚀 Model Transfer Guide: Moving model.h5 to Another Project

## 📋 Prerequisites Checklist

### 1. Required Python Packages
Make sure your target project has these exact versions:

```bash
pip install tensorflow>=2.8.0
pip install keras>=2.8.0
pip install opencv-python>=4.5.0
pip install numpy>=1.21.0
pip install pillow>=8.3.0
pip install streamlit>=1.20.0  # Only if using Streamlit UI
```

### 2. Model File
- Copy `model.h5` (61MB) to your target project
- Ensure the file is not corrupted during transfer

## 🔧 Step-by-Step Transfer Process

### Step 1: Copy the Model File
```bash
# Copy model.h5 to your target project directory
cp /path/to/MEDI_SCAN-main/model.h5 /path/to/your/new/project/
```

### Step 2: Create Model Loading Function
Create a Python file (e.g., `model_loader.py`) in your target project:

```python
import tensorflow as tf
from tensorflow import keras
import numpy as np
from PIL import Image
import cv2

def load_eye_disease_model(model_path='model.h5'):
    """
    Load the trained eye disease classification model
    
    Args:
        model_path (str): Path to the model.h5 file
        
    Returns:
        model: Loaded Keras model
    """
    try:
        model = tf.keras.models.load_model(model_path)
        print("✅ Model loaded successfully!")
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
    # Load and resize image
    img = Image.open(image_path)
    img = img.resize(target_size)
    
    # Convert to numpy array and normalize
    img_array = np.array(img)
    img_array = img_array.astype('float32') / 255.0
    
    # Add batch dimension
    img_array = np.expand_dims(img_array, axis=0)
    
    return img_array

def predict_disease(model, image_path):
    """
    Predict eye disease from image
    
    Args:
        model: Loaded Keras model
        image_path (str): Path to the image file
        
    Returns:
        dict: Prediction results with confidence scores
    """
    # Preprocess image
    processed_image = preprocess_image(image_path)
    
    # Make prediction
    predictions = model.predict(processed_image)
    
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
```

### Step 3: Usage Example
Create a simple test script (`test_model.py`):

```python
from model_loader import load_eye_disease_model, predict_disease

def main():
    # Load the model
    model = load_eye_disease_model('model.h5')
    
    if model is None:
        print("Failed to load model")
        return
    
    # Test with an image
    image_path = 'path/to/your/test/image.jpg'
    
    try:
        results = predict_disease(model, image_path)
        
        print(f"Predicted Disease: {results['predicted_class']}")
        print(f"Confidence: {results['confidence']:.2%}")
        print("\nAll Probabilities:")
        for disease, prob in results['all_probabilities'].items():
            print(f"  {disease}: {prob:.2%}")
            
    except Exception as e:
        print(f"Error during prediction: {str(e)}")

if __name__ == "__main__":
    main()
```

## ⚠️ Important Considerations

### 1. Model Architecture Requirements
The model expects:
- **Input shape**: (224, 224, 3) RGB images
- **Input normalization**: Values scaled to [0, 1]
- **Output**: 4-class classification probabilities

### 2. Class Labels
The model outputs predictions for these 4 classes in order:
1. **Cataract**
2. **Diabetic Retinopathy** 
3. **Glaucoma**
4. **Normal**

### 3. TensorFlow Version Compatibility
- **Minimum**: TensorFlow 2.8.0
- **Recommended**: TensorFlow 2.x (latest stable)
- **Avoid**: TensorFlow 1.x (not compatible)

### 4. Memory Requirements
- **Model size**: ~61MB
- **RAM usage**: ~500MB during inference
- **GPU**: Optional but recommended for faster inference

## 🔍 Troubleshooting Common Issues

### Issue 1: "Unknown layer" error
**Solution**: Ensure you have the exact same TensorFlow/Keras version used during training.

### Issue 2: "Input shape mismatch" error
**Solution**: Make sure images are resized to 224x224x3 and normalized to [0,1].

### Issue 3: "Model file corrupted" error
**Solution**: Re-download/copy the model.h5 file and verify file integrity.

### Issue 4: "CUDA/GPU" errors
**Solution**: Install CPU-only TensorFlow or configure GPU drivers properly.

## 📊 Model Performance Expectations

- **Accuracy**: ~90.40% on test set
- **Inference time**: ~0.1-0.5 seconds per image (CPU)
- **Memory usage**: ~500MB RAM during inference

## 🎯 Best Practices

1. **Always test** the model with sample images after transfer
2. **Keep backups** of the original model.h5 file
3. **Document** the transfer process for future reference
4. **Validate** predictions with known test cases
5. **Monitor** model performance in the new environment

## 📝 Complete Example Project Structure

```
your_new_project/
├── model.h5                    # Transferred model file
├── model_loader.py            # Model loading utilities
├── test_model.py              # Test script
├── requirements.txt           # Dependencies
├── test_images/              # Test images directory
│   ├── sample1.jpg
│   └── sample2.jpg
└── README.md                 # Project documentation
```

## 🚀 Quick Start Commands

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Test model loading
python test_model.py

# 3. Run with your own images
python -c "
from model_loader import load_eye_disease_model, predict_disease
model = load_eye_disease_model('model.h5')
result = predict_disease(model, 'your_image.jpg')
print(result)
"
```

---

**Note**: This model is designed for educational and research purposes. For medical applications, always consult healthcare professionals.
