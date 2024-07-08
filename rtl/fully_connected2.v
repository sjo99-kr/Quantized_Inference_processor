module fully_connected2 #(parameter INPUT_NUM = 16, OUTPUT_NUM = 10, DATA_BITS = 8) (
   input clk,
   input rst_n,
   input valid_in,
   input signed [11:0] data_in,
   output  [11:0] data_out,
   output reg valid_out_fc
 );

// input data => 16
 localparam INPUT_WIDTH = 16;
 localparam INPUT_NUM_DATA_BITS = 4;

 reg state;
 reg [INPUT_WIDTH - 1:0] buf_idx;
 reg [3:0] out_idx;
 reg signed [13:0] buffer [0:INPUT_NUM - 1];
 reg signed [DATA_BITS - 1:0] weight [0:INPUT_NUM * OUTPUT_NUM - 1];
 reg signed [DATA_BITS - 1:0] bias [0:OUTPUT_NUM - 1];
   
 wire signed [19:0] calc_out;
 wire signed [13:0] data1;

 initial begin
   $readmemh("fc2_weight.txt", weight);
   $readmemh("fc2_bias.txt", bias);
 end

 assign data1 = data_in;
 
 always @(posedge clk) begin
   if(~rst_n) begin
     valid_out_fc <= 0;
     buf_idx <= 0;
     out_idx <= 0;
     state <= 0;
   end

   if(valid_out_fc == 1) begin
     valid_out_fc <= 0;
   end

   if(valid_in == 1) begin
     // Wait until 48 input data filled in buffer
     if(!state) begin
       buffer[buf_idx] <= data1;
       

       buf_idx <= buf_idx + 1'b1;
       if(buf_idx == INPUT_WIDTH - 1) begin
         buf_idx <= 0;
         state <= 1;
         valid_out_fc <= 1;
     end
       
     end else begin // valid state
       out_idx <= out_idx + 1'b1;
       if(out_idx == OUTPUT_NUM - 1) begin
         out_idx <= 0;
       end
       
       valid_out_fc <= 1;
       
     end
   end
 end

 assign calc_out = weight[out_idx * INPUT_NUM] * buffer[0] + weight[out_idx * INPUT_NUM + 1] * buffer[1] + 
		  		weight[out_idx * INPUT_NUM + 2] * buffer[2] + weight[out_idx * INPUT_NUM + 3] * buffer[3] + 
  				weight[out_idx * INPUT_NUM + 4] * buffer[4] + weight[out_idx * INPUT_NUM + 5] * buffer[5] + 
	  			weight[out_idx * INPUT_NUM + 6] * buffer[6] + weight[out_idx * INPUT_NUM + 7] * buffer[7] + 
		  		weight[out_idx * INPUT_NUM + 8] * buffer[8] + weight[out_idx * INPUT_NUM + 9] * buffer[9] + 
  				weight[out_idx * INPUT_NUM + 10] * buffer[10] + weight[out_idx * INPUT_NUM + 11] * buffer[11] + 
  				weight[out_idx * INPUT_NUM + 12] * buffer[12] + weight[out_idx * INPUT_NUM + 13] * buffer[13] + 
	  			weight[out_idx * INPUT_NUM + 14] * buffer[14] + weight[out_idx * INPUT_NUM + 15] * buffer[15] + 
  				bias[out_idx];
 assign data_out = calc_out[19]==0 ? calc_out[18:7]: 0;

 endmodule
