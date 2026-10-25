
`timescale 1ns / 1ps
`default_nettype none

module pipeline_gpio (
    input  wire       clk_50mhz,
    output wire [3:0] gpio
);

  // ==========================================
  // Clock Enable: 50MHz -> 10MHz
  // 5 clock cycles = 100ns
  // ==========================================

  logic [2:0] divider = 0;
  logic tick = 0;

  always_ff @(posedge clk_50mhz) begin
    if (divider == 4) begin
      divider <= 0;
      tick <= 1;
    end else begin
      divider <= divider + 1'b1;
      tick <= 0;
    end
  end

  // ==========================================
  // Input: 4 valid data, 4 idle cycles
  // ==========================================

  logic [2:0] slot = 0;
  logic [7:0] input_data = 0;

  // ==========================================
  // Pipeline Registers
  // ==========================================

  logic [7:0] stage1_data = 0;
  logic [7:0] stage2_data = 0;
  logic [7:0] stage3_data = 0;
  logic [7:0] stage4_data = 0;

  logic [3:0] valid = 0;

  // ==========================================
  // 4-Stage Pipeline
  // ==========================================

  always_ff @(posedge clk_50mhz) begin
    if (tick) begin

      // Input generator
      slot <= slot + 1'b1;

      if (slot < 4) input_data <= input_data + 1'b1;

      // Stage 1: +1
      stage1_data <= input_data + 8'd1;

      // Stage 2: x2
      stage2_data <= stage1_data << 1;

      // Stage 3: +3
      stage3_data <= stage2_data + 8'd3;

      // Stage 4: XOR
      stage4_data <= stage3_data ^ 8'h55;

      // Valid pipeline
      valid[0] <= (slot < 4);
      valid[1] <= valid[0];
      valid[2] <= valid[1];
      valid[3] <= valid[2];

    end
  end

  // ==========================================
  // Oscilloscope Outputs
  // CH1~CH3: Pipeline Data
  // CH4: 10MHz Sampling Clock
  // ==========================================

  assign gpio[0] = valid[0] & stage1_data[0];
  assign gpio[1] = valid[1] & stage2_data[1];
  assign gpio[2] = valid[2] & stage3_data[1];

  // 50MHz / 5 = 10MHz
  // 100ns period, 40ns HIGH / 60ns LOW
  assign gpio[3] = (divider < 2);

endmodule

`default_nettype wire
