SHELL := /bin/bash

VIVADO ?= /opt/Xilinx/2025.2/Vivado/bin/vivado
ROOT := $(CURDIR)

# FPGA Configuration
FPGA_PART := xc7a100tfgg676
JTAG_CABLE := digilent_hs3
BITSTREAM := $(ROOT)/build/blink.bit

.PHONY: build program flash run timing utilization clean

# ==========================================
# Build Bitstream
# ==========================================
build:
	mkdir -p build
	cd build && "$(VIVADO)" -mode batch -notrace \
		-source "$(ROOT)/scripts/build.tcl" \
		-log build.log \
		-journal build.jou

# ==========================================
# Program FPGA SRAM (Volatile)
# ==========================================
program:
	mkdir -p build
	cd build && "$(VIVADO)" -mode batch -notrace \
		-source "$(ROOT)/scripts/program.tcl" \
		-log program.log \
		-journal program.jou

# ==========================================
# Program SPI Flash (Persistent)
# ==========================================
flash:
	@test -f "$(BITSTREAM)" || { echo 'Run make build first.'; exit 1; }
	openFPGALoader \
		-c $(JTAG_CABLE) \
		--fpga-part $(FPGA_PART) \
		-f "$(BITSTREAM)"

# ==========================================
# Build + Program FPGA SRAM
# ==========================================
run: build
	$(MAKE) program

# ==========================================
# Reports
# ==========================================
timing:
	@test -f build/timing_summary.rpt || { echo 'Run make build first.'; exit 1; }
	cat build/timing_summary.rpt

utilization:
	@test -f build/utilization.rpt || { echo 'Run make build first.'; exit 1; }
	cat build/utilization.rpt

# ==========================================
# Clean
# ==========================================
clean:
	rm -rf build