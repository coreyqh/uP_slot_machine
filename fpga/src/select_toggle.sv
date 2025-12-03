module select_toggle(
    input  logic clk,
    input  logic reset_n,
    output logic [2:0] freq_counter
);


    // ~2 kHz per digit, 10 kHz total
    localparam int CYCLES_PER_DISPLAY = 100000;

    logic [$clog2(CYCLES_PER_DISPLAY):0] counter;

    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            counter      <= 0;
            freq_counter <= 0;

        end else if (counter == CYCLES_PER_DISPLAY - 1) begin
            counter <= 0;

            if (freq_counter == 3'd4)
                freq_counter <= 0;
            else
                freq_counter <= freq_counter + 1;

        end else begin
            counter <= counter + 1;
        end
    end

endmodule
