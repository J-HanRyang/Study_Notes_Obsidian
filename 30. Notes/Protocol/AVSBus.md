# 1. 어떤 역할을 하는가
- AVSBus는 프로세서 등의 요청에 따라 전원 장치의 목표 전압을 동적으로 바꾸는 인터페이스다.
- [[30. Notes/Protocol/PMBus|PMBus]]가 설정·상태·Fault 관리에 쓰인다면 AVSBus는 빠른 전압 조정에 초점을 둔다.
- 두 인터페이스를 모두 지원하는 전원 장치도 있지만 어느 쪽이 현재 출력 전압을 제어하는지는 장치의 제어권 정책에 달려 있다.
- AVSBus는 PMBus 명령을 SMBus에 실어 나르는 전송 방식이 아니라 별도의 직렬 인터페이스다.
- 공식 PMBus 사이트에서 확인되는 현재 AVSBus 규격 안내는 2.0이다.
- 이전 PMBus Part III의 프레임과 현재 독립 규격의 프레임을 혼합해 해석하면 안 된다.

# 2. 신호와 전송 방향
- 현재 규격의 기본 연결은 Controller가 보내는 Clock과 Command Data, Target이 돌려주는 Target Data의 세 신호로 이해한다.
- Command Data와 Target Data가 분리되어 있으므로 [[30. Notes/Protocol/I2C|I2C]]의 공유 SDA, START/STOP, Clock Stretching을 그대로 적용하지 않는다.
- Controller는 목표 장치와 출력 Rail을 지정하고 명령 및 데이터를 전송한다.
- Target은 명령 처리 결과, 상태와 읽기 데이터를 응답한다.
- 같은 장치 안의 여러 Rail을 구분하는 값과 버스의 여러 Target을 구분하는 주소는 별개다.

# 3. 프레임을 읽는 순서
- AVSBus 2.0은 Controller Sub-frame 48비트와 Target Sub-frame 48비트를 한 Frame으로 사용한다.
- 이전 PMBus Part III 계열의 32비트 Sub-frame 두 개와 길이가 다르다.
- Controller Sub-frame에서는 시작 코드, Target 주소, 명령 종류, 데이터 대상, Rail 선택과 데이터의 관계를 읽는다.
- Target Sub-frame에서는 명령에 대한 응답, 상태와 반환 데이터의 관계를 읽는다.
- 2.0의 시작 코드는 8비트 `00000000`이며, Marker 비트는 데이터가 시작 코드처럼 오인되지 않게 돕는다.
- 각 Sub-frame의 CRC-3은 전송 비트 오류를 검출하는 데 사용한다.
- CRC-3은 [[90_Glossary/Protocol/PEC|SMBus PEC]]의 CRC-8과 같은 계산이 아니다.
- 실제 필드 위치와 예약 비트 값은 검증 대상의 AVSBus 개정판 원문을 기준으로 결정한다.

# 4. 전압 명령과 응답
- Voltage Write는 선택한 Target과 Rail에 새 목표 전압 값을 전달한다.
- Voltage Read는 전압 관련 값을 요청하고 Target의 응답 데이터에서 결과를 받는다.
- Write-and-Hold는 새 값을 즉시 적용하지 않고 보류하는 동작이다.
- Commit은 보류한 값을 적용하는 동작이며 여러 Rail의 변경 시점을 맞추는 데 사용될 수 있다.
- 응답의 TargetAck는 명령 수용 또는 오류의 종류를 알리는 필드다.
- TargetAck가 정상이어도 실제 전압이 이미 목표값에 도달했다고 단정할 수 없다.
- 상태 응답과 전압 측정값을 함께 봐야 명령 수락, 목표값 반영, 전압 도달을 구분할 수 있다.
- 전압 데이터의 단위, 허용 범위와 전환 속도는 사용하는 규격 개정판과 대상 장치 명세로 확인한다.

# 5. PMBus와 제어권을 넘길 때
- PMBus의 `VOUT_COMMAND`와 AVSBus의 목표 전압은 같은 출력에 대한 서로 다른 명령 경로가 될 수 있다.
- PMBus에서 AVSBus로 제어권을 넘기는 순간 전압이 튀지 않도록 기존 목표값을 AVSBus 경로에 먼저 반영한다.
- 제어권 전환 전후에는 현재 제어 인터페이스, 목표값과 실제 측정값을 각각 확인한다.
- AVSBus에서 PMBus로 돌아올 때 `VOUT_COMMAND`를 갱신할지는 장치의 설정과 규격에 따른다.
- AVSBus 명령과 PMBus 명령이 가까운 시점에 도착해도 실제로 적용될 값은 제어권 정책으로 판단한다.

# 6. 오류와 복구
- CRC 오류, 잘못된 시작 코드나 Marker, 미지원 명령, 범위 밖 전압 값은 서로 다른 오류 조건이다.
- CRC가 잘못된 전압 변경 명령이 출력 목표값을 바꾸지 않는지 확인한다.
- Target이 응답하지 않거나 명령을 처리할 수 없을 때의 응답과 재시도 정책을 구분한다.
- 2.0은 Controller가 프레임을 중단하고 다시 동기화하는 절차를 정의한다.
- AVSBus의 복구와 Timeout을 [[30. Notes/Protocol/SMBus|SMBus]]의 25~35 ms Clock LOW Timeout으로 대체하지 않는다.

# 7. DV에서 연결해 볼 것
- VIP가 Frame과 CRC를 검사하더라도 DUT의 전압 목표값 갱신과 상태 전이는 별도로 확인한다.
- Target 주소와 Rail 선택을 각각 바꾸어 다른 출력이 잘못 변경되지 않는지 확인한다.
- Write-and-Hold 뒤에는 보류값과 현재 적용값이 구분되는지 확인한다.
- Commit 이후에는 지정된 범위의 값만 적용되는지 확인한다.
- 잘못된 CRC와 범위 밖 값을 주입해 목표값 유지, 오류 응답과 상태 기록을 확인한다.
- PMBus와 AVSBus 사이의 제어권 전환 시점에 출력 목표값이 불필요하게 바뀌지 않는지 확인한다.
- 아날로그 전압 응답은 DUT에 연결된 모델 또는 실제 측정 경로로 확인하고 디지털 인터페이스 결과와 구분한다.

# 8. 관련 노트와 근거
- [[30. Notes/Protocol/PMBus|PMBus]]
- [[30. Notes/Protocol/SMBus|SMBus]]
- [[30. Notes/Protocol/I2C|I2C]]
- [PMBus 공식 현재 규격 안내 (웹페이지, AVSBus 2.0 판본 확인)](https://pmbus.org/current-specifications/).
- [Synopsys AVSBus 2.0 설명 (웹페이지, 48비트 Sub-frame·주소·Hold/Commit·DV)](https://www.synopsys.com/blogs/chip-design/multi-domain-voltage-control-verification-avsbus-2-vip.html).
- 전압 수치 인코딩, 비트 위치와 타이밍의 정확한 기준은 실제 사용 중인 AVSBus 원문과 DUT 명세다.