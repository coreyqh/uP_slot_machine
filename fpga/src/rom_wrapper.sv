module rom_wrapper (
    input  logic clk,
    input  logic [2:0] sprite_idx,       
    input  logic [5:0] x_in_sprite,      
    input  logic [5:0] y_in_sprite,      
    output logic [2:0] pixel_rgb         
);

    localparam SPRITE_WIDTH = 64;
    localparam DATA_WIDTH = 16;
    localparam TOTAL_WORDS = 7 * 4 * 256; // 7168 words total
    localparam ADDRESS_WIDTH = 13;        // 13 bits for 7168 words
    
    // forcing to use bram
    (* ram_style = "block" *) 
    logic [DATA_WIDTH-1:0] single_bram [0:TOTAL_WORDS-1]; 

    // NOTE: need a file with "all_sprites_combined.mem" (7168 lines) --> should have all the sprites in 1 hopefully it uses 28 bram blcocks
    initial begin
        $readmemh("sprite_rom0.mem", single_bram);
    end

    // calculate the index offsets
    logic [11:0] pixel_index; // which pixel we want for a sprite       
    logic [9:0] word_offset; // which word line are we in      
    logic [4:0] sprite_bram_index;  // which bram block
    logic [7:0] bram_addr; // address in bram        
    logic [1:0] pixel_in_word;   // finally which pixel   
    logic [ADDRESS_WIDTH-1:0] linear_addr;


    assign pixel_index       = (y_in_sprite * SPRITE_WIDTH) + x_in_sprite; // calcualte offset into the storage for one sprite
    assign word_offset       = pixel_index >> 2; // divide by 4 to get which line we are in
    assign pixel_in_word     = pixel_index[1:0]; // %4 in order to get the pixel we want in the word

    // address calc
    assign sprite_bram_index = (sprite_idx << 2) | (word_offset[9:8]); // take the sprite index * 4 (since 4 blocks per sprite) + (word % 4_rom_blocks) so we get which block to go into
    assign bram_addr         = word_offset[7:0];   
    assign linear_addr       = (sprite_bram_index << 8) | bram_addr; // form 16 bit address


    // register for storing pipelined stages
    logic [DATA_WIDTH-1:0] read_word; 
    logic [2:0] r_pixel_in_word;

    
    // syncing
    always_ff @(posedge clk) begin
        
        // stage 1 - use stable inputs for rom block --> want to make it stabel for a clk
        read_word      <= single_bram[linear_addr]; 
        r_pixel_in_word  <= pixel_in_word;

        // stage 2 - 
        // moved this in here to make sure we also have to time to safely get a sifnal on the output
        // this will help avoud any hold time conflicts of data changing too fast before the captyre flop in the mem contrller
        always_comb begin
            // based on which pixel we want, choose the bits
            // but we still only want 3 bits even tho we are storing it as 4 --> doing this for smoother calculations
            case (r_pixel_in_word)
                2'd0: pixel_rgb = read_word[3:1];
                2'd1: pixel_rgb = read_word[7:5];
                2'd2: pixel_rgb = read_word[11:9];
                2'd3: pixel_rgb = read_word[15:13]; 
                default: pixel_rgb = 4'b000;
            endcase
        end

    end


endmodule












// module rom_wrapper (
//     input  logic clk,
//     input  logic [2:0] sprite_idx,       // 0-6 for 7 sprites
//     input  logic [5:0] x_in_sprite,      // 0-63
//     input  logic [5:0] y_in_sprite,      // 0-63
//     output logic [2:0] pixel_rgb         // 3-bit RGB output
// );

//     localparam SPRITE_WIDTH = 64;
//     localparam SPRITE_HEIGHT = 64;
    
//     // --- 1. Explicit Memory Declarations (28 Separate 1D Arrays) ---
//     // This is the key change: replacing the single 2D array with 28 separate 1D arrays
//     logic [15:0] s0_bram0 [0:255]; 
//     logic [15:0] s0_bram1 [0:255]; 
//     logic [15:0] s0_bram2 [0:255]; 
//     logic [15:0] s0_bram3 [0:255];

//     logic [15:0] s1_bram0 [0:255]; 
//     logic [15:0] s1_bram1 [0:255];
//     logic [15:0] s1_bram2 [0:255]; 
//     logic [15:0] s1_bram3 [0:255];

//     logic [15:0] s2_bram0 [0:255]; 
//     logic [15:0] s2_bram1 [0:255];
//     logic [15:0] s2_bram2 [0:255]; 
//     logic [15:0] s2_bram3 [0:255];

