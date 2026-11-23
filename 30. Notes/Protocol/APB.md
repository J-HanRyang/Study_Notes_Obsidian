# 1. 구조

- AMBA APB는 주변장치 레지스터에 단순한 읽기와 쓰기 전송을 제공한다.
- 주소 디코더가 대상의 PSEL을 선택하고 선택된 주변장치가 읽기 데이터와 완료 상태를 돌려준다.

# 2. 레지스터 쓰기

- SETUP 주기에는 PSEL=1, PENABLE=0으로 주소·방향·쓰기 데이터를 제시한다.
- 다음 ACCESS 주기에는 PENABLE=1을 유지하며 PREADY가 LOW이면 주소와 제어 및 쓰기 데이터를 유지한다.
- 상승 에지에서 PSEL·PENABLE·PREADY가 모두 HIGH이면 전송이 완료된다.
- 같은 대상으로 연속 접근해도 다음 SETUP에서 PENABLE을 내린다.

# 3. 읽기와 오류

- 읽기에서는 완료 에지에서 PRDATA를 샘플링한다.
- APB3 이후의 PSLVERR는 선택된 전송의 완료 주기에 오류를 알릴 수 있다.
- 예를 들어 ACCESS 첫 주기에 PREADY=0이고 다음 주기에 1이면 대기가 한 주기 추가되고 레지스터 쓰기는 완료 시점에 한 번만 반영한다.
- [Arm APB 규격 열기](https://developer.arm.com/documentation/ihi0024/latest/).

# 4. 학습 PDF
- [APB GPIO Complete Workbook 열기 (PDF)](<../../_Attachment/프로토콜 학습자료/APB_GPIO_Complete_Workbook.pdf>)
- [APB GPIO Design Specification 열기 (PDF)](<../../_Attachment/프로토콜 학습자료/APB_GPIO_Design_Specification.pdf>)
- [APB GPIO Verification Plan 열기 (PDF)](<../../_Attachment/프로토콜 학습자료/APB_GPIO_Verification_Plan.pdf>)
- [APB GPIO Supplement 열기 (PDF)](<../../_Attachment/프로토콜 학습자료/APB_GPIO_Supplement.pdf>)
- [APB GPIO 5 Day Plan 열기 (PDF)](<../../_Attachment/프로토콜 학습자료/APB_GPIO_5_Day_Plan.pdf>)
