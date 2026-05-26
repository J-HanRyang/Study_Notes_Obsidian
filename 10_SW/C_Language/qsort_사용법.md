---
tags:
  - C언어
  - 정렬
---
## 한줄 요약
> stdlib.h의 내장 정렬 함수. 비교 함수만 만들어주면 됨

## 코드 예시
```c
#include <stdlib.h>

// 오름차순
int compare(const void* a, const void* b) {
    return *(int*)a - *(int*)b;
}

// 내림차순
int compare_desc(const void* a, const void* b) {
    return *(int*)b - *(int*)a;
}

// 사용법
qsort(arr, n, sizeof(int), compare);
// qsort(배열, 원소수, 원소크기, 비교함수)
```

## 주의사항
- 이진 탐색 전에 반드시 qsort 먼저 해야 함
- 시간복잡도: O(n log n)

## 관련 노트
- [[이진탐색]]
- [[배열_입력패턴]]
