# FSM + 2-stage pipeline example

Copy `rtl/fsm_pipeline.sv`, `tb/tb_fsm_pipeline.sv`, and
`scripts/sim_fsm.tcl` into the matching directories of `fpga_format_test`.

Append this target to the existing Makefile (recipe lines must begin with TAB):

```makefile
.PHONY: sim-fsm wave-fsm

sim-fsm:
	mkdir -p build/sim_fsm
	cd build/sim_fsm && \
		source "$(VIVADO_HOME)/settings64.sh" && \
		xvlog -sv "$(ROOT)/rtl/fsm_pipeline.sv" "$(ROOT)/tb/tb_fsm_pipeline.sv" && \
		xelab -debug all tb_fsm_pipeline -s fsm_pipeline_sim && \
		xsim fsm_pipeline_sim -tclbatch "$(ROOT)/scripts/sim_fsm.tcl"

wave-fsm:
	@test -f build/sim_fsm/fsm_pipeline.vcd || { echo 'Run make sim-fsm first.'; exit 1; }
	surfer build/sim_fsm/fsm_pipeline.vcd
```

Run `make sim-fsm` then `make wave-fsm` (or `gtkwave build/sim_fsm/fsm_pipeline.vcd`).

Observe `state`, `source_data`, `source_valid`, `stage1_data`, `stage1_valid`,
`result`, and `result_valid`. The FSM emits x=0..7 on successive cycles.
The first pipeline register computes x+3, the second computes (x+3)*2.
Each valid token advances one stage per clock; after filling, results appear
every clock. The testbench checks values 6,8,10,12,14,16,18,20.

This is an RTL simulation example only. It does not change the existing FPGA
blink top-level, XDC, build/flash targets, or board wiring.
