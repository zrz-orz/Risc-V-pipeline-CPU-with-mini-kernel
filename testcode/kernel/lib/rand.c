#include "rand.h"
#include "math.h"
int initialize = 1;
int r[1000];
int t;

uint64 rand() {
    t++;
    return t;
    int i;

    if (initialize == 1) {
        t = 0;
        r[0] = SEED;
        for (i = 1; i < 31; i++) {
            r[i] = int_mod((16807LL * r[i - 1]),2147483647);
            if (r[i] < 0) {
                r[i] += 2147483647;
            }
        }
        for (i = 31; i < 34; i++) {
            r[i] = r[i - 31];
        }
        for (i = 34; i < 344; i++) {
            r[i] = r[i - 31] + r[i - 3];
        }

		initialize = 0;
    }

	t = int_mod(t,656);

    r[t + 344] = r[t + 344 - 31] + r[t + 344 - 3];
    
	t++;

    return (uint64)int_mod(r[t - 1 + 344] , 10) + 1;
}
