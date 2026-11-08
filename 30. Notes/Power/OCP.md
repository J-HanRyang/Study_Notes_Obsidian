# 1. 뜻과 보호 흐름
- OCP는 전류가 허용 범위를 넘는 상황을 감지하고 전력 회로를 보호하는 Overcurrent Protection이다.
- 기본 흐름은 `전류 감지 → 조건 판정 → 보호 동작 → 상태 보고 → 복구`다.
- OCP는 내부 보호 조건이고 [[30. Notes/Power/FAULT|FAULT]]는 그 결과를 외부에 알리는 신호일 수 있다.
- OCP 발생이 항상 FAULT 핀 주장과 1:1로 대응하는지는 제품 명세로 확인한다.

# 2. 감지값과 임계값
- 전류는 DrMOS, Controller 또는 별도 센싱 회로에서 얻을 수 있다.
- 순간 전류, Phase별 전류, Rail 합산 전류 중 무엇을 기준으로 비교하는지 확인한다.
- 설정된 임계값과 감지 전류의 비교에는 오차와 노이즈가 따른다.
- `>`와 `>=` 중 어느 경계에서 OCP를 주장하는지는 Register·RTL·아날로그 명세에 따라 정한다.
- 단일 짧은 스파이크를 무시하려면 Blanking이나 Debounce 조건을 둘 수 있다.

# 3. 세 가지 시간
- Detection Delay는 과전류 조건이 지속되어 OCP로 인정되기까지의 시간이다.
- Response Delay는 OCP 판정 뒤 PWM 제한이나 차단이 실제로 일어나기까지의 시간이다.
- Recovery Delay는 전류가 정상으로 돌아온 뒤 동작을 재개하기까지의 시간이다.
- 세 지연을 하나의 Fault 지연으로 합치지 않고 각각의 시작점과 끝점을 기록한다.
- 예를 들어 4회 연속 샘플에서 OCP를 검출하는 설계라면 3회와 4회의 경계 및 중간 정상 샘플에서 카운터가 어떻게 되는지 확인한다.
- 이 4회 조건은 검증 예시이며 공통 규격값은 아니다.

# 4. 보호 동작과 복구
- Current Limiting은 전류를 제한하면서 동작을 지속하거나 출력 전압을 낮출 수 있다.
- Hiccup은 출력을 멈춘 뒤 일정 시간 후 재시도하는 방식이다.
- Latch-off는 Fault가 해제될 때까지 출력을 멈추는 방식이다.
- 어떤 방식이 선택되고 언제 복귀하는지는 제품 설정과 Fault 정책에 따른다.
- Fault 상태 비트를 지워도 실제 과전류 원인이 남아 있으면 다시 보호가 걸릴 수 있다.

# 5. Status와 Mask
- Status는 OCP가 감지되거나 기록된 사실을 나타낼 수 있다.
- Mask는 알림이나 출력 신호만 막을 수도 있고 보호 경로에 영향을 줄 수도 있으므로 정확한 범위를 명세로 확인한다.
- Mask 설정, Status 비트, FAULT 핀, PWM 제한 동작을 각각 별도로 관찰한다.
- Clear 명령의 수락과 실제 보호 상태의 해제는 다른 사건이다.
- 재시도 조건이 Reset, 타이머, 외부 Enable 중 무엇인지 확인한다.

# 6. DV 시나리오
- 임계값 바로 아래, 정확히 같은 값, 바로 위에서 판정 경계를 확인한다.
- 짧은 펄스와 연속 과전류에서 Detection Delay를 구분한다.
- 지연 조건이 N회라면 N-1회와 N회, 중간 정상 샘플, Counter Reset을 확인한다.
- 보호 중 VID 변경이나 Phase 전환이 겹칠 때 우선순위와 출력 상태를 확인한다.
- Fault가 계속 남은 경우의 재시도와 원인이 사라진 경우의 복귀를 따로 확인한다.
- Scoreboard는 감지, 판정, 응답, 보고, 복구의 기대 시점을 분리해 비교한다.

# 7. 연결과 참고 자료
- [[30. Notes/Power/VR Controller|VR Controller]]
- [[30. Notes/Power/DrMOS|DrMOS]]
- [[30. Notes/Power/FAULT|FAULT]]
- [Analog Devices 전원 관리 IC 자료 열기 (PDF, Current Limit·Hiccup·Latch-off 사례)](https://www.analog.com/media/en/technical-documentation/data-sheets/ADP5051.pdf).
- [Infineon DrMOS 자료 열기 (PDF, Cycle-by-cycle OCP 사례)](https://www.infineon.com/assets/row/public/documents/24/49/infineon-tlf12500-datasheet-en.pdf).
