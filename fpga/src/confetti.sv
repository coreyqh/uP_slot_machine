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


// next attempt
// Add these to your VGA module signals
logic [9:0] confetti_x [0:31];  // X positions
logic [8:0] confetti_y [0:31];  // Y positions (0-479)
logic [2:0] confetti_c [0:31];  // Colors
logic [15:0] lfsr;              // Random number generator
logic show_confetti;
logic [23:0] fall_counter;      // Counter for fall speed

// LFSR for randomness
always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
        lfsr <= 16'hACE1;  // Seed
    end else begin
        lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end
end

// Control when to show confetti
always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
        show_confetti <= 0;
    end else if (done && is_win) begin
        show_confetti <= 1;
    end else if (start_spin) begin
        show_confetti <= 0;
    end
end

// Combined fall counter and position update logic
integer i;
always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
        fall_counter <= 0;
        // Initialize confetti at random positions at top of screen
        for (i = 0; i < 32; i = i + 1) begin
            confetti_x[i] <= (16'hACE1 ^ (i * 101)) % 640;  // Random X across screen
            confetti_y[i] <= ((16'hACE1 >> 3) ^ (i * 73)) % 100;  // Stagger starting heights
            confetti_c[i] <= (i % 6);  // Rainbow colors
        end
    end else if (!show_confetti) begin
        fall_counter <= 0;
        // Re-initialize when confetti turns off
        for (i = 0; i < 32; i = i + 1) begin
            confetti_x[i] <= (lfsr ^ (i * 101)) % 640;
            confetti_y[i] <= ((lfsr >> 3) ^ (i * 73)) % 100;
            confetti_c[i] <= (i % 6);
        end
    end else if (fall_counter == 24'd416666) begin  // ~60Hz update
        fall_counter <= 0;
        
        for (i = 0; i < 32; i = i + 1) begin
            // Move confetti down by 3-5 pixels (varied speeds)
            if (confetti_y[i] < 9'd476) begin
                confetti_y[i] <= confetti_y[i] + 9'd3 + ((lfsr[i%16]) ? 9'd2 : 9'd0);
            end else begin
                // Reset to top with new random X position
                confetti_y[i] <= 9'd0;
                confetti_x[i] <= (lfsr ^ (i * 131)) % 640;
                confetti_c[i] <= ((confetti_c[i] + 1) % 6);  // Cycle color
            end
        end
    end else begin
        fall_counter <= fall_counter + 1;
    end
end

// Check if current pixel is a confetti particle
logic is_confetti_pixel;
logic [2:0] confetti_pixel_color;

always_comb begin
    is_confetti_pixel = 0;
    confetti_pixel_color = 3'b000;
    
    if (show_confetti) begin
        for (i = 0; i < 32; i = i + 1) begin
            // Draw 3x3 pixel confetti pieces
            if (hcount >= confetti_x[i] && hcount < confetti_x[i] + 10'd3 &&
                vcount >= confetti_y[i] && vcount < confetti_y[i] + 9'd3) begin
                is_confetti_pixel = 1;
                
                // Map color index to actual RGB
                case (confetti_c[i])
                    3'd0: confetti_pixel_color = 3'b100;  // Red
                    3'd1: confetti_pixel_color = 3'b110;  // Yellow
                    3'd2: confetti_pixel_color = 3'b010;  // Green
                    3'd3: confetti_pixel_color = 3'b011;  // Cyan
                    3'd4: confetti_pixel_color = 3'b001;  // Blue
                    3'd5: confetti_pixel_color = 3'b101;  // Magenta
                    default: confetti_pixel_color = 3'b111;
                endcase
            end
        end
    end
end

// Pipeline the confetti signals to match your other delays (stage 4)
logic is_confetti_pixel_r, is_confetti_pixel_r2, is_confetti_pixel_r3, is_confetti_pixel_r4;
logic [2:0] confetti_pixel_color_r, confetti_pixel_color_r2, confetti_pixel_color_r3, confetti_pixel_color_r4;

always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
        is_confetti_pixel_r <= 0;
        confetti_pixel_color_r <= 0;
        is_confetti_pixel_r2 <= 0;
        confetti_pixel_color_r2 <= 0;
        is_confetti_pixel_r3 <= 0;
        confetti_pixel_color_r3 <= 0;
        is_confetti_pixel_r4 <= 0;
        confetti_pixel_color_r4 <= 0;
    end else begin
        is_confetti_pixel_r <= is_confetti_pixel;
        confetti_pixel_color_r <= confetti_pixel_color;
        
        is_confetti_pixel_r2 <= is_confetti_pixel_r;
        confetti_pixel_color_r2 <= confetti_pixel_color_r;
        
        is_confetti_pixel_r3 <= is_confetti_pixel_r2;
        confetti_pixel_color_r3 <= confetti_pixel_color_r2;
        
        is_confetti_pixel_r4 <= is_confetti_pixel_r3;
        confetti_pixel_color_r4 <= confetti_pixel_color_r3;
    end
end

// Modified output with confetti overlay
always_comb begin 
    if (active_video_d4) begin 
        if (is_confetti_pixel_r4) begin  // Confetti on top!
            pixel_rgb = confetti_pixel_color_r4;
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


// flashing border:
logic [23:0] flash_counter;
logic flash_on;

logic win_state;  // Stays high until next spin

always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
        win_state <= 0;
        flash_counter <= 0;
    end else begin
        if (start_spin) begin
            win_state <= 0;  // Clear on new spin
            flash_counter <= 0;
        end else if (done) begin  // Capture win on the done pulse
            win_state <= 1;  // Latch the win
        end
        
        // Counter runs whenever we're in win state
        if (win_state) begin
            flash_counter <= flash_counter + 1;
        end
    end
end

// Flash at ~6Hz (toggle every ~4M cycles at 25MHz)
assign flash_on = flash_counter[21];

// Change border from yellow to rainbow when winning
logic [2:0] win_border_color;
always_comb begin
    case (flash_counter[23:22])  // Cycle through colors
        2'd0: win_border_color = 3'b100;  // Red
        2'd1: win_border_color = 3'b110;  // Yellow
        2'd2: win_border_color = 3'b010;  // Green
        2'd3: win_border_color = 3'b011;  // Cyan
    endcase
end

// In your output logic:
always_comb begin 
    if (active_video_d4) begin 
        if (is_yellow_border_r4 && win_state && flash_on) begin
            pixel_rgb = win_border_color;  // Rainbow flashing border
        end else if (is_yellow_border_r4) begin
            pixel_rgb = 3'b110;  // Normal yellow
        end else if (inside_reel_r4) begin  
            pixel_rgb = sprite_pixel_color;
        end else begin
            pixel_rgb = 3'b000;
        end
    end else begin
        pixel_rgb = 3'b000;
    end
end