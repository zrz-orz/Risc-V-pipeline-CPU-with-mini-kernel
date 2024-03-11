.section .text
.global _start1
.extern load_binary
_start1:
    li sp,0x1000
    li a0,0x10000
    call load_binary
    li t0,0x80000000
    jalr x0,0(t0)

.section .data
    .incbin	FW_PAYLOAD_PATH
