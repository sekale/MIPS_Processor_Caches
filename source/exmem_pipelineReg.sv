`include "cpu_types_pkg.vh"
`include "exmem_pipelineReg_if.vh"

import cpu_types_pkg::*;

module exmem_pipelineReg
(
  input logic clk, n_rst, enable, flush,
  exmem_pipelineReg_if exmem
);

always_ff @(posedge clk, negedge n_rst)
begin
  if(n_rst == 1'b0)
  begin
    exmem.pc_add4 <= '0;
    exmem.instruction <= '0;
    exmem.opCode <= opcode_t'('0);
    exmem.immediate <= '0;
    exmem.portB_fwd <= '0;
    exmem.dREN <= 1'b0;
    exmem.dWEN <= 1'b0;
    exmem.regWr <= 1'b0;
    exmem.memToReg <= 1'b0;
    exmem.regDst <= '0;
    exmem.zeroFlag <= 1'b0;
    exmem.bra_addr <= '0;
    exmem.halt <= 1'b0;
    exmem.portOut <= '0;
  end
  else
  begin
    if(enable == 1'b1)
    begin
      if (flush == 1'b1)
      begin
        exmem.pc_add4 <= '0;
        exmem.instruction <= '0;
        exmem.opCode <= opcode_t'('0);
        exmem.immediate <= '0;
        exmem.portB_fwd <= '0;
        exmem.dREN <= 1'b0;
        exmem.dWEN <= 1'b0;
        exmem.regWr <= 1'b0;
        exmem.memToReg <= 1'b0;
        exmem.regDst <= '0;
        exmem.zeroFlag <= 1'b0;
        exmem.bra_addr <= '0;
        exmem.halt <= 1'b0;
        exmem.portOut <= '0;
      end

      else
      begin
        exmem.pc_add4 <= exmem.pc_add4_in;
        exmem.instruction <= exmem.instruction_in;
        exmem.opCode <= exmem.opCode_in;
        exmem.immediate <= exmem.immediate_in;
        exmem.portB_fwd <= exmem.portB_fwd_in;
        exmem.dREN <= exmem.dREN_in;
        exmem.dWEN <= exmem.dWEN_in;
        exmem.regWr <= exmem.regWr_in;
        exmem.memToReg <= exmem.memToReg_in;
        exmem.regDst <= exmem.regDst_in;
        exmem.zeroFlag <= exmem.zeroFlag_in;
        exmem.bra_addr <= exmem.bra_addr_in;
        exmem.halt <= exmem.halt_in;
        exmem.portOut <= exmem.portOut_in;
      end
    end
    else
    begin
      exmem.pc_add4 <= exmem.pc_add4;
      exmem.instruction <= exmem.instruction;
      exmem.opCode <= exmem.opCode;
      exmem.immediate <= exmem.immediate;
      exmem.portB_fwd <= exmem.portB_fwd;
      exmem.dREN <= exmem.dREN;
      exmem.dWEN <= exmem.dWEN;
      exmem.regWr <= exmem.regWr;
      exmem.memToReg <= exmem.memToReg;
      exmem.regDst <= exmem.regDst;
      exmem.zeroFlag <= exmem.zeroFlag;
      exmem.bra_addr <= exmem.bra_addr;
      exmem.halt <= exmem.halt;
      exmem.portOut <= exmem.portOut;
    end

  end
end

endmodule
