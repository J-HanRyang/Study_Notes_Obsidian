# SystemVerilog UVM 14단계 - Coverage와 Assertion

학습일: 2026-10-10. 역할 구분, 짧은 코드와 상황 해석을 대화로 확인했다. Covergroup·assertion의 독립 작성 및 simulator 실행은 미실행이다.

## 1. 왜 coverage가 필요한가

모든 비교가 통과했더라도 중요한 상황을 시험하지 않았다면 그 기능을 검증했다고 말할 수 없다. FIFO의 일반 쓰기·읽기 100건을 통과해도 full 추가 쓰기나 empty 읽기를 하지 않았다면 해당 경계 동작은 미확인이다.

| 기능 | 질문 |
|---|---|
| Scoreboard | 예상 결과와 실제 결과가 일치하는가? |
| Functional coverage | 검증 계획에서 정의한 상황이 발생했는가? |
| Assertion | 신호·시간 규칙이 지켜졌는가? |
| Code coverage | RTL 문장·분기·신호 변화 등이 얼마나 실행됐는가? |

Coverage는 정확성 검사를 대체하지 않는다. 상황이 발생한 사실과 결과가 맞은 사실을 구분한다.

## 2. Coverpoint와 cross

Coverpoint는 특정 값이나 범위를 관찰하는 측정 지점이다. Bin은 측정할 값·범위를 구분하는 항목이다. Cross는 여러 coverpoint의 조합을 측정한다.

```systemverilog
covergroup fifo_cg with function sample(bit empty_s, bit rd_s);
  cp_empty : coverpoint empty_s;
  cp_read  : coverpoint rd_s;
  empty_read : cross cp_empty, cp_read;
endgroup

// 먼저 cg = new()로 covergroup instance를 생성한다.
// 같은 요청 판단 시점에서 관찰한 두 값을 함께 넘긴다.
cg.sample(empty_before, read_request);
```

위의 bit 인자에는 0/1 값을 측정하며 기본 bin이 생성된다. X/Z 상태를 검사하려면 별도의 관찰·검사 방식을 정의한다. Sampling 계약은 실제 interface·clocking과 DUT timing에 맞게 정해야 한다. 이 예제를 실제 FIFO monitor에 구현한 것은 아니다.

| empty | rd_en | 조합의 의미 |
|---|---|---|
| 0 | 0 | 데이터 있음 / 읽기 요청 없음 |
| 0 | 1 | 데이터 있을 때 읽기 요청 |
| 1 | 0 | 비어 있음 / 읽기 요청 없음 |
| 1 | 1 | 비어 있을 때 읽기 요청 |

Empty와 read를 서로 다른 cycle에서 관찰해 각각의 coverpoint가 채워져도, empty 읽기 조합을 시험한 것은 아니다. DUT가 요청을 판단하는 같은 시점의 상태와 요청을 측정해야 한다. 수락된 읽기만 수집하면 거부되는 empty 읽기 요청을 놓칠 수 있다.

## 3. Coverage가 오류를 판정하지 않는 이유

Empty 읽기 조합이 발생한 뒤 DUT가 잘못해서 읽기 포인터를 증가시켜도 stimulus coverage는 채워질 수 있다. 그 동작이 옳은지는 사양을 기준으로 scoreboard 또는 assertion이 검사한다.

검증 계획에서 빠뜨린 기능은 coverage 100%에서도 빠져 있다. 잘못된 sampling, 약한 checker, 잘못된 예상 모델도 결과를 왜곡한다. 따라서 100%는 정의된 목표의 달성이지 무결함 보장이 아니다.

## 4. Assertion과 시간 규칙

Assertion은 특정 조건에서 지켜야 할 신호·시간 규칙을 검사한다. 예를 들어 사양이 “empty 읽기는 거부하고 읽기 포인터를 유지한다”라면 다음과 같이 표현할 수 있다.

```systemverilog
assert property (@(posedge clk) disable iff (!rst_n)
  (empty && rd_en) |=> $stable(rd_ptr));
```

| 문법 | 의미 |
|---|---|
| @(posedge clk) | 상승 에지에서 값을 sampling |
| disable iff (!rst_n) | active-low reset 중 검사 비활성화·진행 중 attempt 취소 |
| empty && rd_en | 검사 시작 조건 |
| \|=> | 다음 clock sampling에서 뒤 조건 검사 |
| $stable(rd_ptr) | 직전 sampling 값과 동일한지 검사 |

이 assertion은 reset 외 다른 포인터 변경 원인이 없고, empty 상태 read를 거부하는 사양을 가정한 개인 학습 예제다. 동시 write의 empty bypass 등 다른 계약에는 그대로 적용할 수 없다. Internal rd_ptr 접근 방식도 실제 DUT에 맞춰야 한다.

Concurrent assertion은 clock의 sampled 값을 사용한다. 요청 에지에서 NBA로 갱신되는 포인터 값은 다음 에지의 sampling에서 확인하는 구조다. `disable iff`의 reset 조건은 일반 sampled 표현과 평가 특성이 다르므로 실제 reset timing을 확인해야 한다. 세부 scheduling과 race 분석은 후속 실습 항목이다.

## 5. Vacuous success

앞 조건이 성립하지 않으면 implication은 뒤 조건 검사를 요구하지 않는다. Empty 읽기를 한 번도 하지 않았어도 위 assertion에서 failure가 없을 수 있다. 이런 통과를 vacuous success라고 한다.

```text
Assertion failure 0개 + empty 읽기 coverage 0
→ empty 읽기 동작을 정상이라고 확인한 것이 아님
```

