# 1. PMBus가 정의하는 것
- PMBus는 전력 변환 장치를 설정하고 상태를 읽기 위한 명령 언어를 정의한다.
- [[30. Notes/Protocol/I2C|I2C]]는 신호와 기본 전송을, [[30. Notes/Protocol/SMBus|SMBus]]는 명령 코드와 데이터가 오가는 트랜잭션 형식을 설명한다.
- PMBus Part I은 일반 요구사항과 전송 방식을, Part II는 명령의 의미·수치 형식·Fault 처리를 다룬다.
- SMBus의 Write Word는 두 데이터 바이트를 보내는 형식이고, PMBus의 `VOUT_COMMAND`는 그 값을 목표 출력 전압으로 쓰라는 의미다.
- 버스에서 ACK를 받았다는 사실과 전원 출력이 목표값에 도달했다는 사실은 다른 단계다.

# 2. Part I: 여러 장치를 다루는 전송
- PMBus 장치는 기본적으로 각자의 버스 주소로 선택한다.
- Group Command는 여러 장치에 쓰기 명령을 하나의 연속 전송으로 전달한다.
- 각 장치는 전송을 끝내는 STOP을 감지하면 자신이 받은 명령의 실행을 시작한다.
- 장치마다 같은 명령을 받을 필요는 없지만 하나의 Group Command 안에서 같은 장치에 두 명령을 보낼 수는 없다.
- Extended Command는 확장 코드와 명령 코드를 이어 보내 명령 공간을 넓힌다.
- 확장 명령 역시 해당 명령에 맞는 SMBus 읽기·쓰기 형식을 사용한다.
- Zone은 여러 장치나 출력을 논리적인 그룹으로 묶어 함께 제어하거나 상태를 읽는 방식이다.
- `ZONE_CONFIG`는 출력이 어느 읽기·쓰기 Zone에 속하는지 설정한다.
- `ZONE_ACTIVE`는 이후 Zone 동작에 사용할 읽기·쓰기 Zone을 선택한다.
- `ZONE_WRITE`는 선택된 Zone의 대상에 명령을 전달한다.
- `ZONE_READ`는 선택된 Zone의 대상에서 상태 또는 명령 데이터를 모아 읽는다.
- Group Command는 주소가 다른 장치에 개별 명령을 연속해서 보내는 방식이고 Zone 동작은 미리 구성한 그룹을 대상으로 한다.
- Zone 지원 여부와 설정 가능 범위는 장치 명세를 확인한다.

# 3. Part II: 동작 값과 저장 값
- Operating Memory는 현재 동작에 쓰는 설정값을 설명하는 개념적인 휘발성 저장 영역이다.
- 전원을 켤 때 하드코딩 값, 핀 설정, 비휘발성 Default Store와 User Store가 동작값의 출처가 될 수 있다.
- 이후 버스로 쓴 설정값은 해당 동작값을 갱신할 수 있다.
- `STORE_USER_ALL`은 현재 동작값을 User Store에 저장한다.
- `RESTORE_USER_ALL`은 User Store의 값을 동작 영역으로 다시 가져온다.
- `_CODE`가 붙은 STORE/RESTORE 명령은 전체가 아니라 지정한 명령의 파라미터를 대상으로 한다.
- Default Store와 User Store의 존재, 저장 가능한 항목, 쓰기 권한은 장치별로 다르다.
- 따라서 `VOUT_COMMAND`를 한 번 쓴 것만으로 전원 재인가 뒤에도 값이 유지된다고 단정할 수 없다.
- 전원 인가 직후 값과 STORE/RESTORE 이후 값을 분리해서 생각한다.

# 4. 수치 데이터를 읽는 방법
- PMBus의 데이터 바이트를 전압이나 전류의 정수값으로 바로 읽으면 안 된다.
- 명령별 데이터 형식과 지수 또는 변환 계수를 적용해 물리량으로 바꾼다.
- LINEAR11은 부호가 있는 지수와 가수를 16비트 안에 담으며 입력 전압, 출력 전류, 온도 등의 표현에 쓰일 수 있다.
- ULINEAR16은 출력 전압 관련 값에 쓰이는 양의 가수와 별도 지수를 사용한다.
- ULINEAR16에서 전압은 `가수 × 2^지수`로 계산하고 지수는 `VOUT_MODE`에서 확인한다.
- DIRECT 형식은 장치가 정한 계수와 오프셋을 알아야 실제 단위로 환산할 수 있다.
- 출력 전압 명령에는 VID 같은 형식도 가능하므로 대상 장치가 지원하는 모드를 먼저 확인한다.
- 같은 2바이트라도 명령과 모드가 다르면 의미와 단위가 달라진다.

