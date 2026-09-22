#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifndef TOTAL_COUNT
#define TOTAL_COUNT 20
#endif

int main()
{
	FILE *golden_fp = fopen("./sim/golden_output.txt", "r");
	FILE *dut_fp = fopen("./sim/dut_output.txt", "r");

	if (golden_fp == NULL || dut_fp == NULL)
	{
		printf("Error opening files.\n");
		return 1;
	}

	int pass_count = 0;
	int fail_count = 0;
	int skip_count = 0;
	char golden_line[100];
	char dut_line[100];

	while (fgets(golden_line, sizeof(golden_line), golden_fp) != NULL &&
		   fgets(dut_line, sizeof(dut_line), dut_fp) != NULL)
	{
		// FAIL 라인 스킵
		// while (strstr(golden_line, "FAIL") != NULL)
		// {
		// 	skip_count++;
		// 	if (fgets(golden_line, sizeof(golden_line), golden_fp) == NULL)
		// 		break;
		// }
		// while (strstr(dut_line, "FAIL") != NULL)
		// {
		// 	skip_count++;
		// 	if (fgets(dut_line, sizeof(dut_line), dut_fp) == NULL)
		// 		break;
		// }

		// dut에서 @ 기준으로 data 부분과 타임스탬프 분리
		char dut_data[100];
		char dut_time[50] = "";

		char *at = strchr(dut_line, '@');
		if (at != NULL)
		{
			strncpy(dut_data, dut_line, at - dut_line);
			dut_data[at - dut_line] = '\0';
			strncpy(dut_time, at + 1, sizeof(dut_time));
			dut_time[strcspn(dut_time, "\n")] = '\0';
		}
		else
		{
			strncpy(dut_data, dut_line, sizeof(dut_data));
		}

		// 개행 제거
		golden_line[strcspn(golden_line, "\n")] = '\0';
		dut_data[strcspn(dut_data, "\n")] = '\0';

		// dut_data 뒤 공백 제거 (@ 앞 space)
		int len = strlen(dut_data);
		while (len > 0 && dut_data[len - 1] == ' ')
			dut_data[--len] = '\0';

		if (strcmp(golden_line, dut_data) == 0)
		{
			// printf("PASS: @ %s\n  Golden %s\n  DUT    %s\n", dut_time, golden_line, dut_data);
			pass_count++;
		}
		else
		{
			printf("FAIL: @ %s\n  Golden %s\n  DUT    %s\n", dut_time, golden_line, dut_data);
			fail_count++;
		}
	}

	printf("\nTotal PASS:    %d\n", pass_count);
	printf("Total FAIL:    %d\n", fail_count);
	printf("Total SKIPPED: %d\n", skip_count / 2); // FAIL 라인은 golden과 dut 각각 1회씩 스킵되므로 2로 나눔

	if (pass_count + fail_count + skip_count / 2 == TOTAL_COUNT)
	{
		printf("All %d cases processed.\n", TOTAL_COUNT); // 예상한 총 케이스 수와 일치
	}
	else
	{
		printf("Warning: Total cases processed (%d) does not match expected (%d).\n",
			   pass_count + fail_count + skip_count / 2, TOTAL_COUNT); // 예상한 총 케이스 수와 일치하지 않음
	}

	fclose(golden_fp);
	fclose(dut_fp);
	return 0;
}