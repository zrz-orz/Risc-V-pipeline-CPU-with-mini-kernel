export
	RISCV_PREFIX ?= riscv64-unknown-linux-gnu-
	RISCV_GCC ?= $(RISCV_PREFIX)gcc
	RISCV_GCC_OPTS ?= -march=rv64g_zicsr -mabi=lp64d -mcmodel=medany -fvisibility=hidden -nostdlib \
		-nostartfiles -DNOBRANCH 
	# -DBOARD
	RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -O binary  
	RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump -Mno-aliases -D
	RISCV_LD  ?= $(RISCV_PREFIX)ld

ELF         = mini_sbi.elf
BIN         = mini_sbi.bin
ASM 		= mini_sbi.asm
HEX			= mini_sbi.hex

all:sim

sim:
	make -C kernel
	make -C mini_sbi
	make -C rom
	$(RISCV_GCC) $(RISCV_GCC_OPTS) ./mini_sbi/*.o ./kernel/lib/*.o \
		./kernel/init/*.o ./kernel/arch/riscv/kernel/*.o -T link.ld -o $(ELF)
	$(RISCV_GCC) $(RISCV_GCC_OPTS) ./mini_sbi/*.o ./kernel/lib/*.o \
		./kernel/init/*.o ./kernel/arch/riscv/kernel/*.o ./rom/*.o \
		-T testcase.ld -o testcase.elf
	${RISCV_OBJCOPY} $(ELF) tmp.bin
	od -v -An -tx8 tmp.bin > tmp.hex
	sed 's/@1/@0/g' tmp.hex > $(HEX)
	rm tmp.hex tmp.bin
	$(RISCV_OBJDUMP) $(ELF) > $(ASM)

board:
	make -C kernel
	make -C mini_sbi
	$(RISCV_GCC) $(RISCV_GCC_OPTS) ./mini_sbi/*.o ./kernel/lib/*.o \
		./kernel/init/*.o ./kernel/arch/riscv/kernel/*.o -T link.ld -o $(ELF)
	${RISCV_OBJCOPY} $(ELF) $(BIN)
	od -v -An -tx8 $(BIN) > $(HEX)
	rm -rf $(BIN)
	$(RISCV_OBJDUMP) $(ELF) > $(ASM)
	python ./compress_elf.py
	make -C bootload

clean:
	make -C kernel clean
	make -C mini_sbi clean
	make -C rom clean
	make -C bootload clean
	rm -f *.asm *.hex *.elf *.o *.bin

	
	