/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 2;

  assign ccif.ramstore = ccif.dstore[0];
  assign ccif.ramWEN = ccif.dWEN[0];

  assign ccif.iload[0] = ccif.ramload;
  assign ccif.dload[0] = ccif.ramload;

  always_comb
  begin
    // to avoid latching (?)
    ccif.ramaddr = ccif.iaddr[0];

    ccif.iwait[0] = 1'b1; // so that Hit signals are default low
    ccif.dwait[0] = 1'b1; // so that Hit signals are default low
    ccif.ramREN = 1'b0;

    if( (ccif.dREN[0] | ccif.dWEN[0]) == 1'b1 )
    begin
      ccif.ramaddr = ccif.daddr[0];
      ccif.ramREN = ccif.dREN[0];

      ccif.dwait[0] = (ccif.ramstate != ACCESS);
    end

    else if(ccif.iREN[0] == 1'b1)
    begin
      ccif.ramaddr = ccif.iaddr[0];
      ccif.ramREN = ccif.iREN[0];

      ccif.iwait[0] = (ccif.ramstate != ACCESS);
    end

  end

/*
  The RAM block does not repeat a request if it has already completed it.
  Hence, don't need to worry about keeping track of which operation to
    operate on when a data operation has been complete and an instruction
    operation should be sent.
*/

endmodule
