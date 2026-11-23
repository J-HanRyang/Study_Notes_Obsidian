# 1. 하는 일

- SystemVerilog Package는 여러 파일이 공유하는 타입, 상수, 함수와 클래스의 선언을 한 이름 아래 모은다.
- 패키지 안의 선언은 `common_pkg::cfg_t`처럼 소속을 붙여 쓰거나 `import`로 현재 스코프에서 쓸 수 있다.

# 2. import와 include

- `import common_pkg::cfg_t;`는 이미 선언된 `cfg_t` 이름을 현재 스코프에 가져온다.
- `import common_pkg::*;`는 그 패키지의 이름을 필요할 때 찾을 후보로 추가한다.
- 두 패키지에 같은 이름이 있으면 `main_pkg::ID`처럼 소속을 지정해 충돌을 피한다.
- `include`는 전처리기가 해당 위치에 파일의 텍스트를 삽입하는 지시문이다.
- 패키지 안에서 클래스 파일을 `include`하면 삽입된 클래스는 그 패키지에 소속된다.
- 같은 클래스 파일을 두 패키지에 각각 `include`하면 `a_pkg::agent`와 `b_pkg::agent`라는 별개의 타입이 생긴다.
- `.sv`와 `.svh`의 구분은 관리 관례이며 파일에 들어 있는 선언과 컴파일 방식에 따라 적절한 위치가 달라진다.
- 독립된 `module`, `interface`, `package` 선언은 패키지 본문 밖에 둔다.

# 3. main과 sub가 공통 타입을 쓸 때

- `main_pkg`와 `sub_pkg`가 같은 `common_pkg::cfg_t`를 참조하면 TB가 동일한 타입을 양쪽에 전달할 수 있다.
- 예제의 TB는 패키지 소속을 직접 적어서 타입과 함수의 출처를 드러낸다.

```systemverilog
// common_pkg.sv
package common_pkg;
  typedef struct packed {
    logic [7:0] address;
  } cfg_t;
endpackage

// main_pkg.sv
package main_pkg;
  import common_pkg::cfg_t;

  function automatic cfg_t default_cfg();
    cfg_t cfg;
    cfg.address = 8'h10;
    return cfg;
  endfunction
endpackage

// sub_pkg.sv
package sub_pkg;
  import common_pkg::cfg_t;

  function automatic bit accepts(cfg_t cfg);
    return cfg.address == 8'h10;
  endfunction
endpackage

// tb.sv
module tb;
  common_pkg::cfg_t cfg;
  initial begin
    cfg = main_pkg::default_cfg();
    assert (sub_pkg::accepts(cfg));
  end
endmodule
```

- 파일 목록의 기본 순서는 `common_pkg.sv → main_pkg.sv·sub_pkg.sv → tb.sv`다.
- `main_pkg`가 `cfg_t`를 import한 사실만으로 TB의 `import main_pkg::*;`에 그 이름이 자동으로 전달되지는 않는다.
- 중간 패키지가 공통 이름을 공개해야 할 때는 명시적으로 import한 이름에 `export common_pkg::cfg_t;`를 적용할 수 있다.
- main과 sub가 서로를 import해야 하는 구조가 생기면 공유 선언이 어느 패키지로 빠져야 의존성이 한 방향이 되는지 먼저 확인한다.

# 4. 클래스 파일과 전처리 조건 관리

- 예를 들어 `dv_pkg.sv`를 파일 목록에서 컴파일하고 내부의 `driver.svh`는 그 패키지 안에서 한 번만 포함한다.
- `include`를 찾는 경로는 파일 검색에 쓰이며 패키지 선언의 컴파일 순서와 별개다.
- Include Guard는 같은 전처리 문맥에서 파일 텍스트가 반복 삽입되는 것을 막는 용도다.
- Guard 이름은 파일별로 고유하게 정하고 같은 패키지가 파일 목록에 중복 등록됐는지도 별도로 확인한다.
- `ifdef`가 `include`나 `import` 대상을 바꾸면 빌드 옵션과 최종 선택된 파일을 함께 기록한다.
- 타입을 찾지 못하면 파일 목록, 패키지 선언 순서, 해당 스코프의 `import` 순으로 확인한다.
- 이름이 충돌하면 선언 위치와 포함 경로를 확인하고 사용할 패키지 소속을 명시한다.

## 4.1. TB와 Sequence의 순환 의존성 풀기

- 공통 타입은 types_pkg에 두고 설정 클래스는 필요한 타입을 가져오는 cfg_pkg에 둔다.
- tb_pkg가 환경과 virtual sequencer를 정의하면 tb_seq_pkg가 그 타입을 가져와 시나리오를 작성할 수 있다.
- tb_pkg 안의 test가 다시 tb_seq_pkg의 sequence를 생성하면 서로 상대 패키지를 먼저 컴파일해야 하는 순환이 생긴다.
- test를 별도 test_pkg로 옮긴 예의 컴파일 순서는 `types_pkg → cfg_pkg → tb_pkg → tb_seq_pkg → test_pkg`다.

## 4.2. 타입 이름과 입력 데이터

```systemverilog
module decoder(input def::ins iw, output logic selected);
  assign selected = iw.a;
endmodule
```

- def::ins는 구조체 타입이고 iw는 모듈 인스턴스가 실제로 받는 값이다.
- 타입을 import하면 선언에서 ins라는 짧은 이름을 쓸 수 있으며 필드는 iw.a로 읽는다.
