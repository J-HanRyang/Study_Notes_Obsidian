# 1. 구조

- AMBA AHB-Lite는 주소 단계와 데이터 단계를 겹쳐 전송한다.
- 한 버스 구간에서 한 마스터가 전송을 시작하고 주소 디코더가 대상 슬레이브를 선택한다.

# 2. 두 번 연속 쓸 때

- A 주소가 수락된 다음 주기에는 A의 쓰기 데이터와 다음 전송 B의 주소가 함께 보인다.
- HREADY가 LOW이면 A의 데이터 단계가 연장되고 B의 주소 수락도 지연된다.
- HREADY가 HIGH인 상승 에지에서 A가 완료되면서 유효한 B 주소가 수락될 수 있다.
- 응답 멀티플렉서는 현재 데이터 단계의 슬레이브가 낸 HREADYOUT·HRESP·HRDATA를 선택한다.

# 3. Burst와 오류

- 한 burst의 첫 beat는 NONSEQ이고 이어지는 유효 beat는 SEQ다.
- 4바이트 INCR4 전송이 0x20에서 시작하면 주소는 0x20, 0x24, 0x28, 0x2C 순서다.
- ERROR 응답은 첫 주기에 HRESP=ERROR와 HREADY=0을, 다음 주기에 HRESP=ERROR와 HREADY=1을 표시한다.
- 이 두 주기 덕분에 마스터는 이미 제시한 다음 전송을 취소할 시간을 확보한다.
- [Arm AHB-Lite 규격 열기](https://developer.arm.com/documentation/ihi0033/latest/).
