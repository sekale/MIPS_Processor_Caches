`include "cpu_types_pkg.vh"
`include "idex_pipelineReg_if.vh"

import cpu_types_pkg::*;

module idex_pipelineReg
(
  input logic clk, n_rst, enable, flush,
  idex_pipelineReg_if idex
);

always_ff @(posedge clk, negedge n_rst)
begin
  if(n_rst == 1'b0)
  begin
    idex.pc_add4 <= '0;
    idex.instruction <= '0;
    idex.rdat1 <= '0;
    idex.rdat2 <= '0;
    idex.halt <= 1'b0;
    idex.dREN <= 1'b0;
    idex.dWEN <= 1'b0;
    idex.extOp <= 1'b0;
    idex.regWr <= 1'b0;
    idex.memToReg <= 1'b0;
    idex.immediate <= '0;
    idex.aluSrc <= 2'b00;
    idex.opCode <= opcode_t'('0);
    idex.aluOp <= aluop_t'('0);
    idex.rs <= '0;
    idex.rt <= '0;
    idex.rd <= '0;
    idex.shamt <= '0;
    idex.isJRFlag <= 1'b0;
  end
  else
  begin
    if(enable == 1'b1)
    begin
      if (flush == 1'b1)
      begin
        idex.pc_add4 <= '0;
        idex.instruction <= '0;
        idex.rdat1 <= '0;
        idex.rdat2 <= '0;
        idex.halt <= 1'b0;
        idex.dREN <= 1'b0;
        idex.dWEN <= 1'b0;
        idex.extOp <= 1'b0;
        idex.regWr <= 1'b0;
        idex.memToReg <= 1'b0;
        idex.immediate <= '0;
        idex.aluSrc <= 2'b00;
        idex.opCode <= opcode_t'('0);
        idex.aluOp <= aluop_t'('0);
        idex.rs <= '0;
        idex.rt <= '0;
        idex.rd <= '0;
        idex.shamt <= '0;
        idex.isJRFlag <= 1'b0;
      end
      else
      begin
        idex.pc_add4 <= idex.pc_add4_in;
        idex.instruction <= idex.instruction_in;
        idex.rdat1 <= idex.rdat1_in;
        idex.rdat2 <= idex.rdat2_in;
        idex.halt <= idex.halt_in;
        idex.dREN <= idex.dREN_in;
        idex.dWEN <= idex.dWEN_in;
        idex.extOp <= idex.extOp_in;
        idex.regWr <= idex.regWr_in;
        idex.memToReg <= idex.memToReg_in;
        idex.immediate <= idex.immediate_in;
        idex.aluSrc <= idex.aluSrc_in;
        idex.opCode <= idex.opCode_in;
        idex.aluOp <= idex.aluOp_in;
        idex.rs <= idex.rs_in;
        idex.rt <= idex.rt_in;
        idex.rd <= idex.rd_in;
        idex.shamt <= idex.shamt_in;
        idex.isJRFlag <= idex.isJRFlag_in;
      end
    end
    else
    begin
      idex.pc_add4 <= idex.pc_add4;
      idex.instruction <= idex.instruction;
      idex.rdat1 <= idex.rdat1;
      idex.rdat2 <= idex.rdat2;
      idex.halt <= idex.halt;
      idex.dREN <= idex.dREN;
      idex.dWEN <= idex.dWEN;
      idex.extOp <= idex.extOp;
      idex.regWr <= idex.regWr;
      idex.memToReg <= idex.memToReg;
      idex.immediate <= idex.immediate;
      idex.aluSrc <= idex.aluSrc;
      idex.opCode <= idex.opCode;
      idex.aluOp <= idex.aluOp;
      idex.rs <= idex.rs;
      idex.rt <= idex.rt;
      idex.rd <= idex.rd;
      idex.shamt <= idex.shamt;
      idex.isJRFlag <= idex.isJRFlag;
    end

  end // if n_rst == 1'b1
end

endmodule
