# 1. 뜻과 위치
- DrMOS는 Gate Driver와 High-side·Low-side MOSFET을 한 전력단으로 묶은 부품이다.
- VR Controller가 만든 PWM 명령을 받아 [[30. Notes/Power/Buck|동기식 Buck]]의 스위칭을 수행한다.
- CPU의 전압 요청은 Controller에서 해석하고 DrMOS는 그 명령에 따라 전력을 변환한다.
- 하나의 Rail에 여러 Phase가 있으면 Phase마다 전력단과 인덕터가 있을 수 있다.

# 2. 한 Phase에서 전류가 흐르는 방식
- High-side MOSFET이 켜지면 입력 전원에서 SW 노드와 인덕터를 거쳐 부하로 에너지가 전달된다.
- 이 구간의 이상적인 인덕터 전압은 `Vin - Vout`이며 인덕터 전류가 증가한다.
- Low-side MOSFET이 켜지면 인덕터 전류가 GND 쪽 경로를 통해 계속 흐른다.
- 이 구간의 이상적인 인덕터 전압은 `-Vout`이며 인덕터 전류가 감소한다.
- MOSFET이 모두 꺼지는 짧은 전환 구간에는 기생 다이오드 경로로 전류가 흐를 수 있다.
- 스위치가 꺼져도 인덕터 전류가 즉시 0이 되지 않는다.

# 3. PWM과 Dead Time
- PWM 입력은 스위칭 의도이고 실제 High-side·Low-side Gate 출력은 Driver 내부 지연을 거쳐 만들어진다.
- 두 MOSFET이 동시에 켜지면 입력 전원에서 GND로 큰 전류가 흐르는 Shoot-through가 생길 수 있다.
- Driver는 전환할 때 양쪽 Gate가 꺼진 Dead Time을 두어 동시 도통을 피한다.
- Dead Time이 지나치게 길면 기생 다이오드 도통과 손실이 커질 수 있다.
- PWM 극성, 전달 지연, Dead Time, 보호 동작은 부품별 자료로 확인한다.

# 4. 센싱과 보호
- 일부 DrMOS는 전류 감지 출력, 온도 정보, 과전류·과온 보호를 제공한다.
- 전류 감지 방식은 MOSFET 특성 이용, Current Mirror, 인덕터 DCR 감지 등 구현마다 다르다.
- 센싱값의 보정과 제한값은 제품 및 Controller 설정에 따라 달라진다.
- [[30. Notes/Power/OCP|OCP]]가 감지·제한·Fault 보고 중 어디에서 처리되는지 전력단과 Controller의 역할을 나누어 본다.
- 보호 상태가 발생해도 모든 제품에서 동일한 PWM 차단이나 재시도 동작을 한다고 가정하지 않는다.

# 5. 여러 Phase와 Rail
- 여러 DrMOS의 출력은 각각 인덕터를 지나 같은 Rail에 합쳐질 수 있다.
- Controller는 Phase의 스위칭 시점을 엇갈리게 하고 전류 분담을 조절한다.
- 특정 Phase의 전류 감지 오류나 Fault가 Rail 전체의 동작에 어떤 영향을 주는지 확인한다.
- Phase Shedding에서는 비활성 Phase의 스위칭 상태와 재활성화 조건을 확인한다.

# 6. DV에서 확인할 것
- 디지털 검증에서는 PWM·Enable·Fault·Current Sense 인터페이스의 순서와 극성을 확인한다.
- Gate 전환과 실제 전류·전압 파형은 전력단 모델 또는 아날로그 검증 범위에서 확인한다.
- PWM 변경과 Fault가 겹칠 때 어느 경로가 우선하는지 명세에 맞춰 확인한다.
- Phase별 Fault 보고와 전체 Rail 보호 상태를 혼동하지 않는다.

# 7. 연결과 참고 자료
- [[30. Notes/Power/VR Controller|VR Controller]]
- [[30. Notes/Power/Buck|Buck]]
- [[30. Notes/Power/OCP|OCP]]
- [Infineon DrMOS 자료 열기 (PDF, Gate Driver·전류 감지·보호)](https://www.infineon.com/assets/row/public/documents/24/49/infineon-tlf12500-datasheet-en.pdf).
- [Infineon DrMOS 자료 열기 (PDF, Shoot-through 방지·Gate 지연)](https://www.infineon.com/dgdl/TDA21220_DrMOS_V1.0_DS_Rev1.9.pdf?fileId=db3a304328c6bd5c0128d3df67f200b0&folderId=db3a3043240e85fe0124160b44183655).
