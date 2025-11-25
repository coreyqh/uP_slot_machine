module rom_wrapper (
    input  logic clk,
	input logic reset_n,
    input  logic [2:0] sprite_sel_i,
    input  logic [9:0] word_addr_i,
    output logic [15:0] data_o
);

    logic [7:0]  bram_addr;
    logic [1:0]  bram_sel;
    
    assign bram_addr = word_addr_i[7:0];
    assign bram_sel  = word_addr_i[9:8];

    // All ROM outputs
    logic [15:0] r1_data, r2_data, r3_data, r4_data;
    logic [15:0] r5_data, r6_data, r7_data, r8_data;
    logic [15:0] r9_data, r10_data, r11_data, r12_data;
    logic [15:0] r13_data, r14_data, r15_data, r16_data;
    logic [15:0] r17_data, r18_data, r19_data, r20_data;
    logic [15:0] r21_data, r22_data, r23_data, r24_data;
    logic [15:0] r25_data, r26_data, r27_data, r28_data;

    logic [27:0] rom_en, rom_en_dly, rom_en_dly2;

    // Generate enables
    assign rom_en[0]  = (sprite_sel_i == 3'd0) && (bram_sel == 2'd0);
    assign rom_en[1]  = (sprite_sel_i == 3'd0) && (bram_sel == 2'd1);
    assign rom_en[2]  = (sprite_sel_i == 3'd0) && (bram_sel == 2'd2);
    assign rom_en[3]  = (sprite_sel_i == 3'd0) && (bram_sel == 2'd3);
    
    assign rom_en[4]  = (sprite_sel_i == 3'd1) && (bram_sel == 2'd0);
    assign rom_en[5]  = (sprite_sel_i == 3'd1) && (bram_sel == 2'd1);
    assign rom_en[6]  = (sprite_sel_i == 3'd1) && (bram_sel == 2'd2);
    assign rom_en[7]  = (sprite_sel_i == 3'd1) && (bram_sel == 2'd3);
    
    assign rom_en[8]  = (sprite_sel_i == 3'd2) && (bram_sel == 2'd0);
    assign rom_en[9]  = (sprite_sel_i == 3'd2) && (bram_sel == 2'd1);
    assign rom_en[10] = (sprite_sel_i == 3'd2) && (bram_sel == 2'd2);
    assign rom_en[11] = (sprite_sel_i == 3'd2) && (bram_sel == 2'd3);
    
    assign rom_en[12] = (sprite_sel_i == 3'd3) && (bram_sel == 2'd0);
    assign rom_en[13] = (sprite_sel_i == 3'd3) && (bram_sel == 2'd1);
    assign rom_en[14] = (sprite_sel_i == 3'd3) && (bram_sel == 2'd2);
    assign rom_en[15] = (sprite_sel_i == 3'd3) && (bram_sel == 2'd3);
    
    assign rom_en[16] = (sprite_sel_i == 3'd4) && (bram_sel == 2'd0);
    assign rom_en[17] = (sprite_sel_i == 3'd4) && (bram_sel == 2'd1);
    assign rom_en[18] = (sprite_sel_i == 3'd4) && (bram_sel == 2'd2);
    assign rom_en[19] = (sprite_sel_i == 3'd4) && (bram_sel == 2'd3);
    
    assign rom_en[20] = (sprite_sel_i == 3'd5) && (bram_sel == 2'd0);
    assign rom_en[21] = (sprite_sel_i == 3'd5) && (bram_sel == 2'd1);
    assign rom_en[22] = (sprite_sel_i == 3'd5) && (bram_sel == 2'd2);
    assign rom_en[23] = (sprite_sel_i == 3'd5) && (bram_sel == 2'd3);
    
    assign rom_en[24] = (sprite_sel_i == 3'd6) && (bram_sel == 2'd0);
    assign rom_en[25] = (sprite_sel_i == 3'd6) && (bram_sel == 2'd1);
    assign rom_en[26] = (sprite_sel_i == 3'd6) && (bram_sel == 2'd2);
    assign rom_en[27] = (sprite_sel_i == 3'd6) && (bram_sel == 2'd3);

    // EBR-based sprites (0-3)
    //r1  r1_ip  (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r1_data));
    //r2  r2_ip  (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r2_data));
    //r3  r3_ip  (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r3_data));
    //r4  r4_ip  (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r4_data));
    
    //r5  r5_ip  (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r5_data));
    //r6  r6_ip  (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r6_data));
    //r7  r7_ip  (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r7_data));
    //r8  r8_ip  (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r8_data));
    
    //r9  r9_ip  (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r9_data));
    //r10 r10_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r10_data));
    //r11 r11_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r11_data));
    //r12 r12_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r12_data));
    
    //r13 r13_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r13_data));
    //r14 r14_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r14_data));
    //r15 r15_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r15_data));
    //r16 r16_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r16_data));









	rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom0.mem"), .UNIQUE_ID(1)) 
        r1_inst (.clk(clk), .address(bram_addr), .dout(r1_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom1.mem"), .UNIQUE_ID(2)) 
        r2_inst (.clk(clk), .address(bram_addr), .dout(r2_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom2.mem"), .UNIQUE_ID(3)) 
        r3_inst (.clk(clk), .address(bram_addr), .dout(r3_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom3.mem"), .UNIQUE_ID(4)) 
        r4_inst (.clk(clk), .address(bram_addr), .dout(r4_data));

	rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom8.mem"), .UNIQUE_ID(5)) 
        r5_inst (.clk(clk), .address(bram_addr), .dout(r5_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom9.mem"), .UNIQUE_ID(6)) 
        r6_inst (.clk(clk), .address(bram_addr), .dout(r6_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom10.mem"), .UNIQUE_ID(7)) 
        r7_inst (.clk(clk), .address(bram_addr), .dout(r7_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom11.mem"), .UNIQUE_ID(8)) 
        r8_inst (.clk(clk), .address(bram_addr), .dout(r8_data));

	rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom12.mem"), .UNIQUE_ID(9)) 
        r9_inst (.clk(clk), .address(bram_addr), .dout(r9_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom13.mem"), .UNIQUE_ID(10)) 
        r10_inst (.clk(clk), .address(bram_addr), .dout(r10_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom14.mem"), .UNIQUE_ID(11)) 
        r11_inst (.clk(clk), .address(bram_addr), .dout(r11_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom15.mem"), .UNIQUE_ID(12)) 
        r12_inst (.clk(clk), .address(bram_addr), .dout(r12_data));

	rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom16.mem"), .UNIQUE_ID(13)) 
        r13_inst (.clk(clk), .address(bram_addr), .dout(r13_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom17.mem"), .UNIQUE_ID(14)) 
        r14_inst (.clk(clk), .address(bram_addr), .dout(r14_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom18.mem"), .UNIQUE_ID(15)) 
        r15_inst (.clk(clk), .address(bram_addr), .dout(r15_data));
    rom_sync #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom19.mem"), .UNIQUE_ID(16)) 
        r16_inst (.clk(clk), .address(bram_addr), .dout(r16_data));

    // r17 r17_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r17_data));
    // r18 r18_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r18_data));
    // r19 r19_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r19_data));
    // r20 r20_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r20_data));

    // r21 r21_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r21_data));
    // r22 r22_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r22_data));
    // r23 r23_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r23_data));
    // r24 r24_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r24_data));

    // r25 r25_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r25_data));
    // r26 r26_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r26_data));
    // r27 r27_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r27_data));
    // r28 r28_ip (.rd_clk_i(clk), .rst_i(1'b0), .rd_en_i(1'b1), .rd_clk_en_i(1'b1), .rd_addr_i(bram_addr), .rd_data_o(r28_data));

    // Combinational sprites (4-6) - KEEP AS COMBINATIONAL, DON'T REGISTER OUTPUT
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom20.mem"), .UNIQUE_ID(17)) 
        r17_inst (.clk(clk), .address(bram_addr), .dout(r17_data));
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom21.mem"), .UNIQUE_ID(18)) 
        r18_inst (.clk(clk), .address(bram_addr), .dout(r18_data));
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom22.mem"), .UNIQUE_ID(19)) 
        r19_inst (.clk(clk), .address(bram_addr), .dout(r19_data));
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom23.mem"), .UNIQUE_ID(20)) 
        r20_inst (.clk(clk), .address(bram_addr), .dout(r20_data));
    
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom24.mem"), .UNIQUE_ID(21)) 
        r21_inst (.clk(clk), .address(bram_addr), .dout(r21_data));
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom25.mem"), .UNIQUE_ID(22)) 
        r22_inst (.clk(clk), .address(bram_addr), .dout(r22_data));
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom26.mem"), .UNIQUE_ID(23)) 
        r23_inst (.clk(clk), .address(bram_addr), .dout(r23_data));
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom27.mem"), .UNIQUE_ID(24)) 
        r24_inst (.clk(clk), .address(bram_addr), .dout(r24_data));
    
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom4.mem"), .UNIQUE_ID(25)) 
        r25_inst (.clk(clk), .address(bram_addr), .dout(r25_data));
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom5.mem"), .UNIQUE_ID(26)) 
        r26_inst (.clk(clk), .address(bram_addr), .dout(r26_data));
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom6.mem"), .UNIQUE_ID(27)) 
        r27_inst (.clk(clk), .address(bram_addr), .dout(r27_data));
    rom_block2 #(.text_file("C:/Users/sanarayanan/my_designs/Slot_Machine_Final/source/impl_1/sprite_rom7.mem"), .UNIQUE_ID(28)) 
        r28_inst (.clk(clk), .address(bram_addr), .dout(r28_data));

    // Delay enables
    always_ff @(posedge clk, negedge reset_n) begin
		if (!reset_n) begin
			rom_en_dly <= 0;
			rom_en_dly2 <= 0;
		end else begin
			rom_en_dly <= rom_en;
			rom_en_dly2 <= rom_en_dly;
		end
    end
    
    // ===== KEY FIX: HIERARCHICAL MUX TO REDUCE FANOUT =====
    // First level: Mux within each sprite (4 BRAMs per sprite)
    logic [15:0] sprite0_data, sprite1_data, sprite2_data, sprite3_data;
    logic [15:0] sprite4_data, sprite5_data, sprite6_data;
    
    // Sprite 0
    always_comb begin
        case (1'b1)
            rom_en_dly2[0]: sprite0_data = r1_data;
            rom_en_dly2[1]: sprite0_data = r2_data;
            rom_en_dly2[2]: sprite0_data = r3_data;
            rom_en_dly2[3]: sprite0_data = r4_data;
            default: sprite0_data = 16'h0000;
        endcase
    end
    
    // Sprite 1
    always_comb begin
        case (1'b1)
            rom_en_dly2[4]: sprite1_data = r5_data;
            rom_en_dly2[5]: sprite1_data = r6_data;
            rom_en_dly2[6]: sprite1_data = r7_data;
            rom_en_dly2[7]: sprite1_data = r8_data;
            default: sprite1_data = 16'h0000;
        endcase
    end
    
    // Sprite 2
    always_comb begin
        case (1'b1)
            rom_en_dly2[8]:  sprite2_data = r9_data;
            rom_en_dly2[9]:  sprite2_data = r10_data;
            rom_en_dly2[10]: sprite2_data = r11_data;
            rom_en_dly2[11]: sprite2_data = r12_data;
            default: sprite2_data = 16'h0000;
        endcase
    end
    
    // Sprite 3
    always_comb begin
        case (1'b1)
            rom_en_dly2[12]: sprite3_data = r13_data;
            rom_en_dly2[13]: sprite3_data = r14_data;
            rom_en_dly2[14]: sprite3_data = r15_data;
            rom_en_dly2[15]: sprite3_data = r16_data;
            default: sprite3_data = 16'h0000;
        endcase
    end
    
    // Sprite 4
    always_comb begin
        case (1'b1)
            rom_en[16]: sprite4_data = r17_data;
            rom_en[17]: sprite4_data = r18_data;
            rom_en[18]: sprite4_data = r19_data;
            rom_en[19]: sprite4_data = r20_data;
            default: sprite4_data = 16'h0000;
        endcase
    end
    
    // Sprite 5
    always_comb begin
        case (1'b1)
            rom_en[20]: sprite5_data = r21_data;
            rom_en[21]: sprite5_data = r22_data;
            rom_en[22]: sprite5_data = r23_data;
            rom_en[23]: sprite5_data = r24_data;
            default: sprite5_data = 16'h0000;
        endcase
    end
    
    // Sprite 6
    always_comb begin
        case (1'b1)
            rom_en[24]: sprite6_data = r25_data;
            rom_en[25]: sprite6_data = r26_data;
            rom_en[26]: sprite6_data = r27_data;
            rom_en[27]: sprite6_data = r28_data;
            default: sprite6_data = 16'h0000;
        endcase
    end
    
    // Second level: Register sprite outputs to break timing path
    logic [15:0] sprite0_data_r, sprite1_data_r, sprite2_data_r, sprite3_data_r;
    logic [15:0] sprite4_data_r, sprite5_data_r, sprite6_data_r;
	logic [15:0] sprite4_data_stage1, sprite5_data_stage1, sprite6_data_stage1;
	logic [15:0] sprite4_data_stage2, sprite5_data_stage2, sprite6_data_stage2;
    logic [2:0] sprite_sel_r, sprite_sel_r2, sprite_sel_r3;
	
	 always_ff @(posedge clk, negedge reset_n) begin
		 if (!reset_n) begin
			sprite4_data_stage1 <= 16'd0;
			sprite5_data_stage1 <= 16'd0;
			sprite6_data_stage1 <= 16'd0;
			
			sprite4_data_stage2 <= 16'd0;
			sprite5_data_stage2 <= 16'd0;
			sprite6_data_stage2 <= 16'd0;
		end else begin
			sprite4_data_stage1 <= sprite4_data;
			sprite5_data_stage1 <= sprite5_data;
			sprite6_data_stage1 <= sprite6_data;
			
			sprite4_data_stage2 <= sprite4_data_stage1;
			sprite5_data_stage2 <= sprite5_data_stage1;
			sprite6_data_stage2 <= sprite6_data_stage1;
		end
	end
    
    always_ff @(posedge clk, negedge reset_n) begin
		if (!reset_n) begin
			sprite0_data_r <= 16'd0;
			sprite1_data_r <= 16'd0;
			sprite2_data_r <= 16'd0;
			sprite3_data_r <= 16'd0;
			sprite4_data_r <= 16'd0;
			sprite5_data_r <= 16'd0;
			sprite6_data_r <= 16'd0;
			sprite_sel_r <= 16'd0;
			sprite_sel_r2 <= 16'd0;
			sprite_sel_r3 <= 16'd0;
		end else begin
			sprite0_data_r <= sprite0_data;
			sprite1_data_r <= sprite1_data;
			sprite2_data_r <= sprite2_data;
			sprite3_data_r <= sprite3_data;
			sprite4_data_r <= sprite4_data_stage2;
			sprite5_data_r <= sprite5_data_stage2;
			sprite6_data_r <= sprite6_data_stage2;
			sprite_sel_r <= sprite_sel_i;
			sprite_sel_r2 <= sprite_sel_r;
			sprite_sel_r3 <= sprite_sel_r2;
		end
    end
    
    // Third level: Final sprite selection (small 7:1 mux)
	/*
    logic [15:0] final_data;
	 always_ff @(posedge clk) begin
        case (sprite_sel_r)
            3'd0: data_o <= sprite0_data_r;
            3'd1: data_o <= sprite1_data_r;
            3'd2: data_o <= sprite2_data_r;
            3'd3: data_o <= sprite3_data_r;
            3'd4: data_o <= sprite4_data_r;
            3'd5: data_o <= sprite5_data_r;
            3'd6: data_o <= sprite6_data_r;
            default: data_o <= 16'h0000;
        endcase
    end
	*/
	
	
    always_comb begin
        case (sprite_sel_r3)
            3'd0: data_o = sprite0_data_r;
            3'd1: data_o = sprite1_data_r;
            3'd2: data_o = sprite2_data_r;
            3'd3: data_o = sprite3_data_r;
            3'd4: data_o = sprite4_data_r;
            3'd5: data_o = sprite5_data_r;
            3'd6: data_o = sprite6_data_r;
            default: data_o = 16'h0000;
        endcase
    end
    
	/*
    // Final output register
    logic [15:0] data_o_reg;
    always_ff @(posedge clk) begin
        data_o_reg <= final_data;
    end
	*/
    
    // assign data_o = data_o_reg;
    
endmodule

