module FC1_layer #(parameter INPUT_NUM = 48, OUTPUT_NUM = 16) (
   input i_clk,
   input i_rst,
   input i_valid,
   input weight_valid,
   input [7:0] filter,
   input signed [15:0] data_in_1, data_in_2, data_in_3, // 0~47 
   
   output reg  [15:0] data_out1, data_out2, data_out3, data_out4, data_out5, data_out6, data_out7, data_out8, data_out9, data_out10, data_out11, data_out12, data_out13, data_out14, data_out15, data_out16,
   
   output reg weight_done,
   output reg o_valid
 );

 localparam INPUT_WIDTH = 16;
 localparam INPUT_NUM_DATA_BITS = 5;


 reg signed [7:0] weight [0:INPUT_NUM * OUTPUT_NUM - 1]; // 0~767
 reg signed [7:0] bias [0:OUTPUT_NUM - 1]; // 0~15
 
 reg bias_flag;
 reg [9:0] weight_cnt;
 // weight setting for fully connect 1
 integer i, j;
 always @(posedge i_clk) begin
   if(!i_rst) begin
       for(i =0; i< 768; i= i+1)begin
            weight[i] <= 0;
       end
       for(j=0; j<768; j = j+1)begin
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

 /// calculation setting
reg [4:0] cal_cnt;
reg [19:0] cal_reg1, cal_reg2, cal_reg3, cal_reg4, cal_reg5, cal_reg6, cal_reg7, cal_reg8, cal_reg9, cal_reg10, cal_reg11, cal_reg12, cal_reg13, cal_reg14, cal_reg15, cal_reg16;

    always@(posedge i_clk)begin
        if(!i_rst)begin
            cal_cnt <= 0;
        end
        else begin
            if(i_valid)begin
                cal_cnt <= cal_cnt + 1;
                if(cal_cnt == OUTPUT_NUM -1)begin
                    cal_cnt <= 0;
                end
            end
        end
    end
    always@(posedge i_clk)begin
        if(!i_rst)begin
            cal_reg1 <= 0; cal_reg2 <= 0; cal_reg3 <= 0; cal_reg4 <= 0; cal_reg5 <= 0; cal_reg6 <= 0; cal_reg7 <= 0; cal_reg8 <= 0;
            cal_reg9 <= 0; cal_reg10 <= 0; cal_reg11 <= 0; cal_reg12 <= 0; cal_reg13 <= 0; cal_reg14 <= 0; cal_reg15 <=0; cal_reg16 <= 0;
            o_valid <= 0;
        end
        else begin
            if(i_valid)begin
                cal_reg1 <= data_in_1 * weight[3*(cal_cnt) ] + data_in_2 * weight[3* (cal_cnt) + 1] + data_in_3 * weight[3 * (cal_cnt) + 2] + cal_reg1;
                cal_reg2 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 1] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *1] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 1] + cal_reg2;
                cal_reg3 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 2] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *2] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 2] + cal_reg3;                cal_reg2 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 1] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *1] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 1] + cal_reg2;
                cal_reg4 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 3] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *3] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 3] + cal_reg4;
                
                cal_reg5 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 4] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *4] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 4] + cal_reg5;
                cal_reg6 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 5] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *5] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 5] + cal_reg6;
                cal_reg7 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 6] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *6] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 6] + cal_reg7;
                cal_reg8 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 7] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *7] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 7] + cal_reg8;
                cal_reg9 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 8] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *8] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 8] + cal_reg9;
                cal_reg10 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 9] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM * 9] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 9] + cal_reg10;
                cal_reg11 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 10] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *10] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 10] + cal_reg11;

                cal_reg12 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 11] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *11] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 11] + cal_reg12;
                cal_reg13 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 12] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *12] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 12] + cal_reg13;
                cal_reg14 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 13] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *13] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 13] + cal_reg14;
                cal_reg15 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 14] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *14] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 14] + cal_reg15;
                cal_reg16 <= data_in_1 * weight[3*(cal_cnt) + OUTPUT_NUM * 15] + data_in_2 * weight[3* (cal_cnt) + 1 + OUTPUT_NUM *15] + data_in_3 * weight[3 * (cal_cnt) + 2 + OUTPUT_NUM * 15] + cal_reg16;
            end
        end
    end

    always@(posedge i_clk)begin
        if(!i_rst)begin
            data_out1 <= 0; data_out2 <= 0; data_out3 <= 0; data_out4 <= 0; data_out5 <= 0; data_out6 <= 0; data_out7 <= 0;
            data_out8 <= 0; data_out9 <= 0; data_out10 <= 0; data_out11 <= 0; data_out12 <= 0; data_out13 <= 0; data_out14 <= 0; data_out15 <= 0; data_out16 <= 0;
        end
        else begin
            if(cal_cnt ==14)begin
                data_out1 <= bias[0]; data_out2 <= bias[1]; data_out3 <= bias[2]; data_out4 <= bias[3];
                data_out5 <= bias[4]; data_out6 <= bias[5]; data_out7 <= bias[6]; data_out8 <= bias[7];
                data_out9 <= bias[8]; data_out10 <= bias[9]; data_out11 <= bias[10]; data_out12 <= bias[11];
                data_out13 <= bias[12]; data_out14 <= bias[13]; data_out15 <= bias[14]; data_out16 <= bias[15];   
            end
            else if(cal_cnt ==15)begin
                o_valid <= 1;
                data_out1 <= {{4{cal_reg1[19]}}, cal_reg1[19:8]};
                data_out2 <= {{4{cal_reg2[19]}}, cal_reg2[19:8]};
                data_out3 <= {{4{cal_reg3[19]}}, cal_reg3[19:8]};
                data_out4 <= {{4{cal_reg4[19]}}, cal_reg4[19:8]};
                data_out5 <= {{4{cal_reg5[19]}}, cal_reg5[19:8]};
                data_out6 <= {{4{cal_reg6[19]}}, cal_reg6[19:8]};
                data_out7 <= {{4{cal_reg7[19]}}, cal_reg7[19:8]};
                data_out8 <= {{4{cal_reg8[19]}}, cal_reg8[19:8]};
                data_out9 <= {{4{cal_reg9[19]}}, cal_reg9[19:8]};
                data_out10 <= {{4{cal_reg10[19]}}, cal_reg10[19:8]};
                data_out11 <= {{4{cal_reg11[19]}}, cal_reg11[19:8]};
                data_out12 <= {{4{cal_reg12[19]}}, cal_reg12[19:8]};
                data_out13 <= {{4{cal_reg13[19]}}, cal_reg13[19:8]};
                data_out14 <= {{4{cal_reg14[19]}}, cal_reg14[19:8]};
                data_out15 <= {{4{cal_reg15[19]}}, cal_reg15[19:8]};
                data_out16 <= {{4{cal_reg16[19]}}, cal_reg16[19:8]};

            end
            else begin
                o_valid <= 0;
            end
        end
    end
  				
 endmodule
