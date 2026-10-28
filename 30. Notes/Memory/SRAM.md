# 1. 뜻
- SRAM은 전원이 공급되는 동안 저장 상태를 유지하는 휘발성 메모리다.
- 대표적인 6T Cell은 서로 교차 연결된 인버터와 접근 트랜지스터로 비트를 저장한다.
- CPU Cache와 SoC 내부 버퍼 등에 사용된다.

# 2. DRAM과 구분
- SRAM은 저장 상태를 유지하기 위해 주기적인 Refresh가 필요하지 않다.
- “Static”은 전원을 꺼도 데이터가 남는다는 뜻이 아니다.
- 일반적으로 빠른 접근에 유리하지만 비트당 면적이 크다.
- 전하를 주기적으로 보충해야 하는 메모리는 [[30. Notes/Memory/DRAM|DRAM]]에서 다룬다.

# 3. 읽기와 쓰기
- 일반적인 동기식 SRAM Interface에서는 `CLK`, `EN/CS`, `WE`, `ADDR`, `WDATA`, `RDATA`를 본다.
- Write는 지정된 Clock Edge에서 요청을 받아 저장 값을 바꾼다.
- Read 결과가 몇 Cycle 뒤 유효한지는 Memory Macro나 RTL 명세에 따른다.
- Byte Enable이 있으면 한 Word의 일부 Byte만 변경할 수 있다.
- CPU의 Byte Address와 내부 SRAM의 Word Address가 다를 수 있다.

# 4. 같은 주소에 동시에 접근하면
- Read와 Write가 같은 주소에 겹치는 상황을 Read-During-Write Collision이라고 한다.
- Read-first는 이전 값을 읽는 정책이다.
- Write-first는 새 값을 읽는 정책이다.
- No-change는 읽기 출력을 유지하는 정책이다.
- 어떤 정책이 맞는지는 DUT와 Memory Macro의 명세로 결정한다.

# 5. DV에서 확인할 것
- 요청을 받는 Edge와 Read 결과가 유효해지는 Cycle을 확인한다.
- Write 후 Readback 값과 Byte Enable 적용 결과를 비교한다.
- 같은 주소와 다른 주소의 동시 접근을 구분한다.
- 두 포트가 있다면 포트별 우선순위와 Collision 정책을 확인한다.
- Scoreboard의 기대값은 선택된 Collision 정책에 맞춰 만든다.

# 6. 복습 질문
- SRAM에 Refresh가 필요하지 않은 이유는 무엇인가?
- Byte Address를 Word Address로 바꿀 때 하위 비트는 어떻게 처리되는가?
- Read-During-Write 결과가 예상과 다르면 먼저 어떤 명세를 확인해야 하는가?

