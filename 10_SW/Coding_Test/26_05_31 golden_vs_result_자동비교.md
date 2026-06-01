---
date: 2026-05-31
tags:
  - C언어
  - 파일입출력
난이도: 실버
---
## 문제 요약
golden_output.txt와 result.txt를 한 줄씩 비교해 PASS/FAIL 출력.

## 풀이 접근
두 파일을 동시에 fgets로 읽으며 strcmp 비교. result가 짧은 경우도 처리.

## 코드
```c
void compare(const char *golden_path, const char *result_path) {
    FILE *golden = fopen(golden_path, "r");
    FILE *result  = fopen(result_path, "r");

    char line_g[128];
    char line_r[128];
    int line_num = 1;
    int fail = 0;

    while (fgets(line_g, sizeof(line_g), golden) != NULL) {
        if (fgets(line_r, sizeof(line_r), result) == NULL) {
            printf("FAIL at line %d: result 파일이 짧음\n", line_num);
            fail = 1;
            break;
        }

        if (strcmp(line_g, line_r) != 0) {
            printf("FAIL at line %d\n", line_num);
            printf("  golden: %s", line_g);
            printf("  result: %s", line_r);
            fail = 1;
        }
        line_num++;
    }

    if (!fail) printf("ALL PASS\n");

    fclose(golden);
    fclose(result);
}
```

## 핵심 포인트
- `fgets` 반환값 == NULL 로 result가 짧은 경우 별도 처리
- `strcmp`는 `\n` 포함 비교 → 두 파일 포맷 완전히 동일해야 함
- `fail` 플래그로 최종 PASS/FAIL 판정

## 실수 / 막혔던 것
- 한쪽 파일만 `\n` 있으면 strcmp가 다르다고 판정
- fgets NULL 체크 없으면 result 짧을 때 UB 발생

## 관련 노트
- [[자동_비교]]
- [[파일_입출력]]
- [[26_05_31 stimulus_생성기]]
