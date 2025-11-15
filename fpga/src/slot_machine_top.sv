module slot_machine_top (input  logic clk, 
                         input  logic reset_n,

                         input  logic sclk, 
                         input  logic copi, 
                         input  logic cs, 
                         output logic sdo, 

                         output logic hsync, 
                         output logic vsync,
                         output logic [2:0] vga_rgb,
                         output logic done,
                        
                         output logic [4:0] select,
                         output logic [6:0] seven_segment_output);

    logic [10:0] hcount;
    logic [9:0] vcount;

    logic [3:0]  reel1_idx, reel2_idx, reel3_idx;
    logic        start_spin;
    logic [11:0] win_credits;
    logic        is_win;
    logic [11:0] total_credits;
    logic        is_total;
    logic        active_video;

    spi_data_extract spi_data_extract (
        .sclk          (sclk),
        .reset_n       (reset_n),
        .copi          (copi),
        .cs            (cs),
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
        .reset_n       (reset_n),
        .hsync         (hsync),
        .vsync         (vsync),
        .hcount        (hcount),
        .vcount        (vcount),
        .active_video  (active_video)
    );

    memory_controller u_memory_controller (
        .clk              (clk),
        .reset_n          (reset_n),
        .hcount           (hcount),
        .vcount           (vcount),
        .vsync            (vsync),
        .active_video     (active_video);
        .final1_sprite    (reel1_idx[2:0]),  // assuming 3-bit sprite IDs
        .final2_sprite    (reel2_idx[2:0]),
        .final3_sprite    (reel3_idx[2:0]),
        .start_spin       (start_spin),
        .pixel_rgb        (vga_rgb),
        .done             (done) // so far only done for hwen finished spinning since havent done update points stuff
    );

    // seven segment display
    // ROM block --> muxing

endmodule
