// TODO: figure out the scaling later from 32x32 to 64x64
// - fix resolution numbers -- done
// - spi ack pin, take out start logic - partial doen for end of spin
// - mapping sprite movement 1-1 to a sprite index -- done
// - addressing into memory blocks
// - retain where we left off for spins -- done maybe ? check

// if you are in state X, you can only move to state Y if Z
// once you hit start spinning, you have to touch every state after
// offset can be incremented by 2 every time frame is asserted

module memory_controller ( // TODO: need to define bus lengths
    input logic clk, // TODO: this is the 25.175MHz clock
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
    output logic done
);

    localparam NUM_SPRITES = 7;
    localparam SPRITE_HEIGHT = 64;
    localparam SPRITE_WIDTH = 64;

    localparam PIXEL_SCALE = 1;

    localparam TOTAL_HEIGHT = NUM_SPRITES * SPRITE_HEIGHT * PIXEL_SCALE;

    localparam REEL1_START_H = 160; // TODO : calculate if these are ok values?
    localparam REEL2_START_H = 288;
    localparam REEL3_START_H = 416;
    localparam REELS_START_V = 40;
    localparam REEL_DISPLAY_HEIGHT = 192;  // Show 384 pixels tall (3 full sprites!) // could be 3
    localparam REELS_END_V = REELS_START_V + REEL_DISPLAY_HEIGHT - 1;  // 423
    // Screen layout for 1024×600
    // localparam SCREEN_WIDTH = 1024;
    // localparam SCREEN_HEIGHT = 600;
    
    // // Center reels horizontally: (1024 - 3*64) / 4 = spacing
    // localparam REEL1_START_H = 244;  // (1024 - 3*64)/4 ≈ 244
    // localparam REEL2_START_H = 480;  // 244 + 64 + gap
    // localparam REEL3_START_H = 716;  // 480 + 64 + gap
    
    // // Vertical: show more sprites with more height!
    // localparam REELS_START_V = 100;
    // localparam REEL_DISPLAY_HEIGHT = 400;  // Show ~6 sprites (400/64 ≈ 6.25)
    // localparam REELS_END_V = REELS_START_V + REEL_DISPLAY_HEIGHT - 1;  // 499

    // localparam REEL1_START_SPRITE = 3'd0;  // Reel 1 starts at sprite 0
    // localparam REEL2_START_SPRITE = 3'd2;  // Reel 2 starts at sprite 2
    // localparam REEL3_START_SPRITE = 3'd5;  // Reel 3 starts at sprite 5

    // localparam REEL1_STRIDE = 3'd1;  // Reel 1: 0→1→2→3→4→5→6→7→0...
    // localparam REEL2_STRIDE = 3'd3;  // Reel 2: 2→5→0→3→6→1→4→7→2...
    // localparam REEL3_STRIDE = 3'd6;  // Reel 3: 5→3→1→7→5→3→1→7...

    localparam PIXELS_PER_FRAME = 2;
    

    // Reel sequences (LUTs)
    logic [2:0] reel1_sequence [0:6];
    logic [2:0] reel2_sequence [0:6];
    logic [2:0] reel3_sequence [0:6];
    
    initial begin
        // Reel 1: sequential
        reel1_sequence[0] = 3'd0; 
        reel1_sequence[1] = 3'd1;
        reel1_sequence[2] = 3'd2; 
        reel1_sequence[3] = 3'd3;
        reel1_sequence[4] = 3'd4; 
        reel1_sequence[5] = 3'd5;
        reel1_sequence[6] = 3'd6; 
        
        // Reel 2: shuffled
        reel2_sequence[0] = 3'd2; 
        reel2_sequence[1] = 3'd5;
        reel2_sequence[2] = 3'd0; 
        reel2_sequence[3] = 3'd6;
        reel2_sequence[4] = 3'd3; 
        reel2_sequence[5] = 3'd1;
        reel2_sequence[6] = 3'd4; 
        
        // Reel 3: different shuffle
        reel3_sequence[0] = 3'd5; 
        reel3_sequence[1] = 3'd3;
        reel3_sequence[2] = 3'd1; 
        reel3_sequence[3] = 3'd4;
        reel3_sequence[4] = 3'd2; 
        reel3_sequence[5] = 3'd0;
        reel3_sequence[6] = 3'd6; 
    end

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

    ///////////////////////
    // Find which sequence position shows the target sprite
    logic [9:0] centering_offset;
    assign centering_offset = (REEL_DISPLAY_HEIGHT / 2) - (SPRITE_HEIGHT / 2);  // 200 - 32 = 168

    // doing a reverse lookup: sprite to position
    logic [2:0] reel1_target_pos, reel2_target_pos, reel3_target_pos;
    
    always_comb begin
        // Reel 1 - just sequential
        reel1_target_pos = reel1_final_sprite;
        
        // Reel 2 - diff order
        case (reel2_final_sprite)
            3'd2: reel2_target_pos = 3'd0;
            3'd5: reel2_target_pos = 3'd1;
            3'd0: reel2_target_pos = 3'd2;
            3'd6: reel2_target_pos = 3'd3;
            3'd3: reel2_target_pos = 3'd4;
            3'd1: reel2_target_pos = 3'd5;
            3'd4: reel2_target_pos = 3'd6;
            default: reel2_target_pos = 3'd0;
        endcase
        
        // Reel 3 - also diff order
        case (reel3_final_sprite)
            3'd5: reel3_target_pos = 3'd0;
            3'd3: reel3_target_pos = 3'd1;
            3'd1: reel3_target_pos = 3'd2;
            3'd2: reel3_target_pos = 3'd3;
            3'd0: reel3_target_pos = 3'd4;
            3'd6: reel3_target_pos = 3'd5;
            3'd4: reel3_target_pos = 3'd6;
            default: reel3_target_pos = 3'd0;
        endcase
    end
    
    // calculate target offsets TODO: come back here
    // get which sequence number this reel belongs to, and calculate offset from this sequence position (offset is independent of order, just when the sprite appears, as it adds 2 until then)
    assign reel1_ending_offset = (reel1_target_pos * SPRITE_HEIGHT + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
    assign reel2_ending_offset = (reel2_target_pos * SPRITE_HEIGHT + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
    assign reel3_ending_offset = (reel3_target_pos * SPRITE_HEIGHT + TOTAL_HEIGHT - centering_offset) % TOTAL_HEIGHT;
    ///////////////////////////////

    logic vsync_prev;
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            frame_done <= 0;
            vsync_prev <= 1;
        end else begin
            if (!vsync && vsync_prev) begin // active low
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
            reel1_spin_amt <= 3'd5; // if this spins 5 times, then we can assume the reels below also spin 5 times, we what we want is just the extra spins for the other two
            reel2_spin_amt <= 3'd2;
            reel3_spin_amt <= 3'd2;
            reel1_final_sprite <= 0;
            reel2_final_sprite <= 0;
            reel3_final_sprite <= 0;
        end else begin
            if (state == IDLE && start_spin) begin
                reel1_final_sprite <= final1_sprite;
                reel2_final_sprite <= final2_sprite;
                reel3_final_sprite <= final3_sprite;
            end
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
        done = 0;

        case(state)
            IDLE: begin 
                // reel1_spin_amt = 3'd5; // if this spins 5 times, then we can assume the reels below also spin 5 times, we what we want is just the extra spins for the other two
                // reel2_spin_amt = 3'd2;
                // reel3_spin_amt = 3'd2;
                if (start_spin) begin
                    next_state = START_SPINNING;
                    next_reel1_offset = reel1_offset; // hopefully this preserves the previosu ending state as hte next starting state (only reset_n clears it)
                    next_reel2_offset = reel2_offset;
                    next_reel3_offset = reel3_offset;
                    next_reel1_spin_amt = 3'd5;  // All reels do 5 base rotations
                    next_reel2_spin_amt = 3'd2;  // Reel 2 does 2 extra rotations
                    next_reel3_spin_amt = 3'd2;  // Reel 3 does 2 extra rotations
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
                    done = 1;
                end
            end
        endcase
    end


    logic inside_reel1_prev, inside_reel2_prev, inside_reel3_prev;
    logic inside_reel1, inside_reel2, inside_reel3;
    logic [2:0] sprite_idx;
    logic [5:0] x_in_sprite, y_in_sprite;
    logic [9:0] y_in_reel;
    logic [2:0] seq_position;
    logic inside_reel;
    //logic [$clog2(NUM_SPRITES*SPRITE_WIDTH*SPRITE_HEIGHT)-1:0] address; // each address here will hodl an rgb value
    
    assign inside_reel1_prev = (hcount >= REEL1_START_H && hcount < REEL1_START_H + SPRITE_WIDTH) && (vcount >= REELS_START_V && vcount < REELS_END_V);
    assign inside_reel2_prev = (hcount >= REEL2_START_H && hcount < REEL2_START_H + SPRITE_WIDTH) && (vcount >= REELS_START_V && vcount < REELS_END_V);
    assign inside_reel3_prev = (hcount >= REEL3_START_H && hcount < REEL3_START_H + SPRITE_WIDTH) && (vcount >= REELS_START_V && vcount < REELS_END_V);

    assign inside_reel_comb = inside_reel1_prev | inside_reel2_prev | inside_reel3_prev;

    always_comb begin
        logic [9:0] y_in_reel;
        logic [2:0] seq_pos;
        
        sprite_idx = 3'd0;
        x_in_sprite = 6'd0;
        y_in_sprite = 6'd0;
        
        if (inside_reel1_prev) begin
            y_in_reel = (vcount - REELS_START_V + reel1_offset) % TOTAL_HEIGHT;
            seq_pos = y_in_reel[8:6]; // divide by 64 to get which sequence sprite we are on (each sprite has a height of 64 so this will tell us sprite order)
            sprite_idx = reel1_sequence[seq_pos]; // but sprite order is not the same for each reel, so map sprite index to actual reel's sprite
            x_in_sprite = hcount - REEL1_START_H; // find horizontal offset, simple
            y_in_sprite = y_in_reel[5:0]; // % 64 to find y location offset
        end else if (inside_reel2_prev) begin
            y_in_reel = (vcount - REELS_START_V + reel2_offset) % TOTAL_HEIGHT;
            seq_pos = y_in_reel[8:6];
            sprite_idx = reel2_sequence[seq_pos];
            x_in_sprite = hcount - REEL2_START_H;
            y_in_sprite = y_in_reel[5:0];
        end else if (inside_reel3_prev) begin
            y_in_reel = (vcount - REELS_START_V + reel3_offset) % TOTAL_HEIGHT;
            seq_pos = y_in_reel[8:6];
            sprite_idx = reel3_sequence[seq_pos];
            x_in_sprite = hcount - REEL3_START_H;
            y_in_sprite = y_in_reel[5:0];
        end
    end

    logic [2:0] sprite_idx_r;
    logic [5:0] x_in_sprite_r, y_in_sprite_r;
    logic inside_reel_r;
    
    // want to clock inputs into rom so we stabalize them at the same/consistent value, otherwie it is pure combinational changing at diff times
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            sprite_idx_r <= 3'd0;
            x_in_sprite_r  <= 6'd0;
            y_in_sprite_r  <= 6'd0;
            inside_reel_r <= 1'b0;
            active_video_d1 <= 1'b0;
        end else begin
            sprite_idx_r <= sprite_idx;
            x_in_sprite_r  <= x_in_sprite;
            y_in_sprite_r  <= y_in_sprite;
            inside_reel_r <= inside_reel_comb;
            active_video_d1 <= active_video;
        end
    end

    assign address = ((sprite_idx * SPRITE_HEIGHT * SPRITE_WIDTH) + (SPRITE_HEIGHT * y_in_sprite) + x_in_sprite); // cinvert to bytes?

    logic [2:0] rgb_rom;
    // INSTANTIATE ROM HERE, AND AS AN OUTPUT TAKE rgb_rom; - use address
    rom_wrapper rom_wrapper (
        .clk           (clk),
        .sprite_idx    (sprite_idx_r),
        .x_in_sprite   (x_in_sprite_r),
        .y_in_sprite   (y_in_sprite_r),
        .pixel_rgb     (rgb_rom)
    );
    
    // pipeline to wait for one cycle latenxy in rom read for the data
    logic [2:0] rom_data_reg;
    logic in_reel_r2, in_reel_r3;
    logic active_video_d3;
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            rom_data_reg <= 3'b000;
            inside_reel_r2 <= 1'b0;
            active_video_d2 <= 1'b0;
        end else begin
            // this when we do first mem read to get the data
            inside_reel_r2 <= inside_reel_r; 
            active_video_d2 <= active_video_d1; // store active vudeo signal too

            // this is when we get the pixel in the data which is also clocked for stability 
            rom_data_reg <= rgb_rom; // capture BRAM output
            in_reel_r3      <= in_reel_r2; // This is the control signal synchronized with rom_data_reg
            active_video_d3 <= active_video_d2;

        end
    end

    logic [2:0] rgb_rom;
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            pixel_rgb <= 3'b000; // black background color
        end else if (active_video_d3 && inside_reel_r3) begin 
            pixel_rgb <= rom_data_reg; // rbg from ROM
        end else if (active_video_d3) begin
            pixel_rgb <= 3'b010; // background color
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
