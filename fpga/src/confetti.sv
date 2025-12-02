// Add to your VGA module
logic [15:0] lfsr;  // Random number generator
logic show_confetti;
logic [2:0] confetti_color;

// LFSR for randomness
always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
        lfsr <= 16'hACE1;  // Seed
    end else begin
        lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end
end

// Confetti enable signal - turn on when win detected
always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
        show_confetti <= 0;
    end else if (done && is_win) begin
        show_confetti <= 1;
    end else if (start_spin) begin
        show_confetti <= 0;
    end
end

// Confetti logic - sparse random colored pixels
logic is_confetti_pixel;
assign is_confetti_pixel = show_confetti && (lfsr[4:0] == 5'b00000);  // ~3% of pixels

// Rainbow color cycling based on position + time
logic [7:0] confetti_counter;
always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
        confetti_counter <= 0;
    end else if (show_confetti) begin
        confetti_counter <= confetti_counter + 1;  // Animate over time
    end
end

always_comb begin
    // Create rainbow effect based on position + time
    case ((hcount[4:2] + vcount[4:2] + confetti_counter[7:5]) % 6)
        3'd0: confetti_color = 3'b100;  // Red
        3'd1: confetti_color = 3'b110;  // Yellow
        3'd2: confetti_color = 3'b010;  // Green
        3'd3: confetti_color = 3'b011;  // Cyan
        3'd4: confetti_color = 3'b001;  // Blue
        3'd5: confetti_color = 3'b101;  // Magenta
        default: confetti_color = 3'b111;
    endcase
end

// Modified output with confetti overlay
always_comb begin 
    if (active_video_d4) begin 
        if (is_confetti_pixel) begin  // Confetti on top
            pixel_rgb = confetti_color;
        end else if (is_yellow_border_r4) begin
            pixel_rgb = 3'b110;
        end else if (inside_reel_r4) begin  
            pixel_rgb = sprite_pixel_color;
        end else begin
            pixel_rgb = 3'b000;
        end
    end else begin
        pixel_rgb = 3'b000;
    end
end
