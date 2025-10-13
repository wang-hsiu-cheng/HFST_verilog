module fix_decoder
#(
    parameter FIX_PAYLOAD_LEN = 220,
    parameter FIX_HEADER_LEN = 42
)
(
    // input
    input clk,
    input rst_n, 
    input rx_enable,
    input [(FIX_PAYLOAD_LEN+FIX_HEADER_LEN)*8-1:0] fix_pre_decode,
    // output
    output is_decoded,
    output [7:0] msg_type, // 8 bits for 1 charactor
    output reg [FIX_PAYLOAD_LEN*8-1:0] fix_post_decode, // received message
    output reg [FIX_PAYLOAD_LEN*8-1:0] error_payload, // return not 0 if there's error in message after decode
    output fatal_error        // need to logout
);

always@(*) begin

end

always@(posedge clk) begin
    if (~rst_n) begin

    end
    else begin

    end
end
endmodule
