/*
  Abhishek Srikanth

  request unit interface
*/
`ifndef REQUEST_UNIT_IF_VH
`define REQUEST_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface request_unit_if;

  // import types
  import cpu_types_pkg::*;

  logic     ihit_in, dhit_in;
  logic     iREN_in, dREN_in, dWEN_in;
  logic     ihit_out, dhit_out;
  logic     iREN_out, dREN_out, dWEN_out;
  word_t    iaddr_in, daddr_in, store_in;
  word_t    iaddr_out, daddr_out, store_out;

  // request_unit ports
  modport ru
  (
    input ihit_in, dhit_in, iREN_in, dREN_in, dWEN_in, iaddr_in, daddr_in, store_in,
    output ihit_out, dhit_out, iREN_out, dREN_out, dWEN_out, iaddr_out, daddr_out, store_out
  );

endinterface

`endif //REQUEST_UNIT_IF_VH
