/*
  Abhishek Srikanth

  memory control test bench
*/
// memory types
`include "cpu_types_pkg.vh"

// mapped needs this
`include "cache_control_if.vh"
`include "caches_if.vh"
`include "cpu_ram_if.vh"

`define EXPAND_MAPPING(IF,SIGNAL) \
  .\``IF``.``SIGNAL``_0_0 (``IF``.``SIGNAL``[0][0]), \
  .\``IF``.``SIGNAL``_0_1 (``IF``.``SIGNAL``[0][1]), \
  .\``IF``.``SIGNAL``_0_2 (``IF``.``SIGNAL``[0][2]), \
  .\``IF``.``SIGNAL``_0_3 (``IF``.``SIGNAL``[0][3]), \
  .\``IF``.``SIGNAL``_0_4 (``IF``.``SIGNAL``[0][4]), \
  .\``IF``.``SIGNAL``_0_5 (``IF``.``SIGNAL``[0][5]), \
  .\``IF``.``SIGNAL``_0_6 (``IF``.``SIGNAL``[0][6]), \
  .\``IF``.``SIGNAL``_0_7 (``IF``.``SIGNAL``[0][7]), \
  .\``IF``.``SIGNAL``_0_8 (``IF``.``SIGNAL``[0][8]), \
  .\``IF``.``SIGNAL``_0_9 (``IF``.``SIGNAL``[0][9]), \
  .\``IF``.``SIGNAL``_0_10 (``IF``.``SIGNAL``[0][10]), \
  .\``IF``.``SIGNAL``_0_11 (``IF``.``SIGNAL``[0][11]), \
  .\``IF``.``SIGNAL``_0_12 (``IF``.``SIGNAL``[0][12]), \
  .\``IF``.``SIGNAL``_0_13 (``IF``.``SIGNAL``[0][13]), \
  .\``IF``.``SIGNAL``_0_14 (``IF``.``SIGNAL``[0][14]), \
  .\``IF``.``SIGNAL``_0_15 (``IF``.``SIGNAL``[0][15]), \
  .\``IF``.``SIGNAL``_0_16 (``IF``.``SIGNAL``[0][16]), \
  .\``IF``.``SIGNAL``_0_17 (``IF``.``SIGNAL``[0][17]), \
  .\``IF``.``SIGNAL``_0_18 (``IF``.``SIGNAL``[0][18]), \
  .\``IF``.``SIGNAL``_0_19 (``IF``.``SIGNAL``[0][19]), \
  .\``IF``.``SIGNAL``_0_20 (``IF``.``SIGNAL``[0][20]), \
  .\``IF``.``SIGNAL``_0_21 (``IF``.``SIGNAL``[0][21]), \
  .\``IF``.``SIGNAL``_0_22 (``IF``.``SIGNAL``[0][22]), \
  .\``IF``.``SIGNAL``_0_23 (``IF``.``SIGNAL``[0][23]), \
  .\``IF``.``SIGNAL``_0_24 (``IF``.``SIGNAL``[0][24]), \
  .\``IF``.``SIGNAL``_0_25 (``IF``.``SIGNAL``[0][25]), \
  .\``IF``.``SIGNAL``_0_26 (``IF``.``SIGNAL``[0][26]), \
  .\``IF``.``SIGNAL``_0_27 (``IF``.``SIGNAL``[0][27]), \
  .\``IF``.``SIGNAL``_0_28 (``IF``.``SIGNAL``[0][28]), \
  .\``IF``.``SIGNAL``_0_29 (``IF``.``SIGNAL``[0][29]), \
  .\``IF``.``SIGNAL``_0_30 (``IF``.``SIGNAL``[0][30]), \
  .\``IF``.``SIGNAL``_0_31 (``IF``.``SIGNAL``[0][31])

  // type import
  import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module memory_control_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  caches_if         cif0 ();
  caches_if         cif1 ();
  cpu_ram_if        ramif  ();
  cache_control_if  ccif (cif0, cif1);

  assign ramif.ramREN = ccif.ramREN;
  assign ramif.ramWEN = ccif.ramWEN;
  assign ramif.ramaddr = ccif.ramaddr;
  assign ramif.ramstore = ccif.ramstore;

  assign ccif.ramstate = ramif.ramstate;
  assign ccif.ramload = ramif.ramload;

  // test program
  test PROG (.CLK, .nRST, .cif0(cif0) );
  // DUT
