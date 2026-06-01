---
date: 2026-05-31
tags:
  - C언어
  - 랜덤
  - 파일입출력
난이도: 실버
---
## 문제 요약
rand()로 WRITE/READ 커맨드를 랜덤 생성해 stimulus.txt에 저장.

## 풀이 접근
srand로 시드 고정 후 cmd, data를 독립적으로 뽑아 fprintf로 파일에 기록.

## 코드
```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    FILE *fp = fopen("stimulus.txt", "w");

    srand(42);

    for (int i = 0; i < 20; i++) {
        int cmd  = rand() % 2;
        int data = rand() % 100;

        if (cmd == 0) {
            fprintf(fp, "WRITE %d\n", data);
        } else {
            fprintf(fp, "READ\n");
        }
    }

    fclose(fp);
    return 0;
}
```

## 핵심 포인트
- cmd와 data를 독립적으로 따로 뽑아야 편향 없음
- `srand(42)` 시드 고정으로 재현 가능한 테스트 보장

## 실수 / 막혔던 것
- 같은 `r` 재사용 시 data가 항상 짝수/홀수로 편향됨
- `srand()` 빠뜨리면 매번 같은 시퀀스

## 관련 노트
- [[랜덤_생성]]
- [[파일_입출력]]
