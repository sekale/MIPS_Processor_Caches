`include "cpu_types_pkg.vh"
`include "ifid_pipelineReg_if.vh"

import cpu_types_pkg::*;

module ifid_pipelineReg
(
  input logic clk, n_rst, enable, stall, flush,
  ifid_pipelineReg_if ifid
);

always_ff @(posedge clk, negedge n_rst)
begin
  if(n_rst == 1'b0)
  begin
    ifid.pc_add4 <= '0;
    ifid.instruction <= '0;
  end
  else
  begin

    if (enable == 1'b1)
    begin
      if(flush == 1'b1)
      begin
        ifid.pc_add4 <= '0;
        ifid.instruction <= '0; // effectively sets destination to $0, hence NOP
      end
      else if(stall == 1'b0)
      begin
        ifid.pc_add4 <= ifid.pc_add4_in;
        ifid.instruction <= ifid.instruction_in;
      end
      else // stall == 1'b1
      begin
        ifid.pc_add4 <= ifid.pc_add4;
        ifid.instruction <= ifid.instruction;
      end
    end
    else
    begin
      ifid.pc_add4 <= ifid.pc_add4;
      ifid.instruction <= ifid.instruction;
    end

  end
end

endmodule
