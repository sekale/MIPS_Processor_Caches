// mapped needs this
`include "caches_if.vh"
`include "datapath_cache_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

// include and import all types
`include "cpu_types_pkg.vh" // for cache_OPS
  import cpu_types_pkg::*;

module dcache_tb;

  parameter PERIOD = 10;

  logic CLK = 0;
  logic n_rst;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  caches_if dc ();
  datapath_cache_if dp ();
  // test program
  test PROG (.clk(CLK), .n_rst(n_rst), .dp(dp), .dc(dc)  );
  // DUT
`ifndef MAPPED
  dcache DUT( .clk(CLK), .n_rst(n_rst), .dp(dp.dcache), .dc(dc.dcache) );
`else
  dcache DUT(
    .\dp.halt       (dp.halt),      //
    .\dp.dmemREN    (dp.dmemREN),   //
    .\dp.dmemWEN    (dp.dmemWEN),   //
    //.\dp.datomic  (dp.datomic),   //
    .\dp.dmemaddr   (dp.dmemaddr),  //
    .\dp.dmemstore  (dp.dmemstore), //
    .\dp.dhit       (dp.dhit),
    .\dp.dmemload   (dp.dmemload),
    .\dp.flushed  (dp.flushed),

    .\dc.dwait      (dc.dwait),     //
    .\dc.dload      (dc.dload),     //
    .\dc.dREN       (dc.dREN),
    .\dc.dWEN       (dc.dWEN),
    .\dc.daddr      (dc.daddr),
    .\dc.dstore     (dc.dstore),

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
  caches_if dc
);

    task clock(int i);
        for(int j = 0; j < i; j += 1)
            @(posedge clk);
    endtask

    task loadWord_x4();
      $info("starting load Word task");
      for(int i = 0 ; i < 32; i+=1)
      begin
        clock(1);
        //lw operation on even rows
        dp.dmemREN = 1'b1;
        dp.dmemaddr = {26'(i),3'(i % 8),1'b0, 2'd0};
        clock(1);

        // state READ_1
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
        clock(3);

        // state READ_1
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
        dc.dload = 32'hfeed0000;
        dc.dwait = 1'b0;
        clock(1);

        dc.dwait = 1'b1;
        // state READ_2
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
        clock(3);

        // state READ_2
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
         dc.dload = 32'hfeed1111;
        dc.dwait = 1'b0;
        clock(1);

        dc.dwait = 1'b1;
        // state CHECK
        #2 assert(dp.dhit == 1'b1) else $error("expect dhit HIGH");
        #2 assert(dp.dmemload == 32'hfeed0000);
        clock(1);
        dp.dmemREN = 1'b0;
        clock(1);

        #2 assert(dp.dhit == 1'b0) else $error("expect dhit LOW");
        clock(3);
        // state CHECK
        dp.dmemREN = 1'b1;
        dp.dmemaddr = {26'(i),3'(i),1'b1, 2'd0};

        // state CHECK
        #2 assert(dp.dhit == 1'b1) else $error("expect dhit HIGH");
        #2 assert(dp.dmemload == 32'hfeed1111) else $error("loaded value not as expected");
        clock(1);
        dp.dmemREN = 1'b0;
        clock(3);

      end
      /*
      *   Loaded both ways across all indexes with feed0000 - feed1111
      *   The tags for both ways are different (done by loop indexes)
      */

    endtask

    task storeWord();
    $info("starting store Word task");
    for(int i = 0; i < 16; i+=1)
    begin
      clock(1);
      // state CHECK
      dp.dmemWEN = 1'b1;
      dp.dmemaddr = {26'(i),3'(i % 8),1'b0, 2'd0};
      clock(1);

      // state READ_1
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
      clock(3);

      // state READ_1
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
      dc.dload = 32'hfeed0000;
      dc.dwait = 1'b0;
      clock(1);

      dc.dwait = 1'b1;
      // state READ_2
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
      clock(3);

      // state READ_2
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
       dc.dload = 32'hfeed1111;
      dc.dwait = 1'b0;
      clock(1);

      dc.dwait = 1'b1;
      // state CHECK
      dp.dmemstore = 32'hbabe0000;
      #2 assert(dp.dhit == 1'b1) else $error("expected dhit HIGH");
      clock(1);
      // value is written here
      dp.dmemWEN = 1'b0;
      clock(1);

      #2 assert(dp.dhit == 1'b0) else $error("expected dhit LOW");
      clock(3);



      // state CHECK
      dp.dmemWEN = 1'b1;
      dp.dmemaddr = {26'(i),3'(i % 8),1'b1, 2'd0};
      dp.dmemstore = 32'hbabe1111;
      // state CHECK
      #2 assert(dp.dhit == 1'b1) else $error("expected dhit HIGH");
      clock(1);
      dp.dmemWEN = 1'b0;
      clock(1);

      #2 assert(dp.dhit == 1'b0) else $error("expected dhit LOW");
      clock(3);

      dp.dmemREN = 1'b1;
      dp.dmemaddr = {26'(i),3'(i % 8),1'b0, 2'd0};
      //clock(1);
      #2 assert(dp.dhit == 1'b1) else $error("expect dhit HIGH");
      #2 assert(dp.dmemload == 32'hbabe0000);
      clock(1);
      dp.dmemaddr = {26'(i),3'(i % 8),1'b1, 2'd0};
      //clock(1);
      #2 assert(dp.dhit == 1'b1) else $error("expect dhit HIGH");
      #2 assert(dp.dmemload == 32'hbabe1111);
      clock(1);
      dp.dmemREN = 1'b0;
      clock(2);
    end

    for(int i = 16; i < 32; i+=1)
    begin
      clock(1);
      // state CHECK
      dp.dmemWEN = 1'b1;
      dp.dmemaddr = {26'(i),3'(i % 8),1'b0, 2'd0};
      clock(1);

      // state WRITE_1
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
      clock(3);

      // state WRITE_1
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
      #2 assert(dc.dstore == 32'hbabe0000) else $error("wrong value written to memory");
      dc.dwait = 1'b0;
      clock(1);

      dc.dwait = 1'b1;
      // state WRITE_2
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
      clock(3);

      // state WRITE_2
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
      #2 assert(dc.dstore == 32'hbabe1111) else $error("wrong value written to memory");
      dc.dwait = 1'b0;
      clock(1);

      dc.dwait = 1'b1;
      // state READ_1
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
      clock(3);

      // state READ_1
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
      dc.dload = 32'hfeed0000;
      dc.dwait = 1'b0;
      clock(1);

      dc.dwait = 1'b1;
      // state READ_2
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
      clock(3);

      // state READ_2
      #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
      #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
      #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
       dc.dload = 32'hfeed1111;
      dc.dwait = 1'b0;
      clock(1);

      dc.dwait = 1'b1;
      // state CHECK
      dp.dmemstore = 32'hbabe0000;
      #2 assert(dp.dhit == 1'b1) else $error("expected dhit HIGH");
      clock(1);

      dp.dmemWEN = 1'b0;
      clock(1);

      #2 assert(dp.dhit == 1'b0) else $error("expected dhit LOW");
      clock(3);



      // state CHECK
      dp.dmemWEN = 1'b1;
      dp.dmemaddr = {26'(i),3'(i % 8),1'b1, 2'd0};
      dp.dmemstore = 32'hbabe1111;

      // state CHECK
      #2 assert(dp.dhit == 1'b1) else $error("expected dhit HIGH");
      clock(1);
      dp.dmemWEN = 1'b0;
      clock(1);

      #2 assert(dp.dhit == 1'b0) else $error("expected dhit LOW");
      clock(3);

      dp.dmemREN = 1'b1;
      dp.dmemaddr = {26'(i),3'(i % 8),1'b0, 2'd0};
      //clock(1);
      #2 assert(dp.dhit == 1'b1) else $error("expect dhit HIGH");
      #2 assert(dp.dmemload == 32'hbabe0000);
      clock(1);
      dp.dmemaddr = {26'(i),3'(i % 8),1'b1, 2'd0};
      //clock(1);
      #2 assert(dp.dhit == 1'b1) else $error("expect dhit HIGH");
      #2 assert(dp.dmemload == 32'hbabe1111);
      clock(1);
      dp.dmemREN = 1'b0;
      clock(2);

    end
    endtask

    task loadWord_dirty();
      $info("starting DIRTY load Word task");
      for(int i = 0 ; i < 16; i+=1)
      begin
        clock(1);
        //lw operation on even rows
        dp.dmemREN = 1'b1;
        dp.dmemaddr = {26'(i),3'(i % 8), 1'b1, 2'd0};
        clock(1);

        // state WRITE_1
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
        clock(3);

        // state WRITE_1
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
        #2 assert(dc.dstore == 32'hbabe0000) else $error("wrong value written to memory");
        dc.dwait = 1'b0;
        clock(1);

        dc.dwait = 1'b1;
        // state WRITE_2
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
        clock(3);

        // state WRITE_2
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
        #2 assert(dc.dstore == 32'hbabe1111) else $error("wrong value written to memory");
        dc.dwait = 1'b0;
        clock(1);

        dc.dwait = 1'b1;
        // state READ_1
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
        clock(3);

        // state READ_1
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b0, 2'd0}) else $error("dc.daddr wrong value");
        dc.dload = 32'hfeed0000;
        dc.dwait = 1'b0;
        clock(1);

        dc.dwait = 1'b1;
        // state READ_2
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
        clock(3);

        // state READ_2
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dREN == 1'b1) else $error("expect dREN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i),1'b1, 2'd0}) else $error("dc.daddr wrong value");
        dc.dload = 32'hfeed1111;
        dc.dwait = 1'b0;
        clock(1);

        dc.dwait = 1'b1;
        // state CHECK
        #2 assert(dp.dhit == 1'b1) else $error("expect dhit HIGH");
        #2 assert(dp.dmemload == 32'hfeed1111);
        clock(1);
        dp.dmemREN = 1'b0;
        clock(1);

        #2 assert(dp.dhit == 1'b0) else $error("expect dhit LOW");
        clock(3);

        // state CHECK
        dp.dmemREN = 1'b1;
        dp.dmemaddr = {26'(i),3'(i),1'b0, 2'd0};
        #2 assert(dp.dhit == 1'b1) else $error("expect dhit HIGH");
        #2 assert(dp.dmemload == 32'hfeed0000) else $error("loaded value not as expected");
        clock(1);
        dp.dmemREN = 1'b0;
        clock(3);

      end

    endtask

    task testHalt();

      dp.halt = 1'b0;
      clock(2);
      // check state
      dp.halt = 1'b1;
      clock(1);
      // in parent halt stage
      clock(1);
      for(int i = 16; i < 32; i += 1)
      begin
        // stage WRITE_1
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i%8),1'b0, 2'd0}) else $error("dc.daddr wrong value");
        clock(3);

        // state WRITE_1
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i%8),1'b0, 2'd0}) else $error("dc.daddr wrong value");
        #2 assert(dc.dstore == 32'hbabe0000) else $error("wrong value written to memory");
        dc.dwait = 1'b0;
        clock(1);

        dc.dwait = 1'b1;
        // state WRITE_2
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i%8),1'b1, 2'd0}) else $error("dc.daddr wrong value");
        clock(3);

        // state WRITE_2
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dWEN == 1'b1) else $error("expect dWEN high");
        #2 assert(dc.daddr ==  {26'(i),3'(i%8),1'b1, 2'd0})
        else $error("dc.daddr wrong value %h",{26'(i),3'(i%8),1'b1, 2'd0});
        #2 assert(dc.dstore == 32'hbabe1111) else $error("wrong value written to memory");
        dc.dwait = 1'b0;
        clock(1);

        dc.dwait = 1'b1;
        // state parent halt
        #2 assert(dp.dhit == 1'b0) else $error("hit should not have #2 asserted as of yet");
        #2 assert(dc.dWEN == 1'b0) else $error("expect dWEN LOW");
        clock(1);
      end

    endtask

    initial
    begin
      n_rst = 1'b1;
      dp.halt = 1'b0;
      dp.dmemREN = 1'b0;
      dp.dmemWEN = 1'b0;
      dp.dmemaddr = 32'd0;
      dp.dmemstore = 32'hbeefbeef;
      dc.dwait = 1'b1;
      dc.dload = 32'hfeedfeed;
      clock(1);

      n_rst = 1'b0;
      clock(3);

      n_rst = 1'b1;

      loadWord_x4();

      storeWord();

      loadWord_dirty();

      n_rst = 1'b1;
      dp.halt = 1'b0;
      dp.dmemREN = 1'b0;
      dp.dmemWEN = 1'b0;
      dp.dmemaddr = 32'd0;
      dp.dmemstore = 32'hbeefbeef;
      dc.dwait = 1'b1;
      dc.dload = 32'hfeedfeed;
      clock(1);

      n_rst = 1'b0;
      clock(3);

      n_rst = 1'b1;

      loadWord_x4();

      storeWord();

      testHalt();

      clock(5);
      $info("finished");

    end

endprogram
