module fix_top
#(
    // FIX_PAYLOAD_LEN + FIX_HEADER_LEN = PAYLOAD_LEN in network_top module
    parameter FIX_PAYLOAD_LEN = 220,
    parameter FIX_HEADER_LEN = 42
)
(
    // input
    input clk,
    input rst_n,
    input [8*5-1:0] user_command,
    input rx_enable, // tx_enable in network_top
    input [(FIX_HEADER_LEN+FIX_PAYLOAD_LEN)*8-1:0] rx_fix_data, // tx_fix_data in network_top
    // output
    output tx_encoded, // rx_enable in network_top
    output [(FIX_HEADER_LEN+FIX_PAYLOAD_LEN)*8-1:0] encoded_msg // rx_fix_data in network_top
);

fix_decoder #(
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
) FIX_DECODER_0 (
    // input
    .clk(clk),
    .rst_n(rst_n),
    .rx_enable(rx_enable),
    .fix_pre_decode(rx_fix_data),
    // output
    .is_decoded(is_decoded),
    .msg_type(rx_msg_type), // 8 bits for 1 charactor
    .fix_post_decode(fix_msg), // received message
    .error_payload(error_payload), // return not 0 if there's error in message after decode
    .fatal_error(fatal_error)        // need to logout
);

order_generator #(
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
) ORDER_GEN (
    // include msg type D, F, G, H, 1
    // input
    .clk(clk),
    .rst_n(rst_n),
    .enable(order_generate_enable),
    .(user_command),
    .(fix_msg),
    // output
    .fix_payload(msg_order_payload)
);

msg_a_encoder #(
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
) MSG_A_ENCODER (
    // input
    .clk(clk),
    .rst_n(rst_n),
    .enable(encode_a_enable),
    // output
    .fix_payload(msg_a_payload)
);

msg_0_encoder #(
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
) MSG_0_ENCODER (
    // input
    .clk(clk),
    .rst_n(rst_n),
    .enable(encode_0_enable),
    // output
    .fix_payload(msg_0_payload)
);

return_2_encoder #(
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
) RETURN_2_ENCODER (
    // read last_payload and resend 
    // input
    .clk(clk),
    .rst_n(rst_n),
    .enable(encode_2_enable),
    .last_payload(last_payload),
    // output
    .fix_payload(return_2_payload)
);

return_3_encoder #(
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
) RETURN_3_ENCODER (
    // read last_payload and modify the error
    // input
    .clk(clk),
    .rst_n(rst_n),
    .enable(encode_3_enable),
    .last_payload(last_payload),
    // output
    .fix_payload(return_3_payload)
);

msg_5_encoder #(
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
) MSG_5_ENCODER (
    // input
    .clk(clk),
    .rst_n(rst_n),
    .enable(encode_5_enable),
    // output
    .fix_payload(msg_5_payload)
);

header_encoder #(
    .FIX_PAYLOAD_LEN(FIX_PAYLOAD_LEN),
    .FIX_HEADER_LEN(FIX_HEADER_LEN)
) HEADER_ENCODER (
    // the msg type is appended at the end of the payload. need to be removed after encode.
    // the output is vaild (tx_encoded_reg) only if payload != 0
    // input
    .clk(clk),
    .rst_n(rst_n),
    .fix_payload(payload),
    // output
    .encoded_msg(encoded_msg_reg),
    .encoded(tx_encoded_reg)
);

wire fatal_error, is_decoded, rx_msg_type; // output from fix_decoder module
wire [FIX_PAYLOAD_LEN*8-1:0] fix_msg; // output from fix_decoder module
wire [FIX_PAYLOAD_LEN*8-1:0] error_payload, msg_order_payload, msg_a_payload, msg_0_payload, msg_5_payload, return_2_payload, return_3_payload;
reg state, next_state; // state of FSM
reg [FIX_PAYLOAD_LEN*8-1:0] last_payload, payload, temp_payload;
reg [32:0] next_heartbeat_counter, heartbeat_counter;
localparam IDLE, LOGGING_ON, ORDERING, LOGGING_OUT; // state of FSM
localparam LOGON, HEART_BT, TEST_RQT, RESEND_RQT, RJT, SEQ_RST, LOGOUT, REPORT, ORDER_RJT; // rx message type

