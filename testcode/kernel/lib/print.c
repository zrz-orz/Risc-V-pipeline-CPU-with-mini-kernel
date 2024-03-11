#include "print.h"
#include "sbi.h"

void puts(char *s) {
  while (*s != 0) {
    sbi_ecall(0x01, 0x0, *s, 0, 0, 0, 0, 0);
    ++s;
  }
}

void puti(int x) {
  int y = 0;
  if (x == 0) {
    puts("0");
    return;
  }
  if (x < 0) {
    puts("-");
    x = -x;
  }
  while (x) {
    y = int_mul(y, 10) + int_mod(x, 10);
    x = int_div(x, 10);
  }
  char s[2] = "";
  while (y) {
    s[0] = int_mod(y, 10) + '0';
    s[1] = 0;
    puts(s);
    y = int_div(y, 10);
  }  
}
