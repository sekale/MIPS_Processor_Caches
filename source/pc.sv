/*
  Abhishek Srikanth

  Program Counter Module
*/

// data path interface
`include "pc_if.vh"

// cpu type definitions
`include "cpu_types_pkg.vh"

module pc (
  input logic clk, n_rst,
  pc_if.pc pcif
);

  // import types
  import cpu_types_pkg::*;

  // pc init
  parameter PC_INIT = 0;

  // definitions
  word_t pcVal, pcVal_nxt, pc_add4;
  logic j_bra_jr_OR, bra_jr_OR;

  assign   bra_jr_OR  = pcif.bra_enable | pcif.jr_enable;
  assign j_bra_jr_OR  = pcif.j_enable   | bra_jr_OR;

  // assign pcif output values
  assign pcif.iaddr = pcVal;
  assign pcif.pc_add4 = pc_add4;
  assign pc_add4 = pcVal + 4;

  always_comb
  begin : pc_nextStateLogic

    if(pcif.pc_enable == 1'b1)
    begin

      if(j_bra_jr_OR == 1'b1)
      begin

        if(bra_jr_OR == 1'b1)
        begin
          if(pcif.bra_enable == 1'b1)   // max precedence to bra
          begin
            pcVal_nxt = pcif.bra_addr;
          end
          else  // jr_enable is high (since their OR was high)
          begin                         // next precedence is jr
            pcVal_nxt = pcif.jr_addr;
          end
        end
        else                            // j has 3rd precedence
        begin
          pcVal_nxt = {pc_add4[31:28], pcif.j_addr, 2'b00};
        end

      end
      else
      begin
        pcVal_nxt = pcVal + 4;
      end

    end
    else
    begin
      pcVal_nxt = pcVal;
    end

  end

  always_ff @(posedge clk, negedge n_rst)
  begin : pcRegister
    if(n_rst == 1'b0)
    begin
      pcVal <= PC_INIT;
    end
    else
    begin
      pcVal <= pcVal_nxt;
    end
  end

endmodule
