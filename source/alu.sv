`include "cpu_types_pkg.vh"
`include "alu_if.vh"

import cpu_types_pkg::*;

module alu
(
  alu_if.alu io
);

always_comb
begin

  case(io.aluOp)

    ALU_SLL:
    begin
      io.portOut = io.portA << io.portB;
      io.overflow = 1'b0;
    end

    ALU_SRL:
    begin
      io.portOut = io.portA >> io.portB;
      io.overflow = 1'b0;
    end

    ALU_ADD:
    begin
      io.portOut = io.portA + io.portB;
      if( (io.portA[WORD_W-1] == io.portB[WORD_W-1]) && (io.portOut[WORD_W-1] != io.portA[WORD_W-1]) )
      begin
        io.overflow = 1'b1;
      end
      else
      begin
        io.overflow = 1'b0;
      end
    end

    ALU_SUB:
    begin
      io.portOut = io.portA - io.portB;
      if( (io.portA[WORD_W-1] != io.portB[WORD_W-1]) && (io.portOut[WORD_W-1] != io.portA[WORD_W-1]))
      begin
        io.overflow = 1'b1;
      end
      else
      begin
        io.overflow = 1'b0;
      end
    end

    ALU_AND:
    begin
      io.portOut = io.portA & io.portB;
      io.overflow = 1'b0;
    end

    ALU_OR:
    begin
      io.portOut = io.portA | io.portB;
      io.overflow = 1'b0;
    end

    ALU_XOR:
    begin
      io.portOut = io.portA ^ io.portB;
      io.overflow = 1'b0;
    end

    ALU_NOR:
    begin
      io.portOut = ~ (io.portA | io.portB);
      io.overflow = 1'b0;
    end

    ALU_SLT:
    begin
      // comparison syntax from http://excamera.com/sphinx/fpga-verilog-sign.html
      io.portOut = {'0, $signed(io.portA) < $signed(io.portB) };
      io.overflow = 1'b0;
    end

    ALU_SLTU:
    begin
      io.portOut = {'0, io.portA < io.portB};
      io.overflow = 1'b0;
    end

    default:  // to avoid latching
    begin
      io.portOut = '0;
      io.overflow = 1'b0;
    end

  endcase

  io.zero = (io.portOut == '0);

end // end of always_comb block

assign io.negative = io.portOut[WORD_W - 1];

endmodule
