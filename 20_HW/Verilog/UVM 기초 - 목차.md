---
tags:
  - UVM
  - textbook
---

# UVM 기초

SystemVerilog의 객체와 실행 문법에서 UVM 환경 구성, 검증, Callback과 RAL까지 다루는 입문 교재입니다.

MD는 개념의 이유와 코드 해설을 담은 글 교재이고, PDF는 그림·흐름·비교를 중심으로 읽는 교재입니다. 두 자료는 장 번호와 제목, 주요 예제를 공유하며 각각 독립적으로 읽을 수 있습니다.

## 목차

- [1장. 객체지향 문법](<UVM 기초 1장 - 객체지향 문법.md>)
- [2장. 데이터 구조와 프로세스 통신](<UVM 기초 2장 - 데이터 구조와 프로세스 통신.md>)
- [3장. Randomization과 Constraint](<UVM 기초 3장 - Randomization과 Constraint.md>)
- [4장. Interface와 Simulation Timing](<UVM 기초 4장 - Interface와 Simulation Timing.md>)
- [5장. UVM 개요와 전체 구조](<UVM 기초 5장 - UVM 개요와 전체 구조.md>)
- [6장. uvm_object와 uvm_component](<UVM 기초 6장 - uvm_object와 uvm_component.md>)
- [7장. Factory와 Utility Macro](<UVM 기초 7장 - Factory와 Utility Macro.md>)
- [8장. Phase와 Objection](<UVM 기초 8장 - Phase와 Objection.md>)
- [9장. Sequence와 Driver Handshake](<UVM 기초 9장 - Sequence와 Driver Handshake.md>)
- [10장. Config DB와 Virtual Interface](<UVM 기초 10장 - Config DB와 Virtual Interface.md>)
- [11장. TLM과 Analysis](<UVM 기초 11장 - TLM과 Analysis.md>)
- [12장. Monitor와 Scoreboard](<UVM 기초 12장 - Monitor와 Scoreboard.md>)
- [13장. Report와 디버깅](<UVM 기초 13장 - Report와 디버깅.md>)
- [14장. Coverage와 Assertion](<UVM 기초 14장 - Coverage와 Assertion.md>)
- [15장. Callback](<UVM 기초 15장 - Callback.md>)
- [16장. Register Abstraction Layer](<UVM 기초 16장 - Register Abstraction Layer.md>)

## PDF

[UVM 기초 · 그림 교재](UVM_기초.pdf)

## 교재의 예제

API 코드는 UVM 1.2를 기준으로 설명합니다. 실제 환경에는 사용하는 library 버전과 DUT 사양을 적용합니다. 코드 조각에 생략된 주변 클래스·인터페이스는 각 예제의 설명에 따라 구성합니다. FIFO의 수락·latency·reset과 RAL의 register 속성은 명시된 예제 계약을 기준으로 해석합니다.
