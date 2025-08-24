import tensorflow as tf
import os


def convert_h5_to_tflite(
    source_model_path: str = "model.h5",
    target_tflite_path: str = "model.tflite",
    enable_float16: bool = False,
    optimize_for_size: bool = True,
):
    if not os.path.exists(source_model_path):
        raise FileNotFoundError(f"Model file not found: {source_model_path}")

    converter = tf.lite.TFLiteConverter.from_keras_model(
        tf.keras.models.load_model(source_model_path)
    )

    optimizations = []
    if optimize_for_size:
        optimizations.append(tf.lite.Optimize.DEFAULT)
    if optimizations:
        converter.optimizations = optimizations

    if enable_float16:
        converter.target_spec.supported_types = [tf.float16]

    tflite_model = converter.convert()
    with open(target_tflite_path, "wb") as f:
        f.write(tflite_model)

    print(f"Saved TFLite model to: {target_tflite_path}")


if __name__ == "__main__":
    convert_h5_to_tflite()


