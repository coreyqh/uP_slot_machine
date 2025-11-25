
TOP_MODULE = tb

SRC_DIR = ../src/

SVA_DIR = ./sva/

TB_DIR = ./sim/

VERILOG_SOURCES = $(wildcard $(SRC_DIR)/*.sv) $(wildcard $(SRC_DIR)/*.v) 

VERILATOR_FLAGS = --binary --exe --build -j 0 -Wall --trace-vcd --Wno-fatal -I$(SVA_DIR)/

OBJ_DIR = obj_dir

lint:
	verilator --lint-only $(VERILOG_SOURCES)

prove_vga:
	cd formal && sby -f vga_formal.sby proof

sim_vga:
	rm -rf $(OBJ_DIR)
	verilator $(VERILATOR_FLAGS) --top-module $(TOP_MODULE) $(TB_DIR)/vga_ctrl_tb.sv $(VERILOG_SOURCES)
	./$(OBJ_DIR)/V$(TOP_MODULE)
	# gtkwave waveform.vcd

sim_spi:
	rm -rf $(OBJ_DIR)
	verilator $(VERILATOR_FLAGS) --top-module $(TOP_MODULE) $(TB_DIR)/spi_tb.sv $(VERILOG_SOURCES)
	./$(OBJ_DIR)/V$(TOP_MODULE)
	# gtkwave waveform.vcd

prove_mem:
	cd formal && sby -f vga_formal.sby proof

sim_mem:
	rm -rf $(OBJ_DIR)
	verilator $(VERILATOR_FLAGS) --top-module $(TOP_MODULE) $(TB_DIR)/mem_ctrl_tb.sv $(VERILOG_SOURCES)
	./$(OBJ_DIR)/V$(TOP_MODULE)
	# gtkwave waveform.vcd

clean:
	rm -rf $(OBJ_DIR)
	rm -f waveform.vcd
	rm -f *.o