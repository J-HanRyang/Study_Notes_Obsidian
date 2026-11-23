# 1. 뜻

- Propagation Delay는 입력 변화가 출력에 전달되는 데 걸리는 시간이다.
- 입력과 출력이 각각 기준 전압을 통과한 두 시점의 차로 측정하며 간단한 파형 예제에서는 각 신호의 50% 지점을 쓴다.
- $t_{PHL}$은 출력이 HIGH에서 LOW로 바뀌는 전파 지연이고 $t_{PLH}$는 반대 방향의 전파 지연이다.

# 2. Rise Time과 Fall Time

- Rise Time과 Fall Time은 한 신호가 두 전압 기준 사이를 이동하는 시간이다.
- 예를 들어 상승 시간은 출력의 10%에서 90%까지 걸린 시간으로 측정할 수 있다.
- 입력 Slew, 출력 부하, 배선 기생 성분과 셀 구동 능력이 전파 지연에 영향을 준다.
- 실제 측정 기준은 데이터시트나 셀 라이브러리에서 확인한다.

# 3. 여러 게이트를 거치는 예시

- 한 경로에서 AND 지연이 40 ps이고 이어지는 OR 지연이 25 ps라면 고정 지연을 가정했을 때 합은 65 ps다.
- 실제 타이밍 분석에서는 이전 셀의 출력 Slew와 배선·부하가 다음 셀의 지연에 반영된다.
- 병렬 경로는 각 경로의 도착 시각을 비교해 [[90_Glossary/Timing/Critical Path|Critical Path]]를 찾는다.

# 4. 참고 자료

- [MIT CMOS 강의 열기 (Propagation Delay 측정)](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c3/c3s1/).
