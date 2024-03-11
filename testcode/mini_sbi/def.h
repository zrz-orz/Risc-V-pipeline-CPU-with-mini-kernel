#ifndef __DEF_H__
#define __DEF_H__
typedef unsigned long long uint64;
#define csr_read(csr)                 \
    ({                                \
        register uint64 __v;          \
        asm volatile("csrr %0, " #csr \
                     : "=r"(__v)      \
                     :                \
                     : "memory");     \
        __v;                          \
    })

#define csr_write(csr, val)              \
    ({                                   \
        unsigned long long __v = (unsigned long long)(val);      \
        asm volatile("csrw " #csr ", %0" \
                     :                   \
                     : "r"(__v)          \
                     : "memory");        \
    })
#endif