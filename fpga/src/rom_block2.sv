module rom_block2 #(
    parameter string text_file,
    parameter int UNIQUE_ID = 0  // Forces separate synthesis for each instance
) (
    input  logic clk,
    input  logic [7:0] address,
    output logic [15:0] dout
);
    localparam SPRITE_WIDTH = 64;
    localparam DATA_WIDTH = 16;
    localparam TOTAL_WORDS = 256;
    localparam ADDRESS_WIDTH = 8;
    
    logic [DATA_WIDTH-1:0] single_bram1 [0:TOTAL_WORDS-1];
    
    initial begin 
        $readmemh(text_file, single_bram1);
    end

    assign dout = single_bram1[address]; 
    
    // always_ff @(posedge clk) begin 
    //     dout <= single_bram1[address]; 
    // end
endmodule


module rom_block3 #(
    parameter string text_file,
    parameter int UNIQUE_ID = 0  // Forces separate synthesis for each instance
) (
    input  logic clk,
    input  logic [7:0] address,
    output logic [15:0] dout
);
	logic [15:0] dout1;
    
    rom_block2 #(.text_file(text_file)) 
        r21_inst (.clk(clk), .address(address), .dout(dout1)); 
    
    always_ff @(posedge clk) begin 
         dout <= dout1; 
    end
endmodule
