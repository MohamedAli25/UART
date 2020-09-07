module ShiftRegister #(
    parameter SIZE = 8
)
(
    input clock,
    input reset,
    input in,
    input receive,
    output reg [SIZE-1:0] out
);

reg [SIZE-1:0] reg_in;

always@(posedge clock)
begin
    out <= reg_in;
end

always@(*)
begin
    if(~reset) reg_in <= 0;
    else if(receive) reg_in <= {in, out[SIZE-1:1]};
    else reg_in <= out;
end

endmodule