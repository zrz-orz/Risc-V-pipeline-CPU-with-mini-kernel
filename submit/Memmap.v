`include "Define.vh"
module Memmap(
    input wen_cpu,
    input ren_cpu,
    output mem_stall,
    output [63:0] rdata_cpu,
    input [63:0] address_cpu,

    output wen_cpu_to_mem,
    output ren_cpu_to_mem,
    input mem_stall_from_mem,
    input [63:0] rdata_cpu_from_mem,

    output wen_cpu_to_mmio,
    output ren_cpu_to_mmio,
    input mem_stall_from_mmio,
    input [63:0] rdata_cpu_from_mmio
);
    
    wire is_mem=
        (address_cpu<(`ROM_BASE+`ROM_LEN))|
        ((`BUFFER_BASE<=address_cpu)&
        (address_cpu<(`BUFFER_BASE+`BUFFER_LEN)))|
        ((`MEM_BASE<=address_cpu)&
        (address_cpu<(`MEM_BASE+`MEM_LEN)));
    wire is_mmio=(`MTIME_BASE==address_cpu)|
        (`MTIMECMP_BASE==address_cpu)|
        (`DISP_BASE==address_cpu)|
        ((`UART_BASE==address_cpu)&((`UART_BASE+`UART_LEN)==address_cpu));

    assign wen_cpu_to_mem=is_mem?wen_cpu:1'b0;
    assign wen_cpu_to_mmio=is_mmio?wen_cpu:1'b0;
    assign ren_cpu_to_mem=is_mem?ren_cpu:1'b0;
    assign ren_cpu_to_mmio=is_mmio?ren_cpu:1'b0;

    assign mem_stall=is_mem?mem_stall_from_mem:
                        is_mmio?mem_stall_from_mmio:
                        1'b0;
    assign rdata_cpu=is_mem?rdata_cpu_from_mem:
                        is_mmio?rdata_cpu_from_mmio:
                        64'b0;
endmodule
