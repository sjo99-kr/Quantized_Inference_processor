// Multi-cycle-process
module FC_decision #(parameter INPUT_NUM = 16, OUTPUT_NUM = 10) (
   input i_clk,
   input i_rst,
   input i_valid,
   input weight_valid,
   input [7:0] filter,
   input signed [15:0] data_in_1, data_in_2, data_in_3, data_in_4, data_in_5, data_in_6, data_in_7, data_in_8, data_in_9, data_in_10, data_in_11, data_in_12, data_in_13, data_in_14, data_in_15, data_in_16,
   
   output reg weight_done,
   output reg dec_done_intr,
   output reg [3:0] data_out
 );

// input data => 16
 localparam INPUT_WIDTH = 16;
 localparam INPUT_NUM_DATA_BITS = 4;


 reg signed [ 7:0] weight [0:INPUT_NUM * OUTPUT_NUM - 1];
 reg signed [ 7:0] bias [0:OUTPUT_NUM - 1];

// weight setting
 reg bias_flag;
 reg [7:0] weight_cnt;
 // weight setting for fully connect 1
 integer i, j;
 always @(posedge i_clk) begin
   if(!i_rst) begin
       for(i =0; i< 160; i= i+1)begin
            weight[i] <= 0;
       end
       for(j=0; j<10; j = j+1)begin
            bias[j] <= 0;
       end
   end
   else begin
        if(weight_valid)begin
            if(weight_done ==0)begin
                if(bias_flag == 0)begin
                    weight[weight_cnt] <=  filter;
                end
                else begin
                    bias[weight_cnt - OUTPUT_NUM * INPUT_NUM] <= filter;
                end
            end
        end
   end
 end

always@(posedge i_clk)begin
    if(!i_rst)begin
       weight_done <= 0;
       weight_cnt <= 0;    
       bias_flag <= 0;
    end
    else begin
        if(weight_valid)begin
            weight_cnt <= weight_cnt + 1;
            if(weight_cnt == OUTPUT_NUM * INPUT_NUM  + OUTPUT_NUM -1)begin
                weight_done <= 1;
            end
            else if(weight_cnt == OUTPUT_NUM * INPUT_NUM -1)begin
                bias_flag <= 1;
            end
        end
    end
