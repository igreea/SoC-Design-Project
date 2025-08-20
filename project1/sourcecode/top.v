`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SoC Design 2025 - 1
// Engineer: Team 1
// 
// Create Date: 2025/05/22 14:54:34
// Design Name: 2dconv
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input clk,
    input rstb,
    output write_fin, // Write finish signal for synthesis check
    output write_fin_delay, // Delayed write finish signal for simulation & synthesis check
    output [31:0] rom_o_data, // output rom data for simulation & synthesis check
    output [9:0] rom_o_addr, // output rom address for simulation & synthesis check
    // implemenation 시 comb 경로 안정화를 위해 출력 포트로 뽑음
    output [8:0] win_data_1, win_data_2, win_data_3,
    output [8:0] win_data_4, win_data_5, win_data_6,
    output [8:0] win_data_7, win_data_8, win_data_9,
    output [31:0] pixel_out // 32-bit pixel output after convolution
    );
    parameter WIDTH = 32;
    parameter HEIGHT = 32;
    parameter KERNEL_SIZE = 3;

    wire [7:0] pixel_in; // 8-bit pixel input from ROM
    wire read_valid;
    wire buf_ready, buf_valid;
    wire win_ready, win_valid;
    wire conv_ready, conv_valid;
    wire write_ready;
    wire [7:0] buf_data_1, buf_data_2, buf_data_3;
    wire [7:0] buf_data_4, buf_data_5, buf_data_6;
    wire [7:0] buf_data_7, buf_data_8, buf_data_9;

    wire in_row2_cond;


    rom_read #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) u_romR( // 한 클럭씩 읽어오는 모듈, 내부에서 input.mem을 rom_i로 로드
        .clk(clk),
        .rstb(rstb),
        // input signals
        .buf_ready(buf_ready),
        // output signals
        .pixel(pixel_in),
        .read_valid(read_valid)
    );

    buffer #(.WIDTH(WIDTH), .KERNEL_SIZE(KERNEL_SIZE)) u_buffer( // 버퍼에 저장하는 모듈, 내부 버퍼 크기 = KERNEL_SIZE * WIDTH
        .clk(clk),
        .rstb(rstb),
        // input signals
        .pixel_in(pixel_in),
        .read_valid(read_valid),
        .win_ready(win_ready),
        // output signals
        .out_data_1(buf_data_1), .out_data_2(buf_data_2), .out_data_3(buf_data_3),
        .out_data_4(buf_data_4), .out_data_5(buf_data_5), .out_data_6(buf_data_6),
        .out_data_7(buf_data_7), .out_data_8(buf_data_8), .out_data_9(buf_data_9),
        .in_row2_cond(in_row2_cond),
        .buf_valid(buf_valid),
        .buf_ready(buf_ready)
    );

    window_extractor u_win(
        .clk(clk),
        .rstb(rstb),
        // input signals
        .buf_valid(buf_valid),
        .conv_ready(conv_ready),
        .in_row2_cond(in_row2_cond),
        .in_data_1(buf_data_1), .in_data_2(buf_data_2), .in_data_3(buf_data_3),
        .in_data_4(buf_data_4), .in_data_5(buf_data_5), .in_data_6(buf_data_6),
        .in_data_7(buf_data_7), .in_data_8(buf_data_8), .in_data_9(buf_data_9),
        // output signals
        .out_data_1(win_data_1), .out_data_2(win_data_2), .out_data_3(win_data_3),
        .out_data_4(win_data_4), .out_data_5(win_data_5), .out_data_6(win_data_6),
        .out_data_7(win_data_7), .out_data_8(win_data_8), .out_data_9(win_data_9),
        .win_ready(win_ready),
        .win_valid(win_valid)
    );

    conv u_conv( // 합성곱 연산 모듈
        .clk(clk),
        .rstb(rstb),
        // input signals
        .win_valid(win_valid),
        .write_ready(write_ready),
        .in_data_1(win_data_1), .in_data_2(win_data_2), .in_data_3(win_data_3),
        .in_data_4(win_data_4), .in_data_5(win_data_5), .in_data_6(win_data_6),
        .in_data_7(win_data_7), .in_data_8(win_data_8), .in_data_9(win_data_9),
        // output signals
        .conv_valid(conv_valid),
        .conv_ready(conv_ready),
        .pixel_out(pixel_out)
    );

    rom_write #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) u_romW( // 결과를 저장하는 모듈, 내부에서 output.mem을 rom_o로 로드
        .clk(clk),
        .rstb(rstb),
        // input signals
        .conv_valid(conv_valid),
        .pixel_out(pixel_out),
        // output signals
        .write_ready(write_ready),
        .write_fin(write_fin),
        .write_fin_delay(write_fin_delay), // Delayed write finish signal for simulation & synthesis check
        .rom_o_data(rom_o_data),
        .addr_delay(rom_o_addr)

    );

endmodule
