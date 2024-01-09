#!/bin/bash

IREE_LEGACY_MODE=0

IMPORT_DIR=mlir
EXPORT_DIR=build
MLIR_SRC_LIST=$(ls ${IMPORT_DIR}/)

IREE_HAL_TARGET_LIST=( \
"cuda" \
"llvm-cpu" \
"metal" \
"metal-spirv" \
"rocm" \
"vmvx" \
"vulkan" \
"vulkan-spirv")
IREE_HAL_TARGET="llvm-cpu"

IREE_FLAGS="--iree-input-type=tosa"
IREE_LLVMCPU_FLAGS="--iree-llvmcpu-target-triple=riscv32-pc-linux-elf \
--iree-llvmcpu-target-cpu=generic-rv32 \
--iree-llvmcpu-target-cpu-features=+m,+f,+zvl512b,+zve32x \
--iree-llvmcpu-target-abi=ilp32 \
--iree-llvmcpu-debug-symbols=false"

# --iree-llvmcpu-target-cpu-features=+m,+f,+zvl512b,+zve32x \
# --iree-llvm-target-cpu-features=+m,+f,+zvl512b,+zve32x \

IREE_LLVMCPU_FLAGS_LEGACY="--iree-llvm-target-triple=riscv32-pc-linux-elf \
--iree-llvm-target-cpu=generic-rv32 \
--iree-llvm-target-cpu-features=+m,+f,+zvl512b,+zve32x \
--iree-llvm-target-abi=ilp32 \
--iree-llvm-debug-symbols=false"
# "--iree-hal-target-backends=llvm-cpu"

# usage: ./compile.sh [<target_device> [<legacy_mode>]]
# target_device: default to llvm-cpu
# legacy_mode: default to 0
if [ $# -gt 0 ]; then
	IREE_HAL_TARGET=$1
	if [ $# -gt 1 ]; then
		IREE_LEGACY_MODE=$2
	fi
fi
echo "HAL target: ${IREE_HAL_TARGET}"
echo "Legacy mode: ${IREE_LEGACY_MODE}"

IREE_FLAGS+=" --iree-hal-target-backends=${IREE_HAL_TARGET}"

# iree-dist-20230218.434  iree-dist-20231231.756
IREE_DIST_VER="iree-dist-20231231.756"

if [ ${IREE_LEGACY_MODE} -ne 0 ]; then
	IREE_DIST_VER="iree-dist-20230218.434"
	IREE_FLAGS+=" --iree-llvm-link-embedded=false "
	IREE_LLVMCPU_FLAGS=${IREE_LLVMCPU_FLAGS_LEGACY}
	IMPORT_DIR="mlir-legacy"
else
	IREE_FLAGS+=" --iree-llvmcpu-link-embedded=false "
	#--iree-iree-hal-dump-executable-files-to=
fi

IREE_COMPILE="iree-compiler/${IREE_DIST_VER}/bin/iree-compile"
#IREE_COMPILE="/home/euntae/projects/iree-rv32-springbok/build/iree_compiler/bin/iree-compile"

if [ ${IREE_HAL_TARGET} = "llvm-cpu" ]; then
	IREE_FLAGS+=${IREE_LLVMCPU_FLAGS}
fi

echo "Compiler version: ${IREE_COMPILE}"
echo "IREE flags: ${IREE_FLAGS}"
echo ""

for fname in ${MLIR_SRC_LIST[@]}; do
	echo "Compile the ${fname}..."
	sname=$(basename -s .mlir ${fname})
	DUMP_DIR=${EXPORT_DIR}/${sname}_${IREE_DIST_VER}_${IREE_HAL_TARGET}-hal-dump
	FLAGS="${IMPORT_DIR}/${fname} ${IREE_FLAGS} -o ${EXPORT_DIR}/${sname}_${IREE_DIST_VER}_${IREE_HAL_TARGET}.vmfb"
	if [ ${IREE_LEGACY_MODE} -ne 0 ]; then
		FLAGS+=" --iree-hal-dump-executable-binaries-to=${DUMP_DIR}"
	else
		FLAGS+=" --iree-hal-dump-executable-files-to=${DUMP_DIR}"
	fi
	echo "${IREE_COMPILE} ${FLAGS}"
	${IREE_COMPILE} ${FLAGS}
	echo ""
done

