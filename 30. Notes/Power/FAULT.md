# 1. 뜻
- 이 노트의 FAULT는 PMIC가 이상 상태를 알리기 위해 사용하는 신호와 그 후속 동작을 가리킨다.
- 어떤 이상을 FAULT로 분류하는지는 대상 PMIC의 명세에 따른다.

# 2. Open-Drain과의 관계
- FAULT 출력이 Open-Drain이라면 출력단은 보통 LOW 구동과 해제 상태를 가진다.
- 실제 선의 HIGH 상태는 풀업 경로가 만든다.
- 여러 장치가 한 선을 공유할 때 한 장치가 LOW를 구동하면 선은 LOW가 된다.
- FAULT의 전기적 연결은 [[90_Glossary/Circuit/Open-Drain|Open-Drain]]을 참고한다.
- Open-Drain이라는 사실만으로 FAULT 발생 조건이나 복구 동작까지 알 수는 없다.

# 3. 제품 명세에서 확인할 것
- FAULT의 극성과 Reset 직후 상태를 확인한다.
- Main/Sub PMIC 중 누가 FAULT를 구동하고 누가 관찰하는지 확인한다.
- 주장 조건, 해제 조건, 지연 시간을 확인한다.
- FAULT 이후 출력 레일과 [[30. Notes/Power/PSI|PSI]] 상태가 어떻게 변하는지 확인한다.

# 4. DV에서 확인할 것
- 정상 동작 중 예기치 않은 FAULT가 발생하지 않는지 본다.
- 각 이상 조건에서 기대한 장치가 FAULT를 주장하는지 본다.
- 공유선이라면 각 장치의 구동 의도와 실제 선 값을 구분해 관찰한다.
- Fault 해제와 재시도 후 상태 전이가 명세에 맞는지 확인한다.
- [[30. Notes/Protocol/PMBus|PMBus]] Status가 있다면 핀 FAULT와 상태 레지스터의 관계를 따로 확인한다.

