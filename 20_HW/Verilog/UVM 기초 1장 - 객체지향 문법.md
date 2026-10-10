---
tags:
  - class
  - object
  - handle
  - inheritance
  - polymorphism
cssclasses:
  - uvm-study-note
---

#class #object #handle #inheritance #polymorphism

# **1. 소개**

- SystemVerilog 검증 코드는 class로 데이터와 동작을 묶는다.
- 설계도인 class, 생성된 object, 이를 참조하는 handle을 구분하면 상속과 UVM의 객체 전달을 이해할 수 있다.

# **2. 구조와 흐름**
![객체지향 문법 구조](assets/uvm-book/chapter01.png)

# **3. 핵심 개념**

## **3.1. class, object, handle, constructor**

- `class`: property와 method를 정의하는 설계도.
- `object`: `new()`로 생성된 class의 실제 instance.
- `handle`: object를 가리키는 변수.  
  handle 선언만으로 object가 생성되지는 않는다.
- `function new(...)`: object 생성 시 실행되는 constructor.  
  직접 정의하지 않아도 기본 `new()`로 object를 만들 수 있지만, 초기화 동작이 필요하면 작성한다.
- `null` handle로 property나 method에 접근하면 안 된다.

```systemverilog
class Packet;
  int data;
  function new(int value = 5);
    data = value;
  endfunction
endclass

Packet p;
// 여기서 p는 null: object는 아직 없다.
p = new(10);
```

- `Packet p;`의 `p`는 object가 아니라 handle이다.
- `p = new(10);`에서 object가 하나 생성되고 `p`가 그 object를 가리킨다.

### **Class와 module의 생성·실행 차이**

- Module/interface instance는 elaboration에서 만들어진 HDL 구조이고, class object는 실행 중 constructor로 생성한다.
- Class 안의 task는 object를 만들었다고 자동 실행되지 않는다.
- 호출한 process에서 수행하며, 병렬 실행에는 fork 등 별도 process가 필요하다.
- Class에 module의 initial/always를 그대로 넣는 방식으로 실행을 구성하지 않는다.

### **Handle 배열도 element마다 생성이 필요하다**

```systemverilog
Packet packets[3]; // handle 3개: 각각 null
foreach (packets[i]) packets[i] = new();
```

- Queue나 array에 class type을 담아도 저장되는 것은 handle이다.
- Container 대입·추가가 내부 object의 deep copy를 의미하지는 않는다.
- 이 규칙은 mailbox, UVM analysis 통신과 7장의 copy/clone에도 이어진다.

## **3.2. handle assignment와 object copy**

![핵심 개념 그림 1](assets/uvm-book/chapter01-concept1.png)

```systemverilog
Packet a, b;
a = new(10);
b = a;       // handle assignment: 새 object 없음
b.data = 20; // a.data도 20으로 관찰됨
a = new(30); // 두 번째 object 생성. b는 첫 object를 계속 가리킴
```

- `b = a`는 값이 담긴 object의 복사가 아니라 handle 값의 대입이다.
- 여러 handle이 같은 object를 가리킬 수 있다.
- 반대로 `a = null`은 `a`의 연결만 끊으며, 같은 object를 가리키는 다른 handle에는 영향을 주지 않는다.

### **Shallow copy와 deep copy**

```systemverilog
class Header;
  int id;
endclass

class Frame;
  int data;
  Header hdr;
endclass

Frame x, y;
x = new();
x.hdr = new();
y = new x; // 바깥 Frame은 새 object, 내부 hdr handle은 공유
```

| 연산          | 바깥 `Frame`   | 내부 `Header`           |
| ----------- | ------------ | --------------------- |
| `y = x`     | 같은 object 공유 | 같은 object 공유          |
| `y = new x` | 새 object 생성  | handle만 복사되어 공유       |
| deep copy   | 새 object 생성  | `new()`로 별도 생성하고 값 복사 |

```systemverilog
y = new();
y.data = x.data;
y.hdr = new();
y.hdr.id = x.hdr.id; // int 값 복사; Header handle은 변경되지 않음
```

- `y.hdr.id = x.hdr.id`는 `int` 값 복사이고, `y.hdr = x.hdr`는 handle assignment이다.
- 이미 `y.hdr = new()`를 했어도 뒤에서 `y.hdr = x.hdr`를 하면 다시 내부 object를 공유한다.

## **3.3. inheritance, overriding, polymorphism**

![핵심 개념 그림 2](assets/uvm-book/chapter01-concept2.png)

