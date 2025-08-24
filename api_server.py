import io
import uvicorn
import numpy as np
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import tensorflow as tf

# Lazy-loaded model
_model = None
_classes = ['Cataract', 'Diabetic Retinopathy', 'Glaucoma', 'Normal']


def get_model():
    global _model
    if _model is None:
        _model = tf.keras.models.load_model('model.h5')
    return _model


def preprocess_image_bytes(data: bytes, target_size=(224, 224)):
    img = Image.open(io.BytesIO(data)).convert('RGB')
    img = img.resize(target_size)
    arr = np.array(img).astype('float32') / 255.0
    arr = np.expand_dims(arr, axis=0)
    return arr


app = FastAPI(title="Eye Disease Prediction API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    data = await file.read()
    model = get_model()
    x = preprocess_image_bytes(data)
    preds = model.predict(x, verbose=0)[0].tolist()

    best_idx = int(np.argmax(preds))
    confidence = float(preds[best_idx])

    return {
        "predicted_class": _classes[best_idx],
        "confidence": confidence,
        "all_probabilities": { _classes[i]: float(preds[i]) for i in range(len(_classes)) }
    }


if __name__ == "__main__":
    uvicorn.run("api_server:app", host="127.0.0.1", port=8000, reload=False)


