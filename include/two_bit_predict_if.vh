`ifndef two_bit_predict_IF_VH
`define two_bit_predict_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface two_bit_predict_if;

import cpu_types_pkg::*;

input logic twobit_decision_in; //wrong or right
output logic twobit_decision_out; //decision that state transition makes

endinterface








