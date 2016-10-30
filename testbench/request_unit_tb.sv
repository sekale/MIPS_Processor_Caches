/*
  Abhishek Srikanth

  alu test bench
*/

// mapped needs this
`include "request_unit_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

// include and import all types
`include "cpu_types_pkg.vh"
  import cpu_types_pkg::*;

module request_unit_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  request_unit_if ruif ();
  // test program
  test PROG (.clk(CLK), .n_rst(nRST), .ruif(ruif) );
  // DUT
`ifndef MAPPED
  request_unit DUT(.clk(CLK), .n_rst(nRST), .ruif(ruif.ru) );
`else
  request_unit DUT(
    .\clk(CLK),
    .\n_rst(nRST),
    .\ruif.ihit_in (ruif.ihit_in),
    .\ruif.dhit_in (ruif.dhit_in),
    .\ruif.iREN_in (ruif.iREN_in),
    .\ruif.dREN_in (ruif.dREN_in),
    .\ruif.dWEN_in (ruif.dWEN_in),
    .\ruif.ihit_out (ruif.ihit_out),
    .\ruif.dhit_out (ruif.dhit_out),
    .\ruif.iREN_out (ruif.iREN_out),
    .\ruif.dREN_out (ruif.dREN_out),
    .\ruif.dWEN_out (ruif.dWEN_out),
    .\ruif.iaddr_in (ruif.iaddr_in),
    .\ruif.daddr_in (ruif.daddr_in),
    .\ruif.store_in (ruif.store_in),
    .\ruif.iaddr_out (ruif.iaddr_out),
    .\ruif.daddr_out (ruif.daddr_out),
    .\ruif.store_out (ruif.store_out)
  );
`endif

endmodule

program test
(
  input logic clk,
  output logic n_rst,
  request_unit_if ruif
);

  initial
  begin
    n_rst = 1'b1;
    ruif.ihit_in = 1'b0;
    ruif.dhit_in = 1'b0;
    ruif.daddr_in = '0;
    ruif.store_in = '0;
    ruif.iaddr_in = '0;
    ruif.iREN_in = 1'b1;
    ruif.dREN_in = 1'b0;
    ruif.dWEN_in = 1'b0;
    clock(1);
    $display("testing reset");
    n_rst = 1'b0;
    clock(2);
    assert(ruif.iREN_out == 1'b0) $display("reset iREN pass"); else $error("in reset, iREN must be low");
    n_rst = 1'b1;
    clock(2);
    assert(ruif.iREN_out == 1'b1) $display("iREN out high pass"); else $error("iREN not high");
    ruif.ihit_in = 1'b1;
    ruif.iaddr_in = 'd4;
    clock(1);
    ruif.ihit_in = 1'b0;
    assert(ruif.iREN_out == 1'b1) $display("new iREN out high pass"); else $error("iREN not high");
    assert(ruif.iaddr_in == 'd4) $display("new iaddr pass"); else $error("wrong address");
    clock(1);
    ruif.dREN_in = 1'b1;
    clock(2);
    assert(ruif.dREN_out == 1'b0) $display("dren low before ihit pass"); else $error("dREN should be low");
    clock(1);
    ruif.ihit_in  = 1'b1;
    clock(1);
    assert(ruif.dREN_out == 1'b1) $display("dren high on ihit pass"); else $error("dREN should be high");
    clock(1);
    ruif.dhit_in = 1'b1;
    clock(1);
    assert(ruif.dREN_out == 1'b0) $display("dren low after dhit pass"); else $error("dREN should be low");
    clock(2);
    ruif.dREN_in = 1'b0;
    ruif.dWEN_in = 1'b1;
    clock(3);

    $display("finished testing");
  end

  task clock(int i);
    for(int j = 0; j < i; j+=1)
    begin
      @(negedge clk);
    end
  endtask

endprogram
