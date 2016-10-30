// mapped needs this
`include "caches_if.vh"
`include "datapath_cache_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

// include and import all types
`include "cpu_types_pkg.vh" // for cache_OPS
  import cpu_types_pkg::*;

module icache_tb;

  parameter PERIOD = 10;

  logic CLK = 0;
  logic n_rst;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  caches_if ic ();
  datapath_cache_if dp ();
  // test program
  test PROG (.clk(CLK), .n_rst(n_rst), .dp(dp), .ic(ic)  );
  // DUT
`ifndef MAPPED
  icache DUT( .clk(CLK), .n_rst(n_rst), .dp(dp.icache), .ic(ic.icache) );
`else
  icache DUT(
    .\dp.imemREN    (dp.imemREN),
    .\dp.imemaddr   (dp.imemaddr),
    .\dp.ihit       (dp.ihit),
    .\dp.imemload   (dp.imemload),
    .\ic.iwait      (ic.iwait),
    .\ic.iload      (ic.iload),
    .\ic.iREN       (ic.iREN),
    .\ic.iaddr      (ic.iaddr),
    .\clk           (CLK),
    .\n_rst         (n_rst)
  );
`endif

endmodule

program test
(
  input logic clk,
  output logic n_rst,
  datapath_cache_if dp,
  caches_if ic
);

    task clock(int i);
        for(int j = 0; j < i; j += 1)
            @(posedge clk);
    endtask

    initial
    begin

        dp.imemREN = 1'b0;
        dp.imemaddr = {26'd50, 4'b0000, 2'd0};
        ic.iwait = 1'b0;
        ic.iload = 32'd432;
        n_rst = 1'b0;
        clock(1);

        n_rst = 1'b1;

        for(int i = 0 ; i < 32; i++)
        begin
            dp.imemREN = 1'b0;
            clock(2);

            dp.imemREN = 1'b1;
            dp.imemaddr = {26'(i), 4'(i%16), 2'd0};
            //$display ("iwait will now be #2 asserted here:",$time);
            ic.iwait = 1'b1;
            ic.iload = i;

            clock(1);

            //iwait #2 asserted to 1
            #2 assert(dp.ihit == 1'b0) //state passes
            else $error("ihit should not have #2 asserted to 1 when iwait was still 1");

            clock(2);
            #2 assert(dp.ihit == 1'b0)
            else $error("didn't pass, wrong behaviour");
            clock(1);

            ic.iwait = 1'b0;
            clock(2); //check this hack, before it was clock(1)
            #2 assert(dp.ihit == 1'b1)
            else $error("ihit failed after ic.iwait was de-#2 asserted");

            clock(1);
            // in checkdata
            #2 assert(dp.ihit == 1'b1)
            else $error("ihit failed");

            #2 assert(dp.imemload == i)
            else $error("Wrong value Loaded");

            clock(1);

        end

        for(int i =16 ; i < 32; i++)
        begin
            dp.imemREN = 1'b0;
            clock(2);

            dp.imemREN = 1'b1;
            dp.imemaddr = {26'(i), 4'(i%16), 2'd0};
            ic.iwait = 1'b0;
            ic.iload = i;

            clock(2); //same hack it was clock(1) before

            // in checkdata
            #2 assert(dp.ihit == 1'b1)
            else $error("ihit failed");

            #2 assert(dp.imemload == i)
            else $error("Wrong value Loaded");

            clock(1);
        end


    end

endprogram
