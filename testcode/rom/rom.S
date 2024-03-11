.section .text
.global _start1
_start1:
test1:
    addi x1, x0, 1
    addi x2, x0, 1
    addi x4, x0, 5
fibonacci:
    add x3, x1, x2
    add x1, x2, x3
    add x2, x1, x3
    addi x4, x4, -1
    bne x0, x4, fibonacci
    addi x5, x0, 0x63D
    bne x2, x5, fail1
pass1:
    li x1,0x80000000
    jr x1
fail1:
    unimp
    j fail1
.section .data