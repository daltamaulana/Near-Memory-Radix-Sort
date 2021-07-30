////////////////////////////////////////////////////////////
/*                    Count module                        */
////////////////////////////////////////////////////////////

// count number of 1s and 0s

module count
#(
    parameter ELEMENT_NUM = 8,
    parameter ELEMENT_LOG2NUM = 3
)
(
    input wire [ELEMENT_NUM-1:0] data_in,
    output wire [ELEMENT_LOG2NUM:0] count0,
    output reg [ELEMENT_LOG2NUM:0] count1
);

    integer i;

    always @(*) begin
        count1 = 0;
        for(i=0; i<ELEMENT_NUM; i=i+1) begin
            count1 = count1 + data_in[i];
        end
    end

    assign count0 = ELEMENT_NUM - count1;

endmodule