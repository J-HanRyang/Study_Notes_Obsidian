# SystemVerilog/UVM 6단계 - `uvm_object`와 `uvm_component`

> 학습 범위: UVM class를 object 계열과 component 계열로 분류하고, 각 계열의 hierarchy, parent, phase, 수명, 역할, constructor 차이를 이해한다.

## 1. 이번 단계의 핵심

UVM class는 크게 두 부류로 나눠 이해할 수 있다.

```text
uvm_object 계열
→ transaction과 sequence처럼 전달되거나 실행되는 대상

uvm_component 계열
→ testbench hierarchy를 구성하고 simulation 동안 역할을 수행하는 구성 요소
```

간단한 판단 기준은 다음과 같다.

- hierarchy 안에 고정된 위치가 필요한가?
- component의 parent가 필요한가?
- UVM phase scheduler가 method를 호출해야 하는가?
- transaction처럼 필요할 때 만들고 처리하는 대상인가?

## 2. `uvm_object` 계열

대표적인 object 계열 class는 다음과 같다.

```text
uvm_object
└─ uvm_transaction
   └─ uvm_sequence_item
      ├─ bus_item 같은 transaction
      └─ uvm_sequence_base
         └─ uvm_sequence
            └─ write_sequence 같은 sequence
```

상속 구조는 UVM 버전과 class 종류에 따라 더 세부적일 수 있다. 여기서는 sequence item과 sequence가 모두 `uvm_object` 계열이라는 점이 중요하다.

### `uvm_sequence_item`

한 번의 요청이나 전송을 표현하는 transaction의 기반 class다.

```systemverilog
class bus_item extends uvm_sequence_item;
  rand bit       write;
  rand bit [7:0] addr;
  rand bit [7:0] data;

  function new(string name = "bus_item");
    super.new(name);
  endfunction
endclass
```

`bus_item`은 “무슨 동작을 할지”를 담는다. Protocol pin timing은 보통 driver가 담당한다.

### `uvm_sequence`

Transaction을 만들고 어떤 순서로 보낼지 표현하는 시나리오의 기반 class다.

```systemverilog
class write_sequence extends uvm_sequence #(bus_item);
  task body();
    // bus_item을 만들어 전송하는 시나리오
  endtask
endclass
```

Sequence는 UVM class이지만 component hierarchy에 들어가지 않는다. 생성만으로 `body()`가 실행되는 것도 아니다. Sequence를 `start(sequencer)`해야 시나리오가 실행된다.

### Object 계열 특징

- component hierarchy에 속하지 않는다.
- component parent를 갖지 않는다.
- UVM phase scheduler가 `build_phase()`나 `run_phase()`를 자동 호출하지 않는다.
- 필요한 시점에 만들고 전달·처리할 수 있다.
- 이름이 있어도 component instance path가 생기지는 않는다.

## 3. `uvm_component` 계열

대표적인 component 계열 class는 다음과 같다. 아래 목록은 계열을 보여주기 위한 것으로 중간 상속 class를 생략했다.

```text
uvm_component
├─ uvm_test
├─ uvm_env
├─ uvm_agent
├─ uvm_sequencer
├─ uvm_driver
├─ uvm_monitor
├─ uvm_scoreboard
└─ uvm_subscriber
```

이 class들은 모두 component 계열이지만 서로가 모두 부모·자식 class인 것은 아니다. 각 class가 `uvm_component`를 바탕으로 서로 다른 역할을 제공한다.

### Component hierarchy 예

```text
uvm_test_top
└─ env
   ├─ agent
   │  ├─ sequencer
   │  ├─ driver
   │  └─ monitor
   └─ scoreboard
```

이 hierarchy는 component 생성 때 parent 관계를 전달하여 만든다. 생성된 driver는 agent 객체 아래에 배치된다.

Component는 보통 환경 구성 중 생성되어 simulation 동안 유지되고 phase에 참여한다.

## 4. 상속 관계와 hierarchy 배치 관계

이 둘은 서로 다른 관계다.

### Class 상속 관계

```systemverilog
class bus_driver extends uvm_driver #(bus_item);
```

`extends`는 class 설계도 사이의 상속을 표현한다.

```text
bus_driver class → uvm_driver class의 기능을 상속
```

### 생성된 component의 부모·자식 관계

```systemverilog
driver = bus_driver::type_id::create("driver", this);
```

이 코드가 agent 안에 있다면 `this`는 현재 agent 객체다. 생성된 driver component는 해당 agent의 자식으로 배치된다.

```text
bus_agent object
└─ bus_driver object
```

따라서 “driver가 agent 아래에 있다”는 사실만으로 driver class가 agent class를 상속하는 것은 아니다.

## 5. Constructor 인수 차이

Object constructor는 보통 이름만 받는다.

```systemverilog
function new(string name = "bus_item");
  super.new(name);
endfunction
```

Component constructor는 이름과 parent를 받는다.

```systemverilog
function new(string name, uvm_component parent);
  super.new(name, parent);
endfunction
```

