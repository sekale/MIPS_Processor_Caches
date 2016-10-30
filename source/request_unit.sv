/*
  Abhishek Srikanth

  Request Unit Module
*/

// data path interface
`include "request_unit_if.vh"

// cpu type definitions
`include "cpu_types_pkg.vh"

module request_unit (
  input logic clk, n_rst,
  request_unit_if.ru ruif
);

  // import types
  import cpu_types_pkg::*;

  assign ruif.iaddr_out = ruif.iaddr_in;
  assign ruif.daddr_out = ruif.daddr_in;
  assign ruif.store_out = ruif.store_in;

  // ihit, dhit, iREN, dREN, dWEN
  assign ruif.ihit_out = ruif.ihit_in;  // can remove from cuif and ruif
  assign ruif.dhit_out = ruif.dhit_in;

  //assign ruif.iREN_out = ruif.iREN_in;

  always_ff @(posedge clk, negedge n_rst)
  begin
    if(n_rst == 1'b0)
    begin
      ruif.iREN_out = 1'b0;
      ruif.dREN_out = 1'b0;
      ruif.dWEN_out = 1'b0;
    end
    else
    begin
      ruif.iREN_out <= ruif.iREN_in;
      if(ruif.ihit_in == 1'b1)
      begin
        ruif.dREN_out <= ruif.dREN_in;
        ruif.dWEN_out <= ruif.dWEN_in;
      end
      if(ruif.dhit_in == 1'b1)
      begin
        ruif.dREN_out <= 1'b0;
        ruif.dWEN_out <= 1'b0;
      end
    end
  end

endmodule
