# SystemVerilog/UVM 3단계 - Randomization과 Constraint

> 학습 범위: `rand`, `randc`, `randomize()`, constraint block, inline constraint, `inside`, `dist`, implication, conditional constraint, `solve before`, `soft`, `constraint_mode()`, `rand_mode()`, `pre_randomize()`, `post_randomize()`, constraint 상속과 override, 충돌 및 과도하거나 부족한 제약.

## 1. Randomization의 기본 구조

```systemverilog
class Packet;
  rand bit [3:0] addr;
       bit [3:0] data;
endclass

Packet p = new();
p.addr = 3;
p.data = 5;

if (!p.randomize())
  $error("Randomization failed");
```

- `new()`는 object를 생성한다.
- `randomize()`는 활성화된 `rand`와 `randc` field에 constraint를 만족하는 값을 실제로 반영한다.
- `rand`가 없는 `data`는 randomization 대상이 아니므로 기존값을 유지한다.
- `randomize()`는 성공 시 1, 실패 시 0을 반환한다. 반환값을 무시하지 않는다.
- Randomization이 실패하면 field는 이전값을 유지한다. 이 값을 정상 transaction으로 사용하면 안 된다.

## 2. rand와 randc

```systemverilog
rand  bit [1:0] a;
randc bit [1:0] b;
```

- `rand`: 매 호출에서 합법적인 값 하나를 선택하며 같은 값이 연속으로 나올 수 있다.
- `randc`: random-cyclic 방식이다. 한 주기 안에서 가능한 값을 한 번씩 사용한 뒤 새 주기를 시작한다.
- `randc`도 주기 경계에서는 같은 값이 연속될 수 있다.

```text
첫 주기:  2, 0, 3, 1
둘째 주기: 1, 3, 0, 2
```

## 3. Constraint는 대입문이 아니라 조건이다

```systemverilog
constraint c_addr {
  addr >= 4;
  addr <= 9;
}
```

Constraint block 안의 식은 기본적으로 AND 관계다.

```text
(addr >= 4) AND (addr <= 9)
가능한 값: 4, 5, 6, 7, 8, 9
```

다음처럼 서로 모순되면 해가 없다.

```systemverilog
constraint c_bad {
  addr >= 4;
  addr < 3;
}
```

Solver는 활성화된 모든 조건을 동시에 만족하는 조합을 찾는다. 코드를 위에서 아래로 실행하며 값을 순서대로 대입하는 방식이 아니다.

## 4. Inline constraint와 inside

```systemverilog
if (!p.randomize() with {
  addr inside {[2:5], 9, [12:14]};
})
  $error("Randomization failed");
```

가능한 값은 `2, 3, 4, 5, 9, 12, 13, 14`다.

```systemverilog
!(addr inside {[2:5], 9, [12:14]});
```

`addr`가 4bit라면 가능한 값은 `0, 1, 6, 7, 8, 10, 11, 15`다.

Inline constraint는 기존 class constraint를 자동으로 대체하지 않는다. 보통 기존 조건에 AND로 추가되며 해당 `randomize()` 호출에만 적용된다.

## 5. dist와 가중치

```systemverilog
mode dist {
  0 := 1,
  1 := 3
};
```

가중치 합이 4이므로 `0`은 25%, `1`은 75%의 확률을 갖는다. 네 번 호출한다고 반드시 1회와 3회로 나뉘는 것은 아니다.

범위에서는 `:=`와 `:/`의 차이가 중요하다.

```systemverilog
value dist {
  0     := 10,
  [1:3] := 30
};
```

`:=`는 범위의 각 값에 weight를 적용한다. Weight는 `10, 30, 30, 30`이고 확률은 `10%, 30%, 30%, 30%`다.

```systemverilog
value dist {
  0     :/ 10,
  [1:3] :/ 30
};
```

`:/`는 범위 전체가 weight를 나눠 갖는다. `[1:3]`의 각 값은 weight 10을 가지므로 네 값의 확률은 각각 25%다.

## 6. Implication과 conditional constraint

```systemverilog
write == 1 -> addr inside {[8:15]};
```

- `write == 1`이면 오른쪽 조건을 반드시 만족한다.
- `write == 0`이면 implication 전체가 참이 되며 이 식은 `addr`를 제한하지 않는다.

양쪽 경우를 모두 제한하려면 conditional constraint를 사용한다.

```systemverilog
if (write)
  addr inside {[8:15]};
else
  addr inside {[0:3]};
```

## 7. solve before

```systemverilog
constraint c_value {
  (kind == 0) -> length == 0;
  (kind == 1) -> length inside {[1:3]};
  solve kind before length;
}
```

`solve before`는 합법적인 조합을 바꾸지 않고 분포에 영향을 준다. 
위 예제에서는 `kind`를 먼저 선택하므로 `kind=0`과 `kind=1`이 각각 약 50%가 된다. 이후 선택된 `kind` 안에서 가능한 `length`가 나뉜다.

```text
P(kind=0, length=0) = 1/2
P(kind=1, length=1) = 1/2 × 1/3 = 1/6
P(kind=1, length=2) = 1/6
P(kind=1, length=3) = 1/6
```

`solve before`는 절차적 실행 순서도 아니고 값의 대입 순서도 아니다.

## 8. soft constraint

```systemverilog
constraint c_default {
  soft addr inside {[0:7]};
}
```

