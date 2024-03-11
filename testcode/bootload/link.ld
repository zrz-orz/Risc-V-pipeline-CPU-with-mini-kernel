OUTPUT_ARCH( "riscv" )
ENTRY(_start1)

SECTIONS
{
  .text 0x00000000 : {*(.text)}
  .data 0x10000 : {*(.data)}
}

