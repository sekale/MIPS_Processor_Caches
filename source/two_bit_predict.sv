// data path interface
`include "pc_if.vh"
`include "two_bit_predict_if.vh"

// cpu type definitions
`include "cpu_types_pkg.vh"

module two_bit_predict(

	input logic clk,
	input logic n_rst,
	two_bit_predict_if tbif
	);

import cpu_types_pkg::*;

typedef enum logic[1:0]{firsttake, secondtake, first_ntake, second_ntake} statetype;
statetype predict_current_state, predict_next_state;

always_ff @(posedge clk, negedge n_rst)
begin
	if(n_rst == 1'b0)
	begin
		predict_current_state <= firsttake;
	end

	else
	begin
		predict_current_state <= predict_next_state;
	end
end


always_comb
begin
	predict_next_state = predict_current_state;
	case(predict_current_state)

		firsttake:
		begin
			if(tbif.twobit_decision_in == 1'b0) //false decision
			begin
				predict_next_state = secondtake;
			end

			else
			begin
				predict_next_state = firsttake;
			end
		end

		secondtake:
		begin
			if(tbif.twobit_decision_in == 1'b0) //false decision
			begin
				predict_next_state = first_ntake;
			end

			else
			begin
				predict_next_state = firsttake;
			end
		end

		first_ntake:
		begin
			if(tbif.twobit_decision_in == 1'b0) //false decision
			begin
				predict_next_state = second_ntake;
			end

			else
			begin
				predict_next_state = first_ntake;
			end
		end

		second_ntake:
		begin
			if(tbif.twobit_decision_in == 1'b0) //false decision
			begin
				predict_next_state = firsttake;
			end

			else
			begin
				predict_next_state = first_ntake;
			end
		end
		default: begin predict_next_state = predict_current_state; end
	endcase

end

assign tbif.twobit_decision_out = (predict_current_state == 2'b00 || predict_current_state == 2'b01) ? 1'b1:1'b0;

endmodule
