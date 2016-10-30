/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();
  // test program
  test PROG (.CLK, .nRST, .io(rfif.tb) );
  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\n_rst (nRST),
    .\clk (CLK)
  );
`endif

endmodule

program test
(
  input logic CLK,
  output logic nRST,
  register_file_if.tb io
);

  initial
  begin
    nRST = 1;
    io.WEN = 0;
    io.wsel = 0;
    io.rsel1 = 0;
    io.rsel2 = 0;
    io.wdat = 0;
    @(negedge CLK);
    nRST = 0;
    @(negedge CLK);
    @(negedge CLK);
    nRST = 1;
    assert(io.rdat1 == '0) else $error("data in $0 is %d", io.rdat1);
    assert(io.rdat2 == '0) else $error("data in $0 is %d", io.rdat2);
    @(negedge CLK);
    io.rsel1 = 'd4;
    io.rsel2 = 'd5;
    assert(io.rdat1 == '0) else $error("data in $4 is %d", io.rdat1);
    assert(io.rdat2 == '0) else $error("data in $5 is %d", io.rdat2);

    @(negedge CLK);
    io.wsel = '0;
    io.wdat = 32'd55;
    io.WEN = 1;
    io.rsel1 = 'd0;
    io.rsel2 = 'd1;
    assert(io.rdat1 == '0) else $error("data in $4 is %d", io.rdat1);
    assert(io.rdat2 == '0) else $error("data in $5 is %d", io.rdat2);

    for(int j = 0; j < 31; j++)
    begin

      io.WEN = 1;
      io.wsel = j;
      //assert(io.rdat1 == '0) else $error("data in $4 is %d", io.rdat1);
      //assert(io.rdat2 == 'd55) else $error("data in $5 is %d", io.rdat2);
      io.rsel1 = j;
      io.rsel2 = j + 1;
      @(negedge CLK);

      io.WEN = 0;
      assert(io.rdat1 == 'd55) else $error("data in $%d is %d", j,   io.rdat1);
      assert(io.rdat2 ==  'd0) else $error("data in $%d is %d", j+1, io.rdat2);
      @(negedge CLK);

    end

    io.WEN = 1;
    io.wsel = 31;
    //assert(io.rdat1 == '0) else $error("data in $4 is %d", io.rdat1);
    //assert(io.rdat2 == 'd55) else $error("data in $5 is %d", io.rdat2);
    io.rsel1 = 31;
    io.rsel2 = 31;
    @(negedge CLK);

    io.WEN = 0;
    assert(io.rdat1 == 'd55) else $error("data in $31 is %d", io.rdat1);
    assert(io.rdat2 == 'd55) else $error("data in $31 is %d", io.rdat2);
    @(negedge CLK);


  end

endprogram