always@(*) begin
    temp_payload = msg_order_payload | msg_a_payload | error_payload | msg_5_payload | return_2_payload | return_3_payload;
    if (|temp_payload == 0 && |msg_0_payload != 0) begin
        payload = msg_0_payload;
    end
    else begin
        payload = temp_payload;
    end 
end
always@(*) begin
    if (!tx_encoded) begin
        next_heartbeat_counter = heartbeat_counter + 1;
    end
    else begin
        next_heartbeat_counter = 0;
    end
    if (heartbeat_counter == 32'd10000000) begin
        encode_0_enable = 1;
    end
    else begin
        encode_0_enable = 0;
    end
end
always@(*) begin
    case (state) begin
        IDLE : begin
            if (user_command == "START") begin
                order_generate_enable = 0;
                encode_a_enable = 0;
                encode_2_enable = 0;
                encode_3_enable = 0;
                encode_5_enable = 0;
                next_state = LOGGING_ON;
            end
            else begin
                order_generate_enable = 0;
                encode_a_enable = 0;
                encode_2_enable = 0;
                encode_3_enable = 0;
                encode_5_enable = 0;
                next_state = IDLE;
            end
        end
        LOGGING_ON : begin
            if (!is_decoded) begin
                order_generate_enable = 0;
                encode_a_enable = 1;
                encode_2_enable = 0;
                encode_3_enable = 0;
                encode_5_enable = 0;
                // Can send logon message
                next_state = LOGGING_ON;
            end
            else if (is_decoded && (rx_msg_type == "A")) begin
                order_generate_enable = 0;
                encode_a_enable = 0;
                encode_2_enable = 0;
                encode_3_enable = 0;
                encode_5_enable = 0;
                next_state = ORDERING;
            end
            else begin
                order_generate_enable = 0;
                encode_a_enable = 0;
                encode_2_enable = 0;
                encode_3_enable = 0;
                encode_5_enable = 0;
                next_state = LOGGING_OUT;
            end
        end
        ORDERING : begin
            if (is_decoded && (rx_msg_type == "2")) begin
                order_generate_enable = 0;
                encode_a_enable = 0;
                encode_2_enable = 1;
                encode_3_enable = 0;
                encode_5_enable = 0;
                // tackle the error message and return correct message
                next_state = ORDERING;
            end
            if (is_decoded && (rx_msg_type == "3")) begin
                order_generate_enable = 0;
                encode_a_enable = 0;
                encode_2_enable = 0;
                encode_3_enable = 1;
                encode_5_enable = 0;
                // tackle the error message and return correct message
                next_state = ORDERING;
            end
            else if (is_decoded && fatal_error) begin
                order_generate_enable = 0;
                encode_a_enable = 0;
                encode_2_enable = 0;
                encode_3_enable = 0;
                encode_5_enable = 1;
                // encode and return error message
                next_state = LOGGING_OUT;
            end
            else begin
                order_generate_enable = 1;
                encode_a_enable = 0;
                encode_2_enable = 0;
                encode_3_enable = 0;
                encode_5_enable = 0;
                // Can send the order message
                next_state = ORDERING;
            end
        end
        LOGGING_OUT : begin
            if (is_decoded && (rx_msg_type == "5")) begin
                order_generate_enable = 0;
                encode_a_enable = 0;
                encode_2_enable = 0;
                encode_3_enable = 0;
                encode_5_enable = 1;
                next_state = IDLE;
            end
            else begin
                order_generate_enable = 0;
                encode_a_enable = 0;
                encode_2_enable = 0;
                encode_3_enable = 0;
                encode_5_enable = 1;
                next_state = LOGGING_OUT;
            end
        end
    endcase
end

always@(posedge clk) begin
    if (~rst_n) begin
        state <= 0;
        last_payload <= 0;
        heartbeat_counter <= 0;
        // module output
        tx_encoded <= 0;
        encoded_msg_reg <= 0;
    end
    else begin
        state <= next_state;
        last_payload <= payload;
        heartbeat_counter <= next_heartbeat_counter;
        // module output
        tx_encoded <= tx_encoded_reg;
        encoded_msg <= encoded_msg_reg;
    end
end
endmodule