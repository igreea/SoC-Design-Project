`timescale 1ns / 1ps

module buffer(
    input clk,
    input rstb,
    input [7:0] pixel_in,
    input read_valid, win_ready,
    output [7:0] out_data_1, out_data_2, out_data_3,
    output [7:0] out_data_4, out_data_5, out_data_6,
    output [7:0] out_data_7, out_data_8, out_data_9,
    output reg in_row2_cond,
    output buf_valid, buf_ready
    );
    parameter WIDTH = 32;
    parameter KERNEL_SIZE = 3;

    // Buffer & address
    reg [7:0] buffer_i[0:KERNEL_SIZE - 1][0:WIDTH - 1] ; // Buffer to store pixel data, buffer_i[row][col]
    reg [2:0] row_addr;
    reg [4:0] col_addr;

    // control signals
    reg [4:0] data_col_addr_0; // Column address for output data, first column
    reg [4:0] data_col_addr_1; // Column address for output data, second column
    reg [4:0] data_col_addr_2; // Column address for output data, third column

    integer i; // Loop variable for buffer initialization, not used in synthesis

    assign buf_ready = win_ready; // Buffer is ready to accept new data when window is ready

    // address management always block
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            row_addr <= 3'b0;
            col_addr <= 5'b0;
            data_col_addr_0 <= 5'd0;
            data_col_addr_1 <= 5'd0;
            data_col_addr_2 <= 5'd0;
            in_row2_cond <= 1'b0;
        end else if (read_valid && win_ready) begin
            if (row_addr == KERNEL_SIZE && col_addr == 0) begin
                row_addr <= 2;
                col_addr <= 1;
            end else begin
                col_addr <= (col_addr < WIDTH - 1) ? col_addr + 1 : 0;
                row_addr <= (col_addr < WIDTH - 1) ? row_addr : row_addr + 1; // buffer[2][31] -> buffer[3][0]
                data_col_addr_0 <= (col_addr < WIDTH - 1) ? col_addr - 2 : 5'd29; // Adjust column address for output when row changes
                data_col_addr_1 <= (col_addr < WIDTH - 1) ? col_addr - 1 : 5'd30; // Adjust column address for output when row changes
                data_col_addr_2 <= (col_addr < WIDTH - 1) ? col_addr : 5'd31; // Adjust column address for output when row changes
                in_row2_cond <= (row_addr >= KERNEL_SIZE - 1 && col_addr >= 2);
            end
        end
    end

    // Buffer management always block -> Delete async reset for set/reset priority warning
    always @(posedge clk) begin
        if (read_valid && win_ready && rstb) begin
            if (row_addr == KERNEL_SIZE && col_addr == 0) begin
                for (i = 0; i < WIDTH; i = i + 1) begin
                    buffer_i[0][i] <= buffer_i[1][i];
                    buffer_i[1][i] <= buffer_i[2][i];
                end
                buffer_i[2][0] <= pixel_in; // Reset the third row with new pixel input
            end else begin
                // Store the incoming pixel data in the current row and column
                buffer_i[row_addr][col_addr] <= pixel_in;
            end
        end else begin
            buffer_i[row_addr][col_addr] <= buffer_i[row_addr][col_addr]; // Maintain current state if not reading or convolution is not ready or reset is low
        end
    end

    /// Data output management
    assign buf_valid  = (col_addr > 2 || col_addr == 0) ? 1'b1 : 1'b0; // Valid output when enough data is available
    assign out_data_1 = buffer_i[0][data_col_addr_0];
    assign out_data_2 = buffer_i[0][data_col_addr_1];
    assign out_data_3 = buffer_i[0][data_col_addr_2];
    assign out_data_4 = buffer_i[1][data_col_addr_0];
    assign out_data_5 = buffer_i[1][data_col_addr_1];
    assign out_data_6 = buffer_i[1][data_col_addr_2];
    assign out_data_7 = buffer_i[2][data_col_addr_0];
    assign out_data_8 = buffer_i[2][data_col_addr_1];
    assign out_data_9 = buffer_i[2][data_col_addr_2];

endmodule