`ifndef MAPPED
  memory_control DUT (CLK, nRST, ccif.cc);
  ram #(.LAT(1)) RAM (CLK, nRST, ramif);
`else
  memory_control DUT(
    .\ccif.iREN (ccif.iREN),
    .\ccif.dREN (ccif.dREN),
    .\ccif.dWEN (ccif.dWEN),
    `EXPAND_MAPPING(ccif,dstore),
    `EXPAND_MAPPING(ccif,iaddr),
    `EXPAND_MAPPING(ccif,daddr),
    .\ccif.ramload (ccif.ramload),
    .\ccif.ramstate (ccif.ramstate),
    .\ccif.ccwrite (ccif.ccwrite),
    .\ccif.cctrans (ccif.cctrans),

    .\ccif.iwait  (ccif.iwait),
    .\ccif.dwait  (ccif.dwait),
    `EXPAND_MAPPING(ccif,iload),
    `EXPAND_MAPPING(ccif,dload),
    .\ccif.ramstore  (ccif.ramstore),
    .\ccif.ramaddr  (ccif.ramaddr),
    .\ccif.ramWEN  (ccif.ramWEN),
    .\ccif.ramREN  (ccif.ramREN),
    .\ccif.ccwait (ccif.ccwait),
    .\ccif.ccinv (ccif.ccinv),
    `EXPAND_MAPPING(ccif,ccsnoopaddr),
    .\nRST (nRST),
    .\CLK (CLK)
  );

  ram #(.LAT(1)) RAM (
    .\CLK (CLK),
    .\nRST (nRST),
    .\ramif.ramREN (ramif.ramREN),
    .\ramif.ramWEN (ramif.ramWEN),
    .\ramif.ramaddr (ramif.ramaddr),
    .\ramif.ramstore (ramif.ramstore),
    .\ramif.ramload (ramif.ramload),
    .\ramif.ramstate (ramif.ramstate)
  );

  // to do ram for mapped state
