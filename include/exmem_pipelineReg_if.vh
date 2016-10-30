/*
  Abhishek Srikanth

  exmem_pipelineReg file interface
*/
`ifndef EXMEM_PIPELINEREG_IF_VH
`define EXMEM_PIPELINEREG_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface exmem_pipelineReg_if;

  // import types
  import cpu_types_pkg::*;

  word_t    pc_add4_in, instruction_in;
  opcode_t  opCode_in;
  logic [IMM_W-1:0] immediate_in;
  word_t    portB_fwd_in;
  logic     dREN_in, dWEN_in;
  logic     regWr_in, memToReg_in; // memToReg for next State
  regbits_t regDst_in;
  logic     zeroFlag_in;
  word_t    bra_addr_in, portOut_in;
  logic     halt_in;

  word_t    pc_add4, instruction;
  opcode_t  opCode;
  logic [IMM_W-1:0] immediate;
  word_t    portB_fwd;
  logic     dREN, dWEN;
  logic     regWr, memToReg;
  regbits_t regDst;
  logic     zeroFlag;
  word_t    bra_addr, portOut;
  logic     halt;

endinterface

`endif //EXMEM_PIPELINEREG_IF_VH

