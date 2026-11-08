# 1. 전원 시스템에서 하는 일
- SVI3는 CPU가 VR Controller에 목표 전압과 전력 상태를 요청하고 상태 정보를 받는 직렬 인터페이스다.
- 전원 생성 흐름은 `CPU → SVI3 → VR Controller → PWM → DrMOS → 인덕터·커패시터 → CPU Rail`이다.
- SVI3 명령 수신, VR의 목표값 갱신, 실제 출력 전압 도달은 각각 다른 단계다.
- SVI2와 같은 계열이지만 신호·프레임·명령이 같다고 가정하지 않는다.
- 실제 검증에서는 사용하는 SVI3 개정판과 DUT의 지원 기능을 먼저 확정한다.

# 2. 신호와 전원 영역
- `SVC`는 CPU에서 VR 장치로 전달되는 직렬 Clock이다.
- `SVD`는 CPU에서 VR 장치로 전달되는 명령 Data다.
- `SVTI`와 `SVTO`는 장치 사이의 Telemetry 입력과 출력을 연결하는 경로다.
- 여러 VR 장치가 SVC·SVD 명령 경로를 공유하더라도 각 장치는 명령의 대상인지 해석해야 한다.
- Telemetry 경로는 장치를 거쳐 CPU 방향으로 돌아오는 Daisy-chain이 될 수 있다.
- Daisy-chain의 물리적 순서와 프로토콜 주소는 별개의 개념이다.
- `VCC`는 VR Controller 자체의 동작 전원이고 `VDDIO`는 SVI3 신호의 전압 기준이다.
- `VOUT`은 VR이 CPU에 공급하는 출력 전압이므로 VCC나 VDDIO와 혼동하지 않는다.
- VCC 또는 VDDIO가 유효하지 않은 동안의 신호 구동과 Reset 동작은 DUT 전원 사양을 따른다.

# 3. 명령을 해석하는 순서
- 학습에 사용한 SVI3 Rev 2.00 예시에서는 Command Body의 `VIDSEL`과 `ADRSEL`을 순서대로 해석한다.
- `VIDSEL=1`이면 대상 주소와 VID 코드를 포함한 전압 요청으로 해석한다.
- `VIDSEL=0, ADRSEL=1`이면 장치 선택과 관련된 Address Command로 해석한다.
- 두 선택 비트가 모두 0이면 뒤의 Command Type으로 명령 종류를 구분한다.
- Rev 2.00 학습 예시의 VID Body는 `VIDSEL 1비트 + 장치 주소 6비트 + VID 9비트`다.
- Rev 2.00 학습 예시의 Address Body는 `VIDSEL 1비트 + ADRSEL 1비트 + 장치 주소 6비트`다.
- 이 비트 배치는 업무에서 사용하는 다른 개정판에 적용하기 전에 원문과 대조한다.
- VID는 목표 전압을 나타내는 코드이며 실제 전압 환산은 해당 개정판과 장치의 VID 규칙을 따른다.
- SVI3 장치 주소는 VR 장치를 선택하고 Register 주소는 선택된 장치 내부의 항목을 선택한다.
- Register Read·Write의 접근 권한, Reset 값과 부작용은 DUT의 Register 명세로 확인한다.

# 4. 전력 상태, Rail과 Phase
- SVI3에서 학습한 PSI 명령은 VR의 전력 상태를 변경하는 명령의 맥락이다.
- [[30. Notes/Power/PSI|Power Sequence Interface]]로 부르는 Main/Sub PMIC 간 PSI와는 다른 뜻이다.
- 하나의 VR 장치가 여러 Rail을 제어하고 하나의 Rail에 여러 Phase를 붙일 수 있다.
- Rail은 부하에 공급되는 하나의 출력 전압이고 Phase는 그 Rail의 전류를 분담하는 스위칭 경로다.
- 명령의 대상 장치, Rail과 Phase를 같은 번호 체계라고 가정하지 않는다.
- Phase마다 PWM·전력단·인덕터가 있고 같은 Rail에서 전류가 합쳐질 수 있다.

# 5. Telemetry, ACK와 오류
- Telemetry는 전압·전류·온도 같은 측정 항목과 그 값을 CPU 방향으로 전달한다.
- Telemetry Index는 보고하는 측정 항목을 구분하는 값이며 내부 SFR 주소와 같은 개념이 아니다.
- Daisy-chain에서는 값을 만든 장치와 그 값을 다음 단계로 전달하는 장치를 구분한다.
- ACK는 명령 수신 또는 처리 결과를 나타내며 실제 출력 전압 도달을 단독으로 보증하지 않는다.
- CRC는 전송 중 비트 오류를 검출하는 정보이며 CRC 오류 뒤의 응답과 상태 갱신은 대상 개정판을 따른다.
- Telemetry 응답이 한 명령 뒤에 도착할 수 있으므로 요청과 응답의 대응 시점을 확인한다.
- 실제 측정값, 목표값, 응답 상태는 서로 다른 항목으로 기록한다.

# 6. 초기화와 연속 명령
- 초기화에서는 VCC·VDDIO 안정, Reset 해제, SVC 시작, 초기화 명령의 순서를 구분한다.
- SVC를 시작하기 전의 전원 안정 대기와 SVC 시작 뒤의 준비 Clock은 다른 시간 조건이다.
- SVC가 정지한 상태와 동작 중 Clock이 멈춘 상태는 Timeout 판정에서 구분한다.
- Back-to-Back 전송에서는 각 명령의 끝과 다음 명령의 시작을 규격의 경계 규칙으로 찾는다.
- 모든 명령에 동일한 Idle 간격이나 동일한 START·END 구성을 반복한다고 단정하지 않는다.
- 초기화 시간, CRC 적용 범위와 연속 명령의 예외는 사용 중인 개정판 원문으로 확인한다.

# 7. DV에서 확인할 흐름
- Monitor는 SVC의 정의된 샘플링 시점에서 SVD와 Telemetry를 수집한다.
- 명령 해석은 VIDSEL, ADRSEL, Command Type, 대상 주소 순으로 검증한다.
- 장치 주소와 Register 주소를 서로 바꾸어 해석하지 않는지 확인한다.
- CRC 오류와 잘못된 명령이 목표 전압이나 SFR을 갱신하지 않는지 확인한다.
- Daisy-chain의 중간 장치가 Telemetry를 전달할 때 데이터와 응답 순서가 유지되는지 확인한다.
- VCC·VDDIO·Reset 순서를 바꾼 시나리오에서 수신과 출력 동작을 DUT 명세에 맞춰 확인한다.
- VID 요청이 반영된 뒤 실제 출력의 Slew와 안정화는 [[30. Notes/Power/VR Controller|VR Controller]] 및 전력단 모델의 검증 범위와 연결한다.

# 8. 연결과 참고 자료
- [[30. Notes/Power/VR Controller|VR Controller]]
- [[30. Notes/Power/DrMOS|DrMOS]]
- [[30. Notes/Power/PSI|Power Sequence Interface]]
- [Richtek SVI3 VR Controller 자료 열기 (PDF, 핀 설명·블록도)](https://www.richtek.com/assets/product_file/RT3674FE/RT3674FE_DS-00.pdf).
- [Infineon SVI3 다중 Phase VR Controller 자료 열기 (PDF, 제품 개요)](https://www.infineon.com/assets/row/public/documents/24/49/infineon-xdpe192c3b-0000-datasheet-en.pdf).
- 위 제조사 자료는 공개 구현 사례이며 실제 Command 비트와 Timing의 기준은 업무에서 사용하는 SVI3 원문이다.