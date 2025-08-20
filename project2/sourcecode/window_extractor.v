`timescale 1ns / 1ps

module window_extractor #(
    parameter WIDTH = 32,
    parameter KERNEL_SIZE = 3
)(
    input clk,
    input rstb,
    input in_row2_cond,
    input [23:0] in_data_1, in_data_2, in_data_3,
    input [23:0] in_data_4, in_data_5, in_data_6,
    input [23:0] in_data_7, in_data_8, in_data_9,
    input buf_valid,
    input conv_ready,

    // R channel 3x3 window
    output reg [7:0] win_R_1, win_R_2, win_R_3,
    output reg [7:0] win_R_4, win_R_5, win_R_6,
    output reg [7:0] win_R_7, win_R_8, win_R_9,
    // G channel 3x3 window
    output reg [7:0] win_G_1, win_G_2, win_G_3,
    output reg [7:0] win_G_4, win_G_5, win_G_6,
    output reg [7:0] win_G_7, win_G_8, win_G_9,
    // B channel 3x3 window
    output reg [7:0] win_B_1, win_B_2, win_B_3,
    output reg [7:0] win_B_4, win_B_5, win_B_6,
    output reg [7:0] win_B_7, win_B_8, win_B_9,
    output reg win_valid,
    output win_ready
);

    assign win_ready = conv_ready; // Window extractor is ready when convolution is ready
    
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            win_R_1 <= 0; win_R_2 <= 0; win_R_3 <= 0;
            win_R_4 <= 0; win_R_5 <= 0; win_R_6 <= 0;
            win_R_7 <= 0; win_R_8 <= 0; win_R_9 <= 0;

            win_G_1 <= 0; win_G_2 <= 0; win_G_3 <= 0;
            win_G_4 <= 0; win_G_5 <= 0; win_G_6 <= 0;
            win_G_7 <= 0; win_G_8 <= 0; win_G_9 <= 0;

            win_B_1 <= 0; win_B_2 <= 0; win_B_3 <= 0;
            win_B_4 <= 0; win_B_5 <= 0; win_B_6 <= 0;
            win_B_7 <= 0; win_B_8 <= 0; win_B_9 <= 0;
        end else if (buf_valid && conv_ready) begin
            // Extract RGB channels from input data
            {win_R_1, win_G_1, win_B_1} <= in_data_1;
            {win_R_2, win_G_2, win_B_2} <= in_data_2;
            {win_R_3, win_G_3, win_B_3} <= in_data_3;
            {win_R_4, win_G_4, win_B_4} <= in_data_4;
            {win_R_5, win_G_5, win_B_5} <= in_data_5;
            {win_R_6, win_G_6, win_B_6} <= in_data_6;
            {win_R_7, win_G_7, win_B_7} <= in_data_7;
            {win_R_8, win_G_8, win_B_8} <= in_data_8;
            {win_R_9, win_G_9, win_B_9} <= in_data_9;

            win_valid <= in_row2_cond; // Set valid signal based on row condition
        end else begin
            win_valid <= 1'b0; // Reset valid signal if not valid
            {win_R_1, win_R_2, win_R_3} <= {win_R_1, win_R_2, win_R_3};
            {win_R_4, win_R_5, win_R_6} <= {win_R_4, win_R_5, win_R_6};
            {win_R_7, win_R_8, win_R_9} <= {win_R_7, win_R_8, win_R_9};
            
            {win_G_1, win_G_2, win_G_3} <= {win_G_1, win_G_2, win_G_3};
            {win_G_4, win_G_5, win_G_6} <= {win_G_4, win_G_5, win_G_6};
            {win_G_7, win_G_8, win_G_9} <= {win_G_7, win_G_8, win_G_9};

            {win_B_1, win_B_2, win_B_3} <= {win_B_1, win_B_2, win_B_3};
            {win_B_4, win_B_5, win_B_6} <= {win_B_4, win_B_5, win_B_6};
            {win_B_7, win_B_8, win_B_9} <= {win_B_7, win_B_8, win_B_9};
        end
    end
endmodule