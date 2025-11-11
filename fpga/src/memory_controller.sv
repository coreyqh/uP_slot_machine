// TODO: figure out the scaling later from 32x32 to 64x64

module memory_controller ( // TODO: need to define bus lengths
    input logic clk, // TODO: this is the 25.175MHz clock
    input logic reset,
    input logic [10:0] hcount, 
    input logic [9:0] vcount,
    input logic vsync,
    input logic [2:0] reel1_final_sprite, 
    input logic [2:0] reel2_final_sprite, 
    input logic [2:0] reel3_final_sprite,
    input logic start_spin,
    output logic [2:0] pixel_rgb
);

    localparam NUM_SPRITES = 8;
    localparam SPRITE_HEIGHT = 64;
    localparam SPRITE_WIDTH = 64;

    localparam PIXEL_SCALE = 1;

    localparam TOTAL_HEIGHT = NUM_SPRITES * SPRITE_HEIGHT * PIXEL_SCALE;

    localparam REEL1_START_H = 160; // TODO : calculate if these are ok values?
    localparam REEL2_START_H = 288;
    localparam REEL3_START_H = 416;
    localparam REELS_START_V = 40;
    localparam REEL_DISPLAY_HEIGHT = 384;  // Show 384 pixels tall (6 full sprites!)
    localparam REELS_END_V = REELS_START_V + REEL_DISPLAY_HEIGHT - 1;  // 423

    localparam REEL1_START_SPRITE = 3'd0;  // Reel 1 starts at sprite 0
    localparam REEL2_START_SPRITE = 3'd2;  // Reel 2 starts at sprite 2
    localparam REEL3_START_SPRITE = 3'd5;  // Reel 3 starts at sprite 5

    localparam REEL1_STRIDE = 3'd1;  // Reel 1: 0→1→2→3→4→5→6→7→0...
    localparam REEL2_STRIDE = 3'd3;  // Reel 2: 2→5→0→3→6→1→4→7→2...
    localparam REEL3_STRIDE = 3'd6;  // Reel 3: 5→3→1→7→5→3→1→7...

    localparam PIXELS_PER_FRAME = 2;

    logic [9:0] reel1_offset, reel2_offset, reel3_offset;
    logic [9:0] next_reel1_offset, next_reel2_offset, next_reel3_offset;
    logic [9:0] reel1_ending_offset, reel2_ending_offset, reel3_ending_offset;
    localparam SPRITE_SIZE = SPRITE_HEIGHT;

    typedef enum [2:0] {IDLE, START_SPINNING, REEL1_STOP, REEL2_STOP, REEL3_STOP} statetype;
    statetype state, next_state;

    logic in_reel; // this will be a signal which is true if hcount/vcount is in a reel boundary, and otherwise it will fill with background color
    // but i assume for this signal, we don't want to keep counting for the reel index because we want to wit 
    // HUH question - do we need to do this wait gating thing, im a little confused how to time the signals on the vga, because if all the reels update on the same clk cycle, only one rgb is produced so woulndt we have to halt everything else until its the correct turn?

    logic [2:0] reel1_spin_amt, reel2_spin_amt, reel3_spin_amt;
    logic [6:0] reel1_pixel_ct, reel2_pixel_ct, reel3_pixel_ct;
    

    logic frame_done;

    // ported from AI idea
    // Find which sequence position shows the target sprite
    function automatic logic [2:0] find_position_of_sprite(
        input logic [2:0] start_sprite,
        input logic [2:0] stride,
        input logic [2:0] target_sprite
    );
        integer i;
        for (i = 0; i < NUM_SPRITES; i = i + 1) begin
            if ((start_sprite + (stride * i[2:0])) % NUM_SPRITES == target_sprite)
                return i[2:0];
        end
        return 3'd0;
    endfunction

    // Calculate target offsets
    // Target should position the winning sprite at the PAYLINE (middle of window)
    always_comb begin
        logic [9:0] sprite_position;
        logic [9:0] centering_offset;
        
        // How far from top of window to payline
        centering_offset = (REEL_DISPLAY_HEIGHT / 2) - (SPRITE_SIZE / 2);
        // Example: (384/2) - (64/2) = 192 - 32 = 160
        
        // Reel 1 --> this gives us the offset the target sprite starts at with its stride
        sprite_position = find_position_of_sprite(
            REEL1_START_SPRITE, REEL1_STRIDE, reel1_final_sprite) * SPRITE_SIZE;
        // here, we want to subtract the center offset (whats above and below hte center), so we can get the offset of what should be at the top, in order to get the srite in the middle
        reel1_ending_offset = (sprite_position + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT; // add total height to avoid negatives
        
        // Reel 2
        sprite_position = find_position_of_sprite(
            REEL2_START_SPRITE, REEL2_STRIDE, reel2_final_sprite) * SPRITE_SIZE;
        reel2_ending_offset = (sprite_position + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
        
        // Reel 3
        sprite_position = find_position_of_sprite(
            REEL3_START_SPRITE, REEL3_STRIDE, reel3_final_sprite) * SPRITE_SIZE;
        reel3_ending_offset = (sprite_position + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
    end
    ///////////////////////////////

    logic vsync_prev;
    always_ff @(posedge clk, negedge reset) begin
        if (!reset) begin
            frame_done <= 0;
        end else if (!vsync && vsync_prev) begin // active low
            frame_done <= 1;
        end else begin
            frame_done <= 0;
        end

        vsync_prev <= vsync;
    end

    always_ff @(posedge clk, negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            reel1_offset <= 0;
            reel2_offset <= 0;
            reel3_offset <= 0;
            reel1_spin_amt <= 3'd5; // if this spins 5 times, then we can assume the reels below also spin 5 times, we what we want is just the extra spins for the other two
            reel2_spin_amt <= 3'd2;
            reel3_spin_amt <= 3'd2;
        end else begin
            // state <= next_state; // because we have a new offset we need to wait for before displaying the next things
            if (frame_done) begin
                state <= next_state; // because we have a new offset we need to wait for before displaying the next things
                reel1_offset <= next_reel1_offset;
                reel2_offset <= next_reel2_offset;
                reel3_offset <= next_reel3_offset;

                reel1_spin_amt <= next_reel1_spin_amt;
                reel2_spin_amt <= next_reel2_spin_amt;
                reel3_spin_amt <= next_reel3_spin_amt;
            end

            // reel1_address <= next_reel1_address;
            // reel2_address <= next_reel2_address;
            // reel3_address <= next_reel3_address;
            
        end
        // else begin
        //     state <= next_state;
        //     if (reel1_pixel_count < TOTAL_HEIGHT && in_reel) begin
        //         reel1_pixel_count <= reel1_pixel_count + 1;
        //     end else if (reel1_pixel_count < TOTAL_HEIGHT) begin
        //         reel1_pixel_count <= reel1_pixel_count;
        //     end else begin
        //         reel1_pixel_count <= 0; // TODO: is this correct?
        //     end

        //     if (reel2_pixel_count < TOTAL_HEIGHT && in_reel) begin
        //         reel2_pixel_count <= reel2_pixel_count + 1;
        //     end else if (reel2_pixel_count < TOTAL_HEIGHT) begin
        //         reel2_pixel_count <= reel2_pixel_count;
        //     end else begin
        //         reel2_pixel_count <= 0; // TODO: is this correct?
        //     end

        //     if (reel3_pixel_count < TOTAL_HEIGHT && in_reel) begin
        //         reel3_pixel_count <= reel3_pixel_count + 1;
        //     end else if (reel3_pixel_count < TOTAL_HEIGHT) begin
        //         reel3_pixel_count <= reel3_pixel_count;
        //     end else begin
        //         reel3_pixel_count <= 0; // TODO: is this correct?
        //     end
        // end
    end

    always_comb begin

        next_state = state;
        next_reel1_offset = reel1_offset;
        next_reel2_offset = reel2_offset;
        next_reel3_offset = reel3_offset;
        next_reel1_spin_amt = reel1_spin_amt;
        next_reel2_spin_amt = reel2_spin_amt;
        next_reel3_spin_amt = reel3_spin_amt;

        case(state)
            IDLE: begin 
                // reel1_spin_amt = 3'd5; // if this spins 5 times, then we can assume the reels below also spin 5 times, we what we want is just the extra spins for the other two
                // reel2_spin_amt = 3'd2;
                // reel3_spin_amt = 3'd2;
                if (start_spin) begin
                    next_state = START_SPINNING;
                    next_reel1_offset = 10'd0;
                    next_reel2_offset = 10'd0;
                    next_reel3_offset = 10'd0;
                    next_reel1_spin_amt = 4'd5;  // All reels do 5 base rotations
                    next_reel2_spin_amt = 4'd2;  // Reel 2 does 2 extra rotations
                    next_reel3_spin_amt = 4'd2;  // Reel 3 does 2 extra rotations
                end
            end

            START_SPINNING: begin
                // All three reels spin (offset increases by 2 pixels per frame)
                // this is the offset in a frame, since everything is calcuated for a reel relative to here (the starting point, which shifts by 2 every frame to make it look continuous)
                next_reel1_offset = reel1_offset + PIXELS_PER_FRAME;
                next_reel2_offset = reel2_offset + PIXELS_PER_FRAME; // replace errors with RHS
                next_reel3_offset = reel3_offset + PIXELS_PER_FRAME;

                if (next_reel1_offset >= TOTAL_HEIGHT) begin
                    next_reel1_offset = next_reel1_offset - TOTAL_HEIGHT; // reel1_offset + PIXELS_PER_FRAME - TOTAL_HEIGHT;
                    
                    if (reel1_spin_amt > 0) begin
                        next_reel1_spin_amt = reel1_spin_amt - 1;
                    end else begin
                        next_state = REEL1_STOP;
                    end
                end

                if (next_reel2_offset >= TOTAL_HEIGHT)
                    next_reel2_offset = next_reel2_offset - TOTAL_HEIGHT; // reel2_offset + PIXELS_PER_FRAME - TOTAL_HEIGHT;
                if (next_reel3_offset >= TOTAL_HEIGHT)
                    next_reel3_offset = next_reel3_offset - TOTAL_HEIGHT;

            end

            REEL1_STOP: begin
                // other two reels spin normally, first is alinging to stop
                next_reel2_offset = reel2_offset + PIXELS_PER_FRAME;
                next_reel3_offset = reel3_offset + PIXELS_PER_FRAME;

                // also csn only check this once a frame is done, so this is good to happen on the frame clk
                // we need to get reel 1 to land on the ending sprite
                if (reel1_offset != reel1_ending_offset) begin // TODO: IMP - this offset is where we start displaying from, so this should NOT be equal to the final sprite's startign address - ight have to be two sprites above target or smthg
                    next_reel1_offset = reel1_offset + 1; // NOTE: here instead of adding PIXELS_PER_FRAME, we are going to slow doen and only add 1 to not overshoot
                    if (next_reel1_offset >= TOTAL_HEIGHT) begin
                        next_reel1_offset = next_reel1_offset - TOTAL_HEIGHT;
                    end

                    // TODO: can find diff logic for this too
                    if (reel1_offset < reel1_ending_offset) begin
                        // Normal case: target is ahead
                        if (next_reel1_offset >= reel1_ending_offset)
                            next_reel1_offset = reel1_ending_offset;
                    end else begin
                        // Wrap case: we'll wrap past 0 before reaching target
                        if (next_reel1_offset < reel1_offset)  // We wrapped
                            next_reel1_offset = reel1_ending_offset;
                    end
                end

                if (next_reel2_offset >= TOTAL_HEIGHT) begin
                    next_reel2_offset = next_reel2_offset - TOTAL_HEIGHT; // reel2_offset + PIXELS_PER_FRAME - TOTAL_HEIGHT;
                    
                    if (reel2_spin_amt > 0) begin
                        next_reel2_spin_amt = reel2_spin_amt - 1;
                    end else begin
                        next_state = REEL2_STOP;
                    end
                end

                if (next_reel3_offset >= TOTAL_HEIGHT)
                    next_reel3_offset = next_reel3_offset - TOTAL_HEIGHT;
            end

            REEL2_STOP: begin
                // third reel spins normally, first has stopped moving, second coming to stop
                next_reel3_offset = reel3_offset + PIXELS_PER_FRAME;

                // we need to get reel 1 to land on the ending sprite
                if (reel2_offset != reel2_ending_offset) begin // TODO: IMP - this offset is where we start displaying from, so this should NOT be equal to the final sprite's startign address - ight have to be two sprites above target or smthg
                    next_reel2_offset = reel2_offset + 1; // NOTE: here instead of adding PIXELS_PER_FRAME, we are going to slow doen and only add 1 to not overshoot
                    if (next_reel2_offset >= TOTAL_HEIGHT) begin
                        next_reel2_offset = next_reel2_offset - TOTAL_HEIGHT;
                    end

                    if (reel2_offset < reel2_ending_offset) begin
                        // Normal case: target is ahead
                        if (next_reel2_offset >= reel2_ending_offset)
                            next_reel2_offset = reel2_ending_offset;
                    end else begin
                        // Wrap case: we'll wrap past 0 before reaching target
                        if (next_reel2_offset < reel2_offset)  // We wrapped
                            next_reel2_offset = reel2_ending_offset;
                    end
                end

                if (next_reel3_offset >= TOTAL_HEIGHT) begin
                    next_reel3_offset = next_reel3_offset - TOTAL_HEIGHT; // reel2_offset + PIXELS_PER_FRAME - TOTAL_HEIGHT;
                    
                    if (reel3_spin_amt > 0) begin
                        next_reel3_spin_amt = reel3_spin_amt - 1;
                    end else begin
                        next_state = REEL3_STOP;
                    end
                end
            end

            REEL3_STOP: begin
                // reels 1 and 2 have stopped and locked, reel3 is alisning to stop

                // we need to get reel 1 to land on the ending sprite
                if (reel3_offset != reel3_ending_offset) begin // TODO: IMP - this offset is where we start displaying from, so this should NOT be equal to the final sprite's startign address - ight have to be two sprites above target or smthg
                    next_reel3_offset = reel3_offset + 1; // NOTE: here instead of adding PIXELS_PER_FRAME, we are going to slow doen and only add 1 to not overshoot
                    if (next_reel3_offset >= TOTAL_HEIGHT) begin
                        next_reel3_offset = next_reel3_offset - TOTAL_HEIGHT;
                    end

                    if (reel3_offset < reel3_ending_offset) begin
                        // Normal case: target is ahead
                        if (next_reel3_offset >= reel3_ending_offset)
                            next_reel3_offset = reel3_ending_offset;
                    end else begin
                        // Wrap case: we'll wrap past 0 before reaching target
                        if (next_reel3_offset < reel3_offset)  // We wrapped
                            next_reel3_offset = reel3_ending_offset;
                    end
                end else begin
                    next_state = IDLE;
                end
            end
        endcase
    end


    logic inside_reel1_prev, inside_reel2_prev, inside_reel3_prev;
    logic temp1, temp2, temp3;
    logic inside_reel1, inside_reel2, inside_reel3;
    logic [2:0] sprite_idx;
    logic [5:0] x_in_sprite, y_in_sprite;
    logic [9:0] y_in_reel;
    logic [2:0] seq_position;
    logic [$clog2(NUM_SPRITES*SPRITE_WIDTH*SPRITE_HEIGHT)-1:0] address; // each address here will hodl an rgb value
    
    assign inside_reel1_prev = (hcount >= REEL1_START_H && hcount < REEL1_START_H + SPRITE_WIDTH) && (vcount >= REELS_START_V && vcount < REELS_END_V);
    assign inside_reel2_prev = (hcount >= REEL2_START_H && hcount < REEL2_START_H + SPRITE_WIDTH) && (vcount >= REELS_START_V && vcount < REELS_END_V);
    assign inside_reel3_prev = (hcount >= REEL3_START_H && hcount < REEL3_START_H + SPRITE_WIDTH) && (vcount >= REELS_START_V && vcount < REELS_END_V);

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            inside_reel1 <= 0;
            inside_reel2 <= 0;
            inside_reel3 <= 0;
        end else begin
            inside_reel1 <= inside_reel1_prev;
            inside_reel2 <= inside_reel2_prev;
            inside_reel3 <= inside_reel3_prev;
        end
    end

    always_comb begin
        sprite_idx = 3'd0;
        x_in_sprite = 6'd0;
        y_in_sprite = 6'd0;
        
        if (inside_reel1) begin
            // Calculate Y position in entire 8 sprite reel (with offset bc we're shifiting down each time by2px)
            y_in_reel = (vcount - REELS_START_V + reel1_offset) % TOTAL_HEIGHT; // TODO: is it rigt to use TOTAL_HEIGHT here?
            
            // Which sequence position? (divide by sprite height to get bucket)
            // ESSENTIALLY, this is how many sprites away do we need to jump
            seq_position = y_in_reel / SPRITE_HEIGHT;  // Divide by 64
            
            // Apply stride to get sprite index
            // start sprite index + how many sprites we need to jump * ()
            sprite_idx = (REEL1_START_SPRITE + (REEL1_STRIDE * seq_position)) % NUM_SPRITES;
            
            // Position within sprite
            x_in_sprite = hcount - REEL1_START_H;
            y_in_sprite = y_in_reel % SPRITE_HEIGHT;  // Modulo 64 (bottom 6 bits)
            
        end else if (inside_reel2) begin
            y_in_reel = (vcount - REELS_START_V + reel2_offset) % TOTAL_HEIGHT;
            seq_position = y_in_reel / SPRITE_HEIGHT;
            sprite_idx = (REEL2_START_SPRITE + (REEL2_STRIDE * seq_position)) % NUM_SPRITES;
            x_in_sprite = hcount - REEL2_START_H;
            y_in_sprite = y_in_reel % SPRITE_HEIGHT; 
            
        end else if (inside_reel3) begin
            y_in_reel = (vcount - REELS_START_V + reel3_offset) % TOTAL_HEIGHT;
            seq_position = y_in_reel / SPRITE_HEIGHT;
            sprite_idx = (REEL3_START_SPRITE + (REEL3_STRIDE * seq_position)) % NUM_SPRITES;
            x_in_sprite = hcount - REEL3_START_H;
            y_in_sprite = y_in_reel % SPRITE_HEIGHT; 
        end

    end

    assign address = ((sprite_idx * SPRITE_HEIGHT * SPRITE_WIDTH) + (SPRITE_HEIGHT * y_in_sprite) + x_in_sprite); // cinvert to bytes?
    // INSTANTIATE ROM HERE, AND AS AN OUTPUT TAKE rgb_rom; - use address
    
    logic [2:0] rom_data_reg;
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) rom_data_reg <= 3'b000;
        else rom_data_reg <= rgb_rom; // rom_data is BRAM output (next-cycle if BRAM sync)
    end

    logic [2:0] rgb_rom;
    always_ff @(posedge clk, negedge reset) begin
        if (!reset) begin
            pixel_rgb <= 3'b000; // black background color
        end else if (inside_reel1 | inside_reel2 | inside_reel3) begin 
            pixel_rgb <= rom_data_reg; // rbg from ROM
        end else begin
            pixel_rgb <= 3'b000; // black background color
        end
    end

endmodule

    // INSTANTIATE ROM HERE, AND AS AN OUTPUT TAKE rgb_rom;

// // TODO:
// - use hcount and vcount along with offset to calc memory address and get rgb
// - target sprite logic calcualtion
// - write rom block
// // in design, around each sprite pad it with black in the 64x64, makes it easier ontop and bottom, sides not needed




// // only if hcount/vcount is in reel1 or reel2 or reel3 domain, use SPRAM memory, otherwise use background color



// vcount - vcount_start --> this will tell us offset from start
// basically we want vcount offset from the starting position to tell us how many lines down from offset memory location we need to pull from
// once it hits 64 pixels, we need to jup by REEL1_STRIDE

// or rather, once offset >= 64, then we jump the offset by REEL1_STRIDE
// hm actally not with offset but rather we should store starting mem addresses and add offst to this, so we won't change offset logic