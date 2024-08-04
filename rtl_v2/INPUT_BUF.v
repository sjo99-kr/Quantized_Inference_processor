`timescale 1ns / 1ps

module INPUT_BUF#(parameter width = 28, height = 28)(

    input i_clk,
    input i_rst,
    // axi_slave prot
    input [7:0] s_axis_data,
    input s_axis_valid,
        
    // master
    output reg [7:0] output_data1, output_data9,  output_data17, output_data25,
    output reg [7:0] output_data2, output_data10, output_data18,
    output reg [7:0] output_data3, output_data11, output_data19,
    output reg [7:0] output_data4, output_data12, output_data20,
    output reg [7:0] output_data5, output_data13, output_data21,
    output reg [7:0] output_data6, output_data14, output_data22,
    output reg [7:0] output_data7, output_data15, output_data23,
    output reg [7:0] output_data8, output_data16, output_data24,
    output reg output_valid,
    output reg buf_done_intr
    );
    
    reg [7:0] buffer [width * 5 - 1:0]; // six line buffers for first conv layer
    integer i;
    reg rd_flag;
    reg [7:0] wr_pt; // 0 ~ 167
    reg [4:0] rd_pt; // 0 ~ 24
    reg [4:0] img_count; // 0~27;
    reg [2:0] rd_pos; // 0~4;
    wire [2:0] line_one, line_two, line_three, line_four, line_five;
    // image count setting
    always@(posedge i_clk)begin
        if(!i_rst)begin
            buf_done_intr <= 0;
            img_count <= 0;
        end
        else begin
            if((wr_pt+1) % 28 == 0)begin
                img_count <= img_count + 1;
            end
            if(img_count == 28 && rd_pt==24)begin
                buf_done_intr <= 1;
                img_count <= 0;
            end
            else begin
                buf_done_intr <= 0;
            end
        end
    
    
    end
   
    // input write setting
    always@(posedge i_clk)begin
        if(!i_rst)begin
            for(i =0; i < width * 5; i = i+1)begin
                buffer[i] <= 0;
            end
            wr_pt <= 0;
            rd_flag <= 0;
        end        
                   
        else begin
            if(s_axis_valid)begin
                wr_pt <= wr_pt + 1;
                buffer[wr_pt] <= s_axis_data;
                if(wr_pt == width * 5 -1)begin
                    wr_pt <= 0;
                    rd_flag <= 1;
                end
            end
            if(buf_done_intr)begin
                rd_flag <= 0;
                wr_pt <= 0;
            end
        end
    end
    
    
    
    // output setting 1
    always@(posedge i_clk)begin
        if(!i_rst)begin
            output_valid <= 0;
            rd_pt <= 0;
            rd_pos <= 0;
        end
        else begin
            if(rd_flag)begin
                rd_pt <= rd_pt + 1;
                if(rd_pt <24)begin
                    output_valid <= 1;
                end
                else begin
                    output_valid <= 0;
                    if(rd_pt == 27)begin
                        rd_pt <= 0;
                        rd_pos <= rd_pos + 1;
                        if(rd_pos == 4)begin
                            rd_pos <= 0; 
                        end
                    end
                end
            end
            if(buf_done_intr)begin
                rd_pt <= 0;
                rd_pos <= 0;
                output_valid <= 0;
            end
        end
     end
     // output setting 2
     assign line_one = rd_pos;
     assign line_two = (rd_pos + 1) % 5; 
     assign line_three = (rd_pos + 2) % 5;
     assign line_four = (rd_pos + 3) % 5;
     assign line_five = (rd_pos + 4) % 5;
     
        // output setting 3
    always@(posedge i_clk)begin
        if(!i_rst)begin
            output_data1 <= 0; output_data9 <= 0;  output_data17 <= 0; output_data25 <= 0;
            output_data2 <= 0; output_data10 <= 0; output_data18 <= 0;
            output_data3 <= 0; output_data11 <= 0; output_data19 <= 0;
            output_data4 <= 0; output_data12 <= 0; output_data20 <= 0;
            output_data5 <= 0; output_data13 <= 0; output_data21 <= 0;
            output_data6 <= 0; output_data14 <= 0; output_data22 <= 0;
            output_data7 <= 0; output_data15 <= 0; output_data23 <= 0; 
            output_data8 <= 0; output_data16 <= 0; output_data24 <= 0; 
        end
        
        else begin
                // set for first line in input data
            output_data1 <= buffer[rd_pt + width * line_one]; output_data2 <= buffer[rd_pt + 1 + width * line_one]; output_data3 <= buffer[rd_pt + 2 + width * line_one]; 
            output_data4 <= buffer[rd_pt +3 + width * line_one]; output_data5<= buffer[rd_pt + 4 + width * line_one];
                
                // set for second line in input data
            output_data6 <= buffer[rd_pt + width * line_two]; output_data7 <= buffer[rd_pt + 1 + width * line_two]; output_data8 <= buffer[rd_pt + 2 + width * line_two]; 
            output_data9 <= buffer[rd_pt +3 + width * line_two]; output_data10<= buffer[rd_pt + 4 + width * line_two];                
            
                // set for three line in input data
            output_data11 <= buffer[rd_pt + width * line_three]; output_data12 <= buffer[rd_pt + 1 + width * line_three]; output_data13 <= buffer[rd_pt + 2 + width * line_three]; 
            output_data14 <= buffer[rd_pt +3 + width * line_three]; output_data15<= buffer[rd_pt + 4 + width * line_three];          
            
            // set for four line in input data
            output_data16 <= buffer[rd_pt + width * line_four]; output_data17 <= buffer[rd_pt + 1 + width * line_four]; output_data18 <= buffer[rd_pt + 2 + width * line_four]; 
            output_data19 <= buffer[rd_pt +3 + width * line_four]; output_data20<= buffer[rd_pt + 4 + width * line_four];        
     
            // set for five line in input data
            output_data21 <= buffer[rd_pt + width * line_five]; output_data22 <= buffer[rd_pt + 1 + width * line_five]; output_data23 <= buffer[rd_pt + 2 + width * line_five]; 
            output_data24 <= buffer[rd_pt +3 + width * line_five]; output_data25<= buffer[rd_pt + 4 + width * line_five];               
        end
    end
endmodule
