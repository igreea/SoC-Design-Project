`timescale 1ns / 1ps

module rom_write #(
    parameter WIDTH = 32,
    parameter HEIGHT = 32,
    parameter OUT_WIDTH = WIDTH - 2,  // 30
    parameter OUT_HEIGHT = HEIGHT - 2 // 30
)(
    input clk,
    input rstb,
    input conv_valid,
    input [47:0] pixel_out,  // {R(16bit), G(16bit), B(16bit)}

    output reg write_fin,
    output reg write_fin_delay,
    output write_ready,
    output reg [47:0] rom_o_data, // Output data for ROM
    output reg [9:0] addr_delay // Delayed address for simulation & synthesis check
);

    (* ram_style = "block" *)
    reg [47:0] rom_o [0:OUT_WIDTH * OUT_HEIGHT - 1];

    reg [9:0] addr;
    reg [9:0] addr_data; // output data address for simulation & synthesis check

    assign write_ready = (addr < OUT_WIDTH * OUT_HEIGHT) ? 1'b1 : 1'b0;

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            addr <= 0;
            addr_data <= 0;
            addr_delay <= 0;
            write_fin <= 0;
        end else if (conv_valid) begin
            if (addr < OUT_WIDTH * OUT_HEIGHT) begin
                addr <= addr + 1; // Increment address
                addr_data <= addr; // Store output data address
                addr_delay <= addr_data; // Store delayed address for simulation & synthesis check
                write_fin <= 0; // Writing is not finished yet
                write_fin_delay <= write_fin; // Store delayed write finish signal for simulation & synthesis check
            end else begin
                addr <= addr; // Keep the address unchanged if it exceeds bounds
                addr_data <= addr_data; // Keep addr_data if it exceeds bounds
                addr_delay <= addr_data; //the delayed address
                write_fin <= 1; // Writing is finished when all entries are written
                write_fin_delay <= write_fin; // Store delayed write finish signal for simulation & synthesis check
            end
        end else begin
                write_fin <= 0;
                write_fin_delay <= write_fin; // Store delayed write finish signal for simulation & synthesis check
                addr_delay <= addr_data; // Keep the delayed address unchanged
        end
    end


    always @(posedge clk) begin
        if (conv_valid && rstb) begin
            if (addr < OUT_WIDTH * OUT_HEIGHT) begin
                rom_o[addr] <= pixel_out; // Write pixel data to ROM
                rom_o_data <= rom_o[addr_data]; // Output data for simulation & synthesis check
            end else begin
                rom_o_data <= rom_o[addr]; // Keep the output data unchanged if conv_valid is low
                rom_o_data <= rom_o[addr_data]; // Output data for simulation & synthesis check
            end
        end
    end

endmodule