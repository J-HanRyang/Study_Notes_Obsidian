# 1. 뜻

- Noise Margin은 앞단 출력에 잡음이 더해져도 뒷단 입력이 같은 논리값으로 판단할 수 있는 전압 여유다.
- $V_{OL(max)}$는 출력 LOW의 최대 보장값이고 $V_{OH(min)}$는 출력 HIGH의 최소 보장값이다.
- $V_{IL(max)}$는 입력 LOW로 해석되는 최대 전압이고 $V_{IH(min)}$는 입력 HIGH로 해석되는 최소 전압이다.
- 두 입력 기준 사이의 전압은 수신기의 논리 판단이 보장되지 않는 구간이다.

# 2. VTC에서 읽는 법

- [[30. Notes/Circuit/CMOS Inverter|CMOS Inverter]]의 전형적인 VTC에서 전이 구간 양쪽의 기울기 $-1$인 점을 각각 $V_{IL}$과 $V_{IH}$로 잡을 수 있다.
- 제품이나 셀을 확인할 때는 사용할 조건에서 명세가 보장하는 입출력 전압을 적용한다.
- 연결하는 두 소자가 다르면 출력 기준은 앞단에서 가져오고 입력 기준은 뒷단에서 가져온다.

# 3. 계산 예시

- LOW의 여유는 $NM_L=V_{IL(max)}-V_{OL(max)}$이다.
- HIGH의 여유는 $NM_H=V_{OH(min)}-V_{IH(min)}$이다.
- $V_{OH(min)}=3.0\,\mathrm V$이고 $V_{IH(min)}=2.3\,\mathrm V$이면 HIGH의 여유는 0.7 V다.
- $V_{OL(max)}=0.4\,\mathrm V$이고 $V_{IL(max)}=0.8\,\mathrm V$이면 LOW의 여유는 0.4 V다.
