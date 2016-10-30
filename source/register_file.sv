`include "cpu_types_pkg.vh"
`include "register_file_if.vh"

import cpu_types_pkg::*;

module register_file
(
  input wire clk,
  input wire n_rst,
  register_file_if.rf rfif
);

word_t registers [31:0];

always_ff @(negedge clk, negedge n_rst)
begin
    if(n_rst == 1'b0)
    begin
        for(int i = 0; i < 32; i+=1)
        begin
            registers[i] <= '0;
        end
        //registers[31:0] <= '0;
    end
    else
    begin
        if(rfif.WEN == 1'b1 && rfif.wsel != '0)
        begin
            registers[rfif.wsel] <= rfif.wdat;
        end
    end
end

assign rfif.rdat1 = rfif.rsel1 ? registers[rfif.rsel1] : 0;
assign rfif.rdat2 = rfif.rsel2 ? registers[rfif.rsel2] : 0;

endmodule
