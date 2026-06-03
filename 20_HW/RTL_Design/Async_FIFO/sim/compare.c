#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

int main()
{
	FILE *golden_fp = fopen("golden_output.txt", "r");
	FILE *dut_fp = fopen("dut_output.txt", "r");

	// 파일 열기 오류 처리
	if (golden_fp == NULL || dut_fp == NULL)
	{
		printf("Error opening files.\n");
		return 1;
	}

	int pass_count = 0;
	int fail_count = 0;
	int skip_count = 0;	// empty / full 상황에서 발생하는 실패는 비교에서 제외
	char golden_line[100];
	char dut_line[100];

	// golden과 dut의 라인을 하나씩 읽으면서 비교
	while (fgets(golden_line, sizeof(golden_line), golden_fp) != NULL &&
		   fgets(dut_line, sizeof(dut_line), dut_fp) != NULL)
	{
		// FAIL 라인 비교 제외
        while (strstr(golden_line, "FAIL") != NULL) {
            skip_count++;
            if (fgets(golden_line, sizeof(golden_line), golden_fp) == NULL) break;
        }

        while (strstr(dut_line, "FAIL") != NULL) {
            skip_count++;
            if (fgets(dut_line, sizeof(dut_line), dut_fp) == NULL) break;
        }
		
		// golden과 dut의 라인 비교
		if (strcmp(golden_line, dut_line) == 0)
		{
			printf("PASS: %s", golden_line);
			pass_count++;
		}
		else
		{
			printf("FAIL:\n  Golden: %s  DUT: %s", golden_line, dut_line);
			fail_count++;
		}
	}

	// 총 PASS/FAIL 카운트 출력
	printf("Total PASS: %d\n", pass_count);
	printf("Total FAIL: %d\n", fail_count);

	fclose(golden_fp);
	fclose(dut_fp);
}