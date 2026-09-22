# EDA Playground 연동

VS Code와 Obsidian을 원본 저장소로 사용하고, UVM 실행에 필요한 코드만 EDA Playground용 파일로 자동 생성합니다.

## 기본 흐름

1. VS Code에서 실행할 프로젝트의 `rtl/` 또는 `tb/` 안에 있는 파일을 엽니다.
2. `F1` → `Tasks: Run Task`를 실행합니다.
3. `UVM: Design 코드 클립보드 복사`를 선택하고 EDA Playground의 **Design** 창에 붙여 넣습니다.
4. `UVM: Testbench 코드 클립보드 복사`를 선택하고 **Testbench** 창에 붙여 넣습니다.
5. EDA Playground에서 SystemVerilog, UVM, UVM 지원 시뮬레이터를 선택한 뒤 실행합니다.

권장 설정:

- Testbench + Design: `SystemVerilog/Verilog`
- UVM/OVM: 사용하려는 UVM 버전
- Tools & Simulators: `Aldec Riviera Pro`

## 생성 위치

각 프로젝트 안에 다음 파일이 자동 생성됩니다.

```text
eda_export/
├─ design.sv
└─ testbench.sv
```

`eda_export/`는 생성 결과이므로 Git에 올리지 않습니다. 실제 수정은 항상 `rtl/`과 `tb/`의 원본 파일에서 합니다.

## 파일 순서가 필요할 때

UVM 클래스의 컴파일 순서가 중요해지면 프로젝트 루트에 다음 파일을 만듭니다.

```text
eda_design_order.txt
eda_testbench_order.txt
```

각 줄에 프로젝트 기준 상대 경로를 컴파일 순서대로 작성합니다.

```text
tb/fifo_if.sv
tb/fifo_pkg.sv
tb/tb_top.sv
```
