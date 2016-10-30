/*
  Abhishek Srikanth

  Forwarding Unit Module
*/

// data path interface
`include "forwarding_unit_if.vh"

// cpu type definitions
`include "cpu_types_pkg.vh"

module forwarding_unit (
  forwarding_unit_if.fu fuif
);

  // import types
  import cpu_types_pkg::*;

  localparam originalValue = 2'b00;
  localparam memStageValue = 2'b01;
  localparam wbStageValue  = 2'b10;

  // definitions

  // assign fuif output values

  always_comb
  begin : for_rdat1

    if( (fuif.mem_regWr == 1'b1) && (fuif.exe_rs == fuif.mem_regDst) && (fuif.mem_regDst != 5'd0) )
    begin
      fuif.rdat1_fwd_mux = memStageValue;
    end
    else if( (fuif.wb_regWr == 1'b1) && (fuif.exe_rs == fuif.wb_regDst) && (fuif.wb_regDst != 5'd0) )
    begin
      fuif.rdat1_fwd_mux = wbStageValue;
    end
    else
    begin
      fuif.rdat1_fwd_mux = originalValue;
    end
  end

  always_comb
  begin : for_rdat2

    if( (fuif.mem_regWr == 1'b1) && (fuif.exe_rt == fuif.mem_regDst) && (fuif.mem_regDst != 5'd0) )
    begin
      fuif.rdat2_fwd_mux = memStageValue;
    end
    else if( (fuif.wb_regWr == 1'b1) && (fuif.exe_rt == fuif.wb_regDst) && (fuif.wb_regDst != 5'd0) )
    begin
      fuif.rdat2_fwd_mux = wbStageValue;
    end
    else
    begin
      fuif.rdat2_fwd_mux = originalValue;
    end
  end

endmodule
