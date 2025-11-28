import numpy as np
import tensorflow as tf
# MobileBERT 토크나이저 로드
from transformers import MobileBertTokenizer

def examineDetails(details):
	for detail in details:
		print(f"Name: {detail['name']}")
		print(f"Index: {detail['index']}")
		print(f"Shape: {detail['shape']}")
		print(f"Data type: {detail['dtype']}")
		print(f"Quantization parameters: {detail['quantization']}")
		print("-" * 30)

def examineTensor(tensor, name=None):
	pass

tflite_model_path = 'tflite/mobilebert.tflite'

## TFLite 인터프리터 로드
interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
interpreter.allocate_tensors()

# 입력 및 출력 텐서 정보 확인
# allocate_tensors() 이후에 호출할 것
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("Input details:")
examineDetails(input_details)
print("Output details:")
examineDetails(output_details)

## MobileBERT 토크나이저 로드
tokenizer = MobileBertTokenizer.from_pretrained('google/mobilebert-uncased')

## 입력 텍스트 토큰화 및 입력 텐서 생성
# input_text = "Once upon a time"
# inputs = tokenizer(input_text, return_tensors='np', padding='max_length', max_length=384, truncation=True)

# 시퀀스 최대 길이가 384로 고정되어 있으므로(input_details에서 확인 가능), 토크나이저의 max_length를 384로 지정
# 384보다 짧은 문장은 나머지가 패딩으로 채워지고, 384보다 긴 문장은 잘린다
question = "What is MobileBERT?"
context = "MobileBERT is a compact version of BERT for on-device applications."
inputs = tokenizer(question, context, return_tensors='np', padding='max_length', max_length=384, truncation=True)

input_ids = inputs['input_ids']
input_mask = inputs['attention_mask']
# Tokenizer는 segment_ids에 들어갈 입력을 token_type_ids라는 이름으로 사용함 (라이브러리에 따라 같은 입력도 다른 이름으로 사용)
segment_ids = inputs['token_type_ids']
#segment_ids = inputs.get('token_type_ids', np.zeros_like(input_ids))
#segment_ids = inputs['segment_ids']

input_ids32 = input_ids.astype(np.int32)
input_mask32 = input_mask.astype(np.int32)
segment_ids32 = segment_ids.astype(np.int32)

print('## Input tensors ##')
print('input_ids: ', input_ids)
print('type(input_ids): ', type(input_ids))
print('input_ids.shape: ', input_ids.shape)
print('input_ids.dtype: ', input_ids.dtype)
print()

print('input_mask: ', input_mask)
print('input_mask.shape: ', input_mask.shape)
print('input_mask.dtype: ', input_mask.dtype)
print()

print('segment_ids: ', segment_ids)
print('segment_ids.shape: ', segment_ids.shape)
print('segment_ids.dtype: ', segment_ids.dtype)
print('-' * 30)
print()

# TFLite 모델에 입력 데이터 설정
interpreter.set_tensor(input_details[0]['index'], input_ids32)
interpreter.set_tensor(input_details[1]['index'], input_mask32)
interpreter.set_tensor(input_details[2]['index'], segment_ids32)

# 예측 수행
interpreter.invoke()

## 출력 데이터 가져오기
# 텐서 데이터의 입출력은 {set,get}_tensor()를 이용
# 텐서의 정보(이름, shape 등)는 {input,output}_details를 이용하여 접근
end_logits = interpreter.get_tensor(output_details[0]['index'])
start_logits = interpreter.get_tensor(output_details[1]['index'])

print(f"name: {output_details[0]['name']}")
print('end_logits: ', end_logits)
print('end_logits.shape: ', end_logits.shape)
print('end_logits.dtype: ', end_logits.dtype)
print()
print(f"name: {output_details[1]['name']}")
print('start_logits: ', start_logits)
print('start_logits.shape: ', start_logits.shape)
print('start_logits.dtype: ', start_logits.dtype)
print('-' * 30)

## 정답 추출
start_idx = np.argmax(start_logits)
end_idx = np.argmax(end_logits)
answerTokens = input_ids[0][start_idx:end_idx+1]
answer = tokenizer.decode(answerTokens)

print(f'question: {question}')
print(f'--> answer: {answer}')

exit(0)
## C 배열로 내보내기 (옵션)
max_length = len(input_ids32.flatten())
print('int input_ids[%d] = { ' % max_length)
for e in input_ids32.flatten():
	print(e, end=', ')
print('};')

print('int input_mask[%d] = {' % max_length)
for e in input_mask32.flatten():
	print(e, end=', ')
print('};')

print('int segment_ids[%d] = {' % max_length)
for e in segment_ids32.flatten():
	print(e, end=', ')
print('};')