end


 reg cal_stage0, cal_stage1, cal_stage2, dec_stage0, dec_stage1, dec_stage2, dec_stage3;
 reg [3:0] out_data;
 
 always@(posedge i_clk)begin
    if(!i_rst)begin
        cal_stage0 <= 0;
        cal_stage1 <= 0;
        cal_stage2 <= 0;
        
        dec_stage0 <= 0;
        dec_stage1 <= 0;
        dec_stage2 <= 0;
        dec_stage3 <= 0;
        
        dec_done_intr <= 0;
        
    end
    else begin
        cal_stage0 <= i_valid;
        cal_stage1 <= cal_stage0;
        cal_stage2 <= cal_stage1;
        
        dec_stage0 <= cal_stage2;
        dec_stage1 <= dec_stage0;
        dec_stage2 <= dec_stage1;
        dec_stage3 <= dec_stage2;
        dec_done_intr <= dec_stage3;
    end
 end
   
 reg signed [19:0] num_cal_0_0, num_cal_0_1, num_cal_0_2, num_cal_0_3;
 reg signed [19:0] num_cal_1_0, num_cal_1_1, num_cal_1_2, num_cal_1_3;
 reg signed [19:0] num_cal_2_0, num_cal_2_1, num_cal_2_2, num_cal_2_3;
 reg signed [19:0] num_cal_3_0, num_cal_3_1, num_cal_3_2, num_cal_3_3;
 reg signed [19:0] num_cal_4_0, num_cal_4_1, num_cal_4_2, num_cal_4_3;
 reg signed [19:0] num_cal_5_0, num_cal_5_1, num_cal_5_2, num_cal_5_3;
 reg signed [19:0] num_cal_6_0, num_cal_6_1, num_cal_6_2, num_cal_6_3;
 reg signed [19:0] num_cal_7_0, num_cal_7_1, num_cal_7_2, num_cal_7_3;
 reg signed [19:0] num_cal_8_0, num_cal_8_1, num_cal_8_2, num_cal_8_3;
 reg signed [19:0] num_cal_9_0, num_cal_9_1, num_cal_9_2, num_cal_9_3;

 always@(posedge i_clk)begin
    if(!i_rst)begin
       num_cal_0_0 <= 0; num_cal_0_1 <= 0; num_cal_0_2 <= 0; num_cal_0_3 <= 0;
       num_cal_1_0 <= 0; num_cal_1_1 <= 0; num_cal_1_2 <= 0; num_cal_1_3 <= 0;
       num_cal_2_0 <= 0; num_cal_2_1 <= 0; num_cal_2_2 <= 0; num_cal_2_3 <= 0;
       num_cal_3_0 <= 0; num_cal_3_1 <= 0; num_cal_3_2 <= 0; num_cal_3_3 <= 0;
       num_cal_4_0 <= 0; num_cal_4_1 <= 0; num_cal_4_2 <= 0; num_cal_4_3 <= 0;
       num_cal_5_0 <= 0; num_cal_5_1 <= 0; num_cal_5_2 <= 0; num_cal_5_3 <= 0;
       num_cal_6_0 <= 0; num_cal_6_1 <= 0; num_cal_6_2 <= 0; num_cal_6_3 <= 0;
       num_cal_7_0 <= 0; num_cal_7_1 <= 0; num_cal_7_2 <= 0; num_cal_7_3 <= 0;
       num_cal_8_0 <= 0; num_cal_8_1 <= 0; num_cal_8_2 <= 0; num_cal_8_3 <= 0;
       num_cal_9_0 <= 0; num_cal_9_1 <= 0; num_cal_9_2 <= 0; num_cal_9_3 <= 0;
 
       data_out <= 0;
 
    end
    else begin
        if(i_valid)begin
            num_cal_0_0 <= data_in_1 * weight[0] + data_in_2 * weight[1] + data_in_3 * weight[2] + data_in_4 * weight[3];
            num_cal_0_1 <= data_in_5 * weight[4] + data_in_6 * weight[5] + data_in_7 * weight[6] +data_in_8 * weight[7];
            num_cal_0_2 <= data_in_9 * weight[8] + data_in_10 * weight[9] + data_in_11 * weight[10] + data_in_12 * weight[11];
            num_cal_0_3 <= data_in_13 * weight[12] + data_in_14 * weight[13] + data_in_15 * weight[14] + data_in_16 * weight[15] + bias[0];
            
            num_cal_1_0 <= data_in_1 * weight[0 + INPUT_NUM * 1] + data_in_2 * weight[1 + INPUT_NUM * 1] + data_in_3 * weight[2 + INPUT_NUM * 1] + data_in_4 * weight[3 + INPUT_NUM * 1];
            num_cal_1_1 <= data_in_5 * weight[4 + INPUT_NUM * 1] + data_in_6 * weight[5 + INPUT_NUM * 1] + data_in_7 * weight[6 + INPUT_NUM * 1] + data_in_8 * weight[7 + INPUT_NUM * 1];
            num_cal_1_2 <= data_in_9 * weight[8 + INPUT_NUM * 1] + data_in_10 * weight[9 + INPUT_NUM * 1] + data_in_11 * weight[10 + INPUT_NUM * 1] + data_in_12 * weight[11 + INPUT_NUM * 1];
            num_cal_1_3 <= data_in_13 * weight[12 + INPUT_NUM * 1] + data_in_14 * weight[13 + INPUT_NUM * 1] + data_in_15 * weight[14 + INPUT_NUM * 1] + data_in_16 * weight[15 + INPUT_NUM * 1] + bias[1];

            num_cal_2_0 <= data_in_1 * weight[0 + INPUT_NUM * 2] + data_in_2 * weight[1 + INPUT_NUM * 2] + data_in_3 * weight[2 + INPUT_NUM * 2] + data_in_4 * weight[3 + INPUT_NUM * 2];
            num_cal_2_1 <= data_in_5 * weight[4 + INPUT_NUM * 2] + data_in_6 * weight[5 + INPUT_NUM * 2] + data_in_7 * weight[6 + INPUT_NUM * 2] + data_in_8 * weight[7 + INPUT_NUM * 2];
            num_cal_2_2 <= data_in_9 * weight[8 + INPUT_NUM * 2] + data_in_10 * weight[9 + INPUT_NUM * 2] + data_in_11 * weight[10 + INPUT_NUM * 2] + data_in_12 * weight[11 + INPUT_NUM * 2];
            num_cal_2_3 <= data_in_13 * weight[12 + INPUT_NUM * 2] + data_in_14 * weight[13 + INPUT_NUM * 2] + data_in_15 * weight[14 + INPUT_NUM * 2] + data_in_16 * weight[15 + INPUT_NUM * 2] +bias[2];

            num_cal_3_0 <= data_in_1 * weight[0 + INPUT_NUM * 3] + data_in_2 * weight[1 + INPUT_NUM * 3] + data_in_3 * weight[2 + INPUT_NUM * 3] + data_in_4 * weight[3 + INPUT_NUM * 3];
            num_cal_3_1 <= data_in_5 * weight[4 + INPUT_NUM * 3] + data_in_6 * weight[5 + INPUT_NUM * 3] + data_in_7 * weight[6 + INPUT_NUM * 3] + data_in_8 * weight[7 + INPUT_NUM * 3];
            num_cal_3_2 <= data_in_9 * weight[8 + INPUT_NUM * 3] + data_in_10 * weight[9 + INPUT_NUM * 3] + data_in_11 * weight[10 + INPUT_NUM * 3] + data_in_12 * weight[11 + INPUT_NUM * 3];
            num_cal_3_3 <= data_in_13 * weight[12 + INPUT_NUM * 3] + data_in_14 * weight[13 + INPUT_NUM * 3] + data_in_15 * weight[14 + INPUT_NUM * 3]  + data_in_16 * weight[15 + INPUT_NUM * 3] + bias[3];
            
            num_cal_4_0 <= data_in_1 * weight[0 + INPUT_NUM * 4] + data_in_2 * weight[1 + INPUT_NUM * 4] + data_in_3 * weight[2 + INPUT_NUM * 4] + data_in_4 * weight[3 + INPUT_NUM * 4];
            num_cal_4_1 <= data_in_5 * weight[4 + INPUT_NUM * 4] + data_in_6 * weight[5 + INPUT_NUM * 4] + data_in_7 * weight[6 + INPUT_NUM * 4] + data_in_8 * weight[7 + INPUT_NUM * 4];
            num_cal_4_2 <= data_in_9 * weight[8 + INPUT_NUM * 4] + data_in_10 * weight[9 + INPUT_NUM * 4] + data_in_11 * weight[10 + INPUT_NUM * 4] + data_in_12 * weight[11 + INPUT_NUM * 4];
            num_cal_4_3 <= data_in_13 * weight[12 + INPUT_NUM * 4] + data_in_14 * weight[13 + INPUT_NUM * 4] + data_in_15 * weight[14 + INPUT_NUM * 4] + data_in_16 * weight[15 + INPUT_NUM * 4] +bias[4];

            num_cal_5_0 <= data_in_1 * weight[0 + INPUT_NUM * 5] + data_in_2 * weight[1 + INPUT_NUM * 5] + data_in_3 * weight[2 + INPUT_NUM * 5] + data_in_4 * weight[3 + INPUT_NUM * 5];
            num_cal_5_1 <= data_in_5 * weight[4 + INPUT_NUM * 5] + data_in_6 * weight[5 + INPUT_NUM * 5] + data_in_7 * weight[6 + INPUT_NUM * 5] + data_in_8 * weight[7 + INPUT_NUM * 5];
            num_cal_5_2 <= data_in_9 * weight[8 + INPUT_NUM * 5] + data_in_10 * weight[9 + INPUT_NUM * 5] + data_in_11 * weight[10 + INPUT_NUM * 5] + data_in_12 * weight[11 + INPUT_NUM * 5];
            num_cal_5_3 <= data_in_13 * weight[12 + INPUT_NUM * 5] + data_in_14 * weight[13 + INPUT_NUM * 5] + data_in_15 * weight[14 + INPUT_NUM * 5] + data_in_16 * weight[15 + INPUT_NUM * 5] + bias[5];
            
            num_cal_6_0 <= data_in_1 * weight[0 + INPUT_NUM * 6] + data_in_2 * weight[1 + INPUT_NUM * 6] + data_in_3 * weight[2 + INPUT_NUM * 6] + data_in_4 * weight[3 + INPUT_NUM * 6];
            num_cal_6_1 <= data_in_5 * weight[4 + INPUT_NUM * 6] + data_in_6 * weight[5 + INPUT_NUM * 6] + data_in_7 * weight[6 + INPUT_NUM * 6] + data_in_8 * weight[7 + INPUT_NUM * 6];
            num_cal_6_2 <= data_in_9 * weight[8 + INPUT_NUM * 6] + data_in_10 * weight[9 + INPUT_NUM * 6] + data_in_11 * weight[10 + INPUT_NUM * 6] + data_in_12 * weight[11 + INPUT_NUM * 6];
            num_cal_6_3 <= data_in_13 * weight[12 + INPUT_NUM * 6] + data_in_14 * weight[13 + INPUT_NUM * 6] + data_in_15 * weight[14 + INPUT_NUM * 6] + data_in_16 * weight[15 + INPUT_NUM * 6] +  bias[6];
            
            num_cal_7_0 <= data_in_1 * weight[0 + INPUT_NUM * 7] + data_in_2 * weight[1 + INPUT_NUM * 7] + data_in_3 * weight[2 + INPUT_NUM * 7] + data_in_4 * weight[3 + INPUT_NUM * 7];
            num_cal_7_1 <= data_in_5 * weight[4 + INPUT_NUM * 7] + data_in_6 * weight[5 + INPUT_NUM * 7] + data_in_7 * weight[6 + INPUT_NUM * 7] + data_in_8 * weight[7 + INPUT_NUM * 7];
            num_cal_7_2 <= data_in_9 * weight[8 + INPUT_NUM * 7] + data_in_10 * weight[9 + INPUT_NUM * 7] + data_in_11 * weight[10 + INPUT_NUM * 7] + data_in_12 * weight[11 + INPUT_NUM * 7];
            num_cal_7_3 <= data_in_13 * weight[12 + INPUT_NUM * 7] + data_in_14 * weight[13 + INPUT_NUM * 7] + data_in_15 * weight[14 + INPUT_NUM * 7] + data_in_16 * weight[15 + INPUT_NUM * 7] + bias[7];

            num_cal_8_0 <= data_in_1 * weight[0 + INPUT_NUM * 8] + data_in_2 * weight[1 + INPUT_NUM * 8] + data_in_3 * weight[2 + INPUT_NUM * 8] + data_in_4 * weight[3 + INPUT_NUM * 8];
            num_cal_8_1 <= data_in_5 * weight[4 + INPUT_NUM * 8] + data_in_6 * weight[5 + INPUT_NUM * 8] + data_in_7 * weight[6 + INPUT_NUM * 8] + data_in_8 * weight[7 + INPUT_NUM * 8];
            num_cal_8_2 <= data_in_9 * weight[8 + INPUT_NUM * 8] + data_in_10 * weight[9 + INPUT_NUM * 8] + data_in_11 * weight[10 + INPUT_NUM * 8] + data_in_12 * weight[11 + INPUT_NUM * 8];
            num_cal_8_3 <= data_in_13 * weight[12 + INPUT_NUM * 8] + data_in_14 * weight[13 + INPUT_NUM * 8] + data_in_15 * weight[14 + INPUT_NUM * 8] + data_in_16 * weight[15 + INPUT_NUM * 8] +bias[8];


            num_cal_9_0 <= data_in_1 * weight[0 + INPUT_NUM * 9] + data_in_2 * weight[1 + INPUT_NUM * 9] + data_in_3 * weight[2 + INPUT_NUM * 9] + data_in_4 * weight[3 + INPUT_NUM * 9];
            num_cal_9_1 <= data_in_5 * weight[4 + INPUT_NUM * 9] + data_in_6 * weight[5 + INPUT_NUM * 9] + data_in_7 * weight[6 + INPUT_NUM * 9] + data_in_8 * weight[7 + INPUT_NUM * 9];
            num_cal_9_2 <= data_in_9 * weight[8 + INPUT_NUM * 9] + data_in_10 * weight[9 + INPUT_NUM * 9] + data_in_11 * weight[10 + INPUT_NUM * 9] + data_in_12 * weight[11 + INPUT_NUM * 9];
            num_cal_9_3 <= data_in_13 * weight[12 + INPUT_NUM * 9] + data_in_14 * weight[13 + INPUT_NUM * 9] + data_in_15 * weight[14 + INPUT_NUM * 9] + data_in_16 * weight[15 + INPUT_NUM * 9] + bias[9];


        end
        else if(cal_stage0)begin
            num_cal_0_0 <= num_cal_0_0 + num_cal_0_1;
            num_cal_0_2 <= num_cal_0_2 + num_cal_0_3;
            
            num_cal_1_0 <= num_cal_1_0 + num_cal_1_1;
            num_cal_1_2 <= num_cal_1_2 + num_cal_1_3;
            
            num_cal_2_0 <= num_cal_2_0 + num_cal_2_1;
            num_cal_2_2 <= num_cal_2_2 + num_cal_2_3;    
             
            num_cal_3_0 <= num_cal_3_0 + num_cal_3_1;
            num_cal_3_2 <= num_cal_3_2 + num_cal_3_3;
                        
            num_cal_4_0 <= num_cal_4_0 + num_cal_4_1;
            num_cal_4_2 <= num_cal_4_2 + num_cal_4_3;        
        
            num_cal_5_0 <= num_cal_5_0 + num_cal_5_1;
            num_cal_5_2 <= num_cal_5_2 + num_cal_5_3;          

            num_cal_6_0 <= num_cal_6_0 + num_cal_6_1;
            num_cal_6_2 <= num_cal_6_2 + num_cal_6_3;
                      
            num_cal_7_0 <= num_cal_7_0 + num_cal_7_1;
            num_cal_7_2 <= num_cal_7_2 + num_cal_7_3;          

            num_cal_8_0 <= num_cal_8_0 + num_cal_8_1;
            num_cal_8_2 <= num_cal_8_2 + num_cal_8_3;  

            num_cal_9_0 <= num_cal_9_0 + num_cal_9_1;
            num_cal_9_2 <= num_cal_9_2 + num_cal_9_3;  


        end
        else if(cal_stage1)begin
            num_cal_0_0 <= num_cal_0_0 + num_cal_0_2;
            num_cal_1_0 <= num_cal_1_0 + num_cal_1_2;
            
            num_cal_2_0 <= num_cal_2_0 + num_cal_2_2;
            num_cal_3_0 <= num_cal_3_0 + num_cal_3_2;

            num_cal_4_0 <= num_cal_4_0 + num_cal_4_2;
            num_cal_5_0 <= num_cal_5_0 + num_cal_5_2;

            num_cal_6_0 <= num_cal_6_0 + num_cal_6_2;
            num_cal_7_0 <= num_cal_7_0 + num_cal_7_2;


            num_cal_8_0 <= num_cal_8_0 + num_cal_8_2;
            num_cal_9_0 <= num_cal_9_0 + num_cal_9_2;
            
        end
        else if(dec_stage0)begin
            num_cal_0_0 <= (num_cal_0_0 > num_cal_1_0) ? num_cal_0_0 : num_cal_1_0;
            num_cal_2_0 <= (num_cal_2_0 > num_cal_3_0) ? num_cal_2_0 : num_cal_3_0;
            num_cal_4_0 <= (num_cal_4_0 > num_cal_5_0) ? num_cal_4_0 : num_cal_5_0;
            num_cal_6_0 <= (num_cal_6_0 > num_cal_7_0) ? num_cal_6_0 : num_cal_7_0;
            num_cal_8_0 <= (num_cal_8_0 > num_cal_9_0) ? num_cal_8_0 : num_cal_9_0;
        
        end
        else if(dec_stage1)begin
            num_cal_0_0 <= (num_cal_0_0 > num_cal_2_0) ? num_cal_0_0 : num_cal_2_0;
            num_cal_4_0 <= (num_cal_4_0 > num_cal_6_0) ? num_cal_4_0 : num_cal_6_0;
            num_cal_8_0 <= (num_cal_6_0 > num_cal_8_0) ? num_cal_6_0 : num_cal_8_0;
        end
        else if(dec_stage2)begin
            if(num_cal_0_0 > num_cal_4_0)begin
                if(num_cal_0_0 >num_cal_8_0)begin
                    num_cal_0_0 <= num_cal_0_0;
                end
                else num_cal_0_0 <= num_cal_8_0;
            end
            else begin
                if(num_cal_4_0 > num_cal_8_0)begin
                    num_cal_0_0 <= num_cal_4_0;
                end
                else num_cal_0_0 <= num_cal_8_0;
            end
        end
        else if(dec_stage3)begin
            case(num_cal_0_0)
                num_cal_0_0 : begin
                    data_out <= 2'b1010; // 0 => 10 ,  led : 1010
                end
                num_cal_1_0 : begin
                    data_out <= 2'b0001; // 1 -> 1 , led : 0001
                end
                num_cal_2_0 : begin
                    data_out <= 2'b0010; //2 -> 2 , led : 0010
                end
                num_cal_3_0 : begin
                    data_out <= 2'b0011;
                end
                num_cal_4_0 : begin
                    data_out <= 2'b0100;
                end
                num_cal_5_0 : begin
                    data_out <= 2'b0101;
                end
                num_cal_6_0 : begin
                    data_out <= 2'b0110;
                end
                num_cal_7_0: begin
                    data_out <= 2'b0111;
                end
                num_cal_8_0 : begin
                    data_out <= 2'b1000;
                end
                num_cal_9_0 : begin
                    data_out <= 2'b1001;
                end
                default : begin
                    data_out <= 2'b0000;
                end
            endcase
        end
    end
 end
 


 endmodule
