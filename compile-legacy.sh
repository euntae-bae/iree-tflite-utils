IREE_COMPILE="/home/euntae/build/iree-compiler/iree-dist-20230218.434/bin/iree-compile"
IMPORT_DIR="mlir_tosa_legacy"
MODEL_NAME="mobilenet_v2"

if [ $# -gt 0 ]; then
    MODEL_NAME=$1
fi

# none, tosa
IREE_INPUT_TYPE="tosa"

IREE_FLAGS="--iree-input-type=${IREE_INPUT_TYPE} "
IREE_FLAGS+="--iree-hal-target-backends=llvm-cpu"
IREE_FLAGS+="--iree-vm-bytecode-module-strip-source-map=true"
IREE_FLAGS+="--iree-vm-emit-polyglot-zip=false"
IREE_FLAGS+="--iree-vm-target-index-bits=32"

IREE_LLVM_FLAGS="--iree-llvm-target-triple=riscv32-pc-linux-elf "
IREE_LLVM_FLAGS+="--iree-llvm-target-cpu=generic-rv32 "
IREE_LLVM_FLAGS+="--iree-llvm-target-cpu-features=+m,+f,+zvl512b,+zve32x "
IREE_LLVM_FLAGS+="--iree-llvm-target-abi=ilp32 "
IREE_LLVM_FLAGS+="--iree-llvm-debug-symbols=false "
IREE_LLVM_FLAGS+="--iree-llvm-link-embedded=false "

IREE_FLAGS+=$IREE_LLVM_FLAGS

# input, abi, preprocessing, flow, stream, hal, vm, end
IREE_COMPILE_TO="end"

EXPORT_DIR="module_${IREE_COMPILE_TO}_legacy"
INPUT_FILE="${IMPORT_DIR}/${MODEL_NAME}.mlir"
OUTPUT_FILE="${EXPORT_DIR}/${MODEL_NAME}_${IREE_COMPILE_TO}.mlir"

if [ ${IREE_COMPILE_TO} = "end" ]; then
    EXPORT_DIR="module_legacy"
    OUTPUT_FILE="${EXPORT_DIR}/${MODEL_NAME}_tosa.vmfb"
fi

echo "## compile-legacy ##"
echo "- IREE_COMPILE: ${IREE_COMPILE}"
echo "- MODEL_NAME:   ${MODEL_NAME}"
echo "- IMPORT_DIR:   ${IMPORT_DIR}"
echo "- EXPORT_DIR:   ${EXPORT_DIR}"
echo "- INPUT_FILE:   ${INPUT_FILE}"
echo "- OUTPUT_FILE:  ${OUTPUT_FILE}"

${IREE_COMPILE} ${IREE_FLAGS} --compile-to=${IREE_COMPILE_TO} ${INPUT_FILE} -o ${OUTPUT_FILE}
