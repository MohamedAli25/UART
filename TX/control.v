module Control #(
    parameter COUNTER_SIZE = 8,
    parameter CLKS_PER_BIT = 8,
    parameter NUM_OF_BITS_IN_BUFFER = 8
)
(
    input send,
    input reset,
    input clock,
    input [COUNTER_SIZE-1:0] count,
    output reg counter_enable,
    output reg shift,
    output reg clear
);

parameter FM_IDLE = 2'b00;
parameter FM_WAIT = 2'b01;
parameter FM_SHIFT = 2'b10;

reg [1:0] fm_in;
reg [1:0] fm_out;
reg [3:0] num_of_sends_in;
reg [3:0] num_of_sends_out;

always@(posedge clock)
begin
    fm_out <= fm_in;
    num_of_sends_out <= num_of_sends_in;
end

always@(*)
begin
    case (fm_out)
        FM_IDLE:
        begin
            counter_enable = 0;
            shift = 0;
            clear = 1;
        end
        FM_WAIT:
        begin
            counter_enable = 1;
            shift = 0;
            clear = 0;
        end
        FM_SHIFT: 
        begin
            counter_enable = 0;
            shift = 1;
            clear = 1;
        end
        default:
        begin
            counter_enable = 1'bx;
            shift = 1'bx;
            clear = 1'bx;
        end
    endcase
end

always@(*)
begin
    if(!reset)
    begin
        fm_in = FM_IDLE;
        num_of_sends_in = 4'b0;
    end
    else
    begin
        case (fm_out)
            FM_IDLE:
            begin
                num_of_sends_in <= 4'b0;
                if(send) fm_in <= FM_WAIT;
                else fm_in <= FM_IDLE;
            end
            FM_WAIT:
            begin
                if(num_of_sends_out == 10)
                begin
                    fm_in <= FM_IDLE;
                    num_of_sends_in <= 0;
                end
                else
                begin
                    if(count == (CLKS_PER_BIT - 2))
                    begin
                        fm_in <= FM_SHIFT;
                        num_of_sends_in <= num_of_sends_out;
                    end
                    else
                    begin
                        fm_in <= FM_WAIT;
                        num_of_sends_in <= num_of_sends_out;
                    end
                end
            end
            FM_SHIFT: 
            begin
                fm_in <= FM_WAIT;
                num_of_sends_in <= (num_of_sends_out + 1);
            end
            default:
            begin
                fm_in <= FM_IDLE;
                num_of_sends_in <= 0;
            end
        endcase
    end
end

endmodule