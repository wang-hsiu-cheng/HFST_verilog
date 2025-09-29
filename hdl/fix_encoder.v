module order_generator
#(
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
)
(
    // include msg type D, F, G, H, 1
    // input
    input clk,
    input rst_n,
    input enable,
    .(user_command),
    .(fix_msg),
    // output
    .fix_payload(msg_order_payload)
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
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
)
(
    // input
    input clk,
    input rst_n,
    input enable,
    // output
    .fix_payload(msg_a_payload)
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
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
)
(
    // input
    input clk,
    input rst_n,
    input enable,
    // output
    .fix_payload(msg_0_payload)
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
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
)
(
    // read last_payload and resend 
    // input
    input clk,
    input rst_n,
    input enable,
    .last_payload(last_payload),
    // output
    .fix_payload(return_2_payload)
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
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
)
(
    // read last_payload and modify the error
    // input
    input clk,
    input rst_n,
    input enable,
    .last_payload(last_payload),
    // output
    .fix_payload(return_3_payload)
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
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
)
(
    // input
    input clk,
    input rst_n,
    input enable,
    // output
    .fix_payload(msg_5_payload)
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
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
)
(
    // the msg type is appended at the end of the payload. need to be removed after encode.
    // the output is vaild (tx_encoded_reg) only if payload != 0
    // input
    input clk,
    input rst_n,
    .fix_payload(payload),
    // output
    .encoded_msg(encoded_msg_reg),
    .encoded(tx_encoded_reg)
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