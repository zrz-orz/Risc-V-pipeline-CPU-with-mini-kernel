DIR_COSIM_IP	?= $(CURDIR)/ip
DIR_SIM			?= $(CURDIR)/sim
DIR_BUILD		?= $(CURDIR)/build
DIR_SRC			?= $(CURDIR)/submit
DIR_TCL			?= $(CURDIR)/tcl
DIR_SYN			?= $(CURDIR)/syn

VERILATOR_TOP		:= Testbench
VERILATOR_SRCS		=  $(shell find $(DIR_SIM) -name "*.v" -o -name "*.sv" -o -name "*.cpp") \
					   $(shell find $(DIR_SRC) -name "*.v" -o -name "*.sv" -o -name "*.cpp")
VERILATOR_TFLAGS	:= --timescale 1ns/10ps --trace
VERILATOR_FLAGS		:= --cc --exe  --main --timing \
						--Mdir $(DIR_BUILD) --top-module $(VERILATOR_TOP) \
						-o $(VERILATOR_TOP) -I$(DIR_SIM) -I$(DIR_SRC) \
						-CFLAGS "-DVL_DEBUG -DTOP=${VERILATOR_TOP} -std=c++17 \
						-iquote$(DIR_COSIM_IP)/include/riscv -iquote$(DIR_COSIM_IP)/include/cosim -iquote$(DIR_COSIM_IP)/include/fesvr" \
						-LDFLAGS "-L$(DIR_COSIM_IP)/lib  -l:libcosim.a -l:libriscv.a -l:libdisasm.a -l:libsoftfloat.a -l:libfdt.a -l:libspike_dasm.a -l:libfesvr.a -l:libspike_main.a -l:libcontroller.a"
VERILATOR_DEFINE	:= +define+TOP_DIR=\"$(DIR_BUILD)\" +define+VERILATE

verilate:testcode/testcase.elf
	mkdir -p $(DIR_BUILD)
	cp testcode/testcase.elf $(DIR_BUILD)/testcase.elf
	cp testcode/rom/rom.hex $(DIR_BUILD)/rom.hex
	cp testcode/mini_sbi.hex $(DIR_BUILD)/mini_sbi.hex
	cp testcode/dummy/dummy.hex $(DIR_BUILD)/dummy.hex

	verilator $(VERILATOR_TFLAGS) $(VERILATOR_FLAGS) $(VERILATOR_SRCS) $(VERILATOR_DEFINE)
	make -C $(DIR_BUILD) -f V$(VERILATOR_TOP).mk $(VERILATOR_TOP) 
	cd $(DIR_BUILD); ./$(VERILATOR_TOP)

board_sim:testcode/bootload.elf
	mkdir -p $(DIR_BUILD)
	cp testcode/bootload/bootload.elf $(DIR_BUILD)/testcase.elf
	cp testcode/bootload/bootload.hex $(DIR_BUILD)/rom.hex
	cp testcode/elf.hex $(DIR_BUILD)/elf.hex
	cp testcode/dummy/dummy.hex $(DIR_BUILD)/dummy.hex

	verilator $(VERILATOR_TFLAGS) $(VERILATOR_FLAGS) $(VERILATOR_SRCS) $(VERILATOR_DEFINE) +define+BOARD_SIM
	make -C $(DIR_BUILD) -f V$(VERILATOR_TOP).mk $(VERILATOR_TOP) 
	cd $(DIR_BUILD); ./$(VERILATOR_TOP)

testcode/bootload.elf:
	make -C testcode board

testcode/testcase.elf:
	make -C testcode

wave:
	gtkwave $(DIR_BUILD)/$(VERILATOR_TOP).vcd

clean_sim:
	make -C testcode clean
	rm -rf $(DIR_BUILD)

# Replace with your own path, for example:
#   If your Vivado is installed in Windows:   
#   	 VIVADO_SETUP := call D:\App\Xilinx\Vivado\2022.2\settings64.bat
#   or in Linux: 
#        VIVADO_SETUP := source /opt/Xilinx/Vivado/2022.2/settings64.sh
VIVADO_SETUP		:=  call D:\vivado\Vivado\2022.2\settings64.bat

CMD_PREFIX			:=	bash -c
PATH_TRANS			:=	realpath
DIR_PROJECT			?= $(CURDIR)/project
BOARD				?=	xc7a100tcsg324-1
TOP_MODULE			?=	top 

ifneq (,$(findstring microsoft,$(shell uname -a)))
WSLENV				:=	$(WSLENV):DIR_SRC/p:DIR_SYN/p:DIR_TCL/p:DIR_BUILD/p
DIR_PROJECT			:=	/mnt/d/txt/system2/lab2
CMD_PREFIX			:=	cmd.exe /c
PATH_TRANS			:=	wslpath -w
endif

export DIR_SRC DIR_SYN DIR_TCL DIR_PROJECT

bitstream: clean_syn
	mkdir -p $(DIR_PROJECT)
	cd $(DIR_PROJECT); cp $(DIR_TCL)/vivado.tcl .; $(CMD_PREFIX) "$(VIVADO_SETUP) && set DIR_SRC && \
		vivado -mode batch -nojournal -source vivado.tcl -tclargs -top-module $(TOP_MODULE) -board $(BOARD)"

vivado:
	mkdir -p $(DIR_PROJECT)
	cd $(DIR_PROJECT); $(CMD_PREFIX) "$(VIVADO_SETUP) && vivado"

clean_syn:
	# rm -rf $(DIR_PROJECT)

clean:clean_sim clean_syn
	

