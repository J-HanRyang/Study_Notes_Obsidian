# 1. 샘플링 구간

- 수신 플립플롭의 입력은 유효 클록 에지 전 setup 시간부터 에지 후 hold 시간까지 안정되어야 한다.
- Setup 분석은 가장 늦게 도착하는 데이터가 다음 캡처 에지에 맞는지 확인한다.
- Hold 분석은 같은 에지에서 출발한 새 데이터가 기존 값을 너무 일찍 바꾸는지 확인한다.

# 2. Slack 계산

- 같은 주파수의 단일 주기 경로에서 skew와 uncertainty를 제외하면 setup slack은 `T − tCQ(max) − tpath(max) − tsetup`이다.
- 같은 조건에서 hold slack은 `tCQ(min) + tpath(min) − thold`이다.
- 최소 데이터 지연이 0.25 ns이고 hold 요구가 0.10 ns이면 hold 여유는 0.15 ns다.
- 클록 주기를 늘리면 setup 여유가 늘지만 같은 에지를 기준으로 계산한 hold 여유는 그대로다.
