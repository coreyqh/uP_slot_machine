// TODO: need to define bus widths for these signals, and do we need a reset, and ack
// have a single wire/pin ack like done after spin is done and after any requet has been serviced
module spi_data_extract (input  logic sclk, 
                         input  logic reset_n, 
                         input  logic copi, // sdi 
                         input  logic cs,  // active low
                         output logic sdo,
                         output logic [3:0] reel1_idx, // make sure in register
                         output logic [3:0] reel2_idx, 
                         output logic [3:0] reel3_idx, 
                         output logic start_spin, 
                         output logic [11:0] win_credits, 
                         output logic is_win, 
                         output logic [11:0] total_credits, 
                         output logic is_total
						 // output logic ready
						 ); 

    logic [15:0] data;
    logic [3:0] counter;
    logic ready;

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
        end else begin
            // cs is low (active)
            if (!ready) begin  // only shift if not ready yet
                data <= {data[14:0], copi};

                if (counter == 4'd15) begin
                    ready <= 1;
                    counter <= 4'b0;
                end else begin
                    counter <= counter + 4'd1;
                    ready <= 0;
                end
            end
            // If ready is already high, don't shift anymore until cs goes high
        end
    end

    always_ff @(posedge sclk, negedge reset_n) begin
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
            start_spin <= 0;
            is_win <= 0;
            is_total <= 0;

            if (ready) begin
                case (data[15:12]) // make sure value is retained
                    REQ_SPIN: begin
                        reel1_idx <= data[11:8];
                        reel2_idx <= data[7:4];
                        reel3_idx <= data[3:0];
                        start_spin <= 1;      // Set flag

                        is_win <= 0;
                        is_total <= 0;
                    end

                    REQ_WIN: begin
                        win_credits <= data[11:0];
                        is_win <= 1;      // Set flag

                        start_spin <= 0;
                        is_total <= 0;
                    end
                    
                    REQ_UPDATE: begin
                        total_credits <= data[11:0];
                        is_total <= 1;    // Set flag

                        start_spin <= 0;
                        is_win <= 0;
                    end

                    default: // do nothing
                endcase
            end
        end
    end
endmodule
