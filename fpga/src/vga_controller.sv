// TODO: maybe add a signal for blank, so that we can blank it out
module vga_controller (input logic clk, 
                       input logic reset, 
                       output logic hsync, 
                       output logic vsync, 
                       output logic [10:0] hcount,  // 0–799
                       output logic [9:0]  vcount,   // 0–524
                       output logic active_video);

    // VGA 640x480 @ 60Hz
    // Pixel clock: 25.175 MHz

    // horizontal
    localparam H_DISPLAY    = 640;  // Visible
    localparam H_FRONT      = 16;   // Front porch
    localparam H_SYNC       = 96;   // Sync pulse
    localparam H_BACK       = 48;   // Back porch
    localparam H_TOTAL      = 800;  // Total

    // vertical
    localparam V_DISPLAY    = 480;  // Visible
    localparam V_FRONT      = 10;   // Front porch
    localparam V_SYNC       = 2;    // Sync pulse
    localparam V_BACK       = 33;   // Back porch
    localparam V_TOTAL      = 525;  // Total

    // calculated values
    localparam H_SYNC_START = H_DISPLAY + H_FRONT;           // 656
    localparam H_SYNC_END   = H_DISPLAY + H_FRONT + H_SYNC;  // 752
    localparam V_SYNC_START = V_DISPLAY + V_FRONT;           // 490
    localparam V_SYNC_END   = V_DISPLAY + V_FRONT + V_SYNC;  // 492

    output logic [10:0] hcount,  // 11 bits for 0-799
    output logic [9:0] vcount    // 10 bits for 0-524
    
    always_ff @(posedge clk, negedge reset) begin
        if (!reset) begin
            hcount <= 0;
            vcount <= 0;
            // TODO on a reset we need to pulse hsync and vsync to 0 so we start at a known place

        end else begin
            if (hcount == H_TOTAL - 1) begin
                hcount <= 0;
                if (vcount == V_TOTAL - 1) begin // this should be one more than the limit, bc we are already adding 1 to it (so i removed the "- 1")
                    vcount <= 0;
                end else begin
                    vcount <= vcount + 1;
                end
            end else begin
                hcount <= hcount + 1;
            end

            // if (vcount == V_TOTAL) begin // this should be one more than the limit, bc we are already adding 1 to it (so i removed the "- 1")
            //     vcount <= 0;
            // end
        end
    end

    assign hsync = ~(hcount >= H_SYNC_START && hcount < H_SYNC_END); // active low
    assign vsync = ~(vcount >= V_SYNC_START && vcount < V_SYNC_END); // active low

    // the inverse of this will tell me if i am in a blank region (anywhere where i am not in the display zone)
    assign active_video = ((hcount >= 0 && hcount < H_DISPLAY) && (vcount >= 0 && vcount < V_DISPLAY));

endmodule