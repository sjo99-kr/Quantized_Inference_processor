module Max_relu #(HALF_WIDTH = 12, HALF_HEIGHT = 12, HALF_WIDTH_BIT = 4) (
	input i_clk,
	input i_rst,	// asynchronous reset, active low
	input i_valid,
	input signed [15 : 0] conv_out_1, conv_out_2, conv_out_3,
	output reg [15 : 0] max_value_1, max_value_2, max_value_3,
	output reg valid_out_relu
);

reg signed [15:0] buffer1 [0:HALF_WIDTH - 1];
reg signed [15:0] buffer2 [0:HALF_WIDTH - 1];
reg signed [15:0] buffer3 [0:HALF_WIDTH - 1];

reg [HALF_WIDTH_BIT - 1:0] pcount;
reg state;
reg flag;

always @(posedge i_clk) begin
	if(!i_rst) begin
		valid_out_relu <= 0;
		pcount <= 0;
		state <= 0;
		flag <= 0;
	end else begin

	if(i_valid == 1'b1) begin
		flag <= ~flag;
		if(flag == 1) begin
			pcount <= pcount + 1;
			if(pcount == HALF_WIDTH - 1) begin
				state <= ~state;
				pcount <= 0;
			end
		end

		if(state == 0) begin	// first line
			valid_out_relu <= 0;
			if(flag == 0) begin	// first input
				buffer1[pcount] <= conv_out_1;
				buffer2[pcount] <= conv_out_2;
				buffer3[pcount] <= conv_out_3;
			end else begin	// second input -> comparison
				if(buffer1[pcount] < conv_out_1)
					buffer1[pcount] <= conv_out_1;
				if(buffer2[pcount] < conv_out_2)
				  buffer2[pcount] <= conv_out_2;
				if(buffer3[pcount] < conv_out_3)
				  buffer3[pcount] <= conv_out_3;
			end
			
		end else begin	// second line
			if(flag == 0) begin	// third input -> comparison
				valid_out_relu <= 0;
				if(buffer1[pcount] < conv_out_1)
				  buffer1[pcount] <= conv_out_1;
				if(buffer2[pcount] < conv_out_2)
				  buffer2[pcount] <= conv_out_2;
			  if(buffer3[pcount] < conv_out_3)
				  buffer3[pcount] <= conv_out_3;
				  
			end else begin	// fourth input -> comparison + relu
				valid_out_relu <= 1;
				if(buffer1[pcount] < conv_out_1) begin
					if(conv_out_1 > 0) begin
						max_value_1 <= conv_out_1;
					end else begin
						max_value_1 <= 0;
					end
				end else begin
					if(buffer1[pcount] > 0) begin
						max_value_1 <= buffer1[pcount];
					end else begin
						max_value_1 <= 0;
					end
				end

				if(buffer2[pcount] < conv_out_2) begin
					if(conv_out_2 > 0) begin
						max_value_2 <= conv_out_2;
					end else begin
						max_value_2 <= 0;
					end
				end else begin
					if(buffer2[pcount] > 0) begin
						max_value_2 <= buffer2[pcount];
					end else begin
						max_value_2 <= 0;
					end
				end

				if(buffer3[pcount] < conv_out_3) begin
					if(conv_out_3 > 0) begin
						max_value_3 <= conv_out_3;
					end else begin
						max_value_3 <= 0;
					end
				end else begin
					if(buffer3[pcount] > 0) begin
						max_value_3 <= buffer3[pcount];
					end else begin
						max_value_3 <= 0;
					end
					
			end
		end		
	end
	end else begin
		valid_out_relu <= 0;
	end
end
end
endmodule
