`timescale 1ns/1ps

module top_tb();
    reg clk;
    reg rstb;

    wire write_fin; // Write finish signal for synthesis check
    wire write_fin_delay; // Delayed write finish signal for simulation & synthesis check
    wire [47:0] rom_o_data; // rom_data for simulation & synthesis check (one clock delayed)
    wire [9:0] rom_o_addr; // rom_address for simulation & synthesis check (one clock delayed)
    wire [47:0] pixel_out; // 48-bit pixel output after convolution

    reg [47:0] dump_rom [0:899]; // ROM dump for simulation & synthesis check
    // Instantiate top module
    top uut (
        .clk(clk),
        .rstb(rstb),

        .write_fin(write_fin),
        .write_fin_delay(write_fin_delay),
        .rom_o_data(rom_o_data), // rom_data for simulation & synthesis check (one clock delayed)
        .rom_o_addr(rom_o_addr), // rom_address for simulation & synthesis check (one clock delayed)
        .pixel_out(pixel_out) // 48-bit pixel output after convolution
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
                dump_rom[i] = 48'b0;
            end
        end else begin
            dump_rom[rom_o_addr] <= rom_o_data; // Store output data in dump_rom for simulation & synthesis check
        end

    end


    always @(*) begin
        if (write_fin) begin
            $display("Write finished at time %t", $time);
            // $writememh("output.mem", uut.u_romW.rom_o);
            // $display("Output written to output.mem");
        end
        if (write_fin_delay) begin
            #10 // Wait for a clock cycle to ensure rom_o_data and rom_o_addr are updated
            $display("Testbench dump ROM Write finished at time %t", $time);
            $writememh("output.mem", dump_rom);
            $display("Delayed output written to output.mem");
            $finish;
        end
    end


endmodule
