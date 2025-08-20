`timescale 1ns/1ps

module top(
    input clk,
    input rstb,
    output write_fin, // Write finish signal
    output write_fin_delay, // Delayed write finish signal for simulation & synthesis check
    output [47:0] rom_o_data, // Output data for ROM
    output [9:0] rom_o_addr, // Output address for ROM

    output [47:0] pixel_out // 48-bit pixel output after convolution
);
    parameter WIDTH = 32;
    parameter HEIGHT = 32;
    parameter KERNEL_SIZE = 3;

    // Data signals
    wire [23:0] pixel_in;        // 24bit input (R, G, B)

    // Control signals
    wire read_valid;
    wire buf_ready, buf_valid;
    wire win_ready, win_valid;
    wire conv_ready, conv_valid;
    wire write_ready;

    // Correct bit width for RGB signal
    wire [23:0] buf_data_1, buf_data_2, buf_data_3;
    wire [23:0] buf_data_4, buf_data_5, buf_data_6;
    wire [23:0] buf_data_7, buf_data_8, buf_data_9;

    wire [7:0] win_R_1, win_R_2, win_R_3, win_R_4, win_R_5, win_R_6, win_R_7, win_R_8, win_R_9;
    wire [7:0] win_G_1, win_G_2, win_G_3, win_G_4, win_G_5, win_G_6, win_G_7, win_G_8, win_G_9;
    wire [7:0] win_B_1, win_B_2, win_B_3, win_B_4, win_B_5, win_B_6, win_B_7, win_B_8, win_B_9;

    wire in_row2_cond; // Condition for row 2 in buffer

    // Input read module
    rom_read #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) u_romR (
        .clk(clk),
        .rstb(rstb),
        // Input signals
        .buf_ready(buf_ready),
        // Output signals
        .pixel(pixel_in),
        .read_valid(read_valid)
    );

    // Buffer
    buffer #(.WIDTH(WIDTH), .KERNEL_SIZE(KERNEL_SIZE)) u_buffer (
        .clk(clk),
        .rstb(rstb),
        // Input signals
        .pixel_in(pixel_in),
        .read_valid(read_valid),
        .win_ready(win_ready),
        // Output signals
        .out_data_1(buf_data_1), .out_data_2(buf_data_2), .out_data_3(buf_data_3),
        .out_data_4(buf_data_4), .out_data_5(buf_data_5), .out_data_6(buf_data_6),
        .out_data_7(buf_data_7), .out_data_8(buf_data_8), .out_data_9(buf_data_9),
        .in_row2_cond(in_row2_cond),
        .buf_valid(buf_valid),
        .buf_ready(buf_ready)
    );

    // Window Extractor
    window_extractor #(.WIDTH(WIDTH), .KERNEL_SIZE(KERNEL_SIZE)) u_window (
        .clk(clk),
        .rstb(rstb),
        // Input signals
        .buf_valid(buf_valid),
        .conv_ready(conv_ready),
        .in_row2_cond(in_row2_cond),
        .in_data_1(buf_data_1), .in_data_2(buf_data_2), .in_data_3(buf_data_3),
        .in_data_4(buf_data_4), .in_data_5(buf_data_5), .in_data_6(buf_data_6),
        .in_data_7(buf_data_7), .in_data_8(buf_data_8), .in_data_9(buf_data_9),
        // output signals
        // R channel 3x3 window
        .win_R_1(win_R_1), .win_R_2(win_R_2), .win_R_3(win_R_3),
        .win_R_4(win_R_4), .win_R_5(win_R_5), .win_R_6(win_R_6),
        .win_R_7(win_R_7), .win_R_8(win_R_8), .win_R_9(win_R_9),
        // G channel 3x3 window
        .win_G_1(win_G_1), .win_G_2(win_G_2), .win_G_3(win_G_3),
        .win_G_4(win_G_4), .win_G_5(win_G_5), .win_G_6(win_G_6),
        .win_G_7(win_G_7), .win_G_8(win_G_8), .win_G_9(win_G_9),
        // B channel 3x3 window
        .win_B_1(win_B_1), .win_B_2(win_B_2), .win_B_3(win_B_3),
        .win_B_4(win_B_4), .win_B_5(win_B_5), .win_B_6(win_B_6),
        .win_B_7(win_B_7), .win_B_8(win_B_8), .win_B_9(win_B_9),
        .win_ready(win_ready),
        .win_valid(win_valid)
    );

    // Convolution
    conv u_conv (
        .clk(clk),
        .rstb(rstb),
        // Input signals
        .win_valid(win_valid),
        .write_ready(write_ready),
        // R channel
        .in_R_1(win_R_1), .in_R_2(win_R_2), .in_R_3(win_R_3),
        .in_R_4(win_R_4), .in_R_5(win_R_5), .in_R_6(win_R_6),
        .in_R_7(win_R_7), .in_R_8(win_R_8), .in_R_9(win_R_9),
        // G channel
        .in_G_1(win_G_1), .in_G_2(win_G_2), .in_G_3(win_G_3),
        .in_G_4(win_G_4), .in_G_5(win_G_5), .in_G_6(win_G_6),
        .in_G_7(win_G_7), .in_G_8(win_G_8), .in_G_9(win_G_9),
        // B channel
        .in_B_1(win_B_1), .in_B_2(win_B_2), .in_B_3(win_B_3),
        .in_B_4(win_B_4), .in_B_5(win_B_5), .in_B_6(win_B_6),
        .in_B_7(win_B_7), .in_B_8(win_B_8), .in_B_9(win_B_9),
        // output
        .conv_valid(conv_valid),
        .conv_ready(conv_ready),
        .pixel_out(pixel_out)
    );

    // Output write module
    rom_write #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) u_romW (
        .clk(clk),
        .rstb(rstb),
        // Input signals
        .conv_valid(conv_valid),
        .pixel_out(pixel_out),
        // Output signals
        .write_ready(write_ready),
        .write_fin(write_fin),
        .write_fin_delay(write_fin_delay),
        .rom_o_data(rom_o_data),
        .addr_delay(rom_o_addr)
    );

endmodule

