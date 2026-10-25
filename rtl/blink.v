`timescale 1ns / 1ps

module blink (
    input wire clk_50mhz,
    output wire [1:0] led
);

    reg [3:0] startup = 4'b0;

    always @(posedge clk_50mhz) begin
        if (!(&startup))
            startup <= startup + 1'b1;
    end

    wire clk_200mhz;
    wire locked;

    clk_wiz_0 clocks (
        .clk_in1(clk_50mhz),
        .clk_out1(clk_200mhz),
        .reset(!(&startup)),
        .locked(locked)
    );

    (* ASYNC_REG = "TRUE" *)
    reg [1:0] ready = 2'b00;

    always @(posedge clk_200mhz or negedge locked) begin
        if (!locked)
            ready <= 2'b00;
        else
            ready <= {ready[0], 1'b1};
    end

    localparam integer CLK_HZ = 200_000_000;
    localparam integer BLINK_MS = 100;
    localparam integer TICKS = CLK_HZ / 1000 * BLINK_MS;

    blink_counter #(
        .HALF_PERIOD_TICKS(TICKS)
    ) counter_inst (
        .clk(clk_200mhz),
        .rst(!ready[1]),
        .led(led)
    );

endmodule