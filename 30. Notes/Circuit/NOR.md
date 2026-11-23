# 1. 뜻

- NOR는 OR 결과를 반전한 논리 게이트다.
- 2입력 NOR의 출력은 $Y=\overline{A+B}$이며 두 입력이 모두 LOW일 때만 HIGH다.

# 2. CMOS 구조

- Pull-down의 NMOS 두 개는 병렬로 연결하여 하나 이상의 입력이 HIGH이면 GND 경로를 만든다.
- Pull-up의 PMOS 두 개는 직렬로 연결하여 두 입력이 모두 LOW일 때 VDD 경로를 만든다.
- 예를 들어 A=1, B=0이면 NMOS A가 켜져 출력이 LOW가 되고 PMOS A가 꺼져 충전 경로가 끊긴다.
- 3입력 NOR는 NMOS 세 개를 병렬로 연결하고 PMOS 세 개를 직렬로 연결한다.

# 3. 지연과 복습

- 출력이 올라갈 때 켜진 PMOS들을 직렬로 지나므로 같은 크기의 단일 PMOS 경로보다 등가 저항이 커질 수 있다.
- 실제 상승 지연은 PMOS 크기와 출력 부하의 영향도 받는다.
- 3입력 NOR에서 입력 하나만 HIGH여도 출력이 방전되는 이유를 전류 경로로 설명해 본다.

# 4. 연결과 참고 자료

- [[30. Notes/Circuit/NAND|NAND]]에서는 NMOS 쪽에 직렬 경로가 생긴다.
- [MIT 6.012 강의 노트 열기 (PDF, Recitation 13의 NAND와 NOR 비교)](https://live.ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/4eaff509f8c5f4d19f99a616cf66a906_MIT6_012S09_rec13.pdf).
