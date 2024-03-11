#include "print.h"
#include "sbi.h"

extern void test();

int start_kernel(int x) {
    //puti(x);
    puts(" ZJU Computer System II\n");

    test(); // DO NOT DELETE !!!

	return 0;
}
