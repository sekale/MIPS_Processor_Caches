`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"

import cpu_types_pkg::*;

module icache
(
  input logic clk,
  input logic n_rst,
  datapath_cache_if.icache dp,
  caches_if.icache ic
);

    logic [58:0] icacheRegs [15:0];
    logic [58:0] icacheRegs_nextState;
    logic pdataflag;
    typedef enum {IDLE, READDATA} States;
    States state, nextState;

    always_ff @(posedge clk, negedge n_rst)
    begin
        if(n_rst == 1'b0)
        begin
            state <= IDLE;
        end
        else
        begin
            state <= nextState;
        end
    end


    always_ff @(posedge clk, negedge n_rst)
    begin
        if(n_rst == 1'b0)
        begin
                icacheRegs <= '{default:'0};
        end
        else
        begin
            icacheRegs[ dp.imemaddr[5:2] ] <= icacheRegs_nextState;
        end
    end

    always_comb
    begin
        if(ic.iwait == 1'b0 && state == READDATA)
        begin
                                // v_bit        tag             data //
            icacheRegs_nextState = {1'b1, dp.imemaddr[31:6] , ic.iload};
        end
        else
        begin
            icacheRegs_nextState = icacheRegs[ dp.imemaddr[5:2] ];
        end
    end

    // valid bt == 1 AND tag matches and iREN is high
    assign pdataflag = dp.imemREN == 1'b1 &&
                        (icacheRegs[dp.imemaddr[5:2]][58] == 1'b1 && (icacheRegs[dp.imemaddr[5:2]][57:32] == dp.imemaddr[31:6]));

    assign dp.ihit = pdataflag;

    // pass adress from datapath to memory controller
    assign ic.iaddr = dp.imemaddr;

    assign dp.imemload = icacheRegs[ dp.imemaddr[5:2] ][31:0];

    // set iREN high in READDATA stage, else keep low
    assign ic.iREN = (state == READDATA) ? 1'b1 : 1'b0;

    always_comb
    begin : nextStateLogic

        nextState = state;
        case(state)
            IDLE:
            begin
                if(dp.imemREN == 1'b1 && pdataflag == 1'b0)
                begin
                    nextState = READDATA;
                end
            end
            READDATA:
            begin
                if(ic.iwait == 1'b0)
                begin
                  nextState = IDLE;
                end
            end
        endcase
    end

endmodule
