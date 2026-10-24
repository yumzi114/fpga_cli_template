SHELL := /bin/bash
VIVADO ?= /opt/Xilinx/2025.2/Vivado/bin/vivado
ROOT := $(CURDIR)

.PHONY: build flash run timing utilization clean
build:
	mkdir -p build
	cd build && "$(VIVADO)" -mode batch -notrace -source "$(ROOT)/scripts/build.tcl" -log build.log -journal build.jou

flash:
	mkdir -p build
	cd build && "$(VIVADO)" -mode batch -notrace -source "$(ROOT)/scripts/program.tcl" -log program.log -journal program.jou

run: build
	$(MAKE) flash

timing:
	@test -f build/timing_summary.rpt || { echo 'Run make build first.'; exit 1; }
	cat build/timing_summary.rpt

utilization:
	@test -f build/utilization.rpt || { echo 'Run make build first.'; exit 1; }
	cat build/utilization.rpt

clean:
	rm -rf build