# 5. 출력 선택과 전압 제어
- 다중 출력 장치의 `PAGE`는 뒤따르는 명령이 적용될 출력을 고른다.
- `PHASE`는 한 출력에 여러 전력 단계를 쓰는 장치에서 관련 단계를 선택하는 데 사용된다.
- `VOUT_MODE`는 출력 전압 관련 수치의 형식을 알려준다.
- `VOUT_COMMAND`는 출력 전압의 목표값을 설정한다.
- `OPERATION`은 출력의 켜짐·꺼짐이나 Margin 동작을 명령하는 데 사용한다.
- `ON_OFF_CONFIG`는 `OPERATION` 명령과 CONTROL 핀을 어떤 조건으로 조합할지 정한다.
- `READ_VOUT`은 장치가 보고하는 출력 전압 측정값이다.
- `VOUT_COMMAND`를 1.0 V로 설정해도 `READ_VOUT`은 시동 중이거나 부하가 변하는 동안 1.0 V와 다를 수 있다.
- 목표값을 쓴 뒤에는 명령 수락, 선택된 PAGE의 설정값, 출력 활성 조건, 측정값과 상태를 구분해 확인한다.
- 내부 SFR 주소와 PMBus 명령 코드는 같은 번호 체계가 아니며 둘의 매핑은 장치 구현에 달려 있다.

# 6. Warning, Fault와 상태 보고
- Warning은 감시값이 경고 임계값을 넘은 상태를 알리고 Fault는 보호 동작을 유발할 수 있는 이상 조건을 알린다.
- 예를 들어 출력 과전압 경고 임계값과 출력 과전압 Fault 임계값은 서로 다른 설정이다.
- `STATUS_BYTE`와 `STATUS_WORD`는 주요 이상 영역을 요약한다.
- `STATUS_VOUT`, `STATUS_IOUT` 같은 세부 상태는 전압·전류 영역의 원인을 더 구체적으로 보여준다.
- CML 상태는 잘못된 명령, 데이터 또는 통신 처리 문제를 확인할 때 본다.
- Fault Response 명령은 해당 Fault 이후 출력을 끄거나 재시도하는 등의 반응을 정한다.
- Retry 횟수와 Delay의 정확한 단위와 동작은 해당 명령 및 장치 명세에 따른다.
- `CLEAR_FAULTS`는 기록된 Fault 상태를 지우는 명령이며 실제 이상 원인을 제거하는 명령은 아니다.
- 따라서 Fault 분석은 `조건 발생 → 상태 비트 → 알림 → 출력 반응 → 원인 제거 → Clear/Retry` 순서로 본다.
- 핀으로 전달되는 [[30. Notes/Power/FAULT|FAULT]] 신호가 있다면 PMBus 상태 비트와의 관계를 별도로 확인한다.

# 7. 지원 여부 확인과 검증 관점
- `CAPABILITY`는 장치의 일부 인터페이스 능력을 알려준다.
- `QUERY`는 지정한 명령의 지원 여부와 읽기·쓰기 및 데이터 형식을 확인하는 데 사용한다.
- PMBus에 명령이 정의되어 있어도 모든 장치가 그 명령을 지원하는 것은 아니다.
- 지원하지 않는 명령이나 잘못된 데이터는 통신 응답과 CML 상태를 함께 확인한다.
- 디지털 DV에서는 버스 트랜잭션뿐 아니라 선택된 PAGE의 설정값, Readback, 상태 비트와 제어 출력까지 확인한다.
- 아날로그 전력단이 RTL 밖에 있으면 실제 전압의 시간 응답은 모델이나 별도 실측의 검증 범위로 둔다.
- VIP가 정상 형식의 명령을 만들더라도 그 명령에 대한 기대 결과는 DUT의 기능 명세에서 가져온다.

# 8. 한 흐름으로 연결하기
- 호스트가 PAGE를 선택하고 `VOUT_MODE`를 읽어 목표 전압의 형식을 확인한다.
- 호스트가 `VOUT_COMMAND`를 쓰면 장치는 해당 출력의 목표값을 갱신한다.
- 출력이 켜질 수 있는지는 `OPERATION`, `ON_OFF_CONFIG`와 하드웨어 조건이 함께 결정한다.
- 호스트는 `READ_VOUT`과 Status 명령으로 실제 보고값과 이상 여부를 확인한다.
- 설정을 전원 재인가 후에도 보존하려면 장치가 지원하는 STORE 동작과 저장 정책을 확인한다.

# 9. 관련 노트와 참고 자료
- [[30. Notes/Protocol/SMBus|SMBus]]
- [[30. Notes/Protocol/I2C|I2C]]
- [[30. Notes/Power/PSI|PSI]]
- [[30. Notes/Power/FAULT|FAULT]]
- [PMBus 공식 FAQ (웹페이지)](https://pmbus.org/resources/faq/).
- [PMBus 공식 규격 안내 (웹페이지)](https://pmbus.org/current-specifications/).
- [PMBus 1.3.1 Part I 원문 (PDF, 5.6절 Group·Extended·Zone 전송)](https://pmbusprod.wpenginepowered.com/wp-content/uploads/2022/01/PMBus-Specification-Rev-1-3-1-Part-I-20150313.pdf).
- [PMBus 1.3.1 Part II 원문 (PDF, 6~17절 메모리·수치·Fault·주요 명령)](https://pmbus.org/wp-content/uploads/2022/01/PMBus-Specification-Rev-1-3-1-Part-II-20150313.pdf).
- 이 노트의 공통 개념은 공개된 1.3.1 원문으로 확인했으며, 1.5의 세부 차이는 사용 중인 1.5 원문과 대조해야 한다.
