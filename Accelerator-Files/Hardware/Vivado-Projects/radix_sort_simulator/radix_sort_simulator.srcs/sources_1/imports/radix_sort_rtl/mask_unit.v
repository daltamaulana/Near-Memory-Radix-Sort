////////////////////////////////////////////////////////////
/*                   Masking module                       */
////////////////////////////////////////////////////////////

// mask 1 for current digit 

module mask_unit
#(
    parameter DWIDTH = 32,
    parameter ELEMENT_NUM = 8,
    parameter ARRAYWIDTH = 256
)
(
    input wire [ARRAYWIDTH-1:0] data_in, 
    input wire [DWIDTH-1:0] mask, // mask 1 for current digit 
    output wire [ELEMENT_NUM-1:0] data_out
);
    wire [DWIDTH-1:0] d0,d1,d2,d3,d4,d5,d6,d7;
    reg [ELEMENT_NUM-1:0] mask_result;

    assign {d7,d6,d5,d4,d3,d2,d1,d0} = data_in;

    always @(*) begin
        mask_result[0] = |(d0 & mask);
        mask_result[1] = |(d1 & mask);
        mask_result[2] = |(d2 & mask);
        mask_result[3] = |(d3 & mask);
        mask_result[4] = |(d4 & mask);
        mask_result[5] = |(d5 & mask);
        mask_result[6] = |(d6 & mask);
        mask_result[7] = |(d7 & mask);
    end

    assign data_out = mask_result;


endmodule