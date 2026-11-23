# 1. 뜻

- Critical Path는 지정된 타이밍 조건에서 여유가 가장 작은 경로다.
- 같은 클록 조건의 단순한 레지스터 간 예제에서는 총 Setup 요구 시간이 가장 긴 경로가 클록 주기를 제한한다.
- 레지스터 간 경로는 `Launch Register → 조합논리와 배선 → Capture Register` 순서로 읽는다.

# 2. Setup 조건

- 같은 클록의 한 주기 경로에서 Skew와 Uncertainty를 제외하면 $T_{clk(min)}=t_{CQ}+t_{logic}+t_{setup}$이다.
- $t_{CQ}$는 출발 레지스터의 Clock-to-Q 지연이다.
- $t_{logic}$은 조합논리와 배선의 [[30. Notes/Circuit/Propagation Delay|전파 지연]]을 합친 값이다.
- Setup Slack은 데이터가 도착해야 하는 시각에서 실제 도착 시각을 뺀 값이다.
- Setup Slack이 음수면 주어진 조건에서 Setup 위반이다.
- Hold는 데이터가 너무 일찍 바뀌지 않는지 별도의 조건으로 확인한다.
- [[30. Notes/Digital/Timing/Setup and Hold Time|Setup과 Hold]]의 최소 지연 식에 [[30. Notes/Digital/Timing/Clock Skew|Clock Skew]]를 반영하면 수신 클록이 늦어질 때의 hold 여유를 계산할 수 있다.

# 3. 계산 예시

- 클록 주기가 10 ns이고 $t_{CQ}=1\,\mathrm{ns}$, $t_{logic}=7\,\mathrm{ns}$, $t_{setup}=1\,\mathrm{ns}$이면 Setup Slack은 $10-(1+7+1)=1\,\mathrm{ns}$이다.
- 같은 경로의 조합논리 지연이 9 ns로 늘면 Setup Slack은 $-1\,\mathrm{ns}$가 된다.
- 실제 STA 결과에서는 적용한 클록 제약과 Skew, Uncertainty 및 동작 조건을 함께 확인한다.