//     logic [15:0] s3_bram0 [0:255]; 
//     logic [15:0] s3_bram1 [0:255];
//     logic [15:0] s3_bram2 [0:255]; 
//     logic [15:0] s3_bram3 [0:255];

//     logic [15:0] s4_bram0 [0:255]; 
//     logic [15:0] s4_bram1 [0:255];
//     logic [15:0] s4_bram2 [0:255]; 
//     logic [15:0] s4_bram3 [0:255];

//     logic [15:0] s5_bram0 [0:255]; 
//     logic [15:0] s5_bram1 [0:255];
//     logic [15:0] s5_bram2 [0:255]; 
//     logic [15:0] s5_bram3 [0:255];

//     logic [15:0] s6_bram0 [0:255]; 
//     logic [15:0] s6_bram1 [0:255];
//     logic [15:0] s6_bram2 [0:255]; 
//     logic [15:0] s6_bram3 [0:255];


//     // --- 2. Memory Initialization (28 Separate $readmemh calls) ---
//     initial begin
//         $readmemh("sprite0_bram0.mem", s0_bram0); $readmemh("sprite0_bram1.mem", s0_bram1);
//         $readmemh("sprite0_bram2.mem", s0_bram2); $readmemh("sprite0_bram3.mem", s0_bram3);
        
//         $readmemh("sprite1_bram0.mem", s1_bram0); $readmemh("sprite1_bram1.mem", s1_bram1);
//         $readmemh("sprite1_bram2.mem", s1_bram2); $readmemh("sprite1_bram3.mem", s1_bram3);
        
//         $readmemh("sprite2_bram0.mem", s2_bram0); $readmemh("sprite2_bram1.mem", s2_bram1);
//         $readmemh("sprite2_bram2.mem", s2_bram2); $readmemh("sprite2_bram3.mem", s2_bram3);
        
//         $readmemh("sprite3_bram0.mem", s3_bram0); $readmemh("sprite3_bram1.mem", s3_bram1);
//         $readmemh("sprite3_bram2.mem", s3_bram2); $readmemh("sprite3_bram3.mem", s3_bram3);
        
//         $readmemh("sprite4_bram0.mem", s4_bram0); $readmemh("sprite4_bram1.mem", s4_bram1);
//         $readmemh("sprite4_bram2.mem", s4_bram2); $readmemh("sprite4_bram3.mem", s4_bram3);
        
//         $readmemh("sprite5_bram0.mem", s5_bram0); $readmemh("sprite5_bram1.mem", s5_bram1);
//         $readmemh("sprite5_bram2.mem", s5_bram2); $readmemh("sprite5_bram3.mem", s5_bram3);
        
//         $readmemh("sprite6_bram0.mem", s6_bram0); $readmemh("sprite6_bram1.mem", s6_bram1);
//         $readmemh("sprite6_bram2.mem", s6_bram2); $readmemh("sprite6_bram3.mem", s6_bram3);
//     end
    
//     // --- 3. Combinational Address and Index Calculations ---
    
//     // Pixel index (0-4095)
//     logic [11:0] pixel_index;
//     assign pixel_index = (y_in_sprite * SPRITE_WIDTH) + x_in_sprite;
    
//     // Word offset (0-818) -> 4096 / 5 = 819 words needed, 819-1 = 818
//     logic [11:0] word_offset;
//     assign word_offset = pixel_index / 5;
    
//     // BRAM offset (0-3) - MSBs of the word offset. Since 4 BRAMs * 256 words = 1024 words, 
//     // we use word_offset[9:8] (10 bits for 1024 words).
//     logic [1:0] bram_offset;    
//     assign bram_offset = word_offset[9:8];
    
//     // Address within that BRAM (0-255) - LSBs of the word offset
//     logic [7:0] bram_addr;
//     assign bram_addr = word_offset[7:0];    
    
//     // Pixel index within the word (0-4)
//     logic [2:0] pixel_in_word;
//     assign pixel_in_word = pixel_index % 5;


//     // --- 4. Read Logic: Selection and Synchronous Read ---
    
//     // Temporary signal for the data word read from the selected BRAM
//     logic [15:0] read_word;
    
//     // Combinational logic to select the correct BRAM using a case statement
//     always_comb begin
//         read_word = 16'h0000; // Default output
        
