# 1. 변환

- Binary-reflected Gray Code는 인접한 수 사이에서 한 비트만 바뀌도록 인코딩한다.
- 변환식은 `gray = binary ^ (binary >> 1)`이다.
- 이진수 `0111 → 1000`은 네 비트가 바뀌지만 Gray 표현은 `0100 → 1100`으로 한 비트만 바뀐다.

# 2. FIFO 포인터

- 송신 도메인에서 한 칸씩 움직이는 포인터의 Gray 값을 레지스터에 저장한 뒤 비트별 동기화기를 거쳐 전달한다.
- 연속 전이가 수신 입력에서 겹치지 않도록 경로 지연과 비트 사이 도착 편차를 제약한다.
- 느린 수신 클록은 중간 포인터 값을 건너뛸 수 있으므로 이벤트 개수 복원에 이 값만 사용하면 안 된다.
- [AMD Gray CDC 설명 열기](https://docs.amd.com/r/2021.2-English/ug953-vivado-7series-libraries/XPM_CDC_GRAY).
