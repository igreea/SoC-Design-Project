`timescale 1ns / 1ps

module rom_read(
    input clk,
    input rstb,
    input buf_ready,
    output reg [7:0] pixel,
    output reg read_valid
    );
    parameter WIDTH = 32;
    parameter HEIGHT = 32;
    parameter depth = 10;

    (* ram_style = "block" *)
    reg [7:0] rom_i [0:HEIGHT * WIDTH - 1];

    reg [depth:0] addr; // {switch, addr} -> addr[10] means reading is done

    // Initialize the ROM with data from input.mem
    initial begin
        $readmemh("input.mem", rom_i);
    end

    // Address management always block
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin // Reset condition, reset & read_en must be high to read
            addr <= 11'b0;
            read_valid <= 1'b0; // Reset read valid signal
        end else begin
            // Read pixel data from ROM (input.mem)
            // Assuming a simple counter to simulate reading from ROM    
            addr <= (buf_ready) ? addr + 1 : addr; // Increment address if buffer is ready
            read_valid <= (addr[10] == 1'b1) ? 1'b0 : 1'b1; // Update read valid signal based on address
        end
    end

    // Data management always block -> Delete async reset for block RAM synthesis
    always @(posedge clk) begin
        if (!rstb)
            pixel <= 8'b0; // Reset pixel data on reset
        else
            pixel <= rom_i[addr]; // Read pixel data from ROM
    end
endmodule
 