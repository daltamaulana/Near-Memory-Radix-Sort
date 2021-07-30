////////////////////////////////////////////////////////////
/*                    Decoder module                      */
////////////////////////////////////////////////////////////

// Decoder of sorting accelerator

module decoder
#(
    parameter DWIDTH = 32,
    parameter ELEMENT_NUM = 8,
    parameter ARRAYWIDTH = 256,
    parameter ELEMENT_LOG2NUM = 3
)
(
    input wire [ARRAYWIDTH-1:0] unsorted_array_in,
    input wire [DWIDTH-1:0] mask_in, 
    output reg [ELEMENT_LOG2NUM:0] pointer0, pointer1,
    output wire [ELEMENT_NUM-1:0] mask_result,
    output wire row_idx,
    output wire [ELEMENT_LOG2NUM-1:0] data_pattern
);

    wire [ELEMENT_LOG2NUM:0] Count0, Count1;

    mask_unit MASK_UNIT
    (
        .data_in(unsorted_array_in), 
        .mask(mask_in), 
        .data_out(mask_result)
    );

    count COUNT
    (
        .data_in(mask_result),
        .count0(Count0),
        .count1(Count1)
    );

    // Pointer logic
    always @(*) begin
        // ascending
        if(Count0 >= Count1) begin
            pointer0 = 0;
            pointer1 = Count0;
        end
        // descending
        else begin
            pointer0 = Count1;
            pointer1 = 0;
        end
    end

    // row_idx logic
    assign row_idx = (Count1 > Count0);

    // Data pattern logic
    assign data_pattern = (row_idx == 0)? (Count0 - ELEMENT_NUM/2) : Count0;

endmodule