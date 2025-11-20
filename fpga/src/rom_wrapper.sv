module rom_wrapper (
    input  logic clk,
    input  logic [2:0] sprite_sel_i,  // Sprite index (0-6)
    input  logic [9:0] word_addr_i,   // 10-bit word address (0-1023)
    output logic [15:0] data_o        // 16-bit word output (4 color pixels)
);

    /* internal logic declarations */
    
    // bram read
    logic [15:0] r1_data         ;
    logic [15:0] r2_data         ;
    logic [15:0] r3_data         ;
    logic [15:0] r4_data         ;
    logic [15:0] r5_data         ;
    logic [15:0] r6_data         ;
    logic [15:0] r7_data         ;
    logic [15:0] r8_data         ;
    logic [15:0] r9_data         ;
    logic [15:0] r10_data        ;
    logic [15:0] r11_data        ;
    logic [15:0] r12_data        ;
    logic [15:0] r13_data        ;
    logic [15:0] r14_data        ;
    logic [15:0] r15_data        ;
    logic [15:0] r16_data        ;
    logic [15:0] r17_data        ;
    logic [15:0] r18_data        ;
    logic [15:0] r19_data        ;
    logic [15:0] r20_data        ;
    logic [15:0] r21_data        ;
    logic [15:0] r22_data        ;
    logic [15:0] r23_data        ;
    logic [15:0] r24_data        ;
    logic [15:0] r25_data        ;
    logic [15:0] r26_data        ;
    logic [15:0] r27_data        ;
    logic [15:0] r28_data        ;

    logic [15:0] reduced_rdata   ;
    logic [15:0] data_o_reg      ;

    // 8 bit bram address given to each bram cell
    logic [7:0]  bram_addr       ;
    logic [1:0]  bram_sel        ;

    // read enables on bram cells
    logic        r1_en , r1_en_dly   ;
    logic        r2_en , r2_en_dly   ;
    logic        r3_en , r3_en_dly   ;
    logic        r4_en , r4_en_dly   ;
    logic        r5_en , r5_en_dly   ;
    logic        r6_en , r6_en_dly   ;
    logic        r7_en , r7_en_dly   ;
    logic        r8_en , r8_en_dly   ;
    logic        r9_en , r9_en_dly   ;
    logic        r10_en, r10_en_dly  ;
    logic        r11_en, r11_en_dly  ;
    logic        r12_en, r12_en_dly  ;
    logic        r13_en, r13_en_dly  ;
    logic        r14_en, r14_en_dly  ;
    logic        r15_en, r15_en_dly  ;
    logic        r16_en, r16_en_dly  ;
    logic        r17_en, r17_en_dly  ;
    logic        r18_en, r18_en_dly  ;
    logic        r19_en, r19_en_dly  ;
    logic        r20_en, r20_en_dly  ;
    logic        r21_en, r21_en_dly  ;
    logic        r22_en, r22_en_dly  ;
    logic        r23_en, r23_en_dly  ;
    logic        r24_en, r24_en_dly  ;
    logic        r25_en, r25_en_dly  ;
    logic        r26_en, r26_en_dly  ;
    logic        r27_en, r27_en_dly  ;
    logic        r28_en, r28_en_dly  ;

    assign bram_addr = word_addr_i[7:0];
    assign bram_sel  = word_addr_i[9:8];

    /* enable logic */
    assign r1_en  = sprite_sel_i == 3'd0 && bram_sel == 2'd0 ;
    assign r2_en  = sprite_sel_i == 3'd0 && bram_sel == 2'd1 ;
    assign r3_en  = sprite_sel_i == 3'd0 && bram_sel == 2'd2 ;
    assign r4_en  = sprite_sel_i == 3'd0 && bram_sel == 2'd3 ;

    assign r5_en  = sprite_sel_i == 3'd1 && bram_sel == 2'd0 ;
    assign r6_en  = sprite_sel_i == 3'd1 && bram_sel == 2'd1 ;
    assign r7_en  = sprite_sel_i == 3'd1 && bram_sel == 2'd2 ;
    assign r8_en  = sprite_sel_i == 3'd1 && bram_sel == 2'd3 ;

    assign r9_en  = sprite_sel_i == 3'd2 && bram_sel == 2'd0 ;
    assign r10_en = sprite_sel_i == 3'd2 && bram_sel == 2'd1 ;
    assign r11_en = sprite_sel_i == 3'd2 && bram_sel == 2'd2 ;
    assign r12_en = sprite_sel_i == 3'd2 && bram_sel == 2'd3 ;

    assign r13_en = sprite_sel_i == 3'd3 && bram_sel == 2'd0 ;
    assign r14_en = sprite_sel_i == 3'd3 && bram_sel == 2'd1 ;
    assign r15_en = sprite_sel_i == 3'd3 && bram_sel == 2'd2 ;
    assign r16_en = sprite_sel_i == 3'd3 && bram_sel == 2'd3 ;

    assign r17_en = sprite_sel_i == 3'd4 && bram_sel == 2'd0 ;
    assign r18_en = sprite_sel_i == 3'd4 && bram_sel == 2'd1 ;
    assign r19_en = sprite_sel_i == 3'd4 && bram_sel == 2'd2 ;
    assign r20_en = sprite_sel_i == 3'd4 && bram_sel == 2'd3 ;

    assign r21_en = sprite_sel_i == 3'd5 && bram_sel == 2'd0 ;
    assign r22_en = sprite_sel_i == 3'd5 && bram_sel == 2'd1 ;
    assign r23_en = sprite_sel_i == 3'd5 && bram_sel == 2'd2 ;
    assign r24_en = sprite_sel_i == 3'd5 && bram_sel == 2'd3 ;

    assign r25_en = sprite_sel_i == 3'd6 && bram_sel == 2'd0 ;
    assign r26_en = sprite_sel_i == 3'd6 && bram_sel == 2'd1 ;
    assign r27_en = sprite_sel_i == 3'd6 && bram_sel == 2'd2 ;
    assign r28_en = sprite_sel_i == 3'd6 && bram_sel == 2'd3 ;

    // Bank A (Even Sprites)
    r1  r1_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r1_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r1_data ) );
    r2  r2_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r2_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r2_data ) );
    r3  r3_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r3_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r3_data ) );
    r4  r4_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r4_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r4_data ) );
    
    // Bank B (Odd Sprites)
    r5  r5_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r5_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r5_data ) );
    r6  r6_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r6_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r6_data ) );
    r7  r7_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r7_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r7_data ) );
    r8  r8_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r8_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r8_data ) );
	
	// Bank C
    r9 r9_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r9_en),  .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r9_data ) );
    r10 r10_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r10_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r10_data) );
    r11 r11_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r11_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r11_data) );
    r12 r12_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r12_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r12_data) );
	
	// Bank D
    r13 r13_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r13_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r13_data) );
    r14 r14_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r14_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r14_data) );
    r15 r15_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r15_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r15_data) );
    r16 r16_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r16_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r16_data) );

    // // Bank E
    // r17 r17_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r17_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r17_data ) );
    // r18 r18_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r18_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r18_data ) );
    // r19 r19_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r19_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r19_data ) );
    // r20 r20_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r20_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r20_data ) );

    // // Bank F
    // r21  r21_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r21_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r21_data ) );
    // r22  r22_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r22_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r22_data ) );
    // r23  r23_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r23_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r23_data ) );
    // r24  r24_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r24_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r24_data ) );

    // // Bank G
    // r25  r25_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r25_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r25_data ) );
    // r26  r26_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r26_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r26_data ) );
    // r27  r27_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r27_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r27_data ) );
    // r28  r28_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r28_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r28_data ) );

    /* ram block enable delay */

    always_ff @(posedge clk) begin

        r1_en_dly  <= r1_en  ;
        r2_en_dly  <= r2_en  ;
        r3_en_dly  <= r3_en  ;
        r4_en_dly  <= r4_en  ;
        r5_en_dly  <= r5_en  ;
        r6_en_dly  <= r6_en  ;
        r7_en_dly  <= r7_en  ;
        r8_en_dly  <= r8_en  ;
        r9_en_dly  <= r9_en  ;
        r10_en_dly <= r10_en ;
        r11_en_dly <= r11_en ;
        r12_en_dly <= r12_en ;
        r13_en_dly <= r13_en ;
        r14_en_dly <= r14_en ;
        r15_en_dly <= r15_en ;
        r16_en_dly <= r16_en ;
        r17_en_dly <= r17_en ;
        r18_en_dly <= r18_en ;
        r19_en_dly <= r19_en ;
        r20_en_dly <= r20_en ;
        r21_en_dly <= r21_en ;
        r22_en_dly <= r22_en ;
        r23_en_dly <= r23_en ;
        r24_en_dly <= r24_en ;
        r25_en_dly <= r25_en ;
        r26_en_dly <= r26_en ;
        r27_en_dly <= r27_en ;
        r28_en_dly <= r28_en ;

    end
    
    // --- FIXED: Priority MUX instead of ORing gated ROM outputs ---
    always_comb begin
        unique case (1'b1)
            r1_en_dly:  reduced_rdata = r1_data;
            r2_en_dly:  reduced_rdata = r2_data;
            r3_en_dly:  reduced_rdata = r3_data;
            r4_en_dly:  reduced_rdata = r4_data;
            r5_en_dly:  reduced_rdata = r5_data;
            r6_en_dly:  reduced_rdata = r6_data;
            r7_en_dly:  reduced_rdata = r7_data;
            r8_en_dly:  reduced_rdata = r8_data;
            r9_en_dly:  reduced_rdata = r9_data;
            r10_en_dly: reduced_rdata = r10_data;
            r11_en_dly: reduced_rdata = r11_data;
            r12_en_dly: reduced_rdata = r12_data;
            r13_en_dly: reduced_rdata = r13_data;
            r14_en_dly: reduced_rdata = r14_data;
            r15_en_dly: reduced_rdata = r15_data;
            r16_en_dly: reduced_rdata = r16_data;
            // r17_en_dly: reduced_rdata = r17_data;
            // r18_en_dly: reduced_rdata = r18_data;
            // r19_en_dly: reduced_rdata = r19_data;
            // r20_en_dly: reduced_rdata = r20_data;
            // r21_en_dly: reduced_rdata = r21_data;
            // r22_en_dly: reduced_rdata = r22_data;
            // r23_en_dly: reduced_rdata = r23_data;
            // r24_en_dly: reduced_rdata = r24_data;
            // r25_en_dly: reduced_rdata = r25_data;
            // r26_en_dly: reduced_rdata = r26_data;
            // r27_en_dly: reduced_rdata = r27_data;
            // r28_en_dly: reduced_rdata = r28_data;
            default:    reduced_rdata = 16'h0000;
        endcase
    end

    // --- Synchronous Output ---    
    always_ff @(posedge clk) begin
        data_o_reg <= reduced_rdata;
    end
    
    assign data_o = data_o_reg;
    
endmodule


/*
module rom_wrapper (
    input  logic clk,
    input  logic [2:0] sprite_sel_i,  // Sprite index (0-6)
    input  logic [9:0] word_addr_i,   // 10-bit word address (0-1023)
    output logic [15:0] data_o        // 16-bit word output (4 color pixels)
);

    // internal logic declarations 
    
    // bram read
    logic [15:0] r1_data         ;
    logic [15:0] r2_data         ;
    logic [15:0] r3_data         ;
    logic [15:0] r4_data         ;
    logic [15:0] r5_data         ;
    logic [15:0] r6_data         ;
    logic [15:0] r7_data         ;
    logic [15:0] r8_data         ;
    logic [15:0] r9_data         ;
    logic [15:0] r10_data        ;
    logic [15:0] r11_data        ;
    logic [15:0] r12_data        ;
    logic [15:0] r13_data        ;
    logic [15:0] r14_data        ;
    logic [15:0] r15_data        ;
    logic [15:0] r16_data        ;
    logic [15:0] r17_data        ;
    logic [15:0] r18_data        ;
    logic [15:0] r19_data        ;
    logic [15:0] r20_data        ;
    logic [15:0] r21_data        ;
    logic [15:0] r22_data        ;
    logic [15:0] r23_data        ;
    logic [15:0] r24_data        ;
    logic [15:0] r25_data        ;
    logic [15:0] r26_data        ;
    logic [15:0] r27_data        ;
    logic [15:0] r28_data        ;

    logic [15:0] reduced_rdata   ;
    logic [15:0] data_o_reg      ;

    // 8 bit bram address given to each bram cell
    logic [7:0]  bram_addr       ;
    logic [1:0]  bram_sel        ;

    // read enables on bram cells
    logic        r1_en , r1_en_dly   ;
    logic        r2_en , r2_en_dly   ;
    logic        r3_en , r3_en_dly   ;
    logic        r4_en , r4_en_dly   ;
    logic        r5_en , r5_en_dly   ;
    logic        r6_en , r6_en_dly   ;
    logic        r7_en , r7_en_dly   ;
    logic        r8_en , r8_en_dly   ;
    logic        r9_en , r9_en_dly   ;
    logic        r10_en, r10_en_dly  ;
    logic        r11_en, r11_en_dly  ;
    logic        r12_en, r12_en_dly  ;
    logic        r13_en, r13_en_dly  ;
    logic        r14_en, r14_en_dly  ;
    logic        r15_en, r15_en_dly  ;
    logic        r16_en, r16_en_dly  ;
    logic        r17_en, r17_en_dly  ;
    logic        r18_en, r18_en_dly  ;
    logic        r19_en, r19_en_dly  ;
    logic        r20_en, r20_en_dly  ;
    logic        r21_en, r21_en_dly  ;
    logic        r22_en, r22_en_dly  ;
    logic        r23_en, r23_en_dly  ;
    logic        r24_en, r24_en_dly  ;
    logic        r25_en, r25_en_dly  ;
    logic        r26_en, r26_en_dly  ;
    logic        r27_en, r27_en_dly  ;
    logic        r28_en, r28_en_dly  ;


    assign bram_addr = word_addr_i[7:0];
    assign bram_sel  = word_addr_i[9:8];

    // enable logic
    assign r1_en  = sprite_sel_i == 3'd0 && bram_sel == 2'd0 ;
    assign r2_en  = sprite_sel_i == 3'd0 && bram_sel == 2'd1 ;
    assign r3_en  = sprite_sel_i == 3'd0 && bram_sel == 2'd2 ;
    assign r4_en  = sprite_sel_i == 3'd0 && bram_sel == 2'd3 ;

    assign r5_en  = sprite_sel_i == 3'd1 && bram_sel == 2'd0 ;
    assign r6_en  = sprite_sel_i == 3'd1 && bram_sel == 2'd1 ;
    assign r7_en  = sprite_sel_i == 3'd1 && bram_sel == 2'd2 ;
    assign r8_en  = sprite_sel_i == 3'd1 && bram_sel == 2'd3 ;

    assign r9_en  = sprite_sel_i == 3'd2 && bram_sel == 2'd0 ;
    assign r10_en = sprite_sel_i == 3'd2 && bram_sel == 2'd1 ;
    assign r11_en = sprite_sel_i == 3'd2 && bram_sel == 2'd2 ;
    assign r12_en = sprite_sel_i == 3'd2 && bram_sel == 2'd3 ;

    assign r13_en = sprite_sel_i == 3'd3 && bram_sel == 2'd0 ;
    assign r14_en = sprite_sel_i == 3'd3 && bram_sel == 2'd1 ;
    assign r15_en = sprite_sel_i == 3'd3 && bram_sel == 2'd2 ;
    assign r16_en = sprite_sel_i == 3'd3 && bram_sel == 2'd3 ;

    assign r17_en = sprite_sel_i == 3'd4 && bram_sel == 2'd0 ;
    assign r18_en = sprite_sel_i == 3'd4 && bram_sel == 2'd1 ;
    assign r19_en = sprite_sel_i == 3'd4 && bram_sel == 2'd2 ;
    assign r20_en = sprite_sel_i == 3'd4 && bram_sel == 2'd3 ;

    assign r21_en = sprite_sel_i == 3'd5 && bram_sel == 2'd0 ;
    assign r22_en = sprite_sel_i == 3'd5 && bram_sel == 2'd1 ;
    assign r23_en = sprite_sel_i == 3'd5 && bram_sel == 2'd2 ;
    assign r24_en = sprite_sel_i == 3'd5 && bram_sel == 2'd3 ;

    assign r25_en = sprite_sel_i == 3'd6 && bram_sel == 2'd0 ;
    assign r26_en = sprite_sel_i == 3'd6 && bram_sel == 2'd1 ;
    assign r27_en = sprite_sel_i == 3'd6 && bram_sel == 2'd2 ;
    assign r28_en = sprite_sel_i == 3'd6 && bram_sel == 2'd3 ;

    // Bank A (Even Sprites)
    r1  r1_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r1_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r1_data ) );
    r2  r2_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r2_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r2_data ) );
    r3  r3_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r3_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r3_data ) );
    r4  r4_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r4_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r4_data ) );
    
    // Bank B (Odd Sprites)
    r5  r5_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r5_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r5_data ) );
    r6  r6_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r6_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r6_data ) );
    r7  r7_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r7_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r7_data ) );
    r8  r8_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r8_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r8_data ) );
	
	// Bank C
    r9 r9_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r9_en),  .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r9_data ) );
    r10 r10_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r10_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r10_data) );
    r11 r11_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r11_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r11_data) );
    r12 r12_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r12_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r12_data) );
	
	// Bank D
    r13 r13_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r13_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r13_data) );
    r14 r14_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r14_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r14_data) );
    r15 r15_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r15_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r15_data) );
    r16 r16_ip ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r16_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r16_data) );

    // Bank E
    r17 r17_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r17_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r17_data ) );
    r18 r18_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r18_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r18_data ) );
    r19 r19_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r19_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r19_data ) );
    r20 r20_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r20_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r20_data ) );

    // Bank F
    r21  r21_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r21_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r21_data ) );
    r22  r22_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r22_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r22_data ) );
    r23  r23_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r23_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r23_data ) );
    r24  r24_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r24_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r24_data ) );

    // Bank G
    r25  r25_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r25_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r25_data ) );
    r26  r26_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r26_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r26_data ) );
    r27  r27_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r27_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r27_data ) );
    r28  r28_ip  ( .rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(r28_en), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r28_data ) );

    // ram block enable delay 

    always_ff @(posedge clk) begin

        r1_en_dly  <= r1_en  ;
        r2_en_dly  <= r2_en  ;
        r3_en_dly  <= r3_en  ;
        r4_en_dly  <= r4_en  ;
        r5_en_dly  <= r5_en  ;
        r6_en_dly  <= r6_en  ;
        r7_en_dly  <= r7_en  ;
        r8_en_dly  <= r8_en  ;
        r9_en_dly  <= r9_en  ;
        r10_en_dly <= r10_en ;
        r11_en_dly <= r11_en ;
        r12_en_dly <= r12_en ;
        r13_en_dly <= r13_en ;
        r14_en_dly <= r14_en ;
        r15_en_dly <= r15_en ;
        r16_en_dly <= r16_en ;
        r17_en_dly <= r17_en ;
        r18_en_dly <= r18_en ;
        r19_en_dly <= r19_en ;
        r20_en_dly <= r20_en ;
        r21_en_dly <= r21_en ;
        r22_en_dly <= r22_en ;
        r23_en_dly <= r23_en ;
        r24_en_dly <= r24_en ;
        r25_en_dly <= r25_en ;
        r26_en_dly <= r26_en ;
        r27_en_dly <= r27_en ;
        r28_en_dly <= r28_en ;

    end
    
    
    // assign reduced_rdata = r1_data | r2_data | r3_data | r4_data | r5_data | r6_data | r7_data | r8_data | r9_data | r10_data | r11_data | r12_data | r13_data | r14_data | r15_data | r16_data ;

    assign reduced_rdata = (r1_data & {16{r1_en_dly}}) | (r2_data & {16{r2_en_dly}}) | (r3_data & {16{r3_en_dly}}) | (r4_data & {16{r4_en_dly}}) | (r5_data & {16{r5_en_dly}}) | (r6_data & {16{r6_en_dly}}) | (r7_data & {16{r7_en_dly}}) | (r8_data & {16{r8_en_dly}}) | (r9_data & {16{r9_en_dly}}) | (r10_data & {16{r10_en_dly}}) | (r11_data & {16{r11_en_dly}}) | (r12_data & {16{r12_en_dly}}) | (r13_data & {16{r13_en_dly}}) | (r14_data & {16{r14_en_dly}}) | (r15_data & {16{r15_en_dly}}) | (r16_data & {16{r16_en_dly}}) |
                           (r17_data & {16{r17_en_dly}}) | (r18_data & {16{r18_en_dly}}) | (r19_data & {16{r19_en_dly}}) | (r20_data & {16{r20_en_dly}}) | (r21_data & {16{r21_en_dly}}) | (r22_data & {16{r22_en_dly}}) | (r23_data & {16{r23_en_dly}}) | (r24_data & {16{r24_en_dly}}) | (r25_data & {16{r25_en_dly}}) | (r26_data & {16{r26_en_dly}}) | (r27_data & {16{r27_en_dly}}) | (r28_data & {16{r28_en_dly}});

    // --- Synchronous Output ---    
    always_ff @(posedge clk) begin
        data_o_reg <= reduced_rdata;
    end
    
    assign data_o = data_o_reg;
    
endmodule
*/


/* 
// SADHVI'S LATEST CODE BELOW, EVERYTHING ABOVE IS COREY'S CRAP


module rom_wrapper (
    input  logic clk,
    input  logic [2:0] sprite_sel_i_i,  // Sprite index (0-6)
    input  logic [9:0] word_addr_i,   // 10-bit word address (0-1023)
    output logic [15:0] data_o        // 16-bit word output (4 color pixels)
);

    // --- Address Decoding ---
    (* keep = "true" *) logic [1:0] bram_select; // word_addr_i[9:8]: Selects which of the 4 columns (0 to 3)
    (* keep = "true" *) logic [7:0] bram_addr;   // word_addr_i[7:0]: 8-bit address within the BRAM (0-255)

    assign bram_select = word_addr_i[9:8];
    assign bram_addr   = word_addr_i[7:0];
	
	logic [1:0] bram_select_r;
	logic [2:0] sprite_sel_i_r;
	
	always_ff @(posedge clk) begin
		bram_select_r <= bram_select;
		sprite_sel_i_r <= sprite_sel_i_i;
	end
	

    // --- Bank Enable Logic ---
	logic bankA_enable, bankB_enable; 
	// LSB of sprite_sel_i_i determines parity: 0=Even (Bank A), 1=Odd (Bank B)
	assign bankA_enable = (sprite_sel_i_i[0] == 1'b0); // Sprites 0,2,4,6 
	assign bankB_enable = (sprite_sel_i_i[0] == 1'b1); // Sprites 1,3,5

    // --- Wires for 8 Physical ROM Outputs ---
    (* keep = "true" *) logic [15:0] r1_data, r2_data, r3_data, r4_data; // Bank A
    (* keep = "true" *) logic [15:0] r5_data, r6_data, r7_data, r8_data; // Bank B
	(* keep = "true" *) logic [15:0] r9_data, r10_data, r11_data, r12_data; // Bank B
	//(* keep = "true" *) logic [15:0] r13_data, r14_data, r15_data, r16_data; // Bank B

    // --- BRAM Output Wires (28 Total - Logical Outputs for Sprites) ---
    // NOTE: These wires are now essentially redundant, as they all point to the same 8 data lines.
    // They are kept here for clear mapping to the final MUX.
	
    // // Sprite 0 (Even) -> Uses Bank A (r1, r2, r3, r4)
    // logic [15:0] s0_bram0_data, s0_bram1_data, s0_bram2_data, s0_bram3_data;
    // assign s0_bram0_data = r1_data; assign s0_bram1_data = r2_data;
    // assign s0_bram2_data = r3_data; assign s0_bram3_data = r4_data;
    
    // // Sprite 1 (Odd) -> Uses Bank B (r5, r6, r7, r8)
    // logic [15:0] s1_bram0_data, s1_bram1_data, s1_bram2_data, s1_bram3_data;
    // assign s1_bram0_data = r5_data; assign s1_bram1_data = r6_data;
    // assign s1_bram2_data = r7_data; assign s1_bram3_data = r8_data;
    
    // // Sprite 2 (Even) -> Uses Bank A (r1, r2, r3, r4)
    // logic [15:0] s2_bram0_data, s2_bram1_data, s2_bram2_data, s2_bram3_data;
    // assign s2_bram0_data = r1_data; assign s2_bram1_data = r2_data;
    // assign s2_bram2_data = r3_data; assign s2_bram3_data = r4_data;
    
    // // Sprite 3 (Odd) -> Uses Bank B (r5, r6, r7, r8)
    // logic [15:0] s3_bram0_data, s3_bram1_data, s3_bram2_data, s3_bram3_data;
    // assign s3_bram0_data = r5_data; assign s3_bram1_data = r6_data;
    // assign s3_bram2_data = r7_data; assign s3_bram3_data = r8_data;
    
    // // Sprite 4 (Even) -> Uses Bank A (r1, r2, r3, r4)
    // logic [15:0] s4_bram0_data, s4_bram1_data, s4_bram2_data, s4_bram3_data;
    // assign s4_bram0_data = r1_data; assign s4_bram1_data = r2_data;
    // assign s4_bram2_data = r3_data; assign s4_bram3_data = r4_data;
    
    // // Sprite 5 (Odd) -> Uses Bank B (r5, r6, r7, r8)
    // logic [15:0] s5_bram0_data, s5_bram1_data, s5_bram2_data, s5_bram3_data;
    // assign s5_bram0_data = r5_data; assign s5_bram1_data = r6_data;
    // assign s5_bram2_data = r7_data; assign s5_bram3_data = r8_data;
    
    // // Sprite 6 (Even) -> Uses Bank A (r1, r2, r3, r4)
    // logic [15:0] s6_bram0_data, s6_bram1_data, s6_bram2_data, s6_bram3_data;
    // assign s6_bram0_data = r1_data; assign s6_bram1_data = r2_data;
    // assign s6_bram2_data = r3_data; assign s6_bram3_data = r4_data;
	


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
        case (sprite_sel_i_i)
            // All even sprites rely on r1-r4 outputs
            3'd0: begin
                case (bram_select) 
                    2'd0: selected_word = r13_data; 2'd1: selected_word = r14_data; 
                    2'd2: selected_word = r15_data; 2'd3: selected_word = r16_data; 
                    default: selected_word = 16'h0000; 
                endcase
            end
			3'd1: begin
                case (bram_select) 
                    2'd0: selected_word = r9_data; 2'd1: selected_word = r10_data; 
                    2'd2: selected_word = r11_data; 2'd3: selected_word = r12_data; 
                    default: selected_word = 16'h0000; 
                endcase
            end
			3'd2: begin
                case (bram_select) 
                    2'd0: selected_word = r5_data; 2'd1: selected_word = r6_data; 
                    2'd2: selected_word = r7_data; 2'd3: selected_word = r8_data; 
                    default: selected_word = 16'h0000; 
                endcase
            end
            // All odd sprites rely on r5-r8 outputs
            3'd3, 3'd4, 3'd5, 3'd6: begin
                case (bram_select) 
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

*/