```systemverilog
class Transaction;
  int id;
  virtual function void print();
    $display("base id=%0d", id);
  endfunction
endclass

class WriteTransaction extends Transaction;
  int data;
  function void print();
    $display("write id=%0d data=%0d", id, data);
  endfunction
endclass
```

- `extends`: 자식 class가 부모의 property와 method를 상속한다.  
  `WriteTransaction`은 `id`, `data`, `print()`를 사용할 수 있지만, 부모 `Transaction`이 자식 고유의 `data`를 갖는 것은 아니다.
- overriding: 자식이 부모와 같은 method를 다시 정의한다.  
  **부모 class의 구현 자체를 수정하지 않는다.**
- 일반적인 의미의 overloading은 같은 이름에 서로 다른 인자 구성을 두는 것이지만, SystemVerilog는 일반적인 method overloading을 지원하지 않는다.
- 부모 type의 handle은 자식 object를 가리킬 수 있다.  
  단, handle assignment가 object를 새로 생성하지는 않는다.

```systemverilog
Transaction t;
WriteTransaction w;
w = new();
w.id = 3;
w.data = 42;
t = w;
t.print();
```

| 부모 `print()` 선언 | method 선택 기준 | 위 코드의 `t.print()` |
|---|---|---|
| `virtual` 없음 | 호출에 사용한 handle type | 부모 `print()` |
| `virtual` 있음 | 실제 object type | 자식 `print()` |

- `t`의 handle type은 `Transaction`, 실제 object type은 `WriteTransaction`이다.
- 두 type을 구분하는 것이 polymorphism을 이해하는 핵심이다.

### **abstract class와 pure virtual method**

```systemverilog
virtual class Transaction;
  pure virtual function void print();
endclass

class WriteTransaction extends Transaction;
  function void print();
    $display("write");
  endfunction
endclass
```

- `pure virtual`은 부모에 method 구현을 두지 않고 구체적인 자식 class가 구현하도록 요구한다.
- 이를 선언하는 부모는 `virtual class`여야 하며 직접 `new()`로 생성할 수 없다.
- 부모 type의 handle 선언은 가능하고, 자식 object를 가리키게 한 뒤 `print()`를 호출할 수도 있다.
- 중간 자식도 `virtual class`로 남아 구현을 더 아래 자식에게 미룰 수 있다.

### **Downcast와 $cast**

- 부모 handle로 자식 object를 참조할 수 있지만, 자식 고유 field를 사용할 때는 해당 type의 handle이 필요하다.
- `$cast(child, parent)`는 실제 object가 호환되는 type인지 확인하고 handle을 대입한다.
- 새로운 object나 복사본을 만들지 않는다.
- 반환값을 확인한 뒤 child에 접근한다.

## **3.4. parameterized class**

```systemverilog
class Box #(type T = int);
  T value;
endclass

Box#(int)    numbers;
Box#(string) words;
Box          default_box; // T의 기본값 int 사용
```

- type parameter를 두면 동일한 class 구조를 여러 데이터 type에 재사용할 수 있다.
- `T = int`는 `int`만 허용한다는 뜻이 아니라 type을 생략했을 때의 기본값이다.
- `Box#(int)`와 `Box#(string)`은 서로 다른 class type이므로 두 handle을 그대로 대입할 수 없다.
- `words.value = "12"` 같은 property 대입과 `words = numbers` 같은 handle 대입은 별개다.

## **3.5. static property와 static method**

![핵심 개념 그림 3](assets/uvm-book/chapter01-concept3.png)

```systemverilog
class Packet;
  static int count = 0;
  int id;

  function new();
    count++;
    this.id = count;
  endfunction

  static function int get_count();
    return count;
  endfunction
endclass
```

- `id`: 각 object마다 따로 존재하는 instance property.
- `static count`: class에서 공유하는 property.  
  `Packet::count`로 접근할 수 있다.
- `static get_count()`: object 없이도 `Packet::get_count()`로 호출할 수 있다.
- handle 선언만으로는 constructor가 실행되지 않는다.  
  `new()`가 실행될 때 이 예제의 `count++`와 `id = count`가 수행된다.
- 이미 저장된 `id`는 나중에 `count`를 수정해도 자동으로 바뀌지 않는다.

## **3.6. 접근 제한자**

| property 선언 | 같은 class | 자식 class | class 밖 |
|---|---|---|---|
| `int data;` | 가능 | 가능 | 가능 |
| `protected int data;` | 가능 | 가능 | 불가능 |
| `local int data;` | 가능 | 불가능 | 불가능 |

