// Copyright 2023 Sycuricon Group
// Author: Jinyan Xu (phantom@zju.edu.cn)

#include <svdpi.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include "cj.h"

cosim_cj_t* simulator=NULL;
config_t cfg;

extern "C" void cosim_init(){
  cfg.verbose = true;
  cfg.isa = "rv64i";
  cfg.boot_addr = 0x0;
  cfg.elffiles = std::vector<std::string> {
      "testcase.elf"
  };
  cfg.mem_layout = std::vector<mem_cfg_t> {
      mem_cfg_t(0x0UL, 0x100000000UL)
  };
  simulator = new cosim_cj_t(cfg);
  printf("initialize the simulation\n");
}

extern "C" int cosim_commit (int hartid, reg_t dut_pc, uint32_t dut_insn) {
  assert(simulator);
  return simulator->cosim_commit_stage(0, dut_pc, dut_insn, true);
}

extern "C" int mmio_load(reg_t addr, size_t len, uint64_t bytes){
  assert(simulator);
  return simulator->mmio_load(addr, len, (uint8_t*)&bytes);
}

extern "C" int mmio_store(reg_t addr, size_t len, const uint64_t bytes){
  assert(simulator);
  return simulator->mmio_store(addr, len, (const uint8_t*)&bytes);
}

extern "C" int cosim_judge (int hartid, const char * which, int dut_waddr, reg_t dut_wdata) {
  assert(simulator);
  if (strcmp(which, "float") == 0)
    return simulator->cosim_judge_stage(0, dut_waddr, dut_wdata, true);
  else
    return simulator->cosim_judge_stage(0, dut_waddr, dut_wdata, false);
}

extern "C" void cosim_raise_trap(reg_t cause){
  assert(simulator);
  return simulator->cosim_raise_trap(0, cause);
}
