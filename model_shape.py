import tensorflow as tf
import numpy as np

# TFLite 모델 파일 경로
tflite_model_path = 'tflite/mobilebert.tflite'

# TFLite 모델 로드
interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
interpreter.allocate_tensors()

# 입력 텐서 정보
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# 입력 텐서 shape 확인
print("Input details:")
for input_tensor in input_details:
    print(f"  Name: {input_tensor['name']}")
    print(f"  Shape: {input_tensor['shape']}")
    print(f"  Data type: {input_tensor['dtype']}")

# 출력 텐서 shape 확인
print("\nOutput details:")
for output_tensor in output_details:
    print(f"  Name: {output_tensor['name']}")
    print(f"  Shape: {output_tensor['shape']}")
    print(f"  Data type: {output_tensor['dtype']}")
