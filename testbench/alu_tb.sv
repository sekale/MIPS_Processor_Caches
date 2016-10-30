/*
  Abhishek Srikanth

  alu test bench
*/

// mapped needs this
`include "alu_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

// include and import all types
`include "cpu_types_pkg.vh" // for ALU_OPS
  import cpu_types_pkg::*;

module alu_tb;

  parameter PERIOD = 10;

  logic CLK = 0;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  alu_if aluObj ();
  // test program
  test PROG (.CLK(CLK), .aluObj(aluObj.alu_tb) );
  // DUT
`ifndef MAPPED
  alu DUT(aluObj);
`else
  alu DUT(
    .\io.negative (aluObj.negative),
    .\io.overflow (aluObj.overflow),
    .\io.zero (aluObj.zero),
    .\io.aluOp (aluObj.aluOp),
    .\io.portA (aluObj.portA),
    .\io.portB (aluObj.portB),
    .\io.portOut (aluObj.portOut)
  );
`endif

endmodule

program test
(
  input logic CLK,
  alu_if.alu_tb aluObj
);

  initial
  begin
    aluObj.portA = 32'h55AA5555;
    aluObj.portB = 32'hAA55AA55;

    @(negedge CLK);
    aluObj.aluOp = ALU_AND;
    #2 assert(aluObj.portOut == (aluObj.portA & aluObj.portB) )
    else $error("AND not working");

    @(negedge CLK);
    aluObj.aluOp = ALU_OR;
    #2 assert(aluObj.portOut == aluObj.portA | aluObj.portB)
    else $error("OR not working");

    @(negedge CLK);
    aluObj.aluOp = ALU_NOR;
    #2 assert(aluObj.portOut != aluObj.portA | aluObj.portB)
    else $error("NOR not working");

    @(negedge CLK);
    aluObj.aluOp = ALU_XOR;
    #2 assert(aluObj.portOut == aluObj.portA ^ aluObj.portB)
    else $error("XOR not working");

    @(negedge CLK);
    aluObj.portA = '0;
    aluObj.portB = '1;

    aluObj.aluOp = ALU_AND;
    #2 assert(aluObj.portOut == aluObj.portA & aluObj.portB)
    else $error("AND not working");

    @(negedge CLK);
    aluObj.aluOp = ALU_OR;
    #2 assert(aluObj.portOut == aluObj.portA | aluObj.portB)
    else $error("OR not working");

    @(negedge CLK);
    aluObj.aluOp = ALU_NOR;
    #2 assert(aluObj.portOut != aluObj.portA | aluObj.portB)
    else $error("NOR not working");

    @(negedge CLK);
    aluObj.aluOp = ALU_XOR;
    #2 assert(aluObj.portOut == aluObj.portA ^ aluObj.portB)
    else $error("XOR not working");

    @(negedge CLK);
    $info("Start of test for bitwise shift and less than");
    aluObj.portA = 32'd8;
    aluObj.portB = 32'h2;

    aluObj.aluOp = ALU_SLL;
    #2 assert(aluObj.portOut == 32'd32)
    else $error("Left shift error");

    @(negedge CLK);
    aluObj.aluOp = ALU_SRL;
    #2 assert(aluObj.portOut == 32'd2)
    else $error("Right shift error");

    @(negedge CLK);
    aluObj.aluOp = ALU_SLT;
    #2 assert(aluObj.portOut == 32'd0)
    else $error("Signed less compare not working");

    @(negedge CLK);
    aluObj.aluOp = ALU_SLTU;
    #2 assert(aluObj.portOut == 32'd0)
    else $error("Unsigned less compare not working");

    @(negedge CLK);
    aluObj.portA = 32'hfffffffe;  // -2
    aluObj.portB = 32'd3;

    aluObj.aluOp = ALU_SLL;
    #2 assert(aluObj.portOut == 32'hfffffff0)
    else $error("Left shift error");

    @(negedge CLK);
    aluObj.aluOp = ALU_SRL;
    #2 assert(aluObj.portOut == 32'h1fffffff)
    else $error("Right shift error");

    @(negedge CLK);
    aluObj.aluOp = ALU_SLT;
    #2 assert(aluObj.portOut == 32'd1)
    else $error("Signed less compare not working");

    @(negedge CLK);
    aluObj.aluOp = ALU_SLTU;
    #2 assert(aluObj.portOut == 32'd0)
    else $error("Unsigned less compare not working");

    @(negedge CLK);
    aluObj.portA = 32'h00000055;
    aluObj.portB = 32'h000000aa;

    @(negedge CLK);
    aluObj.aluOp = ALU_SLT;
    #2 assert(aluObj.portOut == 32'd1)
    else $error("Signed less compare not working");

    @(negedge CLK);
    aluObj.aluOp = ALU_SLTU;
    #2 assert(aluObj.portOut == 32'd1)
    else $error("unsigned less compare not working");

    @(negedge CLK);
    $info("Start of test for add/subtract");
    // small positives
    aluObj.portA = 32'd15;
    aluObj.portB = 32'd17;
    aluObj.aluOp = ALU_ADD;
    #2 assert(aluObj.portOut == 32'd32)
    else $error("ADD not working for small numbers");

    @(negedge CLK);
    aluObj.aluOp = ALU_SUB;
    #2 assert(aluObj.portOut == 32'hfffffffe)
    else $error("SUB not working for small numbers");

    @(negedge CLK);
    // 2 large +ve
    aluObj.portA = 32'h7fffffff;
    aluObj.portB = 32'h70000fff;
    aluObj.aluOp = ALU_ADD;
    #2 assert(aluObj.portOut == aluObj.portA + aluObj.portB)
    else $error("ADD not working for large numbers");
    #2 assert(aluObj.overflow == 1'b1) else $error("overflow not asserted");

    @(negedge CLK);
    aluObj.aluOp = ALU_SUB;
    #2 assert(aluObj.portOut == aluObj.portA - aluObj.portB)
    else $error("SUB not working for small numbers");
    #2 assert(aluObj.overflow == 1'b0) else $error("overflow was asserted");

    @(negedge CLK);
    // 1 large -ve and 1 small -ve
    aluObj.portA = 32'h80000001;
    aluObj.portB = 32'hfffffff0;
    aluObj.aluOp = ALU_ADD;
    #2 assert(aluObj.portOut == aluObj.portA + aluObj.portB)
    else $error("ADD not working for large numbers");
    #2 assert(aluObj.overflow == 1'b1) else $error("overflow not asserted");

    @(negedge CLK);
    aluObj.aluOp = ALU_SUB;
    #2 assert(aluObj.portOut == aluObj.portA - aluObj.portB)
    else $error("SUB not working for small numbers");
    #2 assert(aluObj.overflow == 1'b0) else $error("overflow was asserted");

    @(negedge CLK);
    // 1 large +ve and 1 small -ve
    aluObj.portA = 32'h7fffffff;
    aluObj.portB = 32'hfffffff0;
    aluObj.aluOp = ALU_ADD;
    #2 assert(aluObj.portOut == aluObj.portA + aluObj.portB)
    else $error("ADD not working for large numbers");
    #2 assert(aluObj.overflow == 1'b0) else $error("overflow not asserted");

    @(negedge CLK);
    aluObj.aluOp = ALU_SUB;
    #2 assert(aluObj.portOut == aluObj.portA - aluObj.portB)
    else $error("SUB not working for small numbers");
    #2 assert(aluObj.overflow == 1'b1) else $error("overflow was asserted");

    @(negedge CLK);
    // 1 large -ve and 1 small -ve
    aluObj.portA = 32'h80000001;
    aluObj.portB = 32'd500;
    aluObj.aluOp = ALU_ADD;
    #2 assert(aluObj.portOut == aluObj.portA + aluObj.portB)
    else $error("ADD not working for large numbers");
    #2 assert(aluObj.overflow == 1'b0) else $error("overflow not asserted");

    @(negedge CLK);
    aluObj.aluOp = ALU_SUB;
    #2 assert(aluObj.portOut == aluObj.portA - aluObj.portB)
    else $error("SUB not working for small numbers");
    #2 assert(aluObj.overflow == 1'b1) else $error("overflow was asserted");


    @(negedge CLK);
  end

endprogram
