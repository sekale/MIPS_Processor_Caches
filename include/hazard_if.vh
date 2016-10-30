/*
  Abhishek Srikanth

  hazard file interface
*/
`ifndef HAZARD_IF_VH
`define HAZARD_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface hazard_if;

  // import types
  import cpu_types_pkg::*;

  logic     lw_status, jr_status, bra_status;
  regbits_t id_rs, id_rt, ex_rd;
  logic     flush_ifid, flush_idex, flush_exmem, stall;

endinterface

`endif //HAZARD_IF_VH
