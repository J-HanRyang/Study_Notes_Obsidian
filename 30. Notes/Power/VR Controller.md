# 1. 하는 일
- VR Controller는 CPU가 요청한 전압과 전력 상태를 받아 Rail의 출력을 제어한다.
- SVI3는 요청을 전달하는 인터페이스이고 VR Controller는 출력 전압을 조절하는 제어부다.
- VR Controller의 PWM 신호는 전력단인 [[30. Notes/Power/DrMOS|DrMOS]]로 전달된다.
- 목표 전압을 받은 시점과 실제 출력이 목표에 도달한 시점은 다르다.

# 2. 피드백 제어
- Controller는 목표 전압과 감지한 출력 전압의 차이를 보고 PWM 동작을 조절한다.
- PWM으로 전력단의 스위칭을 바꾸면 인덕터 전류가 변하고 출력 커패시터와 부하의 전압이 따라 변한다.
- 제어 루프의 응답에는 대역폭과 안정성의 한계가 있다.
- 출력 감지값, 목표값, 실제 Rail 전압을 검증에서 따로 관찰한다.

# 3. 부하가 갑자기 바뀔 때
- 부하 전류가 급증하면 인덕터 전류가 즉시 따라오지 못해 출력 커패시터가 부족한 전류를 잠시 공급한다.
- 이때의 일시적인 출력 전압 하강을 Load Transient에 따른 Droop으로 본다.
- 부하 전류가 급감하면 남아 있는 인덕터 전류 때문에 출력 전압이 일시적으로 상승할 수 있다.
- Controller가 PWM을 조정한 뒤 안정화하는 과정까지 시간에 따라 확인한다.
- 순간 과도응답은 의도한 정상상태 Load-line과 구분한다.

# 4. Load-line
- Load-line은 부하 전류가 늘 때 정상상태 목표 전압을 의도적으로 낮추는 특성이다.
- 단순 선형 모델에서는 `Vtarget = V_ID - I_load × R_LL`로 표현할 수 있다.
- 실제 적용값과 허용 오차는 CPU·VR 설계 요구사항을 따른다.
- 전류 증가 직후의 순간 Droop과 안정화 뒤의 Load-line 전압을 따로 측정한다.

# 5. VID와 Slew Rate
- VID 코드는 요청 전압을 나타내며 실제 환산값은 사용하는 SVI3 개정판과 장치 설정을 따른다.
- VID가 바뀌면 Controller는 목표 전압을 갱신하고 출력은 지정된 Slew Rate에 따라 이동한다.
- Slew Rate는 단위 시간당 출력 전압 변화 속도다.
- VID 변경에 따른 전압 이동과 부하 변화에 따른 과도응답은 원인이 다르다.
- VID 요청의 수신 응답만으로 출력이 새 전압에 안정화되었다고 판단하지 않는다.

# 6. 여러 Phase의 제어
- 여러 Phase가 같은 Rail의 전류를 분담하면 각 스위칭 시점을 엇갈리게 배치할 수 있다.
- Phase Interleaving은 출력 리플과 입력 전류의 피크를 낮추는 데 도움이 된다.
- 부하가 작을 때 일부 Phase를 끄는 Phase Shedding은 효율 개선에 쓰일 수 있다.
- 부하가 커지면 필요한 Phase를 다시 켜서 전류를 나눈다.
- 한 Rail의 Phase 수와 장치가 제어하는 Rail 수는 다른 값이다.
- 각 Phase의 전류 분담과 전환 순간의 출력 변화를 함께 본다.

# 7. DV에서 보는 경계
- [[30. Notes/Protocol/SVI3|SVI3]] 명령 디코드와 목표 Register 갱신을 먼저 확인한다.
- 다음으로 PWM·Phase 상태가 목표값과 감지값에 맞게 바뀌는지 확인한다.
- 실제 전압·전류 파형은 아날로그 모델이나 측정 범위에서 확인한다.
- VID 변경과 Phase 추가·제거가 겹칠 때 응답 순서와 출력 허용 범위를 검증한다.
- Fault가 발생하면 명령 응답, PWM 차단, 상태 보고가 각각 언제 일어나는지 구분한다.

# 8. 연결과 참고 자료
- [[30. Notes/Power/Buck|Buck]]
- [[30. Notes/Power/DrMOS|DrMOS]]
- [[30. Notes/Power/OCP|OCP]]
- [Infineon SVI3 다중 Phase VR Controller 자료 열기 (PDF, 제어·Telemetry 개요)](https://www.infineon.com/assets/row/public/documents/24/49/infineon-xdpe192c3b-0000-datasheet-en.pdf).
- [Analog Devices 다중 Phase Buck 설명 열기 (웹 문서, 리플·과도응답)](https://www.analog.com/en/resources/analog-dialogue/articles/output-current-and-volt-ripple-in-multiphase-buck.html).
