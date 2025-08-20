`timescale 1ns / 1ps

module conv(
    input clk,
    input rstb,
    input win_valid, write_ready,
    input wire signed [8:0] in_data_1, in_data_2, in_data_3,
    input wire signed [8:0] in_data_4, in_data_5, in_data_6,
    input wire signed [8:0] in_data_7, in_data_8, in_data_9,
    output reg [31:0] pixel_out,
    output reg conv_valid, 
    output conv_ready
);
    wire signed [15:0] gx, gy;
    wire signed [8:0] inv_data_1, inv_data_2, inv_data_3, inv_data_4, inv_data_7; // Inverted data for Sobel filter

    reg signed [15:0] gx_buf, gy_buf; // Buffers for Gx and Gy
    reg conv_valid_buf; // Buffer for valid signal
    assign conv_ready = write_ready; // Always ready to compute convolution (if conv has timing violation, must make busy flag)

    // Buffering for Gx and Gy
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            gx_buf <= 16'b0;
            gy_buf <= 16'b0;
            conv_valid_buf <= 1'b0;
        end else if (win_valid && write_ready) begin
            gx_buf <= gx;
            gy_buf <= gy;
            conv_valid_buf <= 1'b1;
        end else begin
            conv_valid_buf <= 1'b0; // Reset valid signal when not computing
        end
    end

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            pixel_out <= 32'b0;
            conv_valid <= 1'b0; // Reset valid signal on reset
        end else begin
            pixel_out <= {gx_buf, gy_buf};
            conv_valid <= conv_valid_buf; // Set valid output signal when computation is done
        end
    end
    
    // Invert data for Sobel filter
    assign inv_data_1 = -in_data_1;
    assign inv_data_2 = -in_data_2;
    assign inv_data_3 = -in_data_3;
    assign inv_data_4 = -in_data_4;
    assign inv_data_7 = -in_data_7;
    
    assign gx = (inv_data_1 + (inv_data_4 << 1) + inv_data_7) + (in_data_3 + (in_data_6 << 1) + in_data_9); // Sobel Gx
    assign gy = (inv_data_1 + (inv_data_2 << 1) + inv_data_3) + (in_data_7 + (in_data_8 << 1) + in_data_9); // Sobel Gy

endmodule