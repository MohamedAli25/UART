module ShiftRegisterPISO #(
    parameter SIZE = 8
)
(
    input clock,
    input reset,
    input set,
    input shift,
    input [SIZE-1:0] data,
    output out
);

reg [SIZE+1:0] reg_in;
reg [SIZE+1:0] reg_out;

always@(posedge clock)
begin
    reg_out <= reg_in;
end

always@(*)
begin
    if(~reset) reg_in <= 0;
    else if(set) reg_in <= {1'b1, data, 1'b0};
    else if(shift) reg_in <= (reg_out >> 1);
    else reg_in <= reg_out;
end

assign out = reg_out[0];

endmodule