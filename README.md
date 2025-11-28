# IREE TFLite Utils
## Prerequisite
IREE 컴파일러와 IREE TFLite importer tool이 설치되어 있어야 한다.
IREE TFLite tool은 파이썬 패키지 형태로 설치되며, IREE 컴파일러는 pip install로 설치하거나 컴파일된 실행 파일 형태로 사용 가능하다. 본 프로젝트에서는 기본적으로 iree-compiler/ 밑에 컴파일된 바이너리를 두고 사용한다.


### IREE compiler
Pre-built IREE compiler releases can be downloaded from the following URL:
```
wget https://github.com/openxla/iree/releases/download/candidate-<tag>/iree-dist-<tag>-linux-x86_64.tar.xz
```

For example, you can download iree-dist-20231231.756-linux-x86_64.tar.xz using
```
wget https://github.com/openxla/iree/releases/download/candidate-20231231.756/iree-dist-20231231.756-linux-x86_64.tar.xz
```

release(tag) 정보는 iree repository에서 git tag 명령을 통해 확인 가능하다.


### IREE TFLite importer
Python package file (.whl) can be downloaded from the following URL:
```
$ wget https://github.com/openxla/iree/releases/download/candidate-<tag>/iree_tools_tflite-<tag>-py3-none-linux_x86_64.whl
```

Install example:
```
$ wget https://github.com/openxla/iree/releases/download/candidate-20230218.434/iree_tools_tflite-20230218.434-py3-none-linux_x86_64.whl
$ pip3 install iree_tools_tflite-20230218.434-py3-none-linux_x86_64.whl --no-cache-dir
```

release 정보는 다음 [링크](https://pypi.org/project/iree-tools-tflite/)에서 확인


## import.sh
```
Usage: ./import.sh [<legacy_mode>]

legacy_mode: default to 0
```
IREE TFLite importer(iree-import-tflite)를 실행하여 tflite/에 있는 pre-trained model들을 MLIR로 export한다. 실행 전에 가상 환경을 활성화할 것.


### Legacy mode
import.sh의 첫 번째 인자로 legacy mode 여부를 지정할 수 있다. 0이 아닌 값을 넣어주면 legacy mode로 동작한다. 기본 값은 0이다.


## compile.sh
```
Usage: ./compile.sh [<target_device> [<legacy_mode>]]

target_device: default to llvm-cpu
legacy_mode: default to 0
```
MLIR로 export된 코드를 컴파일하여 build/에 IREE VM FlatBuffer(.vmfb)와 dump를 생성한다.


### Legacy mode
compile.sh의 두 번째 인자로 legacy mode 여부를 지정할 수 있다. 0이 아닌 값을 넣어주면 legacy mode로 동작한다. 기본 값은 0이다.

IREE TFLite importer와 IREE compiler 버전 간 호환성 문제 때문에 legacy mode를 별도로 지원해야 한다. 구버전 importer가 생성한 MLIR 코드는 신버전 IREE 컴파일러에서 컴파일되지 않는다. 본 프로젝트에서는 이런 문제를 해결하기 위해 MLIR 소스 디렉토리를 `mlir`과 `mlir-legacy`로 분리했다. 또한 iree-compile의 구버전과 신버전은 옵션명과 기능에 차이가 있기 때문에 이를 반영하여 legacy mode에서는 구버전용 옵션을 적용하도록 코드를 구성했다.


### 컴파일 시 유의사항
TFLite를 import한 MLIR을 입력으로 하는 경우에는 iree-compile 실행 시 `--iree-input-type=tosa` 옵션을 넣어주어야 한다.


## TODO


## Issues
Posenet이 cuda, vulkan-spirv 등에서 제대로 지원되지 않는 문제