`timescale 1ns/1ps

module top_tb();
    reg clk;
    reg rstb;

    wire write_fin; // Write finish signal for synthesis check
    wire write_fin_delay; // Delayed write finish signal for simulation & synthesis check
    wire [31:0] rom_o_data; // rom_data for simulation & synthesis check 
    wire [9:0] rom_o_addr; // rom_addr for simulation & synthesis check 
    wire [8:0] win_data_1, win_data_2, win_data_3;
    wire [8:0] win_data_4, win_data_5, win_data_6;
    wire [8:0] win_data_7, win_data_8, win_data_9;
    wire [31:0] pixel_out; // 32-bit pixel output after convolution

    reg [31:0] dump_rom [0:899]; // ROM dump for simulation & synthesis check
    // Instantiate top module
    top uut (
        .clk(clk),
        .rstb(rstb),

        .write_fin(write_fin),
        .write_fin_delay(write_fin_delay), // Delayed write finish signal for simulation & synthesis check
        .rom_o_data(rom_o_data), // rom_data for simulation & synthesis check
        .rom_o_addr(rom_o_addr), // rom_addr for simulation & synthesis check
        .win_data_1(win_data_1), .win_data_2(win_data_2), .win_data_3(win_data_3),
        .win_data_4(win_data_4), .win_data_5(win_data_5), .win_data_6(win_data_6),
        .win_data_7(win_data_7), .win_data_8(win_data_8), .win_data_9(win_data_9),
        .pixel_out(pixel_out)
    );

    // 100MHz clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rstb = 0;

        // Reset pulse
        #20;
        rstb = 1;
    end
    integer i;
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            // Initialize dump_rom with zeros
            for (i = 0; i < 900; i = i + 1) begin
                dump_rom[i] = 32'b0;
            end
        end else begin
            dump_rom[rom_o_addr] <= rom_o_data; // Store output data in dump_rom for simulation & synthesis check
        end

    end

    always @(*) begin
        if (write_fin) begin
            $display("ROM Write finished at time %t", $time);
            // $writememh("inter_rom_o.mem", uut.u_romW.rom_o);
            // $display("Output written to inter_rom_o.mem");
        end
        if (write_fin_delay) begin
            #10; // Delay to ensure write_fin_delay is captured correctly
            $display("Testbench dump ROM Write finished at time %t", $time);
            $writememh("output.mem", dump_rom);
            $display("Delayed output written to output.mem");
            $finish; // End simulation after writing output
        end
    end


endmodule
