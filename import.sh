#!/bin/bash
IMPORT_DIR=tflite
EXPORT_DIR=mlir
SRC_FILE_LIST=$(ls ${IMPORT_DIR}/)
#echo $SRC_FILE_LIST
for fname in ${SRC_FILE_LIST[@]}; do
	sname=$(basename -s .tflite ${fname})
	echo "Import the ${fname}..."
	echo "${IMPORT_DIR}/${fname} -o ${EXPORT_DIR}/${sname}.mlir"
	iree-import-tflite ${IMPORT_DIR}/${fname} -o ${EXPORT_DIR}/${sname}.mlir
	echo ""
done
