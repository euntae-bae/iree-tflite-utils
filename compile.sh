#!/bin/bash

IREE_LEGACY_MODE=0
IREE_DISABLE_OPT=0

IMPORT_DIR="mlir"
EXPORT_DIR="build"

# usage: ./compile.sh [<target_device> [<legacy_mode>]]
# e.g., ./compile.sh llvm-cpu 1

# target_device: default=llvm-cpu, (available targets: cuda, llvm-cpu, metal, metal-spirv, rocm, vmvx, vulkan, vulkan-spirv)
# legacy_mode: default to 0
if [ $# -gt 0 ]; then
	IREE_HAL_TARGET=$1
	if [ $# -gt 1 ]; then
		IREE_LEGACY_MODE=$2
	fi
fi

if [ $IREE_LEGACY_MODE -ne 0 ]; then
	IMPORT_DIR="mlir-legacy"
	EXPORT_DIR="build-legacy"
fi

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
#IREE_HAL_TARGET="cuda"
IREE_HAL_TARGET="llvm-cpu"

#IREE_FLAGS="--iree-input-type=tosa"
IREE_FLAGS="--iree-input-type=none"
IREE_LLVMCPU_FLAGS="--iree-llvmcpu-target-triple=riscv32-pc-linux-elf \
--iree-llvmcpu-target-cpu=generic-rv32 \
--iree-llvmcpu-target-cpu-features=+m,+f,+zvl512b,+zve32x \
--iree-llvmcpu-target-abi=ilp32 \
--iree-llvmcpu-debug-symbols=false"

# --iree-llvmcpu-target-cpu-features=+m,+f,+zvl512b,+zve32x \
# --iree-llvm-target-cpu-features=+m,+f,+zvl512b,+zve32x \

IREE_LLVMCPU_FLAGS_LEGACY="--iree-llvm-target-triple=riscv32-pc-linux-elf \
--iree-llvm-target-cpu=generic-rv32 \
--iree-llvm-target-cpu-features=+m,+f,+c,+zvl512b,+zve32x \
--iree-llvm-target-abi=ilp32 \
--iree-llvm-debug-symbols=false"
# "--iree-hal-target-backends=llvm-cpu"

echo "HAL targetbackend : ${IREE_HAL_TARGET}"
echo "Legacy mode: ${IREE_LEGACY_MODE}"
echo "IMPORT_DIR: ${IMPORT_DIR}"
echo "EXPORT_DIR: ${EXPORT_DIR}"

IREE_COMPILE_BASE="/home/euntae/build"
IREE_FLAGS+=" --iree-hal-target-backends=${IREE_HAL_TARGET}"

# iree-dist-20230218.434  iree-dist-20231231.756 iree-3.1.0rc20250107
#IREE_DIST_VER="iree-dist-20231231.756"
IREE_DIST_VER="iree-3.1.0rc20250107"

if [ ${IREE_LEGACY_MODE} -ne 0 ]; then
	IREE_DIST_VER="iree-dist-20230218.434"
	IREE_FLAGS+=" --iree-llvm-link-embedded=false "
	IREE_LLVMCPU_FLAGS=${IREE_LLVMCPU_FLAGS_LEGACY}
	IMPORT_DIR="mlir-legacy"
	EXPORT_DIR="build-legacy"
else
	IREE_FLAGS+=" --iree-llvmcpu-link-embedded=false "
	#--iree-iree-hal-dump-executable-files-to=
fi

IREE_COMPILE="${IREE_COMPILE_BASE}/iree-compiler/${IREE_DIST_VER}/bin/iree-compile"
#IREE_COMPILE="/home/euntae/projects/iree-rv32-springbok/build/iree_compiler/bin/iree-compile"
#IREE_COMPILE="iree-compile"

if [ ${IREE_LEGACY_MODE} -eq 0 ]; then
	IREE_COMPILE="iree-compile"
fi

if [ ${IREE_HAL_TARGET} = "llvm-cpu" ]; then
	IREE_FLAGS+=${IREE_LLVMCPU_FLAGS}
fi

# if [ ${IREE_DISABLE_OPT} -ne 0 ]; then
# 	# IREE_FLAGS+=" --opt-level=0 " 이런 옵션 없음
# fi

echo "Compiler version: ${IREE_COMPILE}"
echo "IREE flags: ${IREE_FLAGS}"
echo ""

# input, abi, preprocessing, flow, stream, hal, vm, end
MLIR_COMPILE_TO="hal"

# echo ${MLIR_SRC_LIST[@]}
# exit 0

for fname in ${MLIR_SRC_LIST[@]}; do
	echo "Compiling ${fname}..."
	sname=$(basename -s .mlir ${fname})
	DUMP_DIR=${EXPORT_DIR}/${sname}_${IREE_DIST_VER}_${IREE_HAL_TARGET}-hal-dump
	FLAGS="${IMPORT_DIR}/${fname} ${IREE_FLAGS} -o ${EXPORT_DIR}/${sname}_${IREE_DIST_VER}_${IREE_HAL_TARGET}.vmfb"
	FLAGS_MLIR="${IMPORT_DIR}/${fname} ${IREE_FLAGS} --compile-to=${MLIR_COMPILE_TO} -o ${EXPORT_DIR}/${sname}_${IREE_DIST_VER}_${IREE_HAL_TARGET}_${MLIR_COMPILE_TO}.mlir"
	if [ ${IREE_LEGACY_MODE} -ne 0 ]; then
		FLAGS+=" --iree-hal-dump-executable-binaries-to=${DUMP_DIR}"
	else
		FLAGS+=" --iree-hal-dump-executable-files-to=${DUMP_DIR}"
	fi

	# --compile-to 옵션에 대응하는 MLIR 코드 생성
	echo "${IREE_COMPILE} ${FLAGS_MLIR}"
	${IREE_COMPILE} ${FLAGS_MLIR}

	#vmfb 및 dump 생성
	echo "${IREE_COMPILE} ${FLAGS}"
	${IREE_COMPILE} ${FLAGS}
	# echo ""
done

