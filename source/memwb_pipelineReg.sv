`include "cpu_types_pkg.vh"
`include "memwb_pipelineReg_if.vh"

import cpu_types_pkg::*;

module memwb_pipelineReg
(
  input logic clk, n_rst, enable,
  memwb_pipelineReg_if memwb
);

always_ff @(posedge clk, negedge n_rst)
begin
  if(n_rst == 1'b0)
  begin
    memwb.pc_add4 <= '0;
    memwb.instruction <= '0;
    memwb.regWr <= 1'b0;
    memwb.memToReg <= 1'b0;
    memwb.regDst <= '0;
    memwb.halt <= 1'b0;
    memwb.portOut <= '0;
    memwb.dataWriteVal <= '0;
  end
  else if (enable == 1'b1)
  begin
    memwb.pc_add4 <= memwb.pc_add4_in;
    memwb.instruction <= memwb.instruction_in;
    memwb.regWr <= memwb.regWr_in;
    memwb.memToReg <= memwb.memToReg_in;
    memwb.regDst <= memwb.regDst_in;
    memwb.halt <= memwb.halt_in;
    memwb.portOut <= memwb.portOut_in;
    memwb.dataWriteVal <= memwb.dataWriteVal_in;
  end
  else
  begin
    memwb.pc_add4 <= memwb.pc_add4;
    memwb.instruction <= memwb.instruction;
    memwb.regWr <= memwb.regWr;
    memwb.memToReg <= memwb.memToReg;
    memwb.regDst <= memwb.regDst;
    memwb.portOut <= memwb.portOut;
    memwb.dataWriteVal <= memwb.dataWriteVal;
    memwb.halt <= memwb.halt; // CHECK
  end
end

endmodule
