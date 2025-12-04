module memory_controller (
    input logic clk,
    input logic reset_n,
    input logic [10:0] hcount, 
    input logic [9:0] vcount,
    input logic vsync,
    input logic active_video,
    input logic [2:0] final1_sprite, 
    input logic [2:0] final2_sprite, 
    input logic [2:0] final3_sprite,
    input logic start_spin,
    output logic [2:0] pixel_rgb,
    output logic done,
    output logic [2:0] state_led
);

    localparam NUM_SPRITES = 7;
    localparam SPRITE_HEIGHT = 64;
    localparam SPRITE_WIDTH = 64;
    localparam PIXEL_SCALE = 1;
    localparam TOTAL_HEIGHT = NUM_SPRITES * SPRITE_HEIGHT * 2 * PIXEL_SCALE;
    localparam TOTAL_SPIN_HEIGHT = NUM_SPRITES * SPRITE_HEIGHT * PIXEL_SCALE;

    localparam REEL1_START_H = 190;
    localparam REEL2_START_H = 398;
    localparam REEL3_START_H = 606;
    localparam REELS_START_V = 60;
    localparam REEL_DISPLAY_HEIGHT = 430;
    localparam REELS_END_V = REELS_START_V + REEL_DISPLAY_HEIGHT - 1;
    localparam PIXELS_PER_FRAME = 24;

    localparam MIDDLE_ROW_TOP = REEL_DISPLAY_HEIGHT / 2 /* Y position of middle row */;
    localparam MIDDLE_ROW_BOTTOM = MIDDLE_ROW_TOP + SPRITE_HEIGHT * 2; // *2 if scaled
    localparam BORDER_WIDTH = 4; // Border thickness in pixels
    
    // Reel sequences (LUTs)
    logic [2:0] reel1_sequence [0:6];
    logic [2:0] reel2_sequence [0:6];
    logic [2:0] reel3_sequence [0:6];
    
    initial begin
		// Reel 1: sequential (no restriction)
		reel1_sequence[0] = 3'd0; 
		reel1_sequence[1] = 3'd1;
		reel1_sequence[2] = 3'd2; 
		reel1_sequence[3] = 3'd3;
		reel1_sequence[4] = 3'd4; 
		reel1_sequence[5] = 3'd5;
		reel1_sequence[6] = 3'd6;  
		
		// Reel 2: shuffled, no consecutive-value adjacency
		reel2_sequence[0] = 3'd3; 
		reel2_sequence[1] = 3'd0;
		reel2_sequence[2] = 3'd6; 
		reel2_sequence[3] = 3'd2;
		reel2_sequence[4] = 3'd4; 
		reel2_sequence[5] = 3'd1;
		reel2_sequence[6] = 3'd5; 
		
		// Reel 3: shuffled, no consecutive-value adjacency
		reel3_sequence[0] = 3'd2; 
		reel3_sequence[1] = 3'd5;
		reel3_sequence[2] = 3'd0; 
		reel3_sequence[3] = 3'd3;
		reel3_sequence[4] = 3'd6; 
		reel3_sequence[5] = 3'd1;
		reel3_sequence[6] = 3'd4; 
	end

    logic [9:0] reel1_offset, reel2_offset, reel3_offset;
    logic [9:0] next_reel1_offset, next_reel2_offset, next_reel3_offset;
    logic [9:0] reel1_ending_offset, reel2_ending_offset, reel3_ending_offset;
    localparam SPRITE_SIZE = SPRITE_HEIGHT;

    typedef enum logic [2:0] {IDLE, START_SPINNING, REEL1_STOP, REEL2_STOP, REEL3_STOP, DEAD} statetype;
    statetype state, next_state;

    logic [2:0] reel1_spin_amt, reel2_spin_amt, reel3_spin_amt;
    logic [2:0] next_reel1_spin_amt, next_reel2_spin_amt, next_reel3_spin_amt;
    logic [2:0] reel1_final_sprite, reel2_final_sprite, reel3_final_sprite;
    logic [2:0] next_state_led;
    
    logic frame_done;

    ///////////////////////
    // Target sprite calculation
    logic [9:0] centering_offset;
    assign centering_offset = (REEL_DISPLAY_HEIGHT / 2) - (SPRITE_HEIGHT); // not dividng by 2 for sprite height bc we're already scaling to 128

    logic [2:0] reel1_target_pos, reel2_target_pos, reel3_target_pos;
    
    always_comb begin
		// Reel 1 - sequential
		reel1_target_pos = reel1_final_sprite;

		// Reel 2
		case (reel2_final_sprite)
			3'd3: reel2_target_pos = 3'd0;
			3'd0: reel2_target_pos = 3'd1;
			3'd6: reel2_target_pos = 3'd2;
			3'd2: reel2_target_pos = 3'd3;
			3'd4: reel2_target_pos = 3'd4;
			3'd1: reel2_target_pos = 3'd5;
			3'd5: reel2_target_pos = 3'd6;
			default: reel2_target_pos = 3'd0;
		endcase

		// Reel 3
		case (reel3_final_sprite)
			3'd2: reel3_target_pos = 3'd0;
			3'd5: reel3_target_pos = 3'd1;
			3'd0: reel3_target_pos = 3'd2;
			3'd3: reel3_target_pos = 3'd3;
			3'd6: reel3_target_pos = 3'd4;
			3'd1: reel3_target_pos = 3'd5;
			3'd4: reel3_target_pos = 3'd6;
			default: reel3_target_pos = 3'd0;
		endcase
	end

    
    //assign reel1_ending_offset = (reel1_target_pos * SPRITE_HEIGHT + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
    //assign reel2_ending_offset = (reel2_target_pos * SPRITE_HEIGHT + TOTAL_HEIGHT + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
    //assign reel3_ending_offset = (reel3_target_pos * SPRITE_HEIGHT + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
    ///////////////////////////////

    logic vsync_prev;
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            frame_done <= 0;
            vsync_prev <= 1;
        end else begin
            if (!vsync && vsync_prev) begin
                frame_done <= 1;
            end else begin
                frame_done <= 0;
            end
            vsync_prev <= vsync;
        end
    end
    
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            reel1_offset <= 0;
            reel2_offset <= 0;
            reel3_offset <= 0;
            reel1_spin_amt <= 3'd3;
            reel2_spin_amt <= 3'd1;
            reel3_spin_amt <= 3'd1;
            reel1_final_sprite <= 0;
            reel2_final_sprite <= 0;
            reel3_final_sprite <= 0;
            state_led <= 3'b0;
        end else begin
            if (state == IDLE && start_spin) begin
                reel1_final_sprite <= final1_sprite;
                reel2_final_sprite <= final2_sprite;
                reel3_final_sprite <= final3_sprite;
            end
            
            if (frame_done) begin
                state <= next_state;
                reel1_offset <= next_reel1_offset;
                reel2_offset <= next_reel2_offset;
                reel3_offset <= next_reel3_offset;
                reel1_spin_amt <= next_reel1_spin_amt;
                reel2_spin_amt <= next_reel2_spin_amt;
                reel3_spin_amt <= next_reel3_spin_amt;
                state_led <= next_state_led;
				
				reel1_final_sprite <= final1_sprite;
                reel2_final_sprite <= final2_sprite;
                reel3_final_sprite <= final3_sprite;
				
				if (reel1_spin_amt == 0) begin
					reel1_ending_offset <= (reel1_target_pos * (SPRITE_HEIGHT + SPRITE_HEIGHT) + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
				end
				if (reel2_spin_amt == 0) begin
					reel2_ending_offset <= (reel2_target_pos * (SPRITE_HEIGHT + SPRITE_HEIGHT) + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
				end
				if (reel3_spin_amt == 0) begin
					reel3_ending_offset <= (reel3_target_pos * (SPRITE_HEIGHT + SPRITE_HEIGHT) + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
				end
				
            end
        end
    end

    always_comb begin
        next_state = state;
        next_reel1_offset = reel1_offset;
        next_reel2_offset = reel2_offset;
        next_reel3_offset = reel3_offset;
        next_reel1_spin_amt = reel1_spin_amt;
        next_reel2_spin_amt = reel2_spin_amt;
        next_reel3_spin_amt = reel3_spin_amt;
        next_state_led = state_led;
        done = 0;

        case(state)
            IDLE: begin 
                if (start_spin) begin
                    next_state = START_SPINNING;
                    next_reel1_offset = reel1_offset;
                    next_reel2_offset = reel2_offset;
                    next_reel3_offset = reel3_offset;
                    next_reel1_spin_amt = 3'd3;
                    next_reel2_spin_amt = 3'd2;
                    next_reel3_spin_amt = 3'd2;
                    next_state_led = 3'b000;
                end
            end

            START_SPINNING: begin 
                next_reel1_offset = reel1_offset + PIXELS_PER_FRAME;
                next_reel2_offset = reel2_offset + PIXELS_PER_FRAME;
                next_reel3_offset = reel3_offset + PIXELS_PER_FRAME;

                if (next_reel1_offset >= TOTAL_HEIGHT) begin  
                    next_reel1_offset = next_reel1_offset - TOTAL_HEIGHT;
                    
                    if (reel1_spin_amt > 0) begin
                        next_reel1_spin_amt = reel1_spin_amt - 1; 
                    end else begin
                        next_state = REEL1_STOP;
                    end
                end

                if (next_reel2_offset >= TOTAL_HEIGHT)
                    next_reel2_offset = next_reel2_offset - TOTAL_HEIGHT;
                if (next_reel3_offset >= TOTAL_HEIGHT)
                    next_reel3_offset = next_reel3_offset - TOTAL_HEIGHT;
                
                next_state_led = 3'b100;
            end

            REEL1_STOP: begin
                next_reel2_offset = reel2_offset + PIXELS_PER_FRAME;
                next_reel3_offset = reel3_offset + PIXELS_PER_FRAME;

                if (reel1_offset != reel1_ending_offset) begin
                    next_reel1_offset = reel1_offset + 12;
                    if (next_reel1_offset >= TOTAL_HEIGHT) begin
                        next_reel1_offset = next_reel1_offset - TOTAL_HEIGHT;
                    end

                    if (reel1_offset < reel1_ending_offset) begin
                        if (next_reel1_offset >= reel1_ending_offset)
                            next_reel1_offset = reel1_ending_offset;
                    end else begin
                        if (next_reel1_offset < reel1_offset)
                            next_reel1_offset = reel1_ending_offset;
                    end
                end

                if (next_reel2_offset >= TOTAL_HEIGHT) begin
                    next_reel2_offset = next_reel2_offset - TOTAL_HEIGHT;
                    
                    if (reel2_spin_amt > 0) begin
                        next_reel2_spin_amt = reel2_spin_amt - 1;
                    end else begin
                        next_state = REEL2_STOP;
                    end
                end

                if (next_reel3_offset >= TOTAL_HEIGHT)
                    next_reel3_offset = next_reel3_offset - TOTAL_HEIGHT;
                
                next_state_led = 3'b101;
            end

            REEL2_STOP: begin
                next_reel3_offset = reel3_offset + PIXELS_PER_FRAME;

                if (reel2_offset != reel2_ending_offset) begin
                    next_reel2_offset = reel2_offset + 12;
                    if (next_reel2_offset >= TOTAL_HEIGHT) begin
                        next_reel2_offset = next_reel2_offset - TOTAL_HEIGHT;
                    end

                    if (reel2_offset < reel2_ending_offset) begin
                        if (next_reel2_offset >= reel2_ending_offset)
                            next_reel2_offset = reel2_ending_offset;
                    end else begin
                        if (next_reel2_offset < reel2_offset)
                            next_reel2_offset = reel2_ending_offset;
                    end
                end

                if (next_reel3_offset >= TOTAL_HEIGHT) begin
                    next_reel3_offset = next_reel3_offset - TOTAL_HEIGHT;
                    
                    if (reel3_spin_amt > 0) begin
                        next_reel3_spin_amt = reel3_spin_amt - 1;
                    end else begin
                        next_state = REEL3_STOP;
                    end
                end
                
                next_state_led = 3'b001;
            end

            REEL3_STOP: begin
                if (reel3_offset != reel3_ending_offset) begin
                    next_reel3_offset = reel3_offset + 12;
                    if (next_reel3_offset >= TOTAL_HEIGHT) begin
                        next_reel3_offset = next_reel3_offset - TOTAL_HEIGHT;
                    end

                    if (reel3_offset < reel3_ending_offset) begin
                        if (next_reel3_offset >= reel3_ending_offset)
                            next_reel3_offset = reel3_ending_offset;
                    end else begin
                        if (next_reel3_offset < reel3_offset)
                            next_reel3_offset = reel3_ending_offset;
                    end
                end else begin
                    next_state = IDLE;
                    done = 1;
                end
                
                next_state_led = 3'b110;
            end
            
            DEAD: begin
                next_state = DEAD;
                next_state_led = 3'b111;
            end
        endcase
    end

    // ============================================================
    // PIPELINE STAGE 0: Combinational address calculation
    // ============================================================
    logic inside_reel1_prev, inside_reel2_prev, inside_reel3_prev;
    logic [2:0] sprite_idx;
    logic [5:0] x_in_sprite, y_in_sprite;
    logic [9:0] y_in_reel;
    logic [2:0] seq_pos;
    logic inside_reel_comb;
    logic is_yellow_border;
    
    assign inside_reel1_prev = (hcount >= REEL1_START_H && hcount < REEL1_START_H + SPRITE_WIDTH + SPRITE_WIDTH) && 
                               (vcount >= REELS_START_V && vcount < REELS_END_V);
    assign inside_reel2_prev = (hcount >= REEL2_START_H && hcount < REEL2_START_H + SPRITE_WIDTH + SPRITE_WIDTH) && 
                               (vcount >= REELS_START_V && vcount < REELS_END_V);
    assign inside_reel3_prev = (hcount >= REEL3_START_H && hcount < REEL3_START_H + SPRITE_WIDTH + SPRITE_WIDTH) && 
                               (vcount >= REELS_START_V && vcount < REELS_END_V);

    assign inside_reel_comb = inside_reel1_prev | inside_reel2_prev | inside_reel3_prev;
	
	
    always_comb begin
        sprite_idx = 3'd0;
        x_in_sprite = 6'd0;
        y_in_sprite = 6'd0;
        
        if (inside_reel1_prev) begin
            y_in_reel = (vcount - REELS_START_V + reel1_offset) % TOTAL_HEIGHT;
            seq_pos = y_in_reel[9:7];
            sprite_idx = reel1_sequence[seq_pos];
            x_in_sprite = ((hcount - REEL1_START_H) >> 1);
            y_in_sprite = y_in_reel[6:1];
        end else if (inside_reel2_prev) begin
            y_in_reel = (vcount - REELS_START_V + reel2_offset) % TOTAL_HEIGHT;
            seq_pos = y_in_reel[9:7];
            sprite_idx = reel2_sequence[seq_pos];
            x_in_sprite = ((hcount - REEL2_START_H) >> 1);
            y_in_sprite = y_in_reel[6:1];
        end else if (inside_reel3_prev) begin
            y_in_reel = (vcount - REELS_START_V + reel3_offset) % TOTAL_HEIGHT;
            seq_pos = y_in_reel[9:7];
            sprite_idx = reel3_sequence[seq_pos];
            x_in_sprite = ((hcount - REEL3_START_H)) >> 1;
            y_in_sprite = y_in_reel[6:1];
        end
    end


    always_comb begin
        is_yellow_border = 0;
        
        // Top and bottom horizontal borders
        if ((vcount >= MIDDLE_ROW_TOP - BORDER_WIDTH && vcount < MIDDLE_ROW_TOP) ||
            (vcount > MIDDLE_ROW_BOTTOM && vcount <= MIDDLE_ROW_BOTTOM + BORDER_WIDTH)) begin
            if (inside_reel_comb) begin
                is_yellow_border = 1;
            end
        end
        
        // Left and right vertical borders
        if (vcount >= MIDDLE_ROW_TOP && vcount <= MIDDLE_ROW_BOTTOM) begin
            if ((hcount >= REEL1_START_H - BORDER_WIDTH && hcount < REEL1_START_H) ||
                (hcount > REEL3_START_H + SPRITE_WIDTH + SPRITE_WIDTH && 
                hcount <= REEL3_START_H + SPRITE_WIDTH + SPRITE_WIDTH + BORDER_WIDTH)) begin
                is_yellow_border = 1;
            end
        end
    end
	
	// --- Signals for ROM Interface ---
    logic [9:0]  word_addr;     
    logic [1:0]  pixel_in_word; 
    logic [15:0] rom_data;      

    // --- Stage N: Combinational Address Calculation ---
    assign word_addr     = (y_in_sprite << 4) | (x_in_sprite >> 2); 
    assign pixel_in_word = x_in_sprite[1:0];                        

    // --- Pipeline Stage 0 (Clock Edge N+1) ---
    // Registers inputs to the ROM (Address Path: 1 Cycle)
    logic [9:0] word_addr_r;
    logic [2:0] sprite_idx_r, sprite_idx_r2, sprite_idx_r3, sprite_idx_r4, sprite_idx_r5, sprite_idx_r6;
    logic [1:0] pixel_in_word_r;

    // Control signal pipeline (Delayed by 1 cycle)
    logic inside_reel_r;
    logic active_video_d1;

    logic is_yellow_border_r1, is_yellow_border_r2, is_yellow_border_r3, is_yellow_border_r4, is_yellow_border_r5;

    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
			word_addr_r     <= 0;
            sprite_idx_r    <= 0;
            pixel_in_word_r <= 0;
            inside_reel_r   <= 0;
            active_video_d1 <= 0;
            is_yellow_border_r1 <= 0;
		end else begin
            word_addr_r     <= word_addr;
            sprite_idx_r    <= sprite_idx;
            pixel_in_word_r <= pixel_in_word;
            inside_reel_r   <= inside_reel_comb;
            active_video_d1 <= active_video;
            is_yellow_border_r1 <= is_yellow_border;
        end
    end

    // ROM Instantiation (Synchronous Read, 1-cycle latency)
    rom_wrapper rom_inst (
        .clk(clk),
		.reset_n(reset_n),
        .sprite_sel_i(sprite_idx_r), 
        .word_addr_i(word_addr_r),   
        .data_o(rom_data)            // Data available at N+1
    );

    // register ROM output and delay control signals (Total Data Path: 2 Cycles)
    logic [15:0] rom_data_r, rom_data_r2, rom_data_r3;
    logic [1:0] pixel_in_word_r2, pixel_in_word_r3, pixel_in_word_r4, pixel_in_word_r5, pixel_in_word_r6; // Final pixel selector (2-cycle delay)
	logic active_video_d5, inside_reel_r5;
	logic active_video_d6, inside_reel_r6;


    // control signal pipeline
    logic inside_reel_r2, inside_reel_r3, inside_reel_r4;
    logic active_video_d2, active_video_d3, active_video_d4;

    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            rom_data_r <= 16'd0; pixel_in_word_r2 <= 2'd0;
            inside_reel_r2 <= 1'b0; active_video_d2 <= 1'b0;
			sprite_idx_r2 <= 0;
			
			rom_data_r2 <= 16'd0; 
            is_yellow_border_r2 <= 0;
			
			pixel_in_word_r3 <= 2'd0;
			inside_reel_r3 <= 1'b0; 
			active_video_d3 <= 1'b0;
			sprite_idx_r3 <= 0;
            is_yellow_border_r3 <= 0;
			
			pixel_in_word_r4 <= 0;
			sprite_idx_r4 <= 0;
			active_video_d4 <= 0;
			inside_reel_r4 <= 0;
            is_yellow_border_r4 <= 0;
			
			pixel_in_word_r5 <= 0;
			active_video_d5 <= 0;
			inside_reel_r5 <= 0;
			sprite_idx_r5	<= 0;
            is_yellow_border_r5 <= 0;
			
			pixel_in_word_r6 <= 0;
			sprite_idx_r6 <= 0;
			active_video_d6 <= 0;
			inside_reel_r6 <= 0;
			
			
			//rom_data_r <= 16'd0; pixel_in_word_r2 <= 2'd0;
            //inside_reel_r2 <= 1'b0; active_video_d2 <= 1'b0;
			
			//rom_data_r2 <= 16'd0; pixel_in_word_r3 <= 2'd0;
			//inside_reel_r3 <= 1'b0; active_video_d3 <= 1'b0;
			
			//sprite_idx_r3 <= 0;
			
			//pixel_in_word_r4 <= 0;
			//sprite_idx_r4 <= 0;
			
			//pixel_in_word_r5 <= 0;
			//active_video_d5 <= 0;
			//inside_reel_r5 <= 0;
			//sprite_idx_r5	<= 0;
			
			//pixel_in_word_r6 <= 0;
			//sprite_idx_r6 <= 0;
        end else begin
            rom_data_r       <= rom_data; // Capture 1-cycle latency data
            pixel_in_word_r2 <= pixel_in_word_r;
            inside_reel_r2   <= inside_reel_r;
            active_video_d2  <= active_video_d1;
			sprite_idx_r2	<= sprite_idx_r;
            is_yellow_border_r2 <= is_yellow_border_r1;
			
			pixel_in_word_r3 <= pixel_in_word_r2;
			rom_data_r2 <= rom_data_r;
			active_video_d3 <= active_video_d2;
			inside_reel_r3 <= inside_reel_r2;
			sprite_idx_r3	<= sprite_idx_r2;
            is_yellow_border_r3 <= is_yellow_border_r2;
			
			pixel_in_word_r4 <= pixel_in_word_r3;
			rom_data_r3 <= rom_data_r2;
			active_video_d4 <= active_video_d3;
			inside_reel_r4 <= inside_reel_r3;
			sprite_idx_r4	<= sprite_idx_r3;
            is_yellow_border_r4 <= is_yellow_border_r3;
			
			pixel_in_word_r5 <= pixel_in_word_r4;
			active_video_d5 <= active_video_d4;
			inside_reel_r5 <= inside_reel_r4;
			sprite_idx_r5	<= sprite_idx_r4;
            is_yellow_border_r5 <= is_yellow_border_r4;
			
			pixel_in_word_r6 <= pixel_in_word_r5;
			sprite_idx_r6 <= sprite_idx_r5;
			active_video_d6 <= active_video_d5;
			inside_reel_r6 <= inside_reel_r5;
			
        end
    end

    // final pixel extraction
    // final pixel extraction
	logic [2:0] sprite_pixel_color;

	always_comb begin
		case (sprite_idx_r4)
			3'd0, 3'd1, 3'd2, 3'd3: begin
				// EBR sprites: use rom_data_r2 (3 total pipeline stages match)
				case (pixel_in_word_r4) 
					2'd0: sprite_pixel_color = rom_data[15:13]; 
					2'd1: sprite_pixel_color = rom_data[11:9];
					2'd2: sprite_pixel_color = rom_data[7:5];
					2'd3: sprite_pixel_color = rom_data[3:1];
					default: sprite_pixel_color = 3'b000; 
				endcase
			end
			3'd4, 3'd5, 3'd6: begin
				// Combinational sprites: use rom_data_r3 (need extra delay)
				case (pixel_in_word_r4) 
					2'd0: sprite_pixel_color = rom_data[15:13]; 
					2'd1: sprite_pixel_color = rom_data[11:9];
					2'd2: sprite_pixel_color = rom_data[7:5];
					2'd3: sprite_pixel_color = rom_data[3:1];
					default: sprite_pixel_color = 3'b000; 
				endcase
			end
			default: sprite_pixel_color = 3'b110;
		endcase
	end

	// output
	always_comb begin 
		if (active_video_d4) begin 
            if (is_yellow_border_r4) begin
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

endmodule
