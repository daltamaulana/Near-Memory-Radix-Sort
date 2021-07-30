////////////////////////////////////////////////////////////
/*                Rearrange mux module                    */
////////////////////////////////////////////////////////////

// Rearrange unsorted array to sorted array

module rearrange_mux
#(
    parameter DWIDTH = 32,
    parameter ELEMENT_NUM = 8,
    parameter ARRAYWIDTH = 256,
    parameter ELEMENT_LOG2NUM = 3
)
(
    input wire [ARRAYWIDTH-1:0] unsorted_array_in,
    input wire [ELEMENT_LOG2NUM:0] pointer0_in, pointer1_in,
    input wire [ELEMENT_NUM-1:0] mask_result_in,
    output wire [ARRAYWIDTH-1:0] sorted_array_out 
);
    wire [DWIDTH-1:0] tmp_unsort[ELEMENT_NUM-1:0];
    reg [DWIDTH-1:0] tmp_sort[ELEMENT_NUM-1:0];
    reg [ELEMENT_LOG2NUM:0] pointer0, pointer1;
    integer i;

    assign {tmp_unsort[7], tmp_unsort[6], tmp_unsort[5], tmp_unsort[4], tmp_unsort[3], tmp_unsort[2], tmp_unsort[1], tmp_unsort[0]} = unsorted_array_in;

    always @(*) begin
        pointer0 = pointer0_in;
        pointer1 = pointer1_in;

        for(i=0; i<ELEMENT_NUM; i= i+1) begin
            if(mask_result_in[i]) begin
                tmp_sort[pointer1] = tmp_unsort[i];     
                pointer1 = pointer1 + 1;              
            end
            else begin
                tmp_sort[pointer0] = tmp_unsort[i];
                pointer0 = pointer0 + 1;
            end
        end
    end
    
    assign sorted_array_out = {tmp_sort[7], tmp_sort[6], tmp_sort[5], tmp_sort[4], tmp_sort[3], tmp_sort[2], tmp_sort[1], tmp_sort[0]};

endmodule