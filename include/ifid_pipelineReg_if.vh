/*
  Abhishek Srikanth

  ifid_pipelineReg file interface
*/
`ifndef IFID_PIPELINEREG_IF_VH
`define IFID_PIPELINEREG_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface ifid_pipelineReg_if;

  // import types
  import cpu_types_pkg::*;

  word_t    pc_add4_in, instruction_in, pc_add4, instruction;

  // ifid_pipelineReg ports
  modport ifid
  (
    input   pc_add4_in, instruction_in,
    output  pc_add4, instruction
  );

endinterface

`endif //IFID_PIPELINEREG_IF_VH

