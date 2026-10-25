SHELL := /bin/bash
VIVADO ?= /opt/Xilinx/2025.2/Vivado/bin/vivado
VIVADO_HOME := $(abspath $(dir $(VIVADO))/..)
ROOT := $(CURDIR)

# FPGA Configuration
FPGA_PART := xc7a100tfgg676
JTAG_CABLE := digilent_hs3
BITSTREAM := $(ROOT)/build/blink.bit

.PHONY: build program flash run timing utilization sim wave clean

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
# RTL Simulation
# ==========================================
sim:
	mkdir -p build/sim
	cd build/sim && \
		source "$(VIVADO_HOME)/settings64.sh" && \
		xvlog -sv \
		"$(ROOT)/rtl/blink_counter.sv" \
		"$(ROOT)/tb/tb_blink_counter.sv" && \
		xelab -debug all \
		tb_blink_counter \
		-s blink_sim && \
		xsim blink_sim \
		-tclbatch "$(ROOT)/scripts/sim.tcl"
# ==========================================
# View Waveform
# ==========================================
wave:
	@test -f build/sim/wave.vcd || { echo 'Run make sim first.'; exit 1; }
	surfer build/sim/wave.vcd
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
# FSM + Pipeline Simulation
.PHONY: sim-fsm wave-fsm

sim-fsm:
	mkdir -p build/sim_fsm
	cd build/sim_fsm && \
		source "$(VIVADO_HOME)/settings64.sh" && \
		xvlog -sv \
			"$(ROOT)/rtl/fsm_pipeline.sv" \
			"$(ROOT)/tb/tb_fsm_pipeline.sv" && \
		xelab -debug all tb_fsm_pipeline -s fsm_pipeline_sim && \
		xsim fsm_pipeline_sim \
			-tclbatch "$(ROOT)/scripts/sim_fsm.tcl"

wave-fsm:
	@test -f build/sim_fsm/fsm_pipeline.vcd || { echo 'Run make sim-fsm first.'; exit 1; }
	surfer build/sim_fsm/fsm_pipeline.vcd

	.PHONY: sim-pipeline4 wave-pipeline4

sim-pipeline4:
	mkdir -p build/sim_pipeline4
	cd build/sim_pipeline4 && \
		source "$(VIVADO_HOME)/settings64.sh" && \
		xvlog -sv \
			"$(ROOT)/rtl/pipeline4.sv" \
			"$(ROOT)/tb/tb_pipeline4.sv" && \
		xelab -debug all tb_pipeline4 \
			-s pipeline4_sim && \
		xsim pipeline4_sim \
			-tclbatch "$(ROOT)/scripts/sim_pipeline4.tcl"

wave-pipeline4:
	surfer build/sim_pipeline4/pipeline4.vcd
