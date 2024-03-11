#ifndef __SBI_TRAP_H__
#define __SBI_TRAP_H__
#include"def.h"
#define USI 0x8000000000000000
#define SSI 0x8000000000000001
#define HSI 0x8000000000000002
#define MSI 0x8000000000000003
#define UTI 0x8000000000000004
#define STI 0x8000000000000005
#define HTI 0x8000000000000006
#define MTI 0x8000000000000007
#define UEI 0x8000000000000008
#define SEI 0x8000000000000009
#define HEI 0x800000000000000a
#define MEI 0x800000000000000b
#define INST_ADDR_UNALIGN  0
#define INST_ACCESS_FAULT  1
#define ILLEAGAL_INST      2
#define BREAKPOINT         3
#define LOAD_ADDR_UNALIGN  4
#define LOAD_ACCESS_FAULT  5
#define STORE_ADDR_UNALIGN 6
#define STORE_ACCESS_FAULT 7
#define U_CALL 8
#define S_CALL 9
#define H_CALL 10
#define M_CALL 11

struct sbi_pr_reg{
    uint64 zero;
    uint64 ra;
    uint64 sp;
    uint64 gp;
    uint64 tp;
    uint64 t0;
    uint64 t1;
    uint64 t2;
    uint64 s0;
    uint64 s1;
    uint64 a0;
    uint64 a1;
    uint64 a2;
    uint64 a3;
    uint64 a4;
    uint64 a5;
    uint64 a6;
    uint64 a7;
    uint64 s2;
    uint64 s3;
    uint64 s4;
    uint64 s5;
    uint64 s6;
    uint64 s7;
    uint64 s8;
    uint64 s9;
    uint64 s10;
    uint64 s11;
    uint64 t3;
    uint64 t4;
    uint64 t5;
    uint64 t6;
    uint64 mepc;
};
extern void sbi_trap_handler(uint64 mcause,struct sbi_pr_reg* pr_reg);
#endif