`timescale 1ns / 1ps

module rom_write(
    input clk,
    input rstb,
    input conv_valid,
    input [31:0] pixel_out,
    output reg write_fin,
    output reg write_fin_delay,
    output write_ready,
    output reg [31:0] rom_o_data, // Delayed output for simulation & synthesis check
    output reg [9:0] addr_delay // Delayed address for simulation & synthesis check
    );

    parameter WIDTH = 32;
    parameter HEIGHT = 32;
    parameter OUT_WIDTH = WIDTH - 2; // Output width after convolution
    parameter OUT_HEIGHT = HEIGHT - 2; // Output height after convolution
    
    (* ram_style = "block" *)
    reg [31:0] rom_o [0:OUT_HEIGHT * OUT_WIDTH - 1]; // Output ROM to store results
    
    reg [9:0] addr; // Address for output ROM, 10 bits to cover 1024 entries
    reg [9:0] addr_data; // output data address for simulation & synthesis check

    assign write_ready = (addr < OUT_HEIGHT * OUT_WIDTH) ? 1'b1 : 1'b0; // Write is ready if address is within bounds


    // Address + control always block
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            addr <= 10'b0; // Reset address
            addr_data <= 10'b0; // Reset output data address
            addr_delay <= 10'b0; // Reset delayed address for simulation & synthesis check
            write_fin <= 0; // Reset write finish signal
        end else if (conv_valid) begin
            if (addr < OUT_HEIGHT * OUT_WIDTH) begin
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
            write_fin <= 0; // If conv_valid is low, writing is not finished
            write_fin_delay <= write_fin; // Store delayed write finish signal for simulation & synthesis check
            addr_delay <= addr_data; // Keep the delayed address unchanged
        end
    end


    // Write ROM always block -> Delete async reset for block RAM synthesis
    always @(posedge clk) begin
        if (conv_valid && rstb) begin
            if (addr < OUT_HEIGHT * OUT_WIDTH) begin
                rom_o[addr] <= pixel_out; // Update ROM with pixel output
                rom_o_data <= rom_o[addr_data]; // Update delayed output for simulation & synthesis check
            end else begin
                rom_o[addr] <= rom_o[addr]; // Keep the last output unchanged if conv_valid is low or rstb is low
                rom_o_data <= rom_o[addr_data]; // Keep the delayed output unchanged
            end
        end
    end

endmodule
