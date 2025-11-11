// TODO: need to define bus widths for these signals, and do we need a reset, and ack
module spi_data_extract (input  logic sclk, 
                         input logic reset, 
                         input logic sdi, 
                         input logic cs, 
                         input logic start, 
                         output logic sdo,
                         output logic [3:0] reel1_idx,
                         output logic [3:0] reel2_idx, 
                         output logic [3:0] reel3_idx, 
                         output logic start_spin, 
                         output logic win_credits, 
                         output logic is_win, 
                         output logic total_credits, 
                         output logic is_total);

    logic [15:0] data;
    logic [3:0] counter;
    logic ready;

    localparam REQ_SPIN   = 4'b0001;
    localparam REQ_WIN    = 4'b0010;
    localparam REQ_UPDATE = 4'b0011;

    always_ff @(posedge sclk, negedge reset) begin
        if (!reset | (!start)) begin
            data <= 16'b0;
            ready <= 0;
            counter <= 4'b0;
        end else begin
            if (start & (!ready)) begin
                data <= {data[14:0], sdi};

                if (counter == 4'd15) begin
                    ready <= 1;
                end

                counter <= counter + 1;
            end
        end
    end

    always_ff @(posedge sclk, negedge reset) begin
        if (!reset) begin
            reel1_idx <= 0;
            reel2_idx <= 0;
            reel3_idx <= 0;
            start_spin <= 0;
            win_credits <= 0;
            total_credits <= 0;
            is_win <= 0;
            is_total <= 0;
        end else if (ready) begin
            case (data[15:12])
                REQ_SPIN: begin
                    reel1_idx <= data[11:8];
                    reel2_idx <= data[7:4];
                    reel3_idx <= data[3:0];
                    spin_start <= 1;      // Set flag

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
            endcase
        end
    end
endmodule