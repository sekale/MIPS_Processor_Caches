/*
  Abhishek Srikanth

  hazard test bench
*/

// mapped needs this
`include "hazard_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

// include and import all types
`include "cpu_types_pkg.vh" // for ALU_OPS
  import cpu_types_pkg::*;

module hazard_tb;

  parameter PERIOD = 10;

  logic CLK = 0;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  hazard_if hzif ();
  // test program
  test PROG (.CLK(CLK), .hzif(hzif) );
  // DUT
`ifndef MAPPED
  hazard DUT(hzif);
`else
  hazard DUT(
    .\hzif.lw_status    (hzif.lw_status),
    .\hzif.jr_status    (hzif.jr_status),
    .\hzif.bra_status   (hzif.bra_status),
    .\hzif.id_rs        (hzif.id_rs),
    .\hzif.id_rt        (hzif.id_rt),
    .\hzif.ex_rd        (hzif.ex_rd),
    .\hzif.flush_ifid   (hzif.flush_ifid),
    .\hzif.flush_idex   (hzif.flush_idex),
    .\hzif.flush_exmem  (hzif.flush_exmem),
    .\hzif.stall        (hzif.stall)
  );
`endif

endmodule

program test
(
  input logic CLK,
  hazard_if hzif
);

  initial
  begin
    hzif.lw_status = 1'b0;
    hzif.jr_status = 1'b0;
    hzif.bra_status = 1'b0;
    hzif.id_rs = 5'd2;
    hzif.id_rt = 5'd3;
    hzif.ex_rd = 5'd4;
    clock(2);
    assertions(4'b0000);
    hzif.jr_status = 1'b1;
    clock(1);
    assertions(4'b1100);
    hzif.jr_status = 1'b0;
    hzif.bra_status = 1'b1;
    clock(1);
    assertions(4'b1110);
    hzif.bra_status = 1'b0;
    hzif.lw_status = 1'b1;
    clock(1);
    assertions(4'b0000);
    hzif.ex_rd = 5'd3;
    clock(1);
    assertions(4'b0101);
    hzif.ex_rd = 5'd2;
    clock(1);
    assertions(4'b0101);
    hzif.lw_status = 1'b0;
    clock(1);
    assertions(4'b0000);
    clock(5);
    $finish();
  end

  task assertions(logic [3:0] bits);
    assert(hzif.flush_ifid == bits[3]) else $error("unexpected flush");
    assert(hzif.flush_idex == bits[2]) else $error("unexpected flush");
    assert(hzif.flush_exmem == bits[1]) else $error("unexpected flush");
    assert(hzif.stall == bits[0]) else $error("unexpected stall");
  endtask


  task clock(integer i);
    for(integer j = 0; j < i; j = j + 1)
      @(negedge CLK);
  endtask

endprogram
