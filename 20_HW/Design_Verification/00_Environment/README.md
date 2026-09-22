# 00. 실행 환경 확인

## 목적

VS Code에서 SystemVerilog 파일을 컴파일하고 Icarus Verilog 시뮬레이션을 실행할 수 있는지 확인합니다.

## 구성

```text
00_Environment/
├─ README.md
└─ hello.sv
```

## 실행

1. [[20_HW/Design_Verification/00_Environment/hello.sv|hello.sv]]를 VS Code에서 엽니다.
2. 우측 상단 실행 버튼 또는 `Ctrl+Shift+B`를 누릅니다.
3. 다음 메시지가 나오면 환경이 정상입니다.

```text
[PASS] Design Verification practice environment is ready.
```

`$finish called at 0`은 오류가 아니라 시뮬레이션이 시간 0에 정상 종료됐다는 의미입니다.

## 연결 방식

`Study`는 Obsidian Vault이고, 그 내부의 `20_HW/Design_Verification`을 VS Code 작업 폴더로 사용합니다.
따라서 VS Code에서 저장한 코드와 Markdown 설명이 Obsidian에도 즉시 나타납니다.
