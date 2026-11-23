# 1. 뜻

- NAND는 AND 결과를 반전한 논리 게이트다.
- 2입력 NAND의 출력은 $Y=\overline{AB}$이며 두 입력이 모두 HIGH일 때만 LOW다.

# 2. CMOS 구조

- Pull-down의 NMOS 두 개는 직렬로 연결하여 두 입력이 모두 HIGH일 때 GND 경로를 만든다.
- Pull-up의 PMOS 두 개는 병렬로 연결하여 하나 이상의 입력이 LOW이면 VDD 경로를 만든다.
- 예를 들어 A=1, B=0이면 NMOS B가 꺼져 방전 경로가 끊기고 PMOS B가 켜져 출력이 HIGH가 된다.

# 3. 지연과 복습

- 출력이 내려갈 때 켜진 NMOS들을 직렬로 지나므로 같은 크기의 단일 NMOS 경로보다 등가 저항이 커질 수 있다.
- 각 NMOS를 $2\,\mathrm{k\Omega}$으로 근사한 3입력 NAND와 $10\,\mathrm{pF}$ 부하에서는 [[30. Notes/Circuit/RC Delay|RC 시간상수]]가 60 ns다.
- 입력이 세 개로 늘었을 때 어느 입력 조합에서만 방전 경로가 완성되는지 그려 본다.

# 4. 관련 노트

- [[30. Notes/Circuit/NOR|NOR]]의 Pull-up과 Pull-down 배치를 비교한다.
