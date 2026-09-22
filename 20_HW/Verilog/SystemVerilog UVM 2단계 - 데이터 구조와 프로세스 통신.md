# SystemVerilog/UVM 2단계 — 데이터 구조와 Process 통신

> 학습 범위: packed/unpacked array, fixed/dynamic array, queue, associative array, enum, struct, typedef, process/thread, fork-join, event, semaphore, mailbox. 코드는 개념 설명용이며 simulator에서 실행해 검증한 결과는 아니다.

## 1. Packed array와 unpacked array

Dimension이 변수 이름 **앞**에 있으면 packed, **뒤**에 있으면 unpacked다.

```systemverilog
bit [7:0] a;       // 8-bit packed vector
bit b [7:0];       // 1-bit element 8개인 unpacked array
bit [3:0][7:0] c;  // 32-bit packed array
bit [7:0] d [3:0]; // 8-bit packed element 4개인 unpacked array
```

```systemverilog
logic [7:0] memory [0:15];
```

- `memory`: `logic [7:0]` element 16개
- `memory[3]`: type은 `logic [7:0]`, 폭은 8bit
- `memory[3][2]`: 네 번째 element의 bit 2
- packed는 vector처럼 bit 연산과 slicing에 적합하다.
- unpacked는 여러 element를 배열로 관리하는 데 적합하다.

## 2. Fixed array와 dynamic array

```systemverilog
int fixed_array[4];
int dynamic_array[];
```

- Fixed array: 선언할 때 element 수가 고정된다.
- Dynamic array: 선언 직후 크기는 0이며 runtime에 `new[n]`으로 할당한다.
- `int`는 element type이고, `[4]` 또는 `new[4]`는 element 수다. 폭과 array 크기를 혼동하지 않는다.

```systemverilog
int values[];

values = new[3];
values[0] = 10;
values[1] = 20;
values[2] = 30;

values = new[5](values); // 기존 값을 보존하며 크기 변경
values.delete();         // size를 0으로 만듦
```

- `new[5]`: 새 배열을 할당하며 기존 값 보존을 기대하면 안 된다.
- `new[5](values)`: 기존 값을 앞에서부터 복사하고 추가된 `int` element는 0으로 초기화한다.
- `values.size()`: 현재 element 수를 반환한다.

## 3. Queue

Queue는 양쪽 끝에서 element를 추가·제거하기 편한 가변 크기 자료구조다.

```systemverilog
int q[$];

q.push_back(10);  // {10}
q.push_back(20);  // {10, 20}
q.push_front(5);  // {5, 10, 20}

int a = q.pop_front(); // a=5, q={10,20}
int b = q.pop_back();  // b=20, q={10}
```

- `q[0]`: 첫 element를 제거하지 않고 읽는다.
- `q[$]`: 마지막 element를 제거하지 않고 읽는다.
- `pop_*()`은 값을 반환하면서 queue에서 제거한다.
- Scoreboard의 in-order expected transaction 대기열 등에 적합하다.

## 4. Associative array

사용한 key에 대해서만 element가 존재하는 sparse 자료구조다.

```systemverilog
int score_by_id[int];       // value type=int, key type=int
int score_by_name[string];  // value type=int, key type=string

score_by_id[10] = 95;
score_by_id[42] = 80;
```

주요 method:

```systemverilog
score_by_id.exists(10); // key 존재 여부
score_by_id.num();      // element 수
score_by_id.delete(10); // 특정 key 삭제
score_by_id.delete();   // 전체 삭제
```

기존 key에 다시 대입하면 element 수가 늘지 않고 값만 덮어쓴다. 
Transaction ID를 이용하는 out-of-order scoreboard matching 등에 적합하다.

## 5. Enum, typedef, struct

### Enum과 typedef

```systemverilog
typedef enum logic [1:0] {
  IDLE  = 2'b00,
  READ  = 2'b01,
  WRITE = 2'b10,
  ERROR = 2'b11
} state_t;
```

- `enum`: 서로 관련된 named value 집합을 하나의 type으로 정의한다.
- `typedef`: 그 type에 재사용할 이름 `state_t`를 부여한다.
- `state.name()`으로 현재 enum 이름을 문자열로 얻을 수 있다.
- `parameter`도 값에 이름을 붙이지만, enum은 named value의 집합과 type을 만든다는 점이 다르다.

### Struct

```systemverilog
typedef struct {
  bit [7:0]  address;
  bit [31:0] data;
  bit        write;
} bus_item_t;
```

Struct는 관련 field를 하나의 value로 묶는다. 
Struct variable 대입은 class handle assignment와 달리 field 값 복사다.

```systemverilog
bus_item_t a, b;
b = a;
b.data = 32'h1234; // a.data에는 영향 없음
```

`struct packed`은 모든 field를 연속된 packed vector처럼 배치한다.

