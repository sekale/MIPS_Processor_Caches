/*
  Abhishek Srikanth

  idex_pipelineReg file interface
*/
`ifndef IDEX_PIPELINEREG_IF_VH
`define IDEX_PIPELINEREG_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface idex_pipelineReg_if;

  // import types
  import cpu_types_pkg::*;

  // from previous state
  word_t    pc_add4_in, instruction_in;
  // from register file
  word_t    rdat1_in, rdat2_in;
  // from control unit
  logic     halt_in, dREN_in, dWEN_in;
  logic     extOp_in, regWr_in, memToReg_in;
  logic [IMM_W-1:0] immediate_in;
  logic [1:0] aluSrc_in;
  opcode_t  opCode_in;
  aluop_t   aluOp_in;
  regbits_t rs_in, rt_in, rd_in;
  word_t    shamt_in;
  logic     isJRFlag_in;

  word_t    pc_add4, instruction;
  word_t    rdat1, rdat2;
  logic     halt, dREN, dWEN;
  logic     extOp, regWr, memToReg;
  logic [IMM_W-1:0] immediate;
  logic [1:0] aluSrc;
  opcode_t  opCode;
  aluop_t   aluOp;
  regbits_t rs, rt, rd;
  word_t    shamt;
  logic     isJRFlag;

endinterface

`endif //IDEX_PIPELINEREG_IF_VH

