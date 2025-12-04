// E155, Based on the frequency implement a counter to decide which display will be enabled (~250Hz)

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 12/04/2025

module select_toggle(
    input  logic clk,
    input  logic reset_n,
    output logic [2:0] freq_counter
);


    // 250Hz, derived from ~25.5Mhz clock
    localparam int CYCLES_PER_DISPLAY = 100000;

	// counter large enough to count up to our cycle amount
    logic [$clog2(CYCLES_PER_DISPLAY):0] counter;

    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            counter      <= 0;
            freq_counter <= 0;
		// if counter hits limit, reset it and update internal counter
        end else if (counter == CYCLES_PER_DISPLAY - 1) begin
            counter <= 0;
			// internal counter increments at each frequency update to control which seven-seg to enable
			// 5 seven-segs so counter goes [0-4]
            if (freq_counter == 3'd4)
                freq_counter <= 0;
            else
                freq_counter <= freq_counter + 1;
        end else begin
            counter <= counter + 1;
        end
    end

endmodule
