/*
  Abhishek Srikanth

  Hazard Unit Module
*/

// data path interface
`include "hazard_if.vh"

// cpu type definitions
`include "cpu_types_pkg.vh"

module hazard (
  hazard_if hzif
);

  // import types
  import cpu_types_pkg::*;

  // definitions
  logic   lw_delay;

  always_comb
  begin
    lw_delay = 1'b0;
    if(hzif.ex_rd == hzif.id_rs || hzif.ex_rd == hzif.id_rt)
    begin
      lw_delay = 1'b1;
    end
  end

  always_comb
  begin
    if(hzif.bra_status == 1'b1)
    begin
      // in case we get a branch, LW and JR signals may be ignored
      hzif.stall = 1'b0;
      hzif.flush_ifid = 1'b1;
      hzif.flush_idex = 1'b1;
      hzif.flush_exmem = 1'b1;
    end
    else if( (hzif.lw_status & lw_delay) == 1'b1 )
    begin
      hzif.stall = 1'b1;
      hzif.flush_ifid = 1'b0;
      hzif.flush_idex = 1'b1;
      hzif.flush_exmem = 1'b0;
    end
    else if(hzif.jr_status == 1'b1)
    begin
      hzif.stall = 1'b0;
      hzif.flush_ifid = 1'b1;
      hzif.flush_idex = 1'b1;
      hzif.flush_exmem = 1'b0;
    end
    else
    begin
      hzif.stall = 1'b0;
      hzif.flush_ifid = 1'b0;
      hzif.flush_idex = 1'b0;
      hzif.flush_exmem = 1'b0;
    end
  end
endmodule