//         // This large case statement replaces the array indexing: bram[bram_index][bram_addr]
//         unique case ({sprite_idx, bram_offset})
//             // Sprite 0 (sprite_idx=0, bram_offset=0-3)
//             3'd0, 2'b00: read_word = s0_bram0[bram_addr];
//             3'd0, 2'b01: read_word = s0_bram1[bram_addr];
//             3'd0, 2'b10: read_word = s0_bram2[bram_addr];
//             3'd0, 2'b11: read_word = s0_bram3[bram_addr];
            
//             // Sprite 1 (sprite_idx=1, bram_offset=0-3)
//             3'd1, 2'b00: read_word = s1_bram0[bram_addr];
//             3'd1, 2'b01: read_word = s1_bram1[bram_addr];
//             3'd1, 2'b10: read_word = s1_bram2[bram_addr];
//             3'd1, 2'b11: read_word = s1_bram3[bram_addr];
            
//             // Sprite 2
//             3'd2, 2'b00: read_word = s2_bram0[bram_addr];
//             3'd2, 2'b01: read_word = s2_bram1[bram_addr];
//             3'd2, 2'b10: read_word = s2_bram2[bram_addr];
//             3'd2, 2'b11: read_word = s2_bram3[bram_addr];
            
//             // Sprite 3
//             3'd3, 2'b00: read_word = s3_bram0[bram_addr];
//             3'd3, 2'b01: read_word = s3_bram1[bram_addr];
//             3'd3, 2'b10: read_word = s3_bram2[bram_addr];
//             3'd3, 2'b11: read_word = s3_bram3[bram_addr];
            
//             // Sprite 4
//             3'd4, 2'b00: read_word = s4_bram0[bram_addr];
//             3'd4, 2'b01: read_word = s4_bram1[bram_addr];
//             3'd4, 2'b10: read_word = s4_bram2[bram_addr];
//             3'd4, 2'b11: read_word = s4_bram3[bram_addr];
            
//             // Sprite 5
//             3'd5, 2'b00: read_word = s5_bram0[bram_addr];
//             3'd5, 2'b01: read_word = s5_bram1[bram_addr];
//             3'd5, 2'b10: read_word = s5_bram2[bram_addr];
//             3'd5, 2'b11: read_word = s5_bram3[bram_addr];
            
//             // Sprite 6
//             3'd6, 2'b00: read_word = s6_bram0[bram_addr];
//             3'd6, 2'b01: read_word = s6_bram1[bram_addr];
//             3'd6, 2'b10: read_word = s6_bram2[bram_addr];
//             3'd6, 2'b11: read_word = s6_bram3[bram_addr];
            
//             default: read_word = 16'h0000;
//         endcase
//     end
    
//     // Synchronous output registration and pixel extraction
//     always_ff @(posedge clk) begin
//         // Extract the right 3-bit pixel from the word read in the previous cycle
//         // Word format: [15]=unused, [14:12]=pix4, [11:9]=pix3, [8:6]=pix2, [5:3]=pix1, [2:0]=pix0
//         case (pixel_in_word)
//             3'd0: pixel_rgb <= read_word[2:0];
//             3'd1: pixel_rgb <= read_word[5:3];
//             3'd2: pixel_rgb <= read_word[8:6];
//             3'd3: pixel_rgb <= read_word[11:9]; 
//             3'd4: pixel_rgb <= read_word[14:12];
//             default: pixel_rgb <= 3'b000;
//         endcase
//     end

// endmodule




// // module rom_wrapper (
// //     input  logic clk,
// //     input  logic [2:0] sprite_idx,       // 0-6 for 7 sprites
// //     input  logic [5:0] x_in_sprite,      // 0-63
// //     input  logic [5:0] y_in_sprite,      // 0-63
// //     output logic [2:0] pixel_rgb         // 3-bit RGB output
// // );

// //     localparam SPRITE_WIDTH = 64;
// //     localparam SPRITE_HEIGHT = 64;

// //     // 28 BRAMs total (4 per sprite × 7 sprites)
// //     // Each word stores 5 pixels (5 × 3 = 15 bits, 1 bit unused)
// //     logic [15:0] bram [0:27][0:255]; // 256x16 BRAMS -- 256 lines, 16bit words
    
// //     // Load sprite data
// //     initial begin
// //         $readmemh("sprite0_bram0.mem", bram[0]);
// //         $readmemh("sprite0_bram1.mem", bram[1]);
// //         $readmemh("sprite0_bram2.mem", bram[2]);
// //         $readmemh("sprite0_bram3.mem", bram[3]);
        
