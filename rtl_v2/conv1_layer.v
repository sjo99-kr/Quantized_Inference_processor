module conv1_layer #(parameter WIDTH = 28, HEIGHT = 28)(
   input i_clk,
   input i_rst,
   input i_valid,
   
   input weight_valid,
   input [7:0] filter,
   
   input [7 : 0] data_out_0, data_out_1, data_out_2, data_out_3, data_out_4,
   data_out_5, data_out_6, data_out_7, data_out_8, data_out_9,
   data_out_10, data_out_11, data_out_12, data_out_13, data_out_14,
   data_out_15, data_out_16, data_out_17, data_out_18, data_out_19,
   data_out_20, data_out_21, data_out_22, data_out_23, data_out_24,
   
   output signed [15:0] conv_out_1, conv_out_2, conv_out_3,
   output reg weight_done,
   output reg out_valid
 );

 localparam FILTER_SIZE = 5;
 localparam CHANNEL_LEN = 3;

 reg signed [7:0] weight_1 [0:FILTER_SIZE * FILTER_SIZE - 1];  //filter -> 5x5
 reg signed [7:0] weight_2 [0:FILTER_SIZE * FILTER_SIZE - 1]; // 0 ~ 24
 reg signed [7:0] weight_3 [0:FILTER_SIZE * FILTER_SIZE - 1]; // Mnist data set channel -> 1, num of filter -> 3 , filter -> 5x5x1



 reg signed [19:0] one_calc_out_1_1, one_calc_out_1_2, one_calc_out_1_3, one_calc_out_1_4, one_calc_out_1_5; 
 reg signed [19:0] one_calc_out_2_1, one_calc_out_2_2, one_calc_out_2_3;
 reg signed [19:0] one_calc_out_3_1;
 
 reg signed [19:0] two_calc_out_1_1, two_calc_out_1_2, two_calc_out_1_3, two_calc_out_1_4, two_calc_out_1_5; 
 reg signed [19:0] two_calc_out_2_1, two_calc_out_2_2, two_calc_out_2_3;
 reg signed [19:0] two_calc_out_3_1;
 
 reg signed [19:0] three_calc_out_1_1, three_calc_out_1_2, three_calc_out_1_3, three_calc_out_1_4, three_calc_out_1_5; 
 reg signed [19:0] three_calc_out_2_1, three_calc_out_2_2, three_calc_out_2_3;
 reg signed [19:0] three_calc_out_3_1;
 
 reg cal_valid_1, cal_valid_2, cal_valid_3;
 
 
 
 wire signed [8:0] exp_data [0:FILTER_SIZE * FILTER_SIZE - 1]; // mnist data is Unsigned data (pixel data)
 
 reg [6:0] weight_cnt;
 integer i;
 // weight setting (before s_axis_ready)
 always@(posedge i_clk)begin
    if(!i_rst)begin
        weight_done <= 0;
        weight_cnt <= 0;
    end
    else begin
        if(weight_valid &&  (weight_done ==0))begin
            weight_cnt <= weight_cnt + 1;
            if(weight_cnt == 74)begin
                weight_done <= 1;
            end
        end
    end
 end
 
 
 always@(posedge i_clk)begin
    if(!i_rst)begin
        for( i= 0; i< 25; i= i+1) begin
            weight_1[i] <= 0;
            weight_2[i] <= 0;
            weight_3[i] <= 0;
        end
    end
    else begin
        if(weight_valid && (weight_done==0))begin
            if(weight_cnt <25) begin
                weight_1[weight_cnt] <= filter;
            end
            else if(weight_cnt < 50) begin
                weight_2[weight_cnt - 25] <= filter;
            end
            else begin
                weight_3[weight_cnt - 50] <= filter;
            end
        end
    end
 end
 
 
 // Unsigned -> Signed (change precision)
 assign exp_data[0] = {1'd0, data_out_0};
 assign exp_data[1] = {1'd0, data_out_1};
 assign exp_data[2] = {1'd0, data_out_2};
 assign exp_data[3] = {1'd0, data_out_3};
 assign exp_data[4] = {1'd0, data_out_4};
 assign exp_data[5] = {1'd0, data_out_5};
 assign exp_data[6] = {1'd0, data_out_6};
 assign exp_data[7] = {1'd0, data_out_7};
 assign exp_data[8] = {1'd0, data_out_8};
 assign exp_data[9] = {1'd0, data_out_9};
 assign exp_data[10] = {1'd0, data_out_10};
 assign exp_data[11] = {1'd0, data_out_11};
 assign exp_data[12] = {1'd0, data_out_12};
 assign exp_data[13] = {1'd0, data_out_13};
 assign exp_data[14] = {1'd0, data_out_14};
 assign exp_data[15] = {1'd0, data_out_15};
 assign exp_data[16] = {1'd0, data_out_16};
 assign exp_data[17] = {1'd0, data_out_17};
 assign exp_data[18] = {1'd0, data_out_18};
 assign exp_data[19] = {1'd0, data_out_19};
 assign exp_data[20] = {1'd0, data_out_20};
 assign exp_data[21] = {1'd0, data_out_21};
 assign exp_data[22] = {1'd0, data_out_22};
 assign exp_data[23] = {1'd0, data_out_23};
 assign exp_data[24] = {1'd0, data_out_24};

// calculation setting
always@(posedge i_clk)begin
    if(!i_rst)begin
        cal_valid_1 <= 0;
        cal_valid_2 <= 0;
    end
    else begin
        cal_valid_1 <= i_valid;
        cal_valid_2 <= cal_valid_1;
        out_valid <= cal_valid_2;
    end
end

// Pipe-Lining - 1 
always@(posedge i_clk)begin
    if(!i_rst)begin
        one_calc_out_1_1 <= 0; one_calc_out_1_2 <= 0; one_calc_out_1_3 <= 0; one_calc_out_1_4 <= 0; one_calc_out_1_5 <= 0;
        two_calc_out_1_1 <= 0; two_calc_out_1_2 <= 0; two_calc_out_1_3 <=0; two_calc_out_1_4 <= 0; two_calc_out_1_5 <= 0;
        three_calc_out_1_1 <= 0; three_calc_out_1_2 <= 0; three_calc_out_1_3 <= 0; three_calc_out_1_4 <= 0; three_calc_out_1_5 <= 0;
    end
    else begin
        if(i_valid)begin
            one_calc_out_1_1 <= exp_data[0] * weight_1[0] + exp_data[1] * weight_1[1] + exp_data[2] * weight_1[2] + exp_data[3] * weight_1[3] + exp_data[4] * weight_1[4];
            one_calc_out_1_2 <= exp_data[5] * weight_1[5] + exp_data[6] * weight_1[6] + exp_data[7] * weight_1[7] + exp_data[8] * weight_1[8] + exp_data[9] * weight_1[9];
            one_calc_out_1_3 <= exp_data[10] * weight_1[10] + exp_data[11] * weight_1[11] + exp_data[12] * weight_1[12] + exp_data[13] * weight_1[13] + exp_data[14] * weight_1[14];
            one_calc_out_1_4 <= exp_data[15] * weight_1[15] + exp_data[16] * weight_1[16] + exp_data[17] * weight_1[17] + exp_data[18] * weight_1[18] + exp_data[19] * weight_1[19];
            one_calc_out_1_5 <= exp_data[20] * weight_1[20] + exp_data[21] * weight_1[21] + exp_data[22] * weight_1[22] + exp_data[23] * weight_1[23] + exp_data[24] * weight_1[24];
            
            two_calc_out_1_1 <= exp_data[0] * weight_2[0] + exp_data[1] * weight_2[1] + exp_data[2] * weight_2[2] + exp_data[3] * weight_2[3] + exp_data[4] * weight_2[4];
            two_calc_out_1_2 <= exp_data[5] * weight_2[5] + exp_data[6] * weight_2[6] + exp_data[7] * weight_2[7] + exp_data[8] * weight_2[8] + exp_data[9] * weight_2[9];
            two_calc_out_1_3 <= exp_data[10] * weight_2[10] + exp_data[11] * weight_2[11] + exp_data[12] * weight_2[12] + exp_data[13] * weight_2[13] + exp_data[14] * weight_2[14];
            two_calc_out_1_4 <= exp_data[15] * weight_2[15] + exp_data[16] * weight_2[16] + exp_data[17] * weight_2[17] + exp_data[18] * weight_2[18] + exp_data[19] * weight_2[19];
            two_calc_out_1_5 <= exp_data[20] * weight_2[20] + exp_data[21] * weight_2[21] + exp_data[22] * weight_2[22] + exp_data[23] * weight_2[23] + exp_data[24] * weight_2[24];        
        
            three_calc_out_1_1 <= exp_data[0] * weight_3[0] + exp_data[1] * weight_3[1] + exp_data[2] * weight_3[2] + exp_data[3] * weight_3[3] + exp_data[4] * weight_3[4];
            three_calc_out_1_2 <= exp_data[5] * weight_3[5] + exp_data[6] * weight_3[6] + exp_data[7] * weight_3[7] + exp_data[8] * weight_3[8] + exp_data[9] * weight_3[9];
            three_calc_out_1_3 <= exp_data[10] * weight_3[10] + exp_data[11] * weight_3[11] + exp_data[12] * weight_3[12] + exp_data[13] * weight_3[13] + exp_data[14] * weight_3[14];
            three_calc_out_1_4 <= exp_data[15] * weight_3[15] + exp_data[16] * weight_3[16] + exp_data[17] * weight_3[17] + exp_data[18] * weight_3[18] + exp_data[19] * weight_3[19];
            three_calc_out_1_5 <= exp_data[20] * weight_3[20] + exp_data[21] * weight_3[21] + exp_data[22] * weight_3[22] + exp_data[23] * weight_3[23] + exp_data[24] * weight_3[24];            
        end
    
    end
end

// Pipe-Lining - 2
always@(posedge i_clk)begin
    if(!i_rst)begin
        one_calc_out_2_1 <= 0; one_calc_out_2_2 <= 0; one_calc_out_2_3 <= 0;
        two_calc_out_2_1 <= 0; two_calc_out_2_2 <= 0; two_calc_out_2_3 <= 0;
        three_calc_out_2_1 <= 0; three_calc_out_2_2 <= 0; three_calc_out_2_3 <= 0;
    end
    else begin
        if(cal_valid_1)begin
            one_calc_out_2_1 <= one_calc_out_1_1 + one_calc_out_1_2;
            one_calc_out_2_2 <= one_calc_out_1_3 + one_calc_out_1_4;
            one_calc_out_2_3 <= one_calc_out_1_5;

            two_calc_out_2_1 <= two_calc_out_1_1 + two_calc_out_1_2;
            two_calc_out_2_2 <= two_calc_out_1_3 + two_calc_out_1_4;
            two_calc_out_2_3 <= two_calc_out_1_5;            
            
            three_calc_out_2_1 <= three_calc_out_1_1 + three_calc_out_1_2;
            three_calc_out_2_2 <= three_calc_out_1_3 + three_calc_out_1_4;
            three_calc_out_2_3 <= three_calc_out_1_5;
        end
    end
end

// Pipe-Lining - 3
always@(posedge i_clk)begin
    if(!i_rst)begin
        one_calc_out_3_1 <= 0;
        two_calc_out_3_1 <= 0;
        three_calc_out_3_1 <= 0;
    end
    else begin
        if(cal_valid_2)begin
            one_calc_out_3_1 <= one_calc_out_2_1 + one_calc_out_2_2 + one_calc_out_2_3;
            
            two_calc_out_3_1 <= two_calc_out_2_1 + two_calc_out_2_2 + two_calc_out_2_3;
            
            three_calc_out_3_1 <= three_calc_out_2_1 + three_calc_out_2_2 + three_calc_out_2_3;
            
        end
    end

end

 
 assign conv_out_1 = {{4{one_calc_out_3_1[19]}}, one_calc_out_3_1[19:8]}; // 16 = 4 + 12
 assign conv_out_2 = {{4{two_calc_out_3_1[19]}}, two_calc_out_3_1[19:8]}; // 16 = 4 + 12
 assign conv_out_3 = {{4{three_calc_out_3_1[19]}}, three_calc_out_3_1[19:8]}; // 16 = 4 + 12
 

 
endmodule
