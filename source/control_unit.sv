/*
  Abhishek Srikanth

  Control Unit Module
*/

// data path interface
`include "control_unit_if.vh"

// cpu type definitions
`include "cpu_types_pkg.vh"

module control_unit (
  input logic clk, n_rst,
  control_unit_if.cu cuif
);

  // import types
  import cpu_types_pkg::*;


  localparam pcVal_nochange = 3'b000;
  localparam pcVal_add4     = 3'b001;
  localparam pcVal_addBRA   = 3'b010;
  localparam pcVal_JR       = 3'b011;
  localparam pcVal_J        = 3'b100;

  localparam regDst_rt      = 2'b00;
  localparam regDst_31      = 2'b01;
  localparam regDst_rd      = 2'b10;

  localparam memToReg_data  = 1'b1;
  localparam memToReg_ALU   = 1'b0;

  localparam aluSrc_regVal    = 2'b00;
  localparam aluSrc_immediate = 2'b01;
  localparam aluSrc_shamt     = 2'b10;

  logic [1:0] regDst;

  opcode_t    opcode;
  assign opcode = opcode_t'(cuif.instruction[31:26]);
  funct_t     funct;
  assign funct  = funct_t'(cuif.instruction[ 5 :0]);

  assign cuif.opCode     = opcode;
  assign cuif.rs         = cuif.instruction[25:21];
  assign cuif.rt         = cuif.instruction[20:16];
  assign cuif.rd         = (regDst == regDst_rd) ? cuif.instruction[15:11]:
                            (regDst == regDst_31) ? 5'd31 : cuif.instruction[20:16];

  assign cuif.shamt      = { '0, cuif.instruction[10: 6] };
  assign cuif.immediate  = cuif.instruction[15: 0];
  assign cuif.isJRFlag   = opcode == RTYPE && funct == JR;

  always_comb
  begin
    // preset values t defaults
    cuif.dREN = 1'b0;
    cuif.dWEN = 1'b0;

    cuif.extOp = 1'b0;
    cuif.aluSrc = aluSrc_regVal;
    cuif.aluOp = ALU_ADD;
    cuif.regWr = 1'b0;
    regDst = regDst_rt;
    cuif.memToReg = memToReg_ALU;
    cuif.halt = 1'b0;

    case(opcode)
    // jtype
    J :
      begin
      end
    JAL :
      begin
        cuif.regWr    = 1'b1;
        regDst   = regDst_31;
        cuif.memToReg = memToReg_ALU;
      end
    // itype
    BEQ :
      begin
        cuif.extOp = 1'b1;
        cuif.aluOp = ALU_XOR;
        cuif.aluSrc = aluSrc_regVal;
      end
    BNE :
      begin
        cuif.extOp = 1'b1;
        cuif.aluOp = ALU_XOR;
        cuif.aluSrc = aluSrc_regVal;
      end
    ADDI, ADDIU :
      begin
        cuif.extOp = 1'b1;
        cuif.aluOp = ALU_ADD;
        cuif.aluSrc = aluSrc_immediate;
        cuif.regWr = 1'b1;
        regDst = regDst_rt;
        cuif.memToReg = memToReg_ALU;
      end
    SLTI :  // signed immediate   A < B op
      begin
        cuif.extOp = 1'b1;
        cuif.aluSrc = aluSrc_immediate;
        cuif.aluOp = ALU_SLT;
        cuif.regWr = 1'b1;
        regDst = regDst_rt;
        cuif.memToReg = memToReg_ALU;
      end
    SLTIU : // unsigned immediate A < B op
      begin
        cuif.extOp = 1'b1;
        cuif.aluSrc = aluSrc_immediate;
        cuif.aluOp = ALU_SLTU;
        cuif.regWr = 1'b1;
        regDst = regDst_rt;
        cuif.memToReg = memToReg_ALU;
      end
    ANDI :
      begin
        cuif.extOp = 1'b0;
        cuif.aluSrc = aluSrc_immediate;
        cuif.aluOp = ALU_AND;
        cuif.regWr = 1'b1;
        regDst = regDst_rt;
        cuif.memToReg = memToReg_ALU;
      end
    ORI :
      begin
        cuif.extOp = 1'b0;
        cuif.aluSrc = aluSrc_immediate;
        cuif.aluOp = ALU_OR;
        cuif.regWr = 1'b1;
        regDst = regDst_rt;
        cuif.memToReg = memToReg_ALU;
      end
    XORI :
      begin
        cuif.extOp = 1'b0;
        cuif.aluSrc = aluSrc_immediate;
        cuif.aluOp = ALU_XOR;
        cuif.regWr = 1'b1;
        regDst = regDst_rt;
        cuif.memToReg = memToReg_ALU;
      end
    LUI :
      begin
        cuif.regWr = 1'b1;
        regDst = regDst_rt;
        cuif.memToReg = memToReg_ALU;
      end
    LW :
      begin
        cuif.dREN = 1'b1;
        cuif.extOp  = 1'b1;
        cuif.aluSrc = aluSrc_immediate;
        cuif.aluOp = ALU_ADD;
        cuif.regWr = 1'b1;
        regDst = regDst_rt;
        cuif.memToReg = memToReg_data;
      end
    SW :
      begin
        cuif.dWEN = 1'b1;
        cuif.extOp = 1'b1;
        cuif.aluSrc = aluSrc_immediate;
        cuif.aluOp = ALU_ADD;
      end
    HALT :
      begin
        cuif.halt = 1'b1;
      end
    // rtype - use funct
    RTYPE :
      begin
        cuif.aluSrc = aluSrc_regVal;
        cuif.regWr = 1'b1;
        regDst = regDst_rd;
        cuif.memToReg = memToReg_ALU;

        case(funct)
          SLL :
          begin
            cuif.aluSrc = aluSrc_shamt;
            cuif.aluOp = ALU_SLL;
          end
          SRL :
          begin
            cuif.aluSrc = aluSrc_shamt;
            cuif.aluOp = ALU_SRL;
          end
          JR :
          begin
            cuif.regWr = 1'b0;
            regDst = '0;
          end
          ADD, ADDU : cuif.aluOp = ALU_ADD;
          SUB, SUBU : cuif.aluOp = ALU_SUB;
          AND :       cuif.aluOp = ALU_AND;
          OR :        cuif.aluOp = ALU_OR;
          XOR :       cuif.aluOp = ALU_XOR;
          NOR :       cuif.aluOp = ALU_NOR;
          SLT :       cuif.aluOp = ALU_SLT;
          SLTU :      cuif.aluOp = ALU_SLTU;
        endcase // case(funct)
      end // RTYPE

    endcase // case(opcode)
  end

endmodule
