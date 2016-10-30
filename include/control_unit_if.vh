/*
  Abhishek Srikanth

  control_unit file interface
*/
`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface control_unit_if;

  // import types
  import cpu_types_pkg::*;

  logic     halt;
  logic     dREN, dWEN;
  word_t    instruction;

  logic             extOp, regWr, memToReg;
  aluop_t           aluOp;
  logic [1:0]       aluSrc;
  logic [IMM_W-1:0] immediate;
  regbits_t         rs, rt, rd;
  word_t            shamt;  // 0 padded
  opcode_t          opCode;
  logic             isJRFlag;

  // control_unit ports
  modport cu
  (
    input   instruction,
    output  dREN, dWEN,
            rs, rt, rd, shamt, opCode, isJRFlag,
            extOp, aluOp, aluSrc, regWr, memToReg, immediate,
            halt
  );

endinterface

`endif //CONTROL_UNIT_IF_VH
