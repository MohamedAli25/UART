module Counter # (
    parameter NUM_OF_FF = 16
)
(
    input clock,
    input enable,
    input reset,
    input clear,
    output reg [NUM_OF_FF - 1:0] count_out
);

reg [NUM_OF_FF - 1:0] count_in;

always@(posedge clock)
begin
    count_out <= count_in;
end

always@(*)
begin
    if(!reset || clear) count_in <= 0;
    else if(enable) count_in <= count_out + 1;
    else count_in <= count_out;
end

endmodule