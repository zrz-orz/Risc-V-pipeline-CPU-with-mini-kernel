#include "sbi_trap.h"
#include "mcsr.h"
#include "def.h"

void sbi_set_time(uint64 time){
    csr_write(mie,csr_read(mie)|MIE_MTIE);
    csr_write(mip,csr_read(mip)&~MIP_STIP);
    volatile uint64* mtimecmp_addr=(uint64*)MTIMECMP;
    volatile uint64* mtime_addr=(uint64*)MTIME;
    *(mtimecmp_addr)=(*mtime_addr>time)?(*mtime_addr+time):time;
}

void sbi_console_putchar(uint64 c){
    volatile uint64* disp_addr=(uint64*)DISP;
    while(*(disp_addr));
    *(disp_addr)=c;
}

uint64 sbi_console_getchar(){
    return 0;
}

void sbi_scall_handler(struct sbi_pr_reg* pr_reg){
    uint64 func_id=pr_reg->a6;
    uint64 extend_id=pr_reg->a7;
    uint64 arg0=pr_reg->a0;
    uint64 arg1=pr_reg->a1;
    uint64 arg2=pr_reg->a2;
    uint64 arg3=pr_reg->a3;
    uint64 arg4=pr_reg->a4;
    uint64 arg5=pr_reg->a5;
    if(func_id==0){
        switch(extend_id){
            case 0:sbi_set_time(arg0);break;
            case 1:sbi_console_putchar(arg0);break;
            case 2:pr_reg->a0=sbi_console_getchar();break;
            default:break;
        }
    }
    pr_reg->mepc+=4;
}

void sbi_mti_handler(struct sbi_pr_reg* pr_reg){
    uint64 mip=csr_read(mip);
    mip|=MIP_STIP;
    csr_write(mip,mip);
    csr_write(mie,csr_read(mie)&~MIE_MTIE);
}

void sbi_trap_handler(uint64 mcause,struct sbi_pr_reg* pr_reg){
    switch(mcause){
        case S_CALL:
            sbi_scall_handler(pr_reg);
            break;
        case MTI:
            sbi_mti_handler(pr_reg);
            break;
        default:
            break;
    }
}