// E155, Create the hsync and vsync signals for our VGA account for the timing and electrom beam transition porch time

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 12/04/2025

module vga_controller (input  logic clk, 
                       input  logic reset_n, 
                       output logic hsync, 
                       output logic vsync, 
                       output logic [10:0] hcount,
                       output logic [9:0]  vcount,
                       output logic active_video);

    // VGA 640x480 @ 60Hz 1024 x 600
    // Our PLL clock: 25.5 MHz

    // horizontal VGA constants
    localparam H_DISPLAY    = 640;  // Visible
    localparam H_FRONT      = 16;   // Front porch
    localparam H_SYNC       = 96;   // Sync pulse
    localparam H_BACK       = 48;   // Back porch
    localparam H_TOTAL      = 800;  // Total

    // vertical VGA constants
    localparam V_DISPLAY    = 480;  // Visible
    localparam V_FRONT      = 10;   // Front porch
    localparam V_SYNC       = 2;    // Sync pulse
    localparam V_BACK       = 33;   // Back porch
    localparam V_TOTAL      = 525;  // Total

    // calculated values for VGA visible controls
    localparam H_DISPLAY_START = H_SYNC + H_BACK;
    localparam H_DISPLAY_END = H_SYNC + H_BACK + H_DISPLAY;
    localparam V_DISPLAY_START = V_SYNC + V_BACK;
    localparam V_DISPLAY_END = V_SYNC + V_BACK + V_DISPLAY;
    
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            hcount <= 0;
            vcount <= 0;
        end else begin
			// check for VGA horizontal boundary
            if (hcount == H_TOTAL - 1) begin
                hcount <= 0;
				// if we are on the last row and we hit vcount, then frame is done
                if (vcount == V_TOTAL - 1) begin
                    vcount <= 0;
                end else begin 
                    vcount <= vcount + 1;
                end
            end else begin
                hcount <= hcount + 1;
            end
        end
    end

	// pulse hsync and vsync if VGA is in the syncing region
    assign hsync = ~(hcount < H_SYNC); // active low
    assign vsync = ~(vcount < V_SYNC); // active low
	
	// active video if we are within display range
    assign active_video = ((hcount >= H_DISPLAY_START && hcount < H_DISPLAY_END) && (vcount >= V_DISPLAY_START && vcount < V_DISPLAY_END));

    `ifdef DV
        `include "vga_ctrl_sva.svh"
    `endif

endmodule
