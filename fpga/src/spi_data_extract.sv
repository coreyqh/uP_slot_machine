// E155, Process SPI commands being sent by the MCU in order to determine spin logic and credit display logic

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 12/04/2025

module spi_data_extract (input  logic sclk, 
						 input logic clk,
                         input  logic reset_n, 
                         input  logic copi, // sdi 
                         input  logic cs,  // active low
                         output logic sdo,
                         output logic [3:0] reel1_idx,
                         output logic [3:0] reel2_idx, 
                         output logic [3:0] reel3_idx, 
                         output logic start_spin, 
                         output logic [11:0] win_credits, 
                         output logic is_win, 
                         output logic [11:0] total_credits, 
                         output logic is_total,
						 output logic ready
						 ); 

	// internal signals
    logic [15:0] data;
    logic [3:0] counter;
    logic ready;

	// request codes from SPI
    localparam REQ_SPIN   = 4'b0001;
    localparam REQ_WIN    = 4'b0010;
    localparam REQ_UPDATE = 4'b0011;

    always_ff @(posedge sclk, negedge reset_n) begin
        if (!reset_n) begin
            data <= 16'b0;
            ready <= 0;
            counter <= 4'b0;
        end else if (cs) begin  // cs high = inactive, reset
            data <= 16'b0;
            ready <= 0;
            counter <= 4'b0;
        end else begin // cs is low (active)
			// load in data
			data <= {data[14:0], copi};

			// if we loaded enough data (16 bits) pulse ready
			if (counter == 4'd15) begin
				ready <= 1;
				counter <= 4'b0;
			end else begin
				counter <= counter + 4'd1;
				ready <= 0;
			end
        end
    end

	// based on SPI signal sent, perform appropriate action
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            reel1_idx <= 0;
            reel2_idx <= 0;
            reel3_idx <= 0;
            start_spin <= 0;
            win_credits <= 0;
            total_credits <= 0;
            is_win <= 0;
            is_total <= 0;
        end else begin
			// clear values
            start_spin <= 0;
            is_win <= 0;
            is_total <= 0;

			// check the loaded data for appropriate codes
            if (ready) begin
                case (data[15:12])
					// request to spin
                    REQ_SPIN: begin
                        reel1_idx <= data[11:8];
                        reel2_idx <= data[7:4];
                        reel3_idx <= data[3:0];
                        start_spin <= 1; // will start spinning

                        is_win <= 0;
                        is_total <= 0;
                    end

					// ending positions was a win --> win request sent
                    REQ_WIN: begin
                        win_credits <= data[11:0];
                        is_win <= 1;      // Set flag

                        start_spin <= 0;
                        is_total <= 0;
                    end
                    
					// credits were added with coins, or won --> update request sent
                    REQ_UPDATE: begin
                        total_credits <= data[11:0];
                        is_total <= 1;    // Set flag

                        start_spin <= 0;
                        is_win <= 0;
                    end

                    default: begin // clear signal just in case
						start_spin <= 0;
					end
                endcase
            end
        end
    end
endmodule