```systemverilog
typedef struct packed {
  bit [3:0]  opcode;
  bit [7:0]  address;
  bit [15:0] data;
} packet_t; // 총 28bit
```

선언 순서대로 `opcode`가 MSB 쪽, `data`가 LSB 쪽에 배치된다.

## 6. Process, thread, fork-join

`fork` 안의 각 statement는 별도의 child thread로 동시 진행된다.

| 문법 | Parent가 기다리는 조건 | 남은 child thread |
|---|---|---|
| `join` | 모든 child 종료 | 없음 |
| `join_any` | 하나의 child 종료 | 계속 실행 |
| `join_none` | 기다리지 않음 | 계속 실행 |
| `wait fork` | 모든 child 종료 | 완료될 때까지 대기 |
| `disable fork` | 기다림 기능이 아님 | 활성 child를 종료 |

`join_any`는 남은 thread를 자동으로 종료하지 않는다.

```systemverilog
fork
  forever begin
    #10;
    monitor();
  end
  begin
    #105;
  end
join_any

disable fork; // forever monitor 종료
```

`join_none`으로 생성한 child는 parent가 처음 멈추거나 종료될 때 실행을 시작한다. Zero-time 코드의 순서를 분석할 때 주의한다.

## 7. Event

Event는 데이터를 저장하지 않고 어떤 일이 발생했다는 사실만 알린다.

```systemverilog
event done;

-> done; // trigger
@done;   // 다음 trigger 대기
```

`@done`이 대기를 시작하기 전에 trigger가 이미 지나가면 event가 유실될 수 있다. 
Event는 과거 trigger 횟수를 queue처럼 기억하지 않는다. 
`done.triggered`는 같은 time slot의 race 완화에는 도움이 되지만 이전 simulation time의 trigger를 복구하지는 않는다.

## 8. Semaphore

Semaphore는 제한된 수의 key로 공유 자원 접근을 제어한다.

```systemverilog
semaphore bus_lock = new(1);

bus_lock.get(1); // key가 없으면 기다림
// shared bus 사용
bus_lock.put(1); // key 반환
```

- `get(n)`: blocking. key가 충분할 때까지 기다린다.
- `try_get(n)`: nonblocking. 성공하면 1, 실패하면 0을 즉시 반환한다.
- `put()` 누락 시 다른 thread가 계속 기다리는 deadlock이 발생할 수 있다.
- 동일 시점에 경쟁하는 thread 중 누가 먼저 key를 얻는지는 코드만으로 단정하지 않는다.

## 9. Mailbox

Mailbox는 producer와 consumer 사이에서 데이터를 안전하게 전달하는 synchronized communication 수단이다.

```systemverilog
mailbox #(int) mbx = new(2); // int 전용, 용량 2
```

| Method | 빈 상태 또는 가득 찬 상태 | 값 제거 |
|---|---|---|
| `put()` | 가득 차면 기다림 | 해당 없음 |
| `try_put()` | 가득 차면 즉시 0 | 해당 없음 |
| `get()` | 비면 기다림 | 제거함 |
| `try_get()` | 비면 즉시 0 | 성공 시 제거 |
| `peek()` | 비면 기다림 | 제거하지 않음 |
| `try_peek()` | 비면 즉시 0 | 제거하지 않음 |

`mailbox #(int)`에는 `int`만 넣을 수 있다. 
`peek()`과 `try_peek()`의 차이는 제거 여부가 아니라 blocking 여부다.

## 10. 도구 선택 기준

| 상황 | 적합한 도구 |
|---|---|
| 한 component 안에서 순서대로 저장·제거 | Queue |
| Process 사이 producer-consumer 데이터 전달 | Mailbox |
| 발생 사실만 알림 | Event |
| 공유 자원의 동시 접근 제한 | Semaphore |
| 연속되지 않은 ID 기반 조회 | Associative array |

Shared variable이나 queue만 여러 thread가 함께 사용하면 대기·깨우기·동시 접근 정책을 직접 구현해야 한다. 
Mailbox와 semaphore는 이 동기화 의도를 명시적으로 표현한다.

## 자주 틀렸던 부분

1. `logic [7:0] mem [0:15]`에서 `mem[3]`은 16개 array가 아니라 8bit element 하나다.
2. Struct의 field를 enum 값으로 오해하지 않는다. Field는 선언된 자기 type의 값을 저장한다.
3. `peek()`도 mailbox가 비면 기다리는 blocking method다.
4. `try_get()`과 `try_put()`의 반환값은 실제 획득/저장 성공 여부다.
5. `join_any`는 남은 child를 종료하지 않는다. 필요한 경우 `disable fork`를 사용한다.

## 현재 이해도와 다음 단계

- 배열과 자료구조: 2~3/5
- enum, struct, typedef: 2/5
- process와 fork-join: 3/5
- event, semaphore, mailbox: 2~3/5

다음 학습 주제는 3단계 Randomization과 constraint다.
