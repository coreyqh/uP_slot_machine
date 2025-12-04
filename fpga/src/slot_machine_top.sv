// E155, Top level module to start the spinning reels after SPI

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 12/04/2025

module slot_machine_top (input  logic reset_n,
                         input  logic sclk, 
                         input  logic copi, 
                         input  logic cs, 
                         output logic sdo, 

                         output logic hsync, 
                         output logic vsync,
                         output logic [2:0] vga_rgb,
                         
						 output logic done,
                        
                         output logic [4:0] select,
                         output logic [6:0] seven_segment_output 
						 );

	// vga counters
    logic [10:0] hcount; 
    logic [9:0] vcount;

	// internal signals for game logic
    logic [2:0]  reel1_idx, reel2_idx, reel3_idx;
    logic        start_spin;
    logic [11:0] win_credits;
    logic        is_win;
    logic [11:0] total_credits;
    logic        is_total;
    logic        active_video;
	
	// pll clock signals
	logic pll_clk_internal, pll_lock;


    // spi module (fpga is the peripheral)
    spi_data_extract spi_data_extract (
        .sclk          (sclk),
		.clk		   (pll_clk_internal),
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
        .is_total      (is_total),
		.ready		    (ready)
    );
	
	// pll clock to get 25.5 MHz for VGA
     pll_clock #(
		.CLKHF_DIV("0b00"),
        .DIVR("0"),
		.DIVF("16"),
		.DIVQ("5")
    ) PLL_CLK (
        .rst_n       (reset_n),
        .clk_internal(pll_clk_internal),
        .clk_external(debug_pll_clk),
        .clk_HSOSC   (debug_HSOSC_clk),
        .locked      (pll_lock)
    );

	// produces hsync + vsync for VGA
	// outputs {v|h}count for memory addressing logic
    vga_controller vga_controller (
        .clk           (pll_clk_internal),
        .reset_n       (reset_n & pll_lock),
        .hsync         (hsync),
        .vsync         (vsync),
        .hcount        (hcount),
        .vcount        (vcount),
        .active_video  (active_video)
    );

	// main reel control module to handle moving reels and reel stopping
    memory_controller u_memory_controller ( 
        .clk              (pll_clk_internal),
        .reset_n          (reset_n & pll_lock),
        .hcount           (hcount),
        .vcount           (vcount),
        .vsync            (vsync),
        .active_video     (active_video),
        .final1_sprite    (reel1_idx[2:0]),
        .final2_sprite    (reel2_idx[2:0]),
        .final3_sprite    (reel3_idx[2:0]),
        .start_spin       (start_spin),
        .pixel_rgb        (vga_rgb),
        .done             (done),
		.state_led		  (state_led)
    );

    // seven segment display
	credit_controller credit_controller (
		.clk(pll_clk_internal),
		.reset_n(reset_n),
		.won_amt1(win_credits[7:4]),
		.won_amt2(win_credits[3:0]),
		.credit_amt1(total_credits[11:8]),
		.credit_amt2(total_credits[7:4]),
		.credit_amt3(total_credits[3:0]),
		.enable_sel(select),
		.seg(seven_segment_output)
	);

endmodule
