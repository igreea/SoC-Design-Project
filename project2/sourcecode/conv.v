`timescale 1ns / 1ps

module conv(
    input clk,
    input rstb,
    input win_valid, write_ready,

    // R channel 3x3 window
    input [7:0] in_R_1, in_R_2, in_R_3,
    input [7:0] in_R_4, in_R_5, in_R_6,
    input [7:0] in_R_7, in_R_8, in_R_9,
    // G channel 3x3 window
    input [7:0] in_G_1, in_G_2, in_G_3,
    input [7:0] in_G_4, in_G_5, in_G_6,
    input [7:0] in_G_7, in_G_8, in_G_9,
    // B channel 3x3 window
    input [7:0] in_B_1, in_B_2, in_B_3,
    input [7:0] in_B_4, in_B_5, in_B_6,
    input [7:0] in_B_7, in_B_8, in_B_9,

    output reg [47:0] pixel_out,  // {R(16bit), G(16bit), B(16bit)}
    output reg conv_valid,
    output conv_ready
);
    wire [15:0] r_sum, g_sum, b_sum;

    reg [15:0] r_sum_buf, g_sum_buf, b_sum_buf;
    reg conv_valid_buf;
    assign conv_ready = write_ready;  // always ready until module finished

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            r_sum_buf <= 0;
            g_sum_buf <= 0;
            b_sum_buf <= 0;
            conv_valid_buf <= 0;
        end else if (win_valid && write_ready) begin
            // R channel
            r_sum_buf <= r_sum;
            // G channel
            g_sum_buf <= g_sum;
            // B channel
            b_sum_buf <= b_sum;
            conv_valid_buf <= 1'b1;
        end else begin
            conv_valid_buf <= 1'b0;
        end
    end

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            pixel_out <= 48'b0;
            conv_valid <= 1'b0; // Reset valid signal on reset
        end else begin
            pixel_out <= {r_sum_buf, g_sum_buf, b_sum_buf}; // Concatenate R, G, B sums
            conv_valid <= conv_valid_buf; // Set valid output signal when computation is done
        end
    end

    assign r_sum = ( in_R_1       + (in_R_2 << 1) + in_R_3 +
                    (in_R_4 << 1) + (in_R_5 << 2) + (in_R_6 << 1) +
                     in_R_7       + (in_R_8 << 1) + in_R_9         ) >> 4;
    
    assign g_sum = ( in_G_1       + (in_G_2 << 1) + in_G_3 +
                    (in_G_4 << 1) + (in_G_5 << 2) + (in_G_6 << 1) +
                     in_G_7       + (in_G_8 << 1) + in_G_9         ) >> 4;

    assign b_sum = ( in_B_1       + (in_B_2 << 1) + in_B_3 +
                    (in_B_4 << 1) + (in_B_5 << 2) + (in_B_6 << 1) +
                     in_B_7       + (in_B_8 << 1) + in_B_9         ) >> 4;

endmodule