Coverage는 검사할 상황이 발생했는지, assertion은 발생한 상황의 규칙이 맞는지 확인한다. 조건의 실제 발생과 attempt·검사 횟수를 함께 보는 것이 중요하다. `cover property` 등의 상세 구현은 아직 학습하지 않았다.

## 6. Code coverage와 functional coverage

Code coverage는 구현을 기준으로 실행 정도를 측정하고, functional coverage는 사양·검증 계획을 기준으로 상황을 측정한다. Code coverage의 종류와 지원 범위는 simulator·도구에 따라 다르다.

Code coverage 100%여도 full 상태의 read/write 동시 요청 같은 특정 조합은 놓칠 수 있다. 반대로 functional coverage 100%여도 정의되지 않은 RTL 경로나 기능은 남아 있을 수 있다. 둘은 함께 확인하며, checker의 정확성도 별도 검토한다.

## 7. 빈 coverage 항목을 분석하는 순서

1. 사양상 가능한 상황인지 확인한다.
2. 가능하지만 미시험이라면 sequence·constraint를 조정해 해당 상황을 만든다.
3. 이미 발생했다면 sampling 시점·수집 경로·coverage 정의를 확인한다.
4. 불가능한 조합은 사양 근거를 남기고 coverage 목표에서 제외한다.

같은 시점의 full=1과 empty=1을 허용하지 않는 사양이라면 채울 목표로 취급하지 않는다. 실제 발생 여부를 오류 규칙으로 검사할 수 있다. Ignore/illegal bin 및 coverage exclusion의 상세 코드와 정책은 미확인이다.

Full 동시 read/write가 가능하지만 coverage 0이면 FIFO를 full로 만든 뒤 같은 cycle에 두 요청을 넣는다. 이후 결과는 DUT 사양으로 검사한다.

```text
깊이 4, 초기 [A, B, C, D], read + E write
사양 1: full이어도 read가 수락되면 write도 수락 → [B, C, D, E]
사양 2: 요청 직전 full이면 write 거부           → [B, C, D]
```

모델에서 pop 후 push로 계산하는 순서는 DUT가 실제로 시간상 읽기 후 쓰기를 실행한다는 뜻이 아니다. 두 동작은 같은 clock edge에 함께 수락될 수 있다. 이 규칙은 설명용 가정이며 실제 FIFO RTL 사양을 확인한 결과가 아니다.

## 8. 회사 PDF 02.08의 coverage 분류

회사 PDF의 책 225~229쪽은 functional coverage를 측정 위치·목적에 따라 설명한다.

- Configuration coverage: 선택된 환경 설정·모드를 측정한다.
- Stimulus coverage: monitor가 관찰한 자극·transaction의 속성을 측정한다.
- Correctness coverage: scoreboard에서 실제 비교가 통과한 transaction을 측정한다.

책에서는 stimulus coverage를 `uvm_subscriber`의 `write()`에서 covergroup `sample()`로 측정하는 흐름을 설명한다. Monitor의 analysis port에서 scoreboard와 coverage collector로 병렬 전달할 수 있다. Correctness coverage는 비교 성공 branch에서 sampling하므로 자극의 발생만 측정하는 coverage와 의미가 다르다.

이 PDF 연결 내용은 문서 보충이며, subscriber 구현·coverage_enable 설정·correctness collector의 독립 작성은 대화에서 확인하지 않았다. Assertion은 회사 해당 절의 기본 설명과 구분한 개인 학습 보충이다.

## 9. 대화에서 확인한 이해

- Empty 읽기 미시험은 해당 결과 미확인임을 설명했다.
- 개별 coverpoint 달성과 같은 sampling 시점의 조합 달성을 구분했다.
- Coverage가 잘못된 읽기 포인터 동작을 판정하지 못함을 확인했다.
- 다음 sampling의 포인터 변화는 예제 assertion 실패임을 답했다.
- Assertion failure 0과 시작 조건 미발생을 구분했다.
- Code coverage 100%가 functional 조합 완료를 보장하지 않음을 답했다.
- Full 동시 요청을 의도적으로 만들고 두 동작 수락 계약에서 [B,C,D,E]를 예측했다.
- Functional coverage 100%·error 0도 비교 누락 가능성과 미시험 코드 때문에 무결함 보장이 아님을 설명했다. 정의한 검증 계획의 누락도 추가 보충했다.

세미나 표현: “Functional coverage는 검증 계획에 정의한 기능과 상황을 실제로 시험했는지 확인한다. 올바른 결과와 규칙은 scoreboard·assertion이 확인한다.”

## 10. 다음 학습과 수준

14단계 기본 이론·코드/상황 해석 확인까지 마쳤다. Covergroup 생성·sample 연결, bin 설계, SVA timing·reset·race, 실제 coverage report와 checker 실행은 미확인이다.

사용자 결정에 따라 다음은 **15단계 Callback → 16단계 RAL → 회사 PDF 범위 누락 점검과 세미나 자료 작성**이다. 16단계까지 주요 이론 기본 학습을 마치고, 이후 FIFO UVM 환경을 직접 작성·실행·디버깅한다. “기본 이론 완료”를 “UVM 전부 숙련”으로 기록하지 않는다.

공식 보충 참고: [Accellera SystemVerilog tutorial - implication과 vacuous success](https://accellera.com/images/resources/videos/systemverilog-design-tutorial-2015.pdf). 예제는 개념 설명용이며 실제 DUT 사양·timing에 맞춰 검증해야 한다.
