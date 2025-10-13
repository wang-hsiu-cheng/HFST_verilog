module order_generator
#(
    parameter FIX_PAYLOAD_LEN = 220,
    parameter FIX_HEADER_LEN = 42
)
(
    // include msg type D, F, G, H, 1
    // input
    input clk,
    input rst_n,
    input enable,
    input [5*8-1:0] user_command,
    input [FIX_PAYLOAD_LEN*8-1:0] fix_msg,
    // output
    output reg [FIX_PAYLOAD_LEN*8-1:0] fix_payload
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

module msg_a_encoder
#(
    parameter FIX_PAYLOAD_LEN = 220,
    parameter FIX_HEADER_LEN = 42
)
(
    // input
    input clk,
    input rst_n,
    input enable,
    // output
    output reg [FIX_PAYLOAD_LEN*8-1:0] fix_payload
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

module msg_0_encoder
#(
    parameter FIX_PAYLOAD_LEN = 220,
    parameter FIX_HEADER_LEN = 42
)
(
    // input
    input clk,
    input rst_n,
    input enable,
    // output
    output reg [FIX_PAYLOAD_LEN*8-1:0] fix_payload
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

module return_2_encoder
#(
    parameter FIX_PAYLOAD_LEN = 220,
    parameter FIX_HEADER_LEN = 42
)
(
    // read last_payload and resend 
    // input
    input clk,
    input rst_n,
    input enable,
    input [FIX_PAYLOAD_LEN*8-1:0] last_payload,
    // output
    output reg [FIX_PAYLOAD_LEN*8-1:0] fix_payload
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

module return_3_encoder
#(
    parameter FIX_PAYLOAD_LEN = 220,
    parameter FIX_HEADER_LEN = 42
)
(
    // read last_payload and modify the error
    // input
    input clk,
    input rst_n,
    input enable,
    input [FIX_PAYLOAD_LEN*8-1:0] last_payload,
    // output
    output reg [FIX_PAYLOAD_LEN*8-1:0] fix_payload
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

module msg_5_encoder
#(
    parameter FIX_PAYLOAD_LEN = 220,
    parameter FIX_HEADER_LEN = 42
)
(
    // input
    input clk,
    input rst_n,
    input enable,
    // output
    output reg [FIX_PAYLOAD_LEN*8-1:0] fix_payload
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

module header_encoder
#(
    parameter FIX_PAYLOAD_LEN = 220,
    parameter FIX_HEADER_LEN = 42
)
(
    // the msg type is appended at the end of the payload. need to be removed after encode.
    // the output is vaild (tx_encoded_reg) only if payload != 0
    // input
    input clk,
    input rst_n,
    input [FIX_PAYLOAD_LEN*8-1:0] fix_payload,
    // output
    output reg [(FIX_PAYLOAD_LEN+FIX_HEADER_LEN)*8-1:0] encoded_msg,
    output reg encoded
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
