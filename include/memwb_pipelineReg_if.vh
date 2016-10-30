/*
  Abhishek Srikanth

  memwb_pipelineReg file interface
*/
`ifndef MEMWB_PIPELINEREG_IF_VH
`define MEMWB_PIPELINEREG_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface memwb_pipelineReg_if;

  // import types
  import cpu_types_pkg::*;

  word_t    pc_add4_in, instruction_in;
  logic     regWr_in, memToReg_in;
  regbits_t regDst_in;
  logic     halt_in;
  word_t    portOut_in, dataWriteVal_in;

  word_t    pc_add4, instruction;
  logic     regWr, memToReg;
  regbits_t regDst;
  logic     halt;
  word_t    portOut, dataWriteVal;

endinterface

`endif //MEMWB_PIPELINEREG_IF_VH