- 외부에서 직접 수정하지 못하게 하려면 `local` 또는 `protected`로 제한하고 공개 method를 제공할 수 있다.
- 자식이 내부 property에 직접 접근해야 하는 설계라면 `protected`가 해당된다.

### **Const, forward declaration, extern**

- Instance constant는 constructor에서 초기화해 object마다 다른 고정값을 갖게 할 수 있다.
- `typedef class Header;`는 뒤에서 정의할 class type을 먼저 알리는 선언이며 object를 생성하지 않는다.
- `extern`은 method 선언과 구현 위치를 나누는 문법으로, factory 등록과는 별개의 역할이다.

## **3.7. `this`와 `super`**

```systemverilog
class Transaction;
  int id;
  function new(int id);
    this.id = id;
  endfunction
endclass

class WriteTransaction extends Transaction;
  int data;
  function new(int id, int data);
    super.new(id);
    this.data = data;
  endfunction
endclass
```

- `this`: 현재 method가 실행 중인 object 자신.  
  `this.data = data`에서 왼쪽은 object의 property, 오른쪽은 argument.
- `super`: “부모 object”가 아니라 부모 class에 정의된 member를 명시적으로 참조할 때 사용한다.  
  `super.new(id)`는 부모 constructor를 호출해 부모가 정한 초기화 절차를 재사용한다.
- 자식 object는 부모의 `id`를 상속받아 가지고 있다.  
  `super.new(id)`를 쓰는 이유는 자식에게 `id`가 없어서가 아니다.

### **Method overriding과 factory override**

- Method overriding은 자식의 method 구현을 선택하는 문제이고, factory override는 생성할 object type을 선택하는 문제다.
- 두 경우 모두 handle type과 실제 object type을 구분해야 한다.
- `super.do_compare()`는 같은 두 객체의 부모 구현을 호출해 상속된 field를 비교하는 것이며, 별도의 부모 객체를 비교하는 것이 아니다.

# **4. 핵심 예제**

```systemverilog
Packet a, b;
a = new(10);
b = a;
b.data = 20;
// a.data도 20: 같은 객체를 참조
a = new(30);
// b는 기존 객체를 계속 참조
```

- 첫 new() 뒤에는 객체 하나를 공유한다.
- 두 번째 new()는 새 객체를 만들고 a만 그 객체를 참조하게 한다.

![핵심 예제의 동작](assets/uvm-book/chapter01-example.png)

# **5. 주의점**

- Handle 대입은 객체 복사가 아니다.
- 상속 관계와 생성된 객체 사이의 포함 관계를 구분한다.
- 부모 handle로 자식 전용 멤버를 사용하려면 성공한 $cast 결과가 필요하다.

# **6. 핵심 정리**

- **Class / object / handle**: class는 설계도, object는 실체, handle은 참조다.  
  선언만 한 handle은 null이며 new()가 객체를 만든다.
- **공유와 복사**: b = a는 handle 대입이다.  
  얕은 복사는 중첩 handle을 공유하고, 깊은 복사는 내부 객체까지 독립시킨다.
- **상속과 다형성**: extends는 클래스 상속이다.  
  virtual 메서드는 handle의 선언 타입보다 실제 객체 타입에 따라 구현을 선택한다.
- **추상·매개변수 클래스**: virtual class는 직접 생성할 수 없다.  
  type parameter를 사용하면 같은 구조를 서로 다른 자료형에 적용한다.
- **Static과 접근 제한**: static 속성은 클래스에서 공유한다.  
  local은 클래스 내부, protected는 내부와 자식 클래스에서 접근한다.
- **this / super**: this는 현재 객체다.  
  super는 부모 클래스의 구현을 참조하며 별도 부모 객체를 만드는 표현이 아니다.

# **7. 확인 문제와 해설**

## **문제 1**

a = new(); b = a; 이후 객체는 몇 개인가?

- **해설:** 하나다.
- 두 handle이 같은 객체를 참조한다.

## **문제 2**

폭 8과 폭 16의 매개변수 클래스는 같은 타입인가?

**해설:** 서로 다른 specialization 타입이다.

## **문제 3**

부모 handle의 virtual 호출은 무엇을 기준으로 선택하는가?

**해설:** 실제 객체 타입의 구현을 선택한다.

# **8. 참고 자료**

- IEEE 1800 SystemVerilog의 class·자료형·randomization·timing 문법
- [UVM 1.2 Class Reference](https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.2/html/)

[목차](<UVM 기초 - 목차.md>)
