/*
  Abhishek Srikanth

  forwarding_unit file interface
*/
`ifndef FORWARDING_UNIT_IF_VH
`define FORWARDING_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface forwarding_unit_if;

  // import types
  import cpu_types_pkg::*;

  logic     mem_regWr,  wb_regWr;
  regbits_t mem_regDst, wb_regDst;
  regbits_t exe_rs,     exe_rt;

  logic [1:0] rdat1_fwd_mux, rdat2_fwd_mux;

  // forwarding_unit ports
  modport fu
  (
    input   mem_regWr, wb_regWr, mem_regDst, wb_regDst, exe_rs, exe_rt,
    output  rdat1_fwd_mux, rdat2_fwd_mux
  );

endinterface

`endif //FORWARDING_UNIT_IF_VH
