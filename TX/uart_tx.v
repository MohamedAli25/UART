`include "control.v"
`include "shift_register_PISO.v"
`include "../ReusableComponents/counter.v"

module UART_TX(
    input send,
    input [7:0] data,
    input reset,
    input clock,
    output out
);

wire clear;
wire counter_enable;
wire receive;
wire shift;
wire [15:0] count_out;

Counter #(16) counter (.clock(clock), .enable(counter_enable), .reset(reset), .clear(clear), .count_out(count_out));

ShiftRegisterPISO #(8) shiftRegister(.clock(clock), .reset(reset), .set(send), .shift(shift), .data(data), .out(out));

Control #(16, 8, 8) control(.clock(clock), .reset(reset), .count(count_out), .counter_enable(counter_enable), .clear(clear), .shift(shift), .send(send));

endmodule