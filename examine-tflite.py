import tensorflow as tf
import numpy as np

modelBase = 'tflite'
modelName = 'mobilenet_v2_jueun'
modelPath = f'{modelBase}/{modelName}.tflite'

# TFLite 모델 불러오기
interpreter = tf.lite.Interpreter(model_path=modelPath)
interpreter.allocate_tensors()

# 텐서 정보 가져오기
tensor_details = interpreter.get_tensor_details()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# 전체 tensor shape 보기
for tensor in tensor_details:
    name = tensor['name']
    shape = tensor['shape']
    dtype = tensor['dtype']
    index = tensor['index']
    print(f"[Tensor] name: {name}, shape: {shape}, dtype: {dtype}, index: {index}")
