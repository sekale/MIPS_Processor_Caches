/*
  Eric Villasenor
  evillase@gmail.com

  this block holds the i and d cache
*/


// interfaces
`include "datapath_cache_if.vh"
`include "caches_if.vh"

// cpu types
`include "cpu_types_pkg.vh"

module caches (
  input logic CLK, nRST,
  datapath_cache_if dcif,
  caches_if cif
);
  // import types
  import cpu_types_pkg::word_t;

//  parameter CPUID = 0;

  icache iCACHE_DUT (
    .clk(CLK),
    .n_rst(nRST),
    .dp(dcif.icache),
    .ic(cif.icache)
);

  dcache dCACHE_DUT (
    .clk(CLK),
    .n_rst(nRST),
    .dp(dcif.dcache),
    .dc(cif.dcache)
);


endmodule
