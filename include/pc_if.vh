/*
  Abhishek Srikanth

  program counter interface
*/
`ifndef PC_IF_VH
`define PC_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface pc_if;

  // import types
  import cpu_types_pkg::*;

  logic               jr_enable, bra_enable, j_enable, pc_enable;
  word_t              jr_addr, bra_addr;
  logic [ADDR_W-1:0]  j_addr;
  word_t              iaddr, pc_add4;



  // pc ports
  modport pc
  (
    input   jr_enable, bra_enable, j_enable, pc_enable,
            jr_addr, bra_addr, j_addr,
    output  iaddr, pc_add4
  );

endinterface

`endif //PC_IF_VH
