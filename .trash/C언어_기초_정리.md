---
date: 2026-05-24
tags:
  - C언어
  - 기초
---

## 목차

1. [[#1단계 기초 문법]]
2. [[#2단계 제어문]]
3. [[#3단계 함수]]
4. [[#4단계 배열과 문자열]]
5. [[#5단계 포인터]]
6. [[#6단계 메모리 관리]]
7. [[#7단계 구조체]]

---

## 1단계: 기초 문법

### 자료형

| 자료형 | 크기 | 설명 | 예시 |
|--------|------|------|------|
| `int` | 4바이트 | 정수 | `int a = 10;` |
| `float` | 4바이트 | 실수 (소수점 6자리) | `float b = 3.14;` |
| `double` | 8바이트 | 실수 (소수점 15자리) | `double c = 3.14159;` |
| `char` | 1바이트 | 문자 1개 | `char d = 'A';` |

### 입출력

```c
// 출력 — printf
printf("%d\n", a);    // 정수
printf("%.2f\n", b);  // 실수 소수점 2자리
printf("%c\n", d);    // 문자
printf("%s\n", str);  // 문자열

// 입력 — scanf (&를 빠뜨리면 안 됨!)
int x;
scanf("%d", &x);
```

#### 형식 지정자

| 지정자 | 타입 |
|--------|------|
| `%d` | int |
| `%f` | float |
| `%lf` | double |
| `%c` | char |
| `%s` | 문자열 |

### Python vs C 핵심 차이

| 항목 | Python | C |
|------|--------|---|
| 변수 선언 | `x = 10` | `int x = 10;` |
| 정수 나눗셈 | `10 / 3 = 3.333...` | `10 / 3 = 3` (정수!) |
| 논리 연산자 | `and`, `or`, `not` | `&&`, `\|\|`, `!` |
| 블록 구분 | 들여쓰기 | `{ }` |

> [!warning] 정수 나눗셈 주의
> C에서 `int / int = int`라 소수점이 버려진다.
> 실수 결과가 필요하면 `(float)a / b` 로 형변환.

---

## 2단계: 제어문

### if / else if / else

```c
int score = 85;

if (score >= 90) {
    printf("A학점\n");
} else if (score >= 80) {
    printf("B학점\n");  // 출력됨
} else {
    printf("F학점\n");
}
```

> Python의 `elif` → C에서는 `else if`

### switch

```c
int day = 3;
switch (day) {
    case 1: printf("월요일"); break;
    case 3: printf("수요일"); break;  // 출력
    default: printf("기타");
}
```

> [!warning] break 필수
> `break` 없으면 다음 case까지 줄줄이 실행됨 (fall-through)

### for 반복문

```c
// for (초기값; 조건; 증감)
for (int i = 0; i < 5; i++) {
    printf("%d ", i);  // 0 1 2 3 4
}
```

### while / do-while

```c
// while — 조건 먼저 검사
int i = 0;
while (i < 5) {
    printf("%d ", i);
    i++;  // 없으면 무한루프!
}

// do-while — 최소 한 번은 실행
do {
    printf("%d\n", i);
    i++;
} while (i < 5);
```

### break & continue

```c
// break — 반복문 탈출
for (int i = 0; i < 10; i++) {
    if (i == 5) break;
    printf("%d ", i);  // 0 1 2 3 4
}

// continue — 이번 반복만 건너뜀
for (int i = 0; i < 10; i++) {
    if (i % 2 == 0) continue;
    printf("%d ", i);  // 1 3 5 7 9
}
```

---

## 3단계: 함수

### 기본 구조

```c
// 반환타입 함수이름(매개변수) { 본문 }

void sayHello() {          // 반환값 없음
    printf("Hello!\n");
}

int add(int a, int b) {    // int 반환
    return a + b;
}

int main() {
    sayHello();
    int result = add(3, 5);  // 8
    return 0;
}
```

### 프로토타입 선언

```c
int add(int a, int b);  // 선언 (세미콜론으로 끝!)

int main() {
    printf("%d\n", add(3, 4));  // OK
    return 0;
}

int add(int a, int b) {  // 정의는 main 아래
    return a + b;
}
```

### Call by Value vs Call by Reference

```c
// Call by Value — 원본 안 바뀜
void tryChange(int x) {
    x = 999;  // 복사본만 바뀜
}

// Call by Reference — 포인터로 넘겨야 원본이 바뀜
void addOne(int *x) {
    *x = *x + 1;
}

int a = 5;
addOne(&a);  // a는 6이 됨
```

### 재귀 함수

```c
int factorial(int n) {
    if (n <= 1) return 1;        // 기저 조건 필수!
    return n * factorial(n - 1);
}
// factorial(5) = 120
```

---

## 4단계: 배열과 문자열

### 배열 기본

```c
int arr[5] = {10, 20, 30, 40, 50};
//            [0]  [1]  [2]  [3]  [4]

printf("%d\n", arr[2]);  // 30
arr[1] = 99;             // 값 변경
```

> [!warning] Python 리스트와 다른 점
> - 크기 고정 (선언 후 변경 불가)
> - 범위 초과 접근해도 오류 안 남 → 위험한 UB(Undefined Behavior)

### 배열 + for문

```c
int arr[5] = {3, 1, 4, 1, 5};
int sum = 0;

for (int i = 0; i < 5; i++) {
    sum += arr[i];
}
// sum = 14
```

### 배열을 함수에 전달

```c
// 크기를 따로 넘겨줘야 함
void printArr(int arr[], int size) {
    for (int i = 0; i < size; i++)
        printf("%d ", arr[i]);
}
// 배열은 포인터로 전달 → 원본이 바뀜!
```

### 문자열 = char 배열 + '\0'

```c
char str[] = "Hello";
// 메모리: ['H']['e']['l']['l']['o']['\0']
//          [0]  [1]  [2]  [3]  [4]  [5]

printf("%s\n", str);  // Hello
```

> [!tip] 크기는 항상 +1
> `char name[6]` = 글자 5개 + `'\0'` 1개

### string.h 주요 함수

```c
#include <string.h>

strlen(s)         // 문자열 길이 ('\0' 제외)
strcpy(dst, src)  // 복사 (= 연산자 안 됨!)
strcat(s1, s2)    // s1 뒤에 s2 붙이기
strcmp(s1, s2)    // 비교 (같으면 0, == 연산자 안 됨!)
```

---

## 5단계: 포인터 ⭐

### 핵심 개념

포인터 = 변수의 **메모리 주소**를 저장하는 변수

```c
int  a = 42;
int *p = &a;   // & : "a의 주소를 알려줘"

printf("%d\n", *p);  // * : "p가 가리키는 값" → 42
*p = 99;             // a의 값을 99로 변경!
printf("%d\n",  a);  // 99
```

| 연산자 | 위치 | 의미 |
|--------|------|------|
| `*` | 선언 시 `int *p` | 포인터 변수 선언 |
| `&` | 사용 시 `&a` | 변수의 주소 반환 |
| `*` | 사용 시 `*p` | 포인터가 가리키는 값 (역참조) |

### swap — 포인터 단골 예제

```c
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

int x = 10, y = 20;
swap(&x, &y);
// x = 20, y = 10
```

### 배열과 포인터

```c
int arr[3] = {10, 20, 30};
int *p = arr;  // arr == &arr[0]

*(p + 0) == arr[0]  // 10
*(p + 1) == arr[1]  // 20
*(p + 2) == arr[2]  // 30
```

> [!note] scanf에서 &를 쓰는 이유
> `scanf("%d", &x)` — scanf가 x의 주소를 받아서 직접 값을 써야 하기 때문

### 자주 하는 실수

```c
int *p;      // 초기화 안 한 포인터
*p = 10;    // ← segfault! 절대 하면 안 됨

// 올바른 패턴
int *p = NULL;
if (p != NULL) { *p = 10; }
```

---

## 6단계: 메모리 관리

### 메모리 구조

| 영역 | 설명 | 관리 |
|------|------|------|
| **Stack** | 지역변수, 매개변수 | 자동 |
| **Heap** | malloc 할당 영역 | **수동** |
| **Data** | 전역변수, 정적변수 | 자동 |
| **Code** | 프로그램 명령어 | - |

### malloc & free

```c
#include <stdlib.h>

// 할당
int *p = (int*)malloc(sizeof(int));
if (p == NULL) { return 1; }  // NULL 체크 필수!

*p = 42;

// 해제
free(p);
p = NULL;  // 해제 후 NULL 초기화 (좋은 습관)
```

### 동적 배열

```c
int n;
scanf("%d", &n);

int *arr = (int*)malloc(n * sizeof(int));

for (int i = 0; i < n; i++) arr[i] = i * 10;

free(arr);
```

### calloc / realloc

```c
// calloc — 0으로 초기화된 메모리
int *b = (int*)calloc(5, sizeof(int));  // b[0]~b[4] = 0

// realloc — 크기 재조정 (기존 데이터 유지)
arr = (int*)realloc(arr, 10 * sizeof(int));

free(b);
free(arr);
```

### 메모리 버그 3종

| 버그 | 설명 | 예방법 |
|------|------|--------|
| Memory Leak | free 안 함 | 할당한 건 반드시 free |
| Double Free | 두 번 free | free 후 NULL 초기화 |
| Use After Free | free 후 접근 | free 후 NULL 초기화 |

---

## 7단계: 구조체

### 기본 선언

```c
typedef struct {
    char  name[50];
    int   age;
    float score;
} Student;

Student s1 = {"Kim", 20, 90.5};
printf("%s: %.1f점\n", s1.name, s1.score);
```

### 멤버 접근 연산자

```c
Student s = {"Lee", 22, 85.0};
Student *p = &s;

s.age      // 일반 변수 → . 으로 접근
p->age     // 포인터    → -> 로 접근
(*p).age   // 위와 동일 (잘 안 씀)
```

### 구조체를 함수에 전달

```c
// 포인터로 넘겨야 원본 수정 가능
void addBonus(Student *s, float bonus) {
    s->score += bonus;
}

Student st = {"Park", 21, 80.0};
addBonus(&st, 10.0);
// st.score = 90.0
```

### 구조체 배열

```c
Student students[3] = {
    {"Kim",  20, 90.5},
    {"Lee",  22, 85.0},
    {"Park", 21, 92.0}
};

for (int i = 0; i < 3; i++) {
    printf("%s: %.1f\n", students[i].name, students[i].score);
}
```

### 동적 할당 구조체

```c
Student *p = (Student*)malloc(sizeof(Student));
p->age = 25;
strcpy(p->name, "Choi");
free(p);
p = NULL;
```

---

## 빠른 참조 — Python vs C 대응표

| 개념 | Python | C |
|------|--------|---|
| 변수 선언 | `x = 10` | `int x = 10;` |
| 함수 정의 | `def f(a, b):` | `int f(int a, int b) {` |
| 조건 분기 | `elif` | `else if` |
| 논리 연산 | `and / or / not` | `&& / \|\| / !` |
| 리스트 | `lst = [1,2,3]` | `int lst[3] = {1,2,3};` |
| 문자열 | `s = "hello"` | `char s[10] = "hello";` |
| 문자열 비교 | `s1 == s2` | `strcmp(s1, s2) == 0` |
| 클래스(데이터) | `class` | `struct` |
| 메모리 관리 | 자동 (GC) | `malloc` / `free` 직접 |
| 원본 수정 함수 | 기본 가능 | 포인터 필요 (`&`, `*`) |

---

*C언어 기초 7단계 완주 ✅*
