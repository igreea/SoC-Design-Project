`timescale 1ns / 1ps

module rom_read #(
    parameter WIDTH = 32,
    parameter HEIGHT = 32,
    parameter depth = 10
)(
    input clk,
    input rstb,
    input buf_ready,
    output reg [23:0] pixel,  // 24bit RGB (R8, G8, B8)
    output reg read_valid
);

    (* ram_style = "block" *)
    reg [23:0] rom_i [0:WIDTH * HEIGHT - 1]; // 24bit RGB

    reg [depth:0] addr;

    initial begin
        $readmemh("input.mem", rom_i);
    end

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            addr <= 0;
            read_valid <= 0;
        end else if (buf_ready) begin
            // Read pixel data from ROM (input.mem)
            // Assuming a simple counter to simulate reading from ROM    
            addr <= (buf_ready) ? addr + 1 : addr; // Increment address if buffer is ready
            read_valid <= (addr[10] == 1'b1) ? 1'b0 : 1'b1; // Update read valid signal based on address
        end
    end


    always @(posedge clk) begin
        if (!rstb)
            pixel <= 24'b0; // Reset pixel data on reset
        else
            pixel <= rom_i[addr]; // Read pixel data from ROM
    end
endmodule
