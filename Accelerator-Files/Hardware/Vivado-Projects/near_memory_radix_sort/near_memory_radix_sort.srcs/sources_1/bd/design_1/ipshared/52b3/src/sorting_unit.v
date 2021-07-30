////////////////////////////////////////////////////////////
/*                     Sorting module                     */
////////////////////////////////////////////////////////////


module sorting_unit
#(
    parameter DWIDTH = 32,
    parameter ELEMENT_NUM = 8,
    parameter ARRAYWIDTH = 256,
    parameter ELEMENT_LOG2NUM = 3
)
(
    input wire [ARRAYWIDTH-1:0] data_in,
    input wire [DWIDTH-1:0] mask_in,
    output wire [ARRAYWIDTH-1:0] data_out,
    output wire row_idx,
    output wire [ELEMENT_LOG2NUM-1:0] data_pattern
);

    wire [ELEMENT_LOG2NUM:0] pointer0, pointer1;
    wire [ELEMENT_NUM-1:0] mask_result;




    decoder DECODER
    (
        .unsorted_array_in(data_in),
        .mask_in(mask_in),
        .pointer0(pointer0), 
        .pointer1(pointer1),
        .mask_result(mask_result),
        .row_idx(row_idx),
        .data_pattern(data_pattern)
    );

    rearrange_mux REARRANGE_MUX
    (
        .unsorted_array_in(data_in),
        .pointer0_in(pointer0), 
        .pointer1_in(pointer1),
        .mask_result_in(mask_result),
        .sorted_array_out(data_out) 
    );

endmodule