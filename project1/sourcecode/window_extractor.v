`timescale 1ns / 1ps

module window_extractor(
    input clk,
    input rstb,
    input in_row2_cond, // Condition to check if the second row is filled
    input [7:0] in_data_1, in_data_2, in_data_3,
    input [7:0] in_data_4, in_data_5, in_data_6,
    input [7:0] in_data_7, in_data_8, in_data_9,
    input buf_valid, // Buffer valid signal
    input conv_ready, // Convolution ready signal

    output reg signed [8:0] out_data_1, out_data_2, out_data_3,
    output reg signed [8:0] out_data_4, out_data_5, out_data_6,
    output reg signed [8:0] out_data_7, out_data_8, out_data_9,
    output reg win_valid, // window valid signal
    output win_ready
    );

    assign win_ready = conv_ready; // Ready to accept new data when conv module is ready

    reg signed [8:0] d1, d2, d3;
    reg signed [8:0] d4, d5, d6;
    reg signed [8:0] d7, d8, d9;

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            // Reset all output data and valid signals
            out_data_1 <= 9'b0;
            out_data_2 <= 9'b0;
            out_data_3 <= 9'b0;
            out_data_4 <= 9'b0;
            out_data_5 <= 9'b0;
            out_data_6 <= 9'b0;
            out_data_7 <= 9'b0;
            out_data_8 <= 9'b0;
            out_data_9 <= 9'b0;
            win_valid <= 1'b0;
        end else if (buf_valid && conv_ready) begin
            // Assign input data to output data when buffer is valid and convolution is ready
            out_data_1 <= d1;
            out_data_2 <= d2;
            out_data_3 <= d3;
            out_data_4 <= d4;
            out_data_5 <= d5;
            out_data_6 <= d6;
            out_data_7 <= d7;
            out_data_8 <= d8;
            out_data_9 <= d9;

            win_valid <= (in_row2_cond); // Allow convolution to proceed
        end else begin
            // If not valid, keep the previous state and stop conv
            win_valid <= 1'b0;
            out_data_1 <= out_data_1;
            out_data_2 <= out_data_2;
            out_data_3 <= out_data_3;
            out_data_4 <= out_data_4;
            out_data_5 <= out_data_5;
            out_data_6 <= out_data_6;
            out_data_7 <= out_data_7;
            out_data_8 <= out_data_8;
            out_data_9 <= out_data_9;
        end
    end


    // sign extension & valid control
    always @(*) begin
        d1 = (in_row2_cond) ? {1'b0, in_data_1} : 9'b0;
        d2 = (in_row2_cond) ? {1'b0, in_data_2} : 9'b0;
        d3 = (in_row2_cond) ? {1'b0, in_data_3} : 9'b0;
        d4 = (in_row2_cond) ? {1'b0, in_data_4} : 9'b0;
        d5 = (in_row2_cond) ? {1'b0, in_data_5} : 9'b0;
        d6 = (in_row2_cond) ? {1'b0, in_data_6} : 9'b0;
        d7 = (in_row2_cond) ? {1'b0, in_data_7} : 9'b0;
        d8 = (in_row2_cond) ? {1'b0, in_data_8} : 9'b0;
        d9 = (in_row2_cond) ? {1'b0, in_data_9} : 9'b0;
    end

endmodule
