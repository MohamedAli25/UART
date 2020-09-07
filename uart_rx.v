`include "control.v"
`include "shift_register.v"
`include "counter.v"

module UART_RX(
    input in,
    input reset,
    input clock,
    output [7:0] out
);

wire clear;
wire counter_enable;
wire receive;
wire [15:0] count_out;

Counter #(16) counter (.clock(clock), .enable(counter_enable), .reset(reset), .clear(clear), .count_out(count_out));

ShiftRegister #(8) shiftRegister(.clock(clock), .reset(reset), .in(in), .receive(receive), .out(out));

Control #(16, 8, 8) control(.in(in), .clock(clock), .reset(reset), .count(count_out), .counter_enable(counter_enable), .receive(receive), .clear(clear));

endmodule