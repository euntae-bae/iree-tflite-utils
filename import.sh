#!/bin/bash
IREE_LEGACY_MODE=0

IMPORT_DIR=tflite
EXPORT_DIR=mlir
SRC_FILE_LIST=$(ls ${IMPORT_DIR}/)
#echo $SRC_FILE_LIST

# usage: ./import.sh [<legacy_mode>]
# legacy_mode: default to 0
if [ $# -gt 0 ]; then
	IREE_LEGACY_MODE=$1
fi

if [ ${IREE_LEGACY_MODE} -ne 0 ]; then
	EXPORT_DIR=mlir-legacy
fi

echo "Legacy mode: ${IREE_LEGACY_MODE}"
echo "TFLite import directory: ${IMPORT_DIR}"
echo "MLIR export directory: ${EXPORT_DIR}"
echo ""

for fname in ${SRC_FILE_LIST[@]}; do
	sname=$(basename -s .tflite ${fname})
	echo "Import the ${fname}..."
	echo "${IMPORT_DIR}/${fname} -o ${EXPORT_DIR}/${sname}.mlir"
	iree-import-tflite ${IMPORT_DIR}/${fname} -o ${EXPORT_DIR}/${sname}.mlir
	echo ""
done
