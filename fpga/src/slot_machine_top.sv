module slot_machine_top (input logic clk, 
                         input logic reset,

                         input logic sclk, 
                         input logic sdi, 
                         input logic cs, 
                         input logic start
                         output logic sdo, 

                         output logic hsync, 
                         output logic vsync,
                         output logic [2:0] vga_rgb,
                        
                         output logic [6:0] seven_segment_output);

    logic [10:0] hcount, 
    logic [9:0] vcount;

    logic [3:0] reel1_idx, reel2_idx, reel3_idx;
    logic       start_spin;
    logic       win_credits;
    logic       is_win;
    logic       total_credits;
    logic       is_total;

    spi_data_extract spi_data_extract (
        .sclk          (sclk),
        .reset         (reset),
        .sdi           (sdi),
        .cs            (cs),
        .start         (start),
        .sdo           (sdo),
        .reel1_idx     (reel1_idx),
        .reel2_idx     (reel2_idx),
        .reel3_idx     (reel3_idx),
        .start_spin    (start_spin),
        .win_credits   (win_credits),
        .is_win        (is_win),
        .total_credits (total_credits),
        .is_total      (is_total)
    );
    
    vga_controller vga_controller (
        .clk           (clk),
        .reset         (reset),
        .hsync         (hsync),
        .vsync         (vsync),
        .hcount        (hcount),
        .vcount        (vcount),
        .active_video  (active_video)
    );

    memory_controller u_memory_controller (
        .clk              (clk),
        .reset            (reset),
        .hcount           (hcount),
        .vcount           (vcount),
        .vsync            (vsync),
        .reel1_final_sprite (reel1_idx[2:0]),  // assuming 3-bit sprite IDs
        .reel2_final_sprite (reel2_idx[2:0]),
        .reel3_final_sprite (reel3_idx[2:0]),
        .start_spin       (start_spin),
        .pixel_rgb        (vga_rgb)
    );

    // seven segment display

endmodule