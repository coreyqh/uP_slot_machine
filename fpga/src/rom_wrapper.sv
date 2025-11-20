module rom_wrapper (
    input  logic clk,
    input  logic [2:0] sprite_sel_i,  // Sprite index (0-6)
    input  logic [9:0] word_addr_i,   // 10-bit word address (0-1023)
    output logic [15:0] data_o        // 16-bit word output (4 color pixels)
);

    // --- Address Decoding ---
    (* keep = "true" *) logic [1:0] bram_select; // word_addr_i[9:8]: Selects which of the 4 columns (0 to 3)
    (* keep = "true" *) logic [7:0] bram_addr;   // word_addr_i[7:0]: 8-bit address within the BRAM (0-255)

    assign bram_select = word_addr_i[9:8];
    assign bram_addr   = word_addr_i[7:0];
	
	logic [1:0] bram_select_r;
	logic [2:0] sprite_sel_r;
	
	always_ff @(posedge clk) begin
		bram_select_r <= bram_select;
		sprite_sel_r <= sprite_sel_i;
	end
	

    // --- Bank Enable Logic ---
	logic bankA_enable, bankB_enable; 
	// LSB of sprite_sel_i determines parity: 0=Even (Bank A), 1=Odd (Bank B)
	assign bankA_enable = (sprite_sel_i[0] == 1'b0); // Sprites 0,2,4,6 
	assign bankB_enable = (sprite_sel_i[0] == 1'b1); // Sprites 1,3,5

    // --- Wires for 8 Physical ROM Outputs ---
    (* keep = "true" *) logic [15:0] r1_data, r2_data, r3_data, r4_data; // Bank A
    (* keep = "true" *) logic [15:0] r5_data, r6_data, r7_data, r8_data; // Bank B
	(* keep = "true" *) logic [15:0] r9_data, r10_data, r11_data, r12_data; // Bank B
	// (* keep = "true" *) logic [15:0] r13_data, r14_data, r15_data, r16_data; // Bank B

    // --- BRAM Output Wires (28 Total - Logical Outputs for Sprites) ---
    // NOTE: These wires are now essentially redundant, as they all point to the same 8 data lines.
    // They are kept here for clear mapping to the final MUX.
	/*
    // Sprite 0 (Even) -> Uses Bank A (r1, r2, r3, r4)
    logic [15:0] s0_bram0_data, s0_bram1_data, s0_bram2_data, s0_bram3_data;
    assign s0_bram0_data = r1_data; assign s0_bram1_data = r2_data;
    assign s0_bram2_data = r3_data; assign s0_bram3_data = r4_data;
    
    // Sprite 1 (Odd) -> Uses Bank B (r5, r6, r7, r8)
    logic [15:0] s1_bram0_data, s1_bram1_data, s1_bram2_data, s1_bram3_data;
    assign s1_bram0_data = r5_data; assign s1_bram1_data = r6_data;
    assign s1_bram2_data = r7_data; assign s1_bram3_data = r8_data;
    
    // Sprite 2 (Even) -> Uses Bank A (r1, r2, r3, r4)
    logic [15:0] s2_bram0_data, s2_bram1_data, s2_bram2_data, s2_bram3_data;
    assign s2_bram0_data = r1_data; assign s2_bram1_data = r2_data;
    assign s2_bram2_data = r3_data; assign s2_bram3_data = r4_data;
    
    // Sprite 3 (Odd) -> Uses Bank B (r5, r6, r7, r8)
    logic [15:0] s3_bram0_data, s3_bram1_data, s3_bram2_data, s3_bram3_data;
    assign s3_bram0_data = r5_data; assign s3_bram1_data = r6_data;
    assign s3_bram2_data = r7_data; assign s3_bram3_data = r8_data;
    
    // Sprite 4 (Even) -> Uses Bank A (r1, r2, r3, r4)
    logic [15:0] s4_bram0_data, s4_bram1_data, s4_bram2_data, s4_bram3_data;
    assign s4_bram0_data = r1_data; assign s4_bram1_data = r2_data;
    assign s4_bram2_data = r3_data; assign s4_bram3_data = r4_data;
    
    // Sprite 5 (Odd) -> Uses Bank B (r5, r6, r7, r8)
    logic [15:0] s5_bram0_data, s5_bram1_data, s5_bram2_data, s5_bram3_data;
    assign s5_bram0_data = r5_data; assign s5_bram1_data = r6_data;
    assign s5_bram2_data = r7_data; assign s5_bram3_data = r8_data;
    
    // Sprite 6 (Even) -> Uses Bank A (r1, r2, r3, r4)
    logic [15:0] s6_bram0_data, s6_bram1_data, s6_bram2_data, s6_bram3_data;
    assign s6_bram0_data = r1_data; assign s6_bram1_data = r2_data;
    assign s6_bram2_data = r3_data; assign s6_bram3_data = r4_data;
	*/


    // Bank A (Even Sprites)
    r1 r1_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r1_data) );
    r2 r2_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r2_data) );
    r3 r3_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r3_data) );
    r4 r4_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r4_data) );
    
    // Bank B (Odd Sprites)
    r5 r5_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r5_data) );
    r6 r6_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r6_data) );
    r7 r7_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r7_data) );
    r8 r8_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r8_data) );
	
	// Bank C
    r9 r9_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r9_data) );
    r10 r10_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r10_data) );
    r11 r11_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r11_data) );
    r12 r12_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r12_data) );
	
	// Bank C
    r13 r13_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r13_data) );
    r14 r14_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r14_data) );
    r15 r15_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r15_data) );
    r16 r16_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r16_data) );


    // --- Data Selection (Combinational Mux) ---
    logic [15:0] selected_word;
    
    always_comb begin
        unique case (sprite_sel_i)
            // All even sprites rely on r1-r4 outputs
            3'd0: begin
                unique case (bram_select) 
                    2'd0: selected_word = r13_data; 2'd1: selected_word = r14_data; 
                    2'd2: selected_word = r15_data; 2'd3: selected_word = r16_data; 
                    default: selected_word = 16'h0000; 
                endcase
            end
			3'd1: begin
                unique case (bram_select) 
                    2'd0: selected_word = r9_data; 2'd1: selected_word = r10_data; 
                    2'd2: selected_word = r11_data; 2'd3: selected_word = r12_data; 
                    default: selected_word = 16'h0000; 
                endcase
            end
			3'd2: begin
                unique case (bram_select) 
                    2'd0: selected_word = r5_data; 2'd1: selected_word = r6_data; 
                    2'd2: selected_word = r7_data; 2'd3: selected_word = r8_data; 
                    default: selected_word = 16'h0000; 
                endcase
            end
            // All odd sprites rely on r5-r8 outputs
            3'd3, 3'd4, 3'd5, 3'd6: begin
                unique case (bram_select) 
                    2'd0: selected_word = r1_data; 2'd1: selected_word = r2_data; 
                    2'd2: selected_word = r3_data; 2'd3: selected_word = r4_data; 
                    default: selected_word = 16'h0000; 
                endcase
            end
            default: selected_word = 16'h0000;
        endcase
    end
    
    // --- Synchronous Output ---
    logic [15:0] data_o_reg;
    
    always_ff @(posedge clk) begin
        data_o_reg <= selected_word;
    end
    
    assign data_o = data_o_reg;
    
endmodule

