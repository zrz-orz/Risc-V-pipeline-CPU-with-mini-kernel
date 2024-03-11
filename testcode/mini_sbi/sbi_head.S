.section .text

.global _sbi_start
.extern _sbi_trap_entry
.extern _payload_address
_sbi_start:
    la sp,_sbi_stack_top
    addi sp,sp,-16
    li t0,0xab
    sb t0,0(sp)
    ld t1,0(sp)
    li t0,0xcd
    sb t0,1(sp)
    ld t1,0(sp)
    li t0,0x1234
    sh t0,2(sp)
    ld t1,0(sp)
    li t0,0x567890ef
    sw t0,4(sp)
    ld t1,0(sp)
    li t0,0x1234567890abcdef
    sd t0,8(sp)
    ld t1,0(sp)
    
    //set MPP as S mode
    li t0,0x800
    csrw mstatus,t0
    //set M trap address
    la t0,_sbi_trap_entry
    csrw mtvec,t0
    //set payload address of kernel
    la t0,_payload_address
    csrw mepc,t0
    //open software interrupt
    li t0,0x8
    csrw mie,t0
    //set stack top of M sbi
    la t0,_sbi_stack_top
    csrw mscratch,t0
    //jump to kernel and switch to S mode
    li t0,0x222
    csrw mideleg,t0
    li t0,0xb109
    csrw medeleg,t0
    mret

.section .bss
    .space 0x1000
_sbi_stack_top:

# .section .payload
# _payload_address:
#     .incbin FW_PAYLOAD_PATH

