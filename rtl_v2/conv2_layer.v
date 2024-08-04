module conv2_layer(
	input i_clk,
  	input i_rst,
  	input i_valid,
  	input weight_valid,
  	input [7:0] filter,
	input signed [15:0] data_ch0, data_ch1, data_ch2,
	
	output reg signed  [15:0] conv2_out_ch0, conv2_out_ch1, conv2_out_ch2,
  	output reg conv2_valid,
    output reg weight_done
);



//filter -> 5x5x3 ,  num of filter -> 3 
reg signed [7:0] weight_1_ch0 [0:24];
reg signed [7:0] weight_1_ch1 [0:24];
reg signed [7:0] weight_1_ch2 [0:24]; // 0~ 74

reg signed [7:0] weight_2_ch0 [0:24];
reg signed [7:0] weight_2_ch1 [0:24];
reg signed [7:0] weight_2_ch2 [0:24]; // 0~74

reg signed [7:0] weight_3_ch0 [0:24];
reg signed [7:0] weight_3_ch1 [0:24];
reg signed [7:0] weight_3_ch2 [0:24]; // 0~74

// num of weights -> 225

reg [1:0] state; 
localparam WEIGHT_IN = 2'b00;
localparam DATA_IN = 2'b01;

reg [7:0] weight_cnt;

reg [19:0] ch0_out, ch1_out, ch2_out;





reg [4:0] cal_cnt; // 0~ 25
reg [19:0] last_one, last_two, last_three;

always@(posedge i_clk)begin
    if(!i_rst)begin
        state <= 2'b00;
        conv2_valid <= 0;
        conv2_out_ch0 <= 0; conv2_out_ch1 <=0; conv2_out_ch2 <= 0;
        weight_done <= 0;
        weight_cnt <= 0; cal_cnt <= 0;
        ch0_out <= 0; ch1_out <= 0; ch2_out <= 0;
    end
    else begin
        case (state)
            WEIGHT_IN : begin
                if(weight_valid && (weight_done==0))begin
                    weight_cnt <= weight_cnt + 1;
                    
                    if(weight_cnt <25)begin
                        weight_1_ch0[weight_cnt] <= filter;
                    end
                    else if(weight_cnt <50)begin
                        weight_1_ch1[weight_cnt - 25] <= filter;
                    end
                    else if(weight_cnt <75)begin
                        weight_1_ch2[weight_cnt - 50] <= filter;
                    end
                    else if(weight_cnt < 100) begin
                        weight_2_ch0[weight_cnt -75] <= filter;
                    end
                    else if(weight_cnt < 125)begin
                        weight_2_ch1[weight_cnt - 100] <= filter;
                    end
                    else if(weight_cnt < 150)begin
                        weight_2_ch2[weight_cnt - 125] <= filter;
                    end
                    else if(weight_cnt < 175)begin
                        weight_3_ch0[weight_cnt -150] <= filter;
                    end
                    else if(weight_cnt < 200) begin
                        weight_3_ch1[weight_cnt - 175] <= filter;
                    end
                    else if(weight_cnt < 225)begin
                        weight_3_ch2[weight_cnt - 200] <= filter;
                    end
                    
                    if(weight_cnt == 224)begin
                        weight_done <= 1;
                        state <= DATA_IN;
                    end
                end
            end
            DATA_IN : begin
                if(i_valid)begin
                    cal_cnt <= cal_cnt + 1;
                    ch0_out <= data_ch0 * weight_1_ch0[cal_cnt] + data_ch1 * weight_1_ch1[cal_cnt] + data_ch2 * weight_1_ch2[cal_cnt];
                    ch1_out <= data_ch0 * weight_2_ch0[cal_cnt] + data_ch1 * weight_2_ch1[cal_cnt] + data_ch2 * weight_2_ch2[cal_cnt];
                    ch2_out <= data_ch0 * weight_3_ch0[cal_cnt] + data_ch1 * weight_3_ch1[cal_cnt] + data_ch2 * weight_3_ch2[cal_cnt];
                    conv2_valid <= 0;
                    
                    if(cal_cnt == 24)begin
                        cal_cnt <= 0;
                        ch0_out <= 0; ch1_out <= 0; ch2_out <= 0;
                        conv2_valid <= 1;
                        conv2_out_ch0 <= {{4{ch0_out[19]}}, ch0_out[19:8]};
                        conv2_out_ch1 <= {{4{ch1_out[19]}}, ch1_out[19:8]};
                        conv2_out_ch2 <= {{4{ch2_out[19]}}, ch2_out[19:8]};
                    end
                end
                else begin
                    conv2_valid <= 0;
                end
            end        
        endcase
    end
end

endmodule