- `name`: 생성할 object 또는 component의 이름
- `parent`: hierarchy에서 component를 포함할 상위 component 객체

Transaction에는 component hierarchy 위치가 없으므로 parent가 필요 없다. Driver, monitor, agent 등은 hierarchy에 놓여야 하므로 parent가 필요하다.

중요한 표현 차이:

```text
parent는 bus_env class 자체가 아니다.
parent는 실제로 생성된 bus_env 객체(this)다.
```

최상위 test는 상위 component가 없으므로 일반적으로 parent가 `null`이다. 그 아래 component는 상위 component 객체를 parent로 받는다.

## 6. 이름과 instance path

Component 생성에서 class 이름과 instance 이름을 구분한다.

```systemverilog
bus_driver::type_id::create("driver", this);
```

```text
bus_driver → class type
"driver"   → 생성되는 component instance 이름
this       → parent component 객체
```

Environment의 경로가 `uvm_test_top.env`라면 위 driver의 경로는 다음과 같다.

```text
uvm_test_top.env.agent.driver
```

같은 parent 아래에 같은 instance 이름의 component를 중복 생성하면 경로가 충돌한다. 두 agent는 다른 이름을 사용해야 한다.

```systemverilog
agent0 = bus_agent::type_id::create("agent0", this);
agent1 = bus_agent::type_id::create("agent1", this);
```

Transaction object는 component hierarchy에 등록되지 않으므로 이름이 같아도 이 component 경로 충돌은 발생하지 않는다.

## 7. Phase와 실행 방식

UVM은 component hierarchy에 있는 component의 phase method를 정해진 순서로 호출한다.

```text
build_phase()   → component 구성과 설정
connect_phase() → 통신 연결
run_phase()     → 시간에 따른 동작
```

Driver와 monitor의 `run_phase()`는 UVM이 실행한다. Sequence는 component가 아니므로 `run_phase()`가 자동 호출되지 않는다.

```text
driver 생성
→ component hierarchy에 등록
→ UVM이 driver.run_phase() 호출

sequence 생성
→ 아직 시나리오는 실행되지 않음
→ sequence.start(sequencer)
→ sequence.body() 실행
```

Sequence의 `body()`는 component phase와 별개의 sequence 실행 method다.

## 8. 역할과 계열 한눈에 보기

| Class 또는 대상 | 계열 | Hierarchy | 핵심 역할 |
|---|---|---:|---|
| `bus_item` | `uvm_object` | 없음 | transaction 한 건의 데이터 |
| `write_sequence` | `uvm_object` | 없음 | transaction 생성과 시나리오 순서 |
| `bus_sequencer` | `uvm_component` | 있음 | sequence 요청을 중재하고 item 전달 |
| `bus_driver` | `uvm_component` | 있음 | transaction을 pin 동작으로 변환 |
| `bus_monitor` | `uvm_component` | 있음 | 실제 pin을 관찰해 transaction 복원 |
| `bus_agent` | `uvm_component` | 있음 | 한 protocol의 구성 요소 묶음 |
| `bus_env` | `uvm_component` | 있음 | agent, scoreboard 등의 검증환경 구성 |
| `bus_test` | `uvm_component` | 있음 | 사용할 환경과 시나리오 선택 |
| `bus_scoreboard` | `uvm_component` | 있음 | expected와 actual 비교 |
| Coverage subscriber | `uvm_component` | 있음 | transaction을 받아 coverage 기록 |

## 9. 자주 혼동한 부분

1. Sequence는 UVM class이지만 component hierarchy에는 없다.
2. Sequencer는 sequence들의 집합이 아니라 item 전달을 중재하는 component다.
3. Sequence는 `body()`가 실행되고, driver는 UVM phase의 `run_phase()`에 참여한다.
4. Object constructor에는 component parent가 없고 component constructor에는 parent가 있다.
5. `extends`는 class 상속이고, `create(..., this)`는 생성된 component의 hierarchy 배치다.
6. `create()`는 이름이 같은 기존 객체를 찾아 반환하는 기능이 아니다. 중복 component 이름은 hierarchy 충돌을 일으킨다.
7. Scoreboard는 driver가 보내려 한 transaction이 아니라 monitor가 실제 interface에서 관찰한 transaction을 받아 비교하는 것이 일반적이다.
8. Coverage subscriber는 coverage를 기록하며 correctness의 최종 판정은 보통 scoreboard가 담당한다.

## 10. 이해도와 다음 단계

현재 이해도: **3/5**

- 예제를 보고 object와 component를 분류할 수 있다.
- Constructor의 name/parent 차이를 설명할 수 있다.
- Class 상속과 component hierarchy 배치 관계를 구분할 수 있다.
- Sequence의 `body()`와 component의 phase 실행 차이를 설명할 수 있다.
- 다음에는 class 계열과 생성 방식을 더 정확히 연결하면 된다.

다음 학습 주제는 **7단계 Factory와 utility macro**다.
