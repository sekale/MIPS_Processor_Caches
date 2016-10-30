
// all interfaces required for datapath
`include "datapath_cache_if.vh"
`include "exmem_pipelineReg_if.vh"
`include "hazard_if.vh"
`include "idex_pipelineReg_if.vh"
`include "ifid_pipelineReg_if.vh"
`include "memwb_pipelineReg_if.vh"
`include "pc_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  // import types
  import cpu_types_pkg::*;

  // pc init
  parameter PC_INIT = 0;

//required definitions for the datapath
  word_t signExtendOut; // used for sign extenstion to immeditate value
  word_t intermediate_portB; //portB can have a different value based on the mux that checks the alusrc in the diagram
  word_t ex_branch_address; //calculated branch address in execute stage
  word_t signExtendOut_adder; //used for the adder logic
  word_t mem_port_out; //value for portout that loads in to the memwb pipeline
  word_t mem_port_out_1; //value that gets out of the LUI mux
  word_t wb_port_out; //final value that is to be written to the regfile as well as forwarding unit case
  logic flush_ifid; //this flush is ported to the ifid idex and exmem stage, its value is pulled from flush_ifid from the hazard unit which is currently set to zero
  logic flush_idex;
  logic flush_exmem;
  logic stall; //this stall is ported to the ifid stage
  logic enable;
  logic halt;
  word_t instr;

  logic final_ihit;   // to accomodate caches (look at end of file for reasons)

  // interfaces
  register_file_if      regif();
  alu_if                aluif();
  pc_if                 pcif();
  control_unit_if       cuif();
  ifid_pipelineReg_if   ifid();
  idex_pipelineReg_if   idex();
  exmem_pipelineReg_if  exmem();
  forwarding_unit_if     fuif();
  memwb_pipelineReg_if  memwb();
  hazard_if             hzif();

  alu                     ALU ( .io(aluif) );
  control_unit            CU  ( .clk(CLK), .n_rst(nRST), .cuif(cuif) );
  register_file           REG ( .clk(CLK), .n_rst(nRST), .rfif(regif));
  pc #(.PC_INIT(PC_INIT)) PC  ( .clk(CLK), .n_rst(nRST), .pcif(pcif) );
  ifid_pipelineReg        IFID( .clk(CLK), .n_rst(nRST), .enable(enable), .stall(stall), .flush(flush_ifid), .ifid(ifid));
  idex_pipelineReg        IDEX( .clk(CLK), .n_rst(nRST), .enable(enable), .flush(flush_idex), .idex(idex));
  exmem_pipelineReg       EXMEM(.clk(CLK), .n_rst(nRST), .enable(enable), .flush(flush_exmem), .exmem(exmem));
  memwb_pipelineReg       MEMWB(.clk(CLK), .n_rst(nRST), .enable(enable), .memwb(memwb));
  hazard                  HZ (.hzif(hzif));
  forwarding_unit         FUIF( .fuif(fuif));

  assign dpif.datomic = '0;   // pulled low right now

  //INPUTS TO THE IFID STAGE
  assign ifid.pc_add4_in = pcif.pc_add4;
  assign instr = final_ihit ? dpif.imemload : '0;
  assign ifid.instruction_in = instr;
 //assign stall = (cuif.opCode == 6'b100011) ? 1'b1 : 1'b0; //stall instruction only required here
  //assign pcif pc enable
  //INPUTS TO THE IDEX STAGE

  // from control unit
  //logic     halt_in; //this one is left

  assign idex.pc_add4_in = ifid.pc_add4;
  assign idex.instruction_in = ifid.instruction;
  assign idex.rdat1_in = regif.rdat1;
  assign idex.rdat2_in = regif.rdat2;

  //setting dpif signals to be used in the idex stage for dren_in and dwen_in and imemren

  assign idex.dREN_in = cuif.dREN;
  assign idex.dWEN_in = cuif.dWEN;
  assign idex.aluSrc_in = cuif.aluSrc;
  assign idex.extOp_in = cuif.extOp;
  assign idex.regWr_in = cuif.regWr;
  assign idex.memToReg_in = cuif.memToReg;
  assign idex.shamt_in = cuif.shamt;
  assign idex.rs_in = cuif.rs;
  assign idex.rt_in = cuif.rt;
  assign idex.rd_in = cuif.rd;
  assign idex.opCode_in = cuif.opCode;
  assign idex.aluOp_in = cuif.aluOp;
  assign idex.immediate_in = cuif.immediate;
  assign idex.halt_in = cuif.halt;
  assign idex.isJRFlag_in = cuif.isJRFlag;

  assign cuif.instruction = ifid.instruction;

//Forwarding Unit Outputs used after this

//input signals to forwarding unit are set here
  assign fuif.mem_regWr = exmem.regWr;
  assign fuif.wb_regWr = memwb.regWr;
  assign fuif.mem_regDst = exmem.regDst;
  assign fuif.wb_regDst = memwb.regDst;
  assign fuif.exe_rs = idex.rs;
  assign fuif.exe_rt = idex.rt;
//input signals to forwarding unit are set above


//covers porta and portb values after this point
  always_comb
  begin :for_portA
    if(fuif.rdat1_fwd_mux == 2'b00)
    begin
      aluif.portA = idex.rdat1;
    end

    else if(fuif.rdat1_fwd_mux == 2'b01)
    begin
      aluif.portA = mem_port_out; //mux at the mem stage set this value
    end

    else if(fuif.rdat1_fwd_mux == 2'b10)
    begin
      aluif.portA = wb_port_out; //mux at the wb stage set this value
    end
    else
    begin
      aluif.portA = idex.rdat1;
    end

  end

  always_comb
  begin : inter_portb_set
    if(fuif.rdat2_fwd_mux == 2'b00)
    begin
      intermediate_portB = idex.rdat2;
    end

    else if(fuif.rdat2_fwd_mux == 2'b01)
    begin
      intermediate_portB = mem_port_out; //mux at the mem stage set this value
    end

    else if(fuif.rdat2_fwd_mux == 2'b10)
    begin
      intermediate_portB = wb_port_out;//mux at the wb stage set this value
    end
    else
    begin
      intermediate_portB = idex.rdat2;
    end

  end

  always_comb
  begin : for_portB
    if(idex.aluSrc == 2'b00)
    begin
      aluif.portB = intermediate_portB;
    end

    else if(idex.aluSrc == 2'b01)
    begin
      aluif.portB = signExtendOut;
    end

    else
    begin
      aluif.portB = idex.shamt;
    end
  end

  assign aluif.aluOp = idex.aluOp;

  //covers porta and portb values before this point



// ----------- Sign extender below ----------- //
  //assign pcif.BRAVal = signExtendOut; //check this statement
  always_comb
  begin : signExtender
    /*
      idex.extOp Definitions :
        0 -> pad zeros
        1 -> extend sign
    */

    if(idex.extOp == 1'b1)
    begin
      signExtendOut = { {16{idex.immediate[15]}} , idex.immediate }; //cuif changed to idex stage for the sign extension as per new datapath
    end
    else
    begin
      signExtendOut = {16'd0, idex.immediate}; //cuif changed to idex stage for the sign extension as per new datapath
    end
  end


// ----------- Sign extender above ----------- //

// pcif being given j_enable and j_addr below //
  assign pcif.j_addr = dpif.imemload[25:0];
  always_comb
  begin
    if(dpif.imemload[31:26] == J || dpif.imemload[31:26] == JAL)
    begin
      pcif.j_enable = 1'b1;
    end
    else
    begin
      pcif.j_enable = 1'b0;
    end
  end
// pcif being given j_enable and j_addr above //


//
//the place where the pc gets signals from the exec stage
assign pcif.jr_addr = aluif.portA;
assign pcif.jr_enable = idex.isJRFlag;
//the place above is where the pc gets signals from the exec stage

      //exmem.bra_addr <= exmem.bra_addr_in;
      //exmem.halt <= exmem.halt_in;

//exmem stage values to be loaded into the pipeline below
  assign exmem.pc_add4_in = idex.pc_add4;
  assign exmem.instruction_in = idex.instruction;
  assign exmem.opCode_in = idex.opCode;
  assign exmem.immediate_in = idex.immediate;
  assign exmem.portB_fwd_in = intermediate_portB;

  assign exmem.dREN_in = idex.dREN;
  assign exmem.dWEN_in = idex.dWEN;

  assign exmem.regWr_in = idex.regWr;
  assign exmem.memToReg_in = idex.memToReg;
  assign exmem.regDst_in = idex.rd;
  assign exmem.zeroFlag_in = aluif.zero;
  assign exmem.portOut_in = aluif.portOut;
  //----------------------------Branching Values----------------------------//
  assign signExtendOut_adder = signExtendOut << 2;
  assign ex_branch_address = idex.pc_add4 + signExtendOut_adder;
  assign exmem.bra_addr_in = ex_branch_address;
  assign pcif.bra_enable = ((exmem.zeroFlag == 1'b1 && exmem.opCode == BEQ)
                     || (exmem.zeroFlag == 1'b0 && exmem.opCode == BNE)) ? 1'b1 : 1'b0;
  assign pcif.bra_addr = exmem.bra_addr;
  //----------------------------Branching Values----------------------------//

  assign exmem.halt_in = idex.halt;
  //exmem stage values to be loaded into the pipeline above

  assign dpif.dmemaddr = exmem.portOut;
  assign dpif.imemaddr = pcif.iaddr;
  assign dpif.imemREN = !halt;
  assign dpif.dmemREN = exmem.dREN;
  assign dpif.dmemWEN = exmem.dWEN;
  assign dpif.dmemstore = exmem.portB_fwd; //PLEASE CHECK THIS
  assign dpif.halt = halt;

  always_comb

  begin: logic_lui
    if(exmem.opCode == LUI)
    begin
      mem_port_out_1 = {exmem.immediate, 16'b0};
    end

    else begin
      mem_port_out_1 = exmem.portOut;
    end
  end

  always_comb
  begin: logic_jal
    if(exmem.opCode == JAL)
    begin
      mem_port_out = exmem.pc_add4;
    end

    else begin
      mem_port_out = mem_port_out_1;
    end

  end

  assign memwb.pc_add4_in = exmem.pc_add4;
  assign memwb.instruction_in = exmem.instruction;
  assign memwb.memToReg_in = exmem.memToReg;
  assign memwb.regDst_in = exmem.regDst;
  assign memwb.halt_in = exmem.halt;
  assign memwb.regWr_in = exmem.regWr;
  assign memwb.dataWriteVal_in = dpif.dmemload; //signal needs to be added as per block diagram
  assign memwb.portOut_in = mem_port_out; //signal needs to be added as per block diagram

  always_comb
  begin:memtoreg_logic
  if(memwb.memToReg == 1'b0)
  begin
    wb_port_out = memwb.portOut;
  end

  else begin
    wb_port_out = memwb.dataWriteVal;
  end

  end //always comb ends

//register file declarations
  assign regif.wdat = wb_port_out;
  assign regif.WEN = memwb.regWr;
  assign regif.wsel = memwb.regDst;
  assign regif.rsel1 = cuif.rs;
  assign regif.rsel2 = cuif.rt;
//register file declarations

  //hazard unit operations

  assign hzif.id_rs = cuif.rs;
  assign hzif.id_rt = cuif.rt;
  assign hzif.ex_rd = idex.rd;
  assign hzif.lw_status = (idex.dREN == 1'b1) ? 1'b1 : 1'b0;
  assign hzif.jr_status = idex.isJRFlag;
  assign hzif.bra_status = ((exmem.zeroFlag == 1'b1 && exmem.opCode == BEQ) ||
                (exmem.zeroFlag == 1'b0 && exmem.opCode == BNE)) ? 1'b1 : 1'b0;

//Dummy flush and stall logic GNDED wires being pulled from the hazard unit below
  assign stall = hzif.stall; //why does hazard unit need a stall
  assign flush_ifid = hzif.flush_ifid;
  assign flush_idex = hzif.flush_idex;
  assign flush_exmem = hzif.flush_exmem;

//Dummy flush and stall logic GNDED wires being pulled from the hazard unit above


//HALT SIGNAL LATCH BELOW
/*
  always_ff @(posedge CLK, negedge nRST)
  begin
    if(nRST == 1'b0)
    begin
      halt <= 1'b0;
    end
    else
    begin
      halt <= memwb.halt;
    end
  end*/
  assign halt = memwb.halt;
//HALT SIGNAL LATCH ABOVE



//PC ENABLE LOGIC BELOW
  always_comb
  begin:PC_ENABLE
    pcif.pc_enable = final_ihit & ~hzif.stall | idex.isJRFlag;
    if(exmem.dREN == 1'b1 || exmem.dWEN == 1'b1)
    begin
      if(dpif.dhit == 1'b1)
      begin
        enable = 1'b1;
      end
      else
      begin
        enable = 1'b0;
      end
    end

    else
    begin
      if(final_ihit == 1'b1)
      begin
        enable = 1'b1;
      end

      else
      begin
        enable = 1'b0;
      end
    end
  end //always_comb block ends
  //PC ENABLE LOGIC ABOVE


  always_comb
  begin
    /*
      ihit is only asserted if dmemREN and dmemWEN(both) are pulled low,
      Explanation: (if there is a data request, and ihit is ready then we want the ihit to wait until the dhit is ready)

      Optimisation : But in the situation that ihit and dhit both are asserted, then there
      is no issue, ihit will remain high


    */
    final_ihit = (dpif.ihit & ~( exmem.dREN | exmem.dWEN ) ) | (dpif.ihit & dpif.dhit);
  end

  endmodule


