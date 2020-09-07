module Control #(
    parameter COUNTER_SIZE = 8,
    parameter CLKS_PER_BIT = 217,
    parameter NUM_OF_BITS_IN_BUFFER = 8
)
(
    input in,
    input reset,
    input clock,
    input [COUNTER_SIZE-1:0] count,
    output reg counter_enable,
    output reg receive,
    output reg clear
);

parameter FM_IDLE = 3'b000;
parameter FM_WAIT_START = 3'b001;
parameter FM_START = 3'b010;
parameter FM_WAIT_RECEIVE = 3'b011;
parameter FM_RECEIVE = 3'b100;
parameter FM_STOP = 3'b101;

reg [2:0] fm_in;
reg [2:0] fm_out;
reg finish;
reg [3:0] num_of_receives_in;
reg [3:0] num_of_receives_out;

always@(posedge clock)
begin
    fm_out <= fm_in;
    num_of_receives_out <= num_of_receives_in;
end

always@(*)
begin
    case (fm_out)
        FM_IDLE:
        begin
            counter_enable = 0;
            receive = 0;
            clear = 1;
        end
        FM_WAIT_START:
        begin
            counter_enable = 1;
            receive = 0;
            clear = 0;
        end
        FM_START: 
        begin
            counter_enable = 1'bx;
            receive = 0;
            clear = 1;
        end
        FM_WAIT_RECEIVE:
        begin
            counter_enable = 1;
            receive = 0;
            clear = 0;
        end
        FM_RECEIVE:
        begin
            counter_enable = 1'bx;
            receive = 1;
            clear = 1;
        end
        FM_STOP:
        begin
            counter_enable = 0;
            receive = 0;
            clear = 1;
        end
        default:
        begin
        end
    endcase
end

always@(*)
begin
    finish = 1'bx;
    if(!reset)
    begin
        fm_in = FM_IDLE;
        num_of_receives_in = 4'b0;
    end
    else
    begin
        case (fm_out)
            FM_IDLE:
            begin
                num_of_receives_in = 4'b0;
                if (!in) fm_in = FM_WAIT_START;
                else fm_in = FM_IDLE;
            end
            FM_WAIT_START:
            begin
                finish = count == ((CLKS_PER_BIT - 1)/2);
                num_of_receives_in = 4'b0;
                if (finish)
                begin
                    if(!in) fm_in = FM_START;
                    else fm_in = FM_IDLE;
                end
                else fm_in = FM_WAIT_START;
            end
            FM_START: 
            begin
                fm_in = FM_WAIT_RECEIVE;
                num_of_receives_in = 4'b0;
            end
            FM_WAIT_RECEIVE:
            begin
                num_of_receives_in = num_of_receives_out;
                finish = count == CLKS_PER_BIT - 2;
                if(finish)
                begin
                    if(num_of_receives_out == NUM_OF_BITS_IN_BUFFER) fm_in = FM_STOP;
                    else fm_in = FM_RECEIVE;
                end
                else fm_in = FM_WAIT_RECEIVE;
            end
            FM_RECEIVE:
            begin
                fm_in = FM_WAIT_RECEIVE;
                num_of_receives_in = num_of_receives_out + 1;
            end
            FM_STOP:
            begin
                fm_in = FM_IDLE;
                num_of_receives_in = 0;
            end
            default:
            begin
                fm_in = FM_IDLE;
                num_of_receives_in = 0;
            end
        endcase
    end
end

endmodule