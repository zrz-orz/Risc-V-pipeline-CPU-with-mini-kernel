.extern start_kernel
.extern _ekernel

.section .text.init  
.globl _start
_start:
    la sp, _ekernel
    li a0, 0x1000
    add sp, sp, a0
    la a0, _traps
    csrw stvec, a0
    li a0, 1 << 5
    csrs sie, a0
    #rdtime a0
    li a0, 0
    li t0, 1000000
    add a0, a0, t0
    call mm_init
    call task_init
    li a0, 0x100000
    call sbi_set_timer
    csrs sstatus, 1 << 1
    li a0, 114514
    j start_kernel

.section .stack.entry
.globl boot_stack_bottom
boot_stack_bottom:
    .space 4096
.globl boot_stack_top
boot_stack_top: