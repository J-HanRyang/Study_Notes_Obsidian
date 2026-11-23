# 1. 뜻과 구조

- CMOS 인버터는 입력의 논리값을 뒤집는 회로다.
- 위쪽 PMOS는 VDD와 출력을 연결하는 Pull-up이고 아래쪽 NMOS는 출력과 GND를 연결하는 Pull-down이다.
- 두 [[30. Notes/Circuit/MOSFET|MOSFET]]의 Gate는 같은 입력에 연결되고 Drain이 만나는 곳이 출력이다.

# 2. 입력을 바꿨을 때

- 입력이 LOW면 PMOS가 켜져 출력 부하를 충전하고 출력이 HIGH로 올라간다.
- 입력이 HIGH면 NMOS가 켜져 출력 부하를 방전하고 출력이 LOW로 내려간다.
- 입력이 중간 전압을 통과할 때 두 소자가 동시에 켜지는 구간이 생길 수 있다.
- 출력 부하의 충전과 방전에는 시간이 걸리므로 입력과 출력 파형의 에지 사이에 지연이 생긴다.

# 3. VTC 읽기

- VTC는 입력 전압에 따른 정상상태 출력 전압을 그린 Voltage Transfer Characteristic이다.
- 가로축은 입력 전압이고 세로축은 출력 전압이다.
- 인버터의 스위칭점 $V_M$은 VTC와 $V_{out}=V_{in}$이 만나는 점이다.
- [[90_Glossary/Circuit/Noise Margin|Noise Margin]] 계산에는 입력 판정 한계인 $V_{IL}$과 $V_{IH}$ 및 출력 보장 범위가 필요하다.

# 4. 연결과 참고 자료

- [[30. Notes/Circuit/RC Delay|RC Delay]]에서 충전과 방전의 시간상수를 확인한다.
- [MIT CMOS 강의 열기 (CMOS Inverter VTC와 지연)](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c3/c3s1/).
