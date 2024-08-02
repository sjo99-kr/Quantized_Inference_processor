`timescale 1ns / 1ps



module CNN_controller(
    input i_clk,
    input i_rst,
    
    // interrupt
    output  o_intr,
    
    // s_axis port
    input [7:0] s_axis_data,
    input s_axis_valid,
    output s_axis_ready
    
    
    );
    
    assign s_axis_ready = conv1_weight_done & conv2_weight_done &fc1_weight_done;
    
    reg [1:0] rd_state; // read from bram  //00 -> layer 1, 01 -> layer 2, 10 -> fc 1, 11 -> fc 2
    reg [1:0] wr_state; // write to bram
    localparam CONV1 = 2'b00;
    localparam CONV2 = 2'b01;
    localparam FC1 = 2'b10;
    
    wire buf_valid;
    wire [7:0] buf_out1, buf_out2, buf_out3, buf_out4, buf_out5, buf_out6, buf_out7, buf_out8, buf_out9;
    wire [7:0] buf_out10, buf_out11, buf_out12, buf_out13, buf_out14, buf_out15, buf_out16, buf_out17, buf_out18, buf_out19;
    wire [7:0] buf_out20, buf_out21, buf_out22, buf_out23, buf_out24, buf_out25;
    
    // INPUT BUFFER SETTING
    INPUT_BUF IN_BUF(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .s_axis_data(s_axis_data),
        .s_axis_valid(s_axis_valid),
        .output_data1(buf_out1), .output_data2(buf_out2), .output_data3(buf_out3), .output_data4(buf_out4), .output_data5(buf_out5),
        .output_data6(buf_out6), .output_data7(buf_out7), .output_data8(buf_out8), .output_data9(buf_out9), .output_data10(buf_out10),
        .output_data11(buf_out11), .output_data12(buf_out12), .output_data13(buf_out13), .output_data14(buf_out14), .output_data15(buf_out15),
        .output_data16(buf_out16), .output_data17(buf_out17), .output_data18(buf_out18), .output_data19(buf_out19), .output_data20(buf_out20),
        .output_data21(buf_out21), .output_data22(buf_out22), .output_data23(buf_out23), .output_data24(buf_out24), .output_data25(buf_out25),
        .o_intr(o_intr),
        .output_valid(buf_valid)
    ); 
    
    wire [7:0] conv1_filter;
    wire conv1_weight_done;
    wire conv1_out_valid;
    wire signed [15:0] conv1_out1, conv1_out2, conv1_out3;
    
    reg [6:0] bram0_addr;
    reg bram0_en;
    reg conv1_weight_en;
    always@(posedge i_clk)begin
        if(!i_rst)begin
            bram0_en <= 0;
            bram0_addr <= 1;
            conv1_weight_en <= 0;
        end
        else begin
            if(bram0_addr == 75)begin
                bram0_en <= 0;
            end
            else begin
                if(bram0_en)begin
                    bram0_addr <= bram0_addr + 1;
                end
                bram0_en <= 1;
            end
            conv1_weight_en <= bram0_en;
        end
    end
    
    // BLOCK RAM SETTING FOR CONV1 LAYER (weight BRAM)
    blk_mem_gen_0 conv1_weight_bram (
        .clka(i_clk),
        .ena(bram0_en),
        .addra(bram0_addr),
        .douta(conv1_filter)
    );
    
    
    conv1_calc conv1_layer(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_valid(buf_valid),
        .weight_valid(conv1_weight_en),
        .filter(conv1_filter),
        .data_out_0(buf_out1), .data_out_1(buf_out2), .data_out_2(buf_out3), .data_out_3(buf_out4), .data_out_4(buf_out5), .data_out_5(buf_out6),
        .data_out_6(buf_out7), .data_out_7(buf_out8), .data_out_8(buf_out9), .data_out_9(buf_out10), .data_out_10(buf_out11),
        .data_out_11(buf_out12), .data_out_12(buf_out13), .data_out_13(buf_out14), .data_out_14(buf_out15), .data_out_15(buf_out16), 
        .data_out_16(buf_out17), .data_out_17(buf_out18), .data_out_18(buf_out19), .data_out_19(buf_out20), .data_out_20(buf_out21),
        .data_out_21(buf_out22),. data_out_22(buf_out23), .data_out_23(buf_out24), .data_out_24(buf_out25),
        .conv_out_1(conv1_out1), .conv_out_2(conv1_out2), .conv_out_3(conv1_out3),
        .weight_done(conv1_weight_done),
        .out_valid(conv1_out_valid)
    );
    wire signed [15:0] max1_out0, max1_out1, max1_out2;
    wire max1_valid;
    
    Max_relu #(.HALF_WIDTH(12), 
            .HALF_HEIGHT(12), 
            .HALF_WIDTH_BIT(4)
        ) max_relu_1(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_valid(conv1_out_valid),
        .conv_out_1(conv1_out1), .conv_out_2(conv1_out2), .conv_out_3(conv1_out3),
        .max_value_1(max1_out0), .max_value_2(max1_out1), .max_value_3(max1_out2),
        .valid_out_relu(max1_valid)
    );
    
    reg [9:0] imme_addr_a, imme_addr_b;
    reg [47:0] imme_in;
    wire [47:0] imme_out;
    reg ena, enb;
    reg wea;
    reg conv1_read_flag;
    reg conv2_read_flag;
    reg [7:0] wr_state_cnt;
    reg [7:0] rd_state_cnt;
    
    reg conv2_i_valid_reg;
    reg fc1_i_valid_reg;
    wire conv2_i_valid;
    wire fc1_i_valid;
    
    /// conv2 addr control  ///
    reg [2:0] conv2_col; // 0~4
    reg [2:0] conv2_row; // 0~4
    reg [2:0] conv2_pos; // 0~7
    reg [3:0] conv2_poi; // 0~8
    ///////////////////////////
    
    assign fc1_i_valid = fc1_i_valid_reg;
    assign conv2_i_valid = conv2_i_valid_reg;
    
    always@(posedge i_clk)begin
        if(!i_rst)begin
            conv2_i_valid_reg <= 0;
            fc1_i_valid_reg <= 0;
        end
        else begin
            conv2_i_valid_reg <= enb & (rd_state == CONV1);
            fc1_i_valid_reg <= enb & (rd_state == CONV2);
        end
    end

    
    always@(posedge i_clk)begin
        if(!i_rst)begin
            conv2_col <= 0; conv2_row <= 0;
            conv2_pos <= 0; conv2_poi <= 0;
        end
        else begin
            case(rd_state)
                CONV1 : begin
                    if(conv1_read_flag)begin
                        conv2_col <= conv2_col + 1;
                        if(conv2_col == 4)begin
                            conv2_col <= 0;
                            conv2_row <= conv2_row + 1;
                            if(conv2_row == 4)begin
                                conv2_row <= 0;
                                conv2_pos <= conv2_pos + 1;
                                if(conv2_pos == 7)begin
                                    conv2_pos <= 0;
                                    conv2_poi <= conv2_poi + 1;
                                end
                            end
                        end
                    end
                end
                CONV2 :begin
                
                end
            endcase
        
        end
    end
    
    always@(posedge i_clk)begin
        if(!i_rst)begin
            wr_state <= 0;
            imme_addr_a <= 0; ena <=0;
            wr_state_cnt <= 0;
        end
        else begin
            case(wr_state) 
                CONV1 :begin
                    if(max1_valid)begin
                        if(ena)begin
                            imme_addr_a <= imme_addr_a +6;
                        end
                        ena <= 1; wea <= 1;
                        imme_in <= {max1_out2, max1_out1, max1_out0};
                        wr_state_cnt <= wr_state_cnt + 1;
                        
                        
                    end
                    else if(wr_state_cnt == 144)begin
                            wr_state_cnt <= 0; 
                            ena <= 0; wea <= 0;
                            imme_addr_a <= 0;
                            wr_state <= CONV2;
                    end
                end
                CONV2 :begin
                    if(max2_valid)begin
                        if(ena)begin
                            imme_addr_a <= imme_addr_a + 6;
                        end
                        ena <= 1; wea <= 1;
                        imme_in <= {max2_out2, max2_out1, max2_out0};
                        wr_state_cnt <= wr_state_cnt + 1;
                        
                    end
                    else if(wr_state_cnt == 16)begin
                            wr_state_cnt <= 0;
                            ena<=0; wea <= 0;
                            imme_addr_a <= 0;
                            wr_state <= FC1;
                    end
                
                end
            endcase
        
        end
    
    end
    always@(posedge i_clk)begin
        if(!i_rst)begin
            conv1_read_flag <= 0;
            conv2_read_flag <= 0;
        end
        else begin
            if(wr_state_cnt==143 && wr_state == CONV1)begin
                conv1_read_flag <= 1;
            end
            if((imme_addr_b == 858) && (rd_state==CONV1))begin
                conv1_read_flag <= 0;
            end
            if(wr_state_cnt == 15 && wr_state == CONV2)begin
                conv2_read_flag <= 1;
            end
            if((imme_addr_b == 90) && rd_state == CONV2)begin
                conv2_read_flag <= 0;
            end
        end
    end
    
    
    always@(posedge i_clk)begin
        if(!i_rst)begin
            rd_state <= 2'b00;
            imme_addr_b <= 0;
            enb <= 0;
            rd_state_cnt <= 0;
        end
        else begin
            case(rd_state)
                CONV1 : begin
                    /// 5x5 연산에 맞춰서 바꿔야 한다 
                    if(conv1_read_flag)begin // read bram
                            enb <= 1;
                            if(enb)begin
                                imme_addr_b <= 6 * (conv2_pos + conv2_poi * 12 + conv2_col + conv2_row * 12);
                            end
                            if(imme_addr_b == 858)begin
                                rd_state <= CONV2;
                                enb <= 0; imme_addr_b <= 0;
                                rd_state_cnt <= 0; 
                            end
                    end
                end
                CONV2 : begin
                        if(conv2_read_flag)begin
                            enb <= 1;
                            if(enb)begin
                                imme_addr_b <= imme_addr_b + 6;
                            end
                            if(imme_addr_b == 90)begin
                                rd_state <= FC1;
                                enb <= 0; imme_addr_b <= 0;
                                rd_state_cnt <=0;
                            end
                        end
                    end
            endcase
        end
    end
    
    inter_mediate_buffer intermediate_Buf(
        .addra(imme_addr_a),
        .clka(i_clk),
        .dina(imme_in),
        .ena(ena),
        .wea(wea),
        
        .addrb(imme_addr_b),
        .clkb(i_clk),
        .doutb(imme_out),
        .enb(enb)
    );
    
    reg [7:0] bram1_addr;
    reg bram1_en;
    reg conv2_weight_en;
    wire [7:0] conv2_filter;
    
    always@(posedge i_clk)begin
        if(!i_rst)begin
            bram1_en <= 0;
            bram1_addr <= 1;
            conv2_weight_en <= 0;
        end
        else begin
            if(bram1_addr == 225)begin
                bram1_en <= 0;
            end
            else begin
                if(bram1_en)begin
                    bram1_addr <= bram1_addr + 1;
                end
                bram1_en <= 1;
            end
            conv2_weight_en <= bram1_en;
        end
    end
    
    // BLOCK RAM SETTING FOR CONV2 LAYER (weight BRAM)
    blk_mem_gen_1 conv2_weight_bram (
        .clka(i_clk),
        .ena(bram1_en),
        .addra(bram1_addr),
        .douta(conv2_filter)
    );
    
    wire signed [15:0] conv2_out0, conv2_out1, conv2_out2;
    wire conv2_valid, conv2_weight_done;
    conv2_layer conv2(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_valid(conv2_i_valid),
        .weight_valid(conv2_weight_en),
        .filter(conv2_filter),
        .data_ch0(imme_out[15:0]),
        .data_ch1(imme_out[31:16]),
        .data_ch2(imme_out[47:32]),
        
        .conv2_out_ch0(conv2_out0),
        .conv2_out_ch1(conv2_out1),
        .conv2_out_ch2(conv2_out2),
        .conv2_valid(conv2_valid),
        
        .weight_done(conv2_weight_done)
      );
    
    wire signed [15:0] max2_out0, max2_out1, max2_out2;
    wire max2_valid;
    
    Max_relu #(
            .HALF_WIDTH(4), 
            .HALF_HEIGHT(4), 
            .HALF_WIDTH_BIT(3) // 0~3, 3-1= 2
        ) max_relu_2(
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_valid(conv2_valid),
            .conv_out_1(conv2_out0), .conv_out_2(conv2_out1), .conv_out_3(conv2_out2),
            .max_value_1(max2_out0), .max_value_2(max2_out1), .max_value_3(max2_out2),
            .valid_out_relu(max2_valid)
        );
        
    reg bram2_en, fc1_weight_en;
    reg [9:0] bram2_addr;
    wire [7:0] fc1_filter;
    
    
    always@(posedge i_clk)begin
        if(!i_rst)begin
            bram2_en <= 0;
            bram2_addr <= 1;
            fc1_weight_en <= 0;
        end
        else begin
            if(bram2_addr == 784)begin
                bram2_en <= 0;
            end
            else begin
                if(bram2_en)begin
                    bram2_addr <= bram2_addr + 1;
                end
                bram2_en <= 1;
            end
            fc1_weight_en <= bram2_en;
        end
    end
    
    
    blk_mem_gen_2 fc1_weight_bram(
        .clka(i_clk),
        .ena(bram2_en),
        .addra(bram2_addr),
        .douta(fc1_filter)
    );
    
    wire signed [15:0] fc1_out1, fc1_out2, fc1_out3, fc1_out4, fc1_out5, fc1_out6, fc1_out7, fc1_out8, fc1_out9, fc1_out10, fc1_out11, fc1_out12, fc1_out13, fc1_out14, fc1_out15, fc1_out16;
    wire fc1_weight_done;
    wire fc1_out_valid;
    
    FC1_layer#(
        .INPUT_NUM(48),
        .OUTPUT_NUM(16)
    ) Fully_connect_1(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_valid(fc1_i_valid),
        .filter(fc1_filter),
        .weight_valid(fc1_weight_en),
        
        .data_in_1(imme_out[15:0]),
        .data_in_2(imme_out[31:16]),
        .data_in_3(imme_out[47:32]),
        
        .data_out1(fc1_out1),
        .data_out2(fc1_out2),
        .data_out3(fc1_out3),
        .data_out4(fc1_out4),
        .data_out5(fc1_out5),
        .data_out6(fc1_out6),
        .data_out7(fc1_out7),
        .data_out8(fc1_out8),
        .data_out9(fc1_out9),
        .data_out10(fc1_out10),
        .data_out11(fc1_out11),
        .data_out12(fc1_out12),
        .data_out13(fc1_out13),
        .data_out14(fc1_out14),
        .data_out15(fc1_out15),
        .data_out16(fc1_out16),
        .weight_done(fc1_weight_done),
        .o_valid(fc1_out_valid)
    );
endmodule
