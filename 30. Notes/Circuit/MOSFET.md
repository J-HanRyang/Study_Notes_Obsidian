# 1. 뜻

- MOSFET은 Gate 전압으로 Source와 Drain 사이의 전류를 제어하는 트랜지스터다.
- CMOS 디지털 회로에서는 Enhancement NMOS와 PMOS를 스위치처럼 근사해 전류 경로를 읽을 수 있다.

# 2. 켜지는 조건

- NMOS의 Gate와 Source 전압 차는 $V_{GS}=V_G-V_S$이고 단순 모델에서 $V_{GS}>V_{TH,n}$일 때 채널이 형성된다.
- PMOS의 Source와 Gate 전압 차는 $V_{SG}=V_S-V_G$이고 단순 모델에서 $V_{SG}>|V_{TH,p}|$일 때 채널이 형성된다.
- NMOS의 Source가 GND에 놓인 인버터에서는 입력 HIGH가 NMOS를 켠다.
- PMOS의 Source가 VDD에 놓인 인버터에서는 입력 LOW가 PMOS를 켠다.
- MOSFET은 켜진 상태에서도 유한한 저항을 가지며 저항 근사는 전압과 동작점에 따라 달라진다.

# 3. 계산 예시

- NMOS의 Gate가 1.0 V이고 Source가 0 V이면 $V_{GS}=1.0\,\mathrm V$다.
- 같은 NMOS에서 Source가 0.8 V로 올라가면 $V_{GS}=0.2\,\mathrm V$가 된다.
- 문턱전압을 0.4 V로 단순화하면 첫 상태는 켜지고 두 번째 상태는 꺼진다.

# 4. 관련 노트

- [[30. Notes/Circuit/CMOS Inverter|CMOS Inverter]]에서 NMOS와 PMOS의 역할을 출력 파형과 연결한다.