// //         $readmemh("sprite1_bram0.mem", bram[4]);
// //         $readmemh("sprite1_bram1.mem", bram[5]);
// //         $readmemh("sprite1_bram2.mem", bram[6]);
// //         $readmemh("sprite1_bram3.mem", bram[7]);
        
// //         $readmemh("sprite2_bram0.mem", bram[8]);
// //         $readmemh("sprite2_bram1.mem", bram[9]);
// //         $readmemh("sprite2_bram2.mem", bram[10]);
// //         $readmemh("sprite2_bram3.mem", bram[11]);
        
// //         $readmemh("sprite3_bram0.mem", bram[12]);
// //         $readmemh("sprite3_bram1.mem", bram[13]);
// //         $readmemh("sprite3_bram2.mem", bram[14]);
// //         $readmemh("sprite3_bram3.mem", bram[15]);
        
// //         $readmemh("sprite4_bram0.mem", bram[16]);
// //         $readmemh("sprite4_bram1.mem", bram[17]);
// //         $readmemh("sprite4_bram2.mem", bram[18]);
// //         $readmemh("sprite4_bram3.mem", bram[19]);
        
// //         $readmemh("sprite5_bram0.mem", bram[20]);
// //         $readmemh("sprite5_bram1.mem", bram[21]);
// //         $readmemh("sprite5_bram2.mem", bram[22]);
// //         $readmemh("sprite5_bram3.mem", bram[23]);
        
// //         $readmemh("sprite6_bram0.mem", bram[24]);
// //         $readmemh("sprite6_bram1.mem", bram[25]);
// //         $readmemh("sprite6_bram2.mem", bram[26]);
// //         $readmemh("sprite6_bram3.mem", bram[27]);
// //     end
    
// //     // Calculate pixel index within sprite (0-4095)
// //     // NOTE: this is just for pixels of which there are 4096 - each of these have 3 bits for rgb which are stored in memory hence we need 4
// //     // so when are doing calcualtions we want to treat it as pixels and not bits - hence we abstract away each bit (treat as 5 insted of 5*3=15 for example)
// //     logic [11:0] pixel_index;
// //     assign pixel_index = (y_in_sprite * SPRITE_WIDTH) + x_in_sprite;
// //     // Example: y=2, x=25 → pixel_index = 2*64 + 25 = 153
    
// //     // Divide by 5 to get word offset within sprite -- which word line??
// //     logic [11:0] word_offset;
// //     assign word_offset = pixel_index / 5;
    
// //     // Which of the 4 BRAMs for this sprite? --> got which word line its own, now need to see which block this wordline belowngs to
// //     logic [1:0] bram_offset;    // 0-3
// //     assign bram_offset = word_offset[9:8];  // word_offset / 256 --> essetnailly dividing pixel_index / (# of pixels in a block), where # of pixels in a block is number of words * 5 = 256 * 5 (since 5 pixels in a word line)
    
// //     // Address within that BRAM
// //     logic [7:0] bram_addr;
// //     assign bram_addr = word_offset[7:0];    // word_offset % 256 --> remainder of the division above, essentiallu tells us spill over into RAM block since it doesn't alsways divide eprfectly into a block   

// //     // Absolute BRAM index (0-27)
// //     logic [4:0] bram_index;
// //     assign bram_index = (sprite_idx << 2) + bram_offset;  // sprite_idx * 4 + bram_offset --> since each index gets 4 blocks
    
// //     // Which of 5 pixels in the word?
// //     logic [2:0] pixel_in_word;
// //     assign pixel_in_word = pixel_index % 5;


    
// //     logic [15:0] selected_word;
    
// //     always_ff @(posedge clk) begin
// //         // Read from the calculated BRAM and address
// //         selected_word <= bram[bram_index][bram_addr];
        
// //         // Extract the right 3-bit pixel from the word
// //         // Word format: [15]=unused, [14:12]=pix4, [11:9]=pix3, [8:6]=pix2, [5:3]=pix1, [2:0]=pix0
// //         case (pixel_in_word)
// //             3'd0: pixel_rgb <= selected_word[2:0];
// //             3'd1: pixel_rgb <= selected_word[5:3];
// //             3'd2: pixel_rgb <= selected_word[8:6];
// //             3'd3: pixel_rgb <= selected_word[11:9]; 
// //             3'd4: pixel_rgb <= selected_word[14:12];
// //             default: pixel_rgb <= 3'b000;
// //         endcase
// //     end

// // endmodule