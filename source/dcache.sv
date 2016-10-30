`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"

import cpu_types_pkg::*;

module dcache
(
	input logic clk,
	input logic n_rst,
	datapath_cache_if.dcache dp,
	caches_if.dcache dc
);

	logic [91:0] dcacheRegs [7:0][1:0];
	logic [91:0] dcacheRegs_nextState;
	logic pdataflag;
	logic [7:0] lru; 		// least recently used block
	logic lru_nxt; 	// LRU next state logic
	logic way;

	// COUNTER LOGIC


  word_t way0_lower_word;
  word_t way0_upper_word;
  word_t way1_upper_word;
  word_t way1_lower_word;

  logic [25:0] way0_tag;
  logic [25:0] way1_tag;

  logic way0_valid;
  logic way1_valid;

  logic way0_dirty;
  logic way1_dirty;

  logic [2:0] ind;
  assign ind = dp.dmemaddr[5:3];


  assign way0_lower_word = dcacheRegs[ind][0][31:0];
  assign way0_upper_word = dcacheRegs[ind][0][63:32];
  assign way1_lower_word = dcacheRegs[ind][1][31:0];
  assign way1_upper_word = dcacheRegs[ind][1][63:32];

  assign way0_valid = dcacheRegs[ind][0][91];
  assign way1_valid = dcacheRegs[ind][1][91];

  assign way0_dirty = dcacheRegs[ind][0][90];
  assign way1_dirty = dcacheRegs[ind][1][90];

  assign way0_tag = dcacheRegs[ind][0][89:64];
  assign way1_tag = dcacheRegs[ind][1][89:64];


	logic rf1; //index roll over flag
	logic clear_flag;
	logic [4:0] index_val;
	logic way_counter_enable;
	logic [31:0]hit_counter;
	logic [31:0]hit_counter_nxt;

	typedef enum {CHECK, WRITE1, WRITE2, READ1, READ2, HALT, HALT_WHC, HALT_DONE, HALT_W1, HALT_W2} STATES;
	STATES state, nextState;

//	flex_counter #(.NUM_CNT_BITS(5)) INDEX_COUNTER(.clk(clk), .n_rst(n_rst),
//                  .clear(clear_flag), .count_enable(way_counter_enable), .rollover_val(5'd16),
//                  .count_out(index_val), .rollover_flag(rf1));

  assign rf1 = (index_val == 5'd16);

  always_ff @(posedge clk, negedge n_rst)
  begin
    if(n_rst == 1'b0)
    begin
      index_val <= 5'd0;
    end
    else
    begin
        if(clear_flag == 1'b1)
        begin
          index_val <= 5'd0;
        end
        else
        begin
          if(way_counter_enable)
          begin
            index_val <= index_val + 5'd1;
          end
          else
          begin
            index_val <= index_val;
          end
        end
    end
  end

	always_ff @(posedge clk, negedge n_rst)
	begin
		if(n_rst == 1'b0) begin
			 state <= CHECK;
			 hit_counter <= 32'd0;
		end else begin
			 state <= nextState;
			 hit_counter <= hit_counter_nxt;
		end
	end

	always_ff @(posedge clk, negedge n_rst)
	begin
		if(n_rst == 1'b0)
		begin
			lru <= '{default:'0};
		end

		else begin
		 	lru [ dp.dmemaddr[5:3] ] <= lru_nxt;
		end
	end

	always_ff @(posedge clk, negedge n_rst)
	begin
		if(n_rst == 1'b0)
		begin
		 dcacheRegs <= '{default:'0};
		end
		else begin
		 dcacheRegs[ dp.dmemaddr[5:3] ][ way ] <= dcacheRegs_nextState; //define this value] <= dcacheRegs_nextState;
		end
	end

	//valid bit[91] == 1 for way 0 && tag matches for way 0
	//or
	//valid bit[91] == 1 for way 1 && tag matches for way 1
  assign dp.dhit = pdataflag;
	assign pdataflag = !dp.halt & (dp.dmemREN == 1'b1 || dp.dmemWEN == 1'b1)
						& (
							(dcacheRegs[ dp.dmemaddr[5:3] ] [0] [91] == 1'b1
							&& dcacheRegs[dp.dmemaddr[5:3]] [0] [89:64] == dp.dmemaddr[31:6] )
							||
							(dcacheRegs[ dp.dmemaddr[5:3] ] [1] [91] == 1'b1
							&& dcacheRegs[dp.dmemaddr[5:3]] [1] [89:64] == dp.dmemaddr[31:6])
						);

	always_comb
	begin: way_logic
		if 	( dcacheRegs[ dp.dmemaddr[5:3] ] [0] [89:64] == dp.dmemaddr[31:6]
			 	&& (dcacheRegs[ dp.dmemaddr[5:3] ] [0] [91] == 1'b1)
			)
		begin
			way = 1'b0;
		end
		else if ( dcacheRegs[ dp.dmemaddr[5:3] ] [1] [89:64] == dp.dmemaddr[31:6]
			 		&& (dcacheRegs[ dp.dmemaddr[5:3] ] [1] [91] == 1'b1)
				)
		begin
			way = 1'b1;
		end
		else
		begin
			way = lru[ dp.dmemaddr[5:3] ];
		end
	end


//OUTPUT LOGIC OF THE CHECK STATE
	always_comb
	begin

		dc.dREN = 1'b0;
		dc.dWEN = 1'b0;
		dc.daddr = 32'hbad1bad1;
		dc.dstore = 32'hbad1bad1;

		lru_nxt = lru[ dp.dmemaddr[5:3] ];
		dcacheRegs_nextState = dcacheRegs[ dp.dmemaddr[5:3] ] [way];
		dp.dmemload = 32'hfad1fad1;

		if(state == CHECK)
		begin
			if(pdataflag == 1'b1 && dp.dmemREN == 1'b1)
			begin
				lru_nxt = !way; //change state of lru_nxt here
				if(dp.dmemaddr[2] == 1'b0) //BLOCK OFFSET IS 0 SEND 63:32 TO THE DMEMLOAD
				begin
					//pull from dcache write value to the one requested by the datapath
					dp.dmemload = dcacheRegs[ dp.dmemaddr[5:3] ] [way] [63:32];
				end

				else if(dp.dmemaddr[2] == 1'b1) //BLOCK OFFSET IS 0 SEND 31:0 TO THE DMEMLOAD
				begin
					dp.dmemload = dcacheRegs[ dp.dmemaddr[5:3] ] [way] [31:0];
				end
			end

			else if(pdataflag == 1'b1 && dp.dmemWEN == 1'b1)
			begin
				lru_nxt = !way; //change state of lru_nxt here
				if(dp.dmemaddr[2] == 1'b0)
				begin
					//pull from dcache write value to the one requested by the datapath
          //temp = dcacheRegs[ dp.dmemaddr[5:3] ] [way] [31:0]; //temp stores the second word in the way
          dcacheRegs_nextState = {1'b1, 1'b1, dp.dmemaddr[31:6], dp.dmemstore, dcacheRegs[ dp.dmemaddr[5:3] ] [way] [31:0] };
				end

				else if(dp.dmemaddr[2] == 1'b1) //BLOCK OFFSET IS 1 SEND 31:0 TO THE DMEMLOAD
				begin
					//pull from dcache write value to the one requested by the datapath
					//temp = dcacheRegs[ dp.dmemaddr[5:3] ] [way] [63:32]; //temp stores the second word in the way
					dcacheRegs_nextState = {1'b1, 1'b1, dp.dmemaddr[31:6], dcacheRegs[ dp.dmemaddr[5:3] ] [way] [63:32] , dp.dmemstore};
				end
			end
		end
		//READ STATE 1 LOGIC BELOW THIS
		else if(state == READ1)
		begin
			dc.dREN = 1'b1;
			dc.daddr = {dp.dmemaddr[31:3], 1'b0, 2'b00};

			if(dc.dwait == 1'b0)	// Don't want to change dcacheReg until first word is received
			begin
				dcacheRegs_nextState = {1'b0, 1'b0, dp.dmemaddr[31:6], dc.dload, 32'hDEADBEEF}; // BAD1BAD1 is for debug reasons
			end
		end

		else if(state == READ2)
		begin
			dc.dREN = 1'b1;
			dc.daddr = {dp.dmemaddr[31:3], 1'b1, 2'b00};

			if(dc.dwait == 1'b0)	// Don't want to change dcacheReg until first word is received
			begin
				dcacheRegs_nextState = {1'b1, 1'b0, dp.dmemaddr[31:6], dcacheRegs[ dp.dmemaddr[5:3] ] [way] [63:32], dc.dload};
			end
		end
		//READ STATE 1 LOGIC ABOVE THIS

		//WRITE STATE 1 LOGIC BELOW THIS
		else if(state == WRITE1)
		begin
			dc.dWEN = 1'b1;
			//dc.daddr = {dp.dmemaddr[31:3], 1'b0, 2'b00};
      dc.daddr = {dcacheRegs[dp.dmemaddr[5:3]][way][89:64], dp.dmemaddr[5:3], 1'b0, 2'b00}; // thanks to pranav
			dc.dstore = dcacheRegs[ dp.dmemaddr[5:3] ] [ way ] [63:32];
		end

		//WRITE STATE 2 LOGIC BELOW THIS
		else if(state == WRITE2)
		begin
			dc.dWEN = 1'b1;
			//dc.daddr = {dp.dmemaddr[31:3], 1'b1, 2'b00};
      dc.daddr = {dcacheRegs[ind][way][89:64], ind, 1'b1, 2'b00};
			dc.dstore = dcacheRegs[ dp.dmemaddr[5:3] ] [ way ] [31:0];
		end
		//WRITE STATE LOGIC ABOVE THIS

		else if(state == HALT_W1)
		begin
			dc.dWEN = 1'b1;
                    //                tag value                          index       block
			dc.daddr = {dcacheRegs [index_val[2:0]] [index_val[3]] [89:64], index_val[2:0], 1'b0, 2'b00};
			dc.dstore = dcacheRegs [index_val[2:0]] [index_val[3]] [63:32];
		end

		else if(state == HALT_W2)
		begin
			dc.dWEN = 1'b1;
                    //                tag value                          index       block
			dc.daddr = {dcacheRegs[index_val[2:0]] [index_val[3]] [89:64], index_val[2:0], 1'b1, 2'b00};
			dc.dstore = dcacheRegs[index_val[2:0]] [index_val[3]] [31:0];
		end
    else if(state == HALT_WHC)
    begin // HALT_WRITE_HIT_COUNTER
      dc.daddr = 32'h00003100;
      dc.dWEN = 1'b1;
      dc.dstore = hit_counter;
    end

	end //always comb block ends


	always_comb
	begin:nextStatelogic
		way_counter_enable = 1'b0;
		clear_flag = 1'b0;
		dp.flushed = 1'b0;
		nextState = state; //to avoid else statements and latches
		hit_counter_nxt = hit_counter;
		case(state)
			CHECK:
			begin

				if(dp.halt == 1'b1)
				begin
					nextState = HALT;
					clear_flag = 1'b1;
				end

				else //IF NOT HALT
				begin

					if(pdataflag == 1'b1 && (dp.dmemREN == 1'b1 || dp.dmemWEN == 1'b1))
					begin
						nextState = CHECK;
						hit_counter_nxt = hit_counter + 1;
					end

					if(pdataflag == 1'b0 && (dp.dmemREN == 1'b0 && dp.dmemWEN == 1'b0) )
					begin
						nextState = CHECK;
						//hit_counter_nxt <= hit_counter_nxt - 1;
					end

					else if(pdataflag == 1'b0 && // dirty bit in lru way is ZERO
											dcacheRegs[ dp.dmemaddr[5:3] ] [ lru[ dp.dmemaddr[5:3] ] ] [90] == 1'b0 )
					begin
						nextState = READ1;
						hit_counter_nxt = hit_counter - 1;
					end

					else if(pdataflag == 1'b0 && // dirty bit in lru way is HIGH
												dcacheRegs[ dp.dmemaddr[5:3] ] [ lru[ dp.dmemaddr[5:3] ] ] [90] == 1'b1 )
					begin
						nextState = WRITE1;
						hit_counter_nxt = hit_counter - 1;
					end
				end


			end

			READ1:
			begin
				if(dc.dwait == 1'b0)
				begin
					nextState = READ2;
				end
				if(dp.halt == 1'b1)
				begin
					nextState = HALT;
					clear_flag = 1'b1;
				end
			end

			READ2:
			begin
				if(dc.dwait == 1'b0)
				begin
					nextState = CHECK;
				end
				if(dp.halt == 1'b1)
				begin
					nextState = HALT;
					clear_flag = 1'b1;
				end
			end

			WRITE1:
			begin
				if(dc.dwait == 1'b0)
				begin
					nextState = WRITE2;
				end
				if(dp.halt == 1'b1)
				begin
					nextState = HALT;
					clear_flag = 1'b1;
				end
			end

			WRITE2:
			begin
				if(dc.dwait == 1'b0)
				begin
					nextState = READ1;
				end
				if(dp.halt == 1'b1)
				begin
					nextState = HALT;
					clear_flag = 1'b1;
				end
			end

			HALT:
			begin
				if(rf1 == 1'b1)
				begin
					nextState = HALT_WHC;
				end

				else if(dcacheRegs[index_val[2:0]][index_val[3]][90] == 1'b1) //checking if dirty bit is one for the halt state index and way
				begin
					nextState = HALT_W1;
					way_counter_enable = 1'b0;
				end

				else if(dcacheRegs[index_val[2:0]][index_val[3]][90] == 1'b0) //checking if dirty bit is one for the halt state index and way
				begin
					way_counter_enable = 1'b1;
					nextState = HALT;
				end

			end

			HALT_W1:
			begin
				if(dc.dwait == 1'b0)
				begin
					nextState = HALT_W2;
				end
			end

			HALT_W2:
			begin
				if(dc.dwait == 1'b0)
				begin
					nextState = HALT;
					way_counter_enable = 1'b1;
				end
			end

      HALT_WHC:
      begin
        if(dc.dwait == 1'b0)
        begin
          nextState = HALT_DONE;
        end
      end

			HALT_DONE:
			begin
				dp.flushed = 1'b1;
			end
		endcase // case statement ends

	end
	endmodule // dcache