`soft`는 기본 조건이다. 다른 조건이 생겼다고 즉시 사라지는 것이 아니라, 함께 만족할 수 없을 때 우선순위가 높은 조건에 양보한다.

```systemverilog
p.randomize() with { addr inside {[4:11]}; };
```

두 조건의 교집합이 있으므로 soft constraint는 유지되고 최종 범위는 `4~7`이다. 
교집합이 전혀 없다면 hard inline constraint가 유지되고 soft constraint가 제거된다. Class soft와 inline soft가 충돌하면 inline soft가 우선한다.

## 9. rand_mode와 constraint_mode

```systemverilog
p.addr.rand_mode(0);          // addr 값을 새로 뽑지 않음
p.c_addr.constraint_mode(0);  // c_addr 조건을 검사하지 않음
```

두 메서드는 서로 독립적이다. `rand_mode(0)`으로 field를 고정해도 그 field를 참조하는 constraint는 자동으로 꺼지지 않는다.

```systemverilog
p.addr = 12;
p.addr.rand_mode(0);

constraint c_addr {
  addr inside {[0:3]};
}
```

Solver는 `addr`를 변경할 수 없으며 고정된 `12`가 조건을 위반하므로 randomization은 실패한다. 실패 후 `addr`는 12를 유지한다.

```text
rand 활성화   → 현재값을 solver가 변경할 수 있음
rand 비활성화 → 현재값이 고정되며 constraint 검사에는 계속 참여함
```

## 10. pre_randomize와 post_randomize

```systemverilog
function void pre_randomize();
  // 랜덤화 전 mode나 constraint 상태 조정
endfunction

function void post_randomize();
  // 결정된 값으로 파생값 또는 checksum 계산
endfunction
```

호출 흐름은 다음과 같다.

```text
randomize() 호출
→ pre_randomize()
→ constraint solving 및 값 반영
→ 성공 시 post_randomize()
→ 반환
```

`pre_randomize()`에서 rand field에 값을 대입해도 `rand_mode`가 켜져 있으면 solver가 그 값을 다시 바꿀 수 있다. 
두 hook은 function이므로 simulation time을 소비할 수 없다.

## 11. Constraint 상속과 override

부모와 자식의 constraint 이름이 다르면 두 조건이 모두 적용된다.

```systemverilog
class BasePacket;
  rand bit [3:0] addr;
  constraint c_range { addr inside {[2:10]}; }
endclass

class PacketA extends BasePacket;
  constraint c_even { addr % 2 == 0; }
endclass
```

최종 가능한 값은 `2, 4, 6, 8, 10`이다.

자식 class에서 부모와 같은 이름의 constraint block을 선언하면 부모 constraint를 override한다.

```systemverilog
class PacketB extends BasePacket;
  constraint c_range { addr inside {[12:15]}; }
endclass
```

최종 가능한 값은 `12, 13, 14, 15`다.

## 12. Conflicting, over-constrained, under-constrained

| 상태 | 의미 | 결과 또는 위험 |
|---|---|---|
| Conflicting | 조건이 모순되어 해가 없음 | `randomize()` 실패 |
| Over-constrained | 합법적인 상황을 지나치게 제한 | 성공할 수 있지만 검증 다양성 감소 |
| Under-constrained | 필요한 조건이 빠짐 | 합법 범위 밖의 값이나 의도하지 않은 조합 생성 |

Over-constrained가 반드시 실패를 뜻하는 것은 아니다. 
예를 들어 사양상 `1~8`이 모두 합법인데 `length == 4`만 허용하면 해는 있지만 다른 합법적 경우를 검증하지 못한다.

## 13. 실패를 안전하게 처리하기

```systemverilog
if (!item.randomize())
  `uvm_fatal("RANDFAIL", "Item randomization failed")
```

반환값을 무시하면 실패 이전의 값이 driver로 전달될 수 있다. Constraint를 작성한 뒤에는 다음을 확인한다.

1. 값 공간이 의도한 범위인가?
2. 모든 조건을 동시에 만족하는 해가 있는가?
3. 분포가 의도와 일치하는가?
4. 필요 이상으로 합법적 경우를 제외하지 않았는가?
5. 실패를 즉시 보고하고 transaction 전달을 중단하는가?

## 자주 틀렸던 부분

1. 활성화된 `rand` field의 초기값은 solver가 변경할 수 있다.
2. `rand_mode(0)`은 constraint를 끄지 않는다. 고정된 현재값도 활성 constraint를 만족해야 한다.
3. Inline constraint는 기존 hard constraint를 자동으로 override하지 않는다.
4. `soft`는 다른 조건이 추가됐다는 이유만으로 사라지지 않는다. 교집합이 있으면 함께 적용된다.
5. `solve before`는 해의 집합이 아니라 분포를 바꾼다.
6. `dist`의 숫자는 횟수 보장이 아니라 상대적인 weight다.

## 현재 이해도와 다음 단계

- 기본 randomization과 반환값: 3/5
- `inside`, `dist`, implication, conditional: 2~3/5
- `solve before`, `soft`: 2/5
- `rand_mode`, `constraint_mode`, 실패 분석: 2~3/5
- Constraint 상속과 상태 분류: 2~3/5

다음 학습 주제는 4단계 Interface와 simulation timing이다.
