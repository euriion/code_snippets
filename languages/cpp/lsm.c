#include <stdio.h>
#define TEXTLENGTH 4096

int main() {
  char text[TEXTLENGTH];
  double xi, yi;
  double sxi = 0, syi = 0, sxiyi = 0, sxi2 = 0;
  double a0, a1;
  int n = 0;

  // 데이터입력
  while (fgets(text, TEXTLENGTH, stdin) != NULL) {
    if (sscanf (text, "%lf %lf", &xi, &yi) == 2) {
      /* 변환 성공, 각 항 계산 */
      sxi += xi;
      syi += yi;
      sxiyi += xi * yi;
      sxi2 += xi * xi;
      ++n;
    } else {
      /* 변환 실패, 건너뛰기 */
      fprintf(stderr, "바르지 않은 데이터입니다 : %s", text);
    }
  }

  if (n > 1) {
    /* 데이터가 2개 이상 있다 */
    /* 계수 계산 */
    a0 = (sxi2 * syi - sxiyi * sxi) / (n * sxi2 -sxi * sxi);
    a1 = (n * sxiyi - sxi * syi) / (n * sxi2 - sxi * sxi);
    /* 결과 출력 */
    printf("%1f\n%1f\n", a0, a1);
  } else {
    fprintf(stderr, "데이터 부족합니다.\n");
  }

  return 0;
}

/* 입력 */
// 1 2.1
// 3 3.7
// 2.5 3.4
// 3.9 3.1
/* 결과 */
// 2.010294
// 0.409502
