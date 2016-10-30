/*
  Abhishek Srikanth

  alu file interface
*/
`ifndef ALU_IF_VH
`define ALU_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface alu_if;

  // import types
  import cpu_types_pkg::*;

  logic     negative, overflow, zero;
  aluop_t   aluOp;
  word_t    portA, portB, portOut;

  // alu ports
  modport alu
  (
    input   aluOp, portA, portB,
    output  portOut, negative, overflow, zero
  );

  // alu tb
  modport alu_tb
  (
    input   portOut, negative, overflow, zero,
    output  aluOp, portA, portB
  );

endinterface

`endif //ALU_IF_VH