`endif

endmodule

program test
(
  input logic CLK,
  output logic nRST,
  caches_if cif0
);

  integer readVal;
  logic [63:0] readHexVal;
  integer fp;
  int chksum;
  string ihex;
  bit [7:0][7:0] values;


  initial
  begin
    initialize();
    clock(1);
    nRST = 1'b0;
    clock(1);
    nRST = 1'b1;
    clock(2);

    //loadRAM("meminit.hex");
    initialize();
    mainTests();
    initialize();
    saveRAM("memcpu.hex");
  end

  task initialize();
    nRST = 1'b1;
    cif0.dWEN = 0;
    cif0.dREN = 0;
    cif0.iREN = 0;
    cif0.dstore = '0;
    cif0.iaddr = '0;
    cif0.daddr = '0;
  endtask

  /*
  *   loadRAM
  *   --------
  *   Task to read from meminit and load RAM with instructions
  *
  *   Turns out this is done automatically
  */
  /*task loadRAM(string filename);
    fp = $fopen(filename, "r");
    if(fp)
    begin
      $display("Starting load from %s to RAM", filename);
    end
    else
    begin
      $display("Failed to open %s", filename);
      $finish;
    end

    while( !( $feof(fp) ) )
    begin
      readVal = $fgetc(fp); // read ":"
      readVal = $fgetc(fp); // read "0"
      readVal = $fgetc(fp); // read "4" or "0" at end of file
      if(readVal == "4")
      begin
        cif0.daddr = '0;
        $fscanf(fp, "%h", readHexVal);
        $display("read: %h", readHexVal);
        cif0.daddr = { '0 , readHexVal[63:48] };
        cif0.dstore = readHexVal[39:8];
        $display("address: %h, data: %h", cif0.daddr, cif0.dstore);
        readVal = $fgetc(fp);   // to read 0x0a (new linw)

        cif0.dWEN = 1'b1;             // request data write
        while(cif0.dwait == 1'b1)     // WHILE ram is writing data
        begin                         //        do nothing
          assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
          assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
        clock(1);
        end
        cif0.dWEN = 1'b0;             // turn off request for write data
        assert(cif0.dwait == 1'b0) else $error("dWait not de-asserted (0)");
        assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
        clock(1);                     // wait 1 clocks doing nothing

      end
      else
      begin
        $fscanf(fp, "%h", readHexVal);
       end
    end
    $fclose(fp);
    $display("done reading");
  endtask*/

  /*
  *   mainTests
  *   ----------
  *   Task to test the memory controller operation and arbitration
  */
  task mainTests();

    cif0.iREN = 1'b1;             // request instruction
    cif0.iaddr = 32'h00000004;    // from address 4 (4)
    while(cif0.iwait == 1'b1)     // WHILE ram is getting instruction
    begin                         //        do nothing
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      clock(1);
    end
    cif0.iREN = 1'b0;             // turn off request for instruction
    assert(cif0.iwait == 1'b0) else $error("iWait not de-asserted (0)");
    assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
    clock(2);                     // wait 2 clocks doing nothing

    cif0.iREN = 1'b1;             // request instruction
    cif0.iaddr = 32'h0000000C;    // from address C (12)
    while(cif0.iwait == 1'b1)     // WHILE ram is getting instruction
    begin                         //        do nothing
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      clock(1);
    end
    cif0.iREN = 1'b0;             // turn off request for instruction
    assert(cif0.iwait == 1'b0) else $error("iWait not de-asserted (0)");
    assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
    clock(2);                     // wait 2 clocks doing nothing

    // *************************************************************** //

    cif0.dREN = 1'b1;             // request data
    cif0.daddr = 32'h00000008;    // from address 8 (8)
    while(cif0.dwait == 1'b1)     // WHILE ram is getting data
    begin                         //        do nothing
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      clock(1);
    end
    cif0.dREN = 1'b0;             // turn off request for data
      assert(cif0.dwait == 1'b0) else $error("dWait not de-asserted (0)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
    clock(2);                     // wait 2 clocks doing nothing


    cif0.dREN = 1'b1;             // request data
    cif0.daddr = 32'h00000010;    // from address 10 (16)
    while(cif0.dwait == 1'b1)     // WHILE ram is getting data
    begin                         //        do nothing
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      clock(1);
    end
    cif0.dREN = 1'b0;             // turn off request for data
      assert(cif0.dwait == 1'b0) else $error("dWait not de-asserted (0)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
    clock(2);                     // wait 2 clocks doing nothing


    // *************************************************************** //

    cif0.daddr = '0;
    cif0.dstore = 32'hABABABAB;
    cif0.dWEN = 1'b1;             // request data write
    while(cif0.dwait == 1'b1)     // WHILE ram is writing data
    begin                         //        do nothing
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
    clock(1);
    end
    clock(1);         // to allow ACCESS to see a +ve edge
    cif0.dWEN = 1'b0;             // turn off request for write data
    assert(cif0.dwait == 1'b0) else $error("dWait not de-asserted (0)");
    assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
    clock(1);                     // wait 1 clocks doing nothing


    cif0.dstore = 32'hDABADABA;
    cif0.daddr = 32'h000000FC;    // from address FC (252)
    cif0.dWEN = 1'b1;             // request write operation
    while(cif0.dwait == 1'b1)     // WHILE ram is writing data
    begin                         //        do nothing
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      clock(1);
    end
    clock(1);         // to allow ACCESS to see a +ve edge
    cif0.dWEN = 1'b0;             // turn off request for write operation
      assert(cif0.dwait == 1'b0) else $error("dWait not de-asserted (0)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
    clock(2);                     // wait 2 clocks doing nothing


    cif0.dstore = 32'hBADABADA;
    cif0.daddr = 32'h000000F8;    // from address F8 (248)
    cif0.dWEN = 1'b1;             // request write operation
    while(cif0.dwait == 1'b1)     // WHILE ram is writing data
    begin                         //        do nothing
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      clock(1);
    end
    clock(1);         // to allow ACCESS to see a +ve edge
    cif0.dWEN = 1'b0;             // turn off request for write operation
      assert(cif0.dwait == 1'b0) else $error("dWait not de-asserted (0)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
    clock(2);                     // wait 2 clocks doing nothing

    // continuous reads
    cif0.iREN = 1'b1;
    cif0.iaddr = 32'h000000F8;
    while(cif0.iwait == 1'b1)
    begin
      clock(1);
    end
    cif0.iaddr = 32'h000000FC;
    clock(1);
    while(cif0.iwait == 1'b1)
    begin
      clock(1);
    end
    cif0.iREN = 0;
    clock(2);

    // continuous reads
    cif0.dREN = 1'b1;
    cif0.daddr = 32'h00000000;
    while(cif0.dwait == 1'b1)
    begin
      clock(1);
    end
    cif0.daddr = 32'h00000008;
    clock(1);
    while(cif0.dwait == 1'b1)
    begin
      clock(1);
    end
    cif0.dREN = 0;
    clock(2);

    // *************************************************************** //

    cif0.dREN = 1'b1;             // request data read operation
    cif0.iREN = 1'b1;             // along with next instruction request
    cif0.iaddr = '0;              // where instruction from 0 (0)
    cif0.daddr = 32'h000000FC;    // and data from address FC (252)
    while(cif0.dwait == 1'b1)     // WHILE ram is reading data
    begin                         //        do nothing
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      clock(1);
    end
    cif0.dREN = 1'b0;             // turn off request for read operation
      assert(cif0.dwait == 1'b0) else $error("dWait not de-asserted (0)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
    // but this means instruction only one left
    while(cif0.iwait == 1'b1)     // WHILE ram is writing data
    begin                         //        do nothing
      //assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      //assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      clock(1);
    end
    cif0.iREN = 1'b0;             // turn off request for instruction read
      assert(cif0.iwait == 1'b0) else $error("iWait not de-asserted (0)");
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
    clock(2);                     // wait 2 clocks doing nothing



    cif0.dWEN = 1'b1;             // request data write operation
    cif0.iREN = 1'b1;             // along with next instruction request
    cif0.iaddr = '0;              // where instruction from 0 (0)
    cif0.daddr = 32'h000000F4;    // and data to address F4 (244)
    cif0.dstore = 32'hADADA111;
    while(cif0.dwait == 1'b1)     // WHILE ram is writing data
    begin                         //        do nothing
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      clock(1);
    end
    cif0.dWEN = 1'b0;             // turn off request for write operation
      assert(cif0.dwait == 1'b0) else $error("dWait not de-asserted (0)");
      assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
    // but this means instruction only one left
    while(cif0.iwait == 1'b1)     // WHILE ram is reading instruction
    begin                         //        do nothing
      //assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
      //assert(cif0.iwait == 1'b1) else $error("iWait not asserted (1)");
      clock(1);
    end
    cif0.iREN = 1'b0;             // turn off request for write operation
      assert(cif0.iwait == 1'b0) else $error("iWait not de-asserted (0)");
      assert(cif0.dwait == 1'b1) else $error("dWait not asserted (1)");
    clock(2);                     // wait 2 clocks doing nothing

    clock(1);
  endtask

  task saveRAM(string filename);

    cif0.iaddr = 0;
    cif0.dREN = 0;
    cif0.iREN = 0;
    cif0.dWEN = 0;

    fp = $fopen(filename,"w");
    if (fp)
    begin
      $display("Starting memory dump.");
    end
    else
    begin
      $display("Failed to open %s.",filename);
      $finish;
    end

    cif0.iREN = 1;
    for (int unsigned i = 0; fp && i < 16384; i++)  // for loop to iterate
    begin                                           // ram_word_size times

      cif0.iaddr = i << 2;
      clock(1);
      while(cif0.iwait == 1'b1)
      begin
        clock(1); //repeat (4) @(posedge CLK);
      end

      if (cif0.iload === 0)
        continue;

      values = {8'h04,16'(i),8'h00,cif0.iload};

      chksum = 0;
      foreach (values[j])
        chksum += values[j];
      chksum = 16'h100 - chksum;

      ihex = $sformatf(":04%h00%h%h",16'(i),cif0.iload,8'(chksum));
      $fdisplay(fp,"%s",ihex.toupper());
      $display("%h",ihex);
    end //for

    if (fp)
    begin
      cif0.iREN = 0;
      $fdisplay(fp,":00000001FF");
      $fclose(fp);
      $display("Finished memory dump.");
    end
  endtask



  task clock(int n);
    for (int i = 0; i < n; i++)
    begin
      @(negedge CLK);
    end
  endtask

endprogram
