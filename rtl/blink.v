`timescale 1ns / 1ps
module blink (
    input wire clk_50mhz,
    output wire [1:0] led
);
  // FPGA configuration initializes these registers; hold the MMCM in reset.
  reg [3:0] startup = 4'b0;
  always @(posedge clk_50mhz) if (!(&startup)) startup <= startup + 1'b1;

  wire clk_200mhz;
  wire locked;
  clk_wiz_0 clocks (
      .clk_in1(clk_50mhz),
      .clk_out1(clk_200mhz),
      .reset(!(&startup)),
      .locked(locked)
  );

  // Asynchronous assertion, synchronous release after MMCM lock.
  (* ASYNC_REG = "TRUE" *) reg [1:0] ready = 2'b00;
  always @(posedge clk_200mhz or negedge locked)
    if (!locked) ready <= 2'b00;
    else ready <= {ready[0], 1'b1};

  reg [26:0] count = 27'd0;
  reg phase = 1'b0;
  // ===== LED 설정 =====
  localparam integer CLK_HZ = 200_000_000;
  localparam integer BLINK_MS = 100;

  // ===== 카운터 =====
  localparam integer TICKS = CLK_HZ / 1000 * BLINK_MS;
  localparam integer COUNT_BITS = $clog2(TICKS);

  

  always @(posedge clk_200mhz) begin
    if (!ready[1]) begin
      count <= 0;
      phase <= 1'b0;
    end else if (count == TICKS - 1) begin
      count <= 0;
      phase <= ~phase;
    end else begin
      count <= count + 1'b1;
    end
  end

  assign led = {~phase, phase};

endmodule
