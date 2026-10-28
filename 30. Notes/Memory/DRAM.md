# 1. 뜻
- DRAM은 커패시터에 저장된 전하로 비트 상태를 표현하는 휘발성 메모리다.
- 대표적인 Cell은 접근 트랜지스터와 커패시터를 사용한다.
- 전하가 시간이 지나며 줄어들기 때문에 Refresh가 필요하다.

# 2. SRAM과 구분
- DRAM은 높은 저장 밀도를 얻기 좋지만 Refresh와 복잡한 접근 순서가 필요하다.
- [[30. Notes/Memory/SRAM|SRAM]]은 일반적으로 Refresh 없이 전원이 있는 동안 상태를 유지한다.
- 두 메모리 모두 전원을 잃으면 일반적으로 데이터도 사라진다.

# 3. 읽기 흐름
- Controller는 필요한 Row를 열기 위해 ACTIVATE를 보낸다.
- 열린 Row에서 Column을 지정해 READ 또는 WRITE를 수행한다.
- 다음 Row 접근을 준비할 때 PRECHARGE가 필요할 수 있다.
- 실제 명령 순서와 허용되는 연속 동작은 사용하는 DRAM 규격을 따른다.

# 4. Timing과 Refresh
- `tRCD`는 ACTIVATE 뒤 READ/WRITE까지 필요한 간격이다.
- `tRP`는 PRECHARGE 뒤 다음 ACTIVATE까지 필요한 간격이다.
- Refresh는 Cell의 전하 손실을 보완한다.
- Refresh 중 일반 접근을 어떻게 제한하는지는 장치와 Controller 규격으로 확인한다.
- Self-Refresh는 장치가 저전력 상태에서 데이터 유지를 맡는 동작으로 공부했다.

# 5. DV에서 확인할 것
- Controller가 너무 빠른 명령을 내보내지 않는지 확인한다.
- 필요한 명령을 지나치게 지연하지 않는지도 확인한다.
- ACTIVATE, READ/WRITE, PRECHARGE의 순서와 타이밍을 검사한다.
- Refresh 요구가 일반 접근과 겹칠 때의 중재를 검사한다.
- 정확한 시간값과 예외는 대상 DRAM 규격 및 Controller 명세에서 가져온다.

# 6. 복습 질문
- DRAM에 Refresh가 필요한 이유는 무엇인가?
- Row를 연 뒤 READ까지 기다려야 하는 이유는 무엇인가?
- Refresh가 밀릴 때 Controller는 어떤 상태를 관찰해야 하는가?

