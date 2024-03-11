export
CROSS	:=	riscv64-linux-gnu-
GCC		:=	${CROSS}gcc
LD		:=	${CROSS}ld
OBJCOPY	:=	${CROSS}objcopy
OBJDUMP	:=	${CROSS}objdump

ISA		:=	rv64g
ABI		:=	lp64d

INCLUDE := 	-I $(shell pwd)/include -I $(shell pwd)/arch/riscv/include
CF 		:= 	-g3 -march=$(ISA) -mabi=$(ABI) -mcmodel=medany 		\
			-fno-builtin -ffunction-sections -fdata-sections  -fno-PIE	\
			-nostartfiles -nostdlib -nostdinc -static -lgcc -Wl,--nmagic -Wl,--gc-sections
CFLAG 	:= 	${CF} ${INCLUDE}

.PHONY:all run debug clean
all:
	${MAKE} -C lib all
	${MAKE} -C init all
	${MAKE} -C arch/riscv all
	@echo -e '\n'Build Finished OK

run: all
	@echo Launch the qemu ......
	@qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -bios default 

debug: all
	@echo Launch the qemu for debug ......
	@qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -bios default -S -s

clean:
	${MAKE} -C lib clean
	${MAKE} -C init clean
	${MAKE} -C arch/riscv clean
	$(shell test -f vmlinux && rm vmlinux)
	$(shell test -f vmlinux.asm && rm vmlinux.asm)
	$(shell test -f System.map && rm System.map)
	@echo -e '\n'Clean Finished
