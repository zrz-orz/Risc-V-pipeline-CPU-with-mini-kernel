ASM_SRC		= $(sort $(wildcard *.S))
C_SRC       = $(sort $(wildcard *.c))
OBJ		    = $(patsubst %.S,%.o,$(ASM_SRC)) $(patsubst %.c,%.o,$(C_SRC))

all:$(OBJ)
	# rm -rf $(TARGET)

%.o:%.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $<

%.o:%.c
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $<

clean:
	rm -f *.o *.asm *.elf *.bin
	
	