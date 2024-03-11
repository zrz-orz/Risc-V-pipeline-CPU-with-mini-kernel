OUTPUT_ARCH( "riscv" )
ENTRY(_start1)

SECTIONS
{
  .text 0x00000000 : {*(.text)}
  . = ALIGN(0x10);
  .data : {*(.data)}
}

