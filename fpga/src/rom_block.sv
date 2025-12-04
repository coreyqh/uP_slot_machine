// E155, Various forms of ROM and RAM blocks with different cycle latency for use - ROM loads in a file

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 12/04/2025

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
    
	// address
    logic [DATA_WIDTH-1:0] single_bram1 [0:TOTAL_WORDS-1];
    
	// load in the file
    initial begin 
        $readmemh(text_file, single_bram1);
    end

	// just a combinational LUT read
    assign dout = single_bram1[address]; 
    
endmodule


module rom_sync #(
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
    
	// ROM storage for the data
    reg [DATA_WIDTH-1:0] single_bram1 [0:TOTAL_WORDS-1];
	// ROM address (EBR)
    logic [DATA_WIDTH-1:0] pre_dout;

	// load data from the file
    initial begin 
        $readmemh(text_file, single_bram1);
    end
	
	// two cycle latency registered output ROM read
     always_ff @(posedge clk) begin 
         pre_dout <= single_bram1[address]; 
         dout     <= pre_dout;
     end


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
    
	// one cycle latency wrapper around combinational ROM to try an not force EBRs
    rom_block2 #(.text_file(text_file)) 
        r21_inst (.clk(clk), .address(address), .dout(dout1)); 
    
    always_ff @(posedge clk) begin 
         dout <= dout1; 
    end
endmodule

module spram #(
    parameter ADDR_WIDTH = 14,
    parameter DATA_WIDTH = 16
)(
    input  logic                    clk,
    input  logic                    wr_en,
    input  logic [ADDR_WIDTH-1:0]   addr,
    input  logic [DATA_WIDTH-1:0]   din,
    output logic [DATA_WIDTH-1:0]   dout
);
    localparam TOTAL_WORDS = 2**ADDR_WIDTH;
    
    logic [DATA_WIDTH-1:0] memory [0:TOTAL_WORDS-1];
    
    // single port RAM with 1-cycle read latency
    always_ff @(posedge clk) begin
        if (wr_en) begin
            memory[addr] <= din;
        end
        dout <= memory[addr];
    end

endmodule
