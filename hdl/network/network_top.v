module network_top
#(
    parameter PAYLOAD_LEN = 100,
    parameter TCPH_LEN = 20, IPH_LEN = 20, PROTOCOL = 8'd6
)
(
    input clk,
    input rst_n,
    input [PAYLOAD_LEN*8-1:0] rx_fix_data,
    input [(PAYLOAD_LEN + IPH_LEN + TCPH_LEN)*8-1:0] rx_ip_data,
    input tx_enable,
    output [(PAYLOAD_LEN + IPH_LEN + TCPH_LEN)*8-1:0] tx_ip_data,
    output [PAYLOAD_LEN*8-1:0] tx_fix_data,
    output tcp_decode_valid
    
);
localparam FIN = 6'b000001, SYN = 6'b000010, RST = 6'b000100, PUSH = 6'b001000, ACK = 6'b010000, URG = 6'b100000;
localparam LOGON=2'd0, CONNECT=2'd1;
localparam SRCADDR = 32'h7f000001, DESADDR = 32'h7f000001;
reg [5:0] flag;
reg [1:0] state, next_state;
reg rx_tcp_enable, next_rx_enable;
reg need_ack, next_need_ack;
wire ip_decode_valid;
reg [31:0] delay_ack_counter, next_delay_ack_counter;
wire [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tcp_to_ip_data;
wire [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] ip_to_tcp_data;

ip_encoder #(
    .PAYLOAD_LEN(PAYLOAD_LEN),
    .TCPH_LEN(TCPH_LEN),
    .IPH_LEN(IPH_LEN),
    .PROTOCOL(PROTOCOL),
    .SRCADDR(SRCADDR),
    .DESADDR(DESADDR)
) IP_ENCODER_0 (
    .clk(clk),
    .rst_n(rst_n),
    .rx_tcp_data(tcp_to_ip_data),
    .tx_ip_data(tx_ip_data)
);

ip_decoder #(
    .PAYLOAD_LEN(PAYLOAD_LEN),
    .TCPH_LEN(TCPH_LEN),
    .IPH_LEN(IPH_LEN),
    .PROTOCOL(PROTOCOL),
    .SRCADDR(DESADDR),
    .DESADDR(SRCADDR)
) IP_DECODER_0 (
    .clk(clk),
    .rst_n(rst_n),
    .rx_ip_data(rx_ip_data),
    .ip_decode_valid(ip_decode_valid),
    .tx_tcp_data(ip_to_tcp_data)
);

tcp_encoder #(
    .PAYLOAD_LEN(PAYLOAD_LEN),
    .PSEUDO_HEADER_LEN(12),
    .TCPH_LEN(TCPH_LEN),
    .IPH_LEN(IPH_LEN),
    .PROTOCOL(PROTOCOL),
    .SRCADDR(SRCADDR),
    .DESADDR(DESADDR)
) TCP_ENCODER_0 (
    .clk(clk),
    .rst_n(rst_n),
    .flag(flag),
    .rx_enable(rx_tcp_enable), // high if encoder can encode data
    .rx_fix_data(rx_fix_data),
    // output
    .tx_tcp_data(tcp_to_ip_data)
);

tcp_decoder #(
    .PAYLOAD_LEN(PAYLOAD_LEN),
    .PSEUDO_HEADER_LEN(12),
    .TCPH_LEN(TCPH_LEN),
    .IPH_LEN(IPH_LEN),
    .PROTOCOL(PROTOCOL),
    .SRCADDR(DESADDR),
    .DESADDR(SRCADDR)
) TCP_DECODER_0 (
    .clk(clk),
    .rst_n(rst_n),
    .ip_decode_valid(ip_decode_valid),
    .rx_tcp_data(ip_to_tcp_data),
    // output
    .tx_enable(tcp_decode_valid), // high if decoded data(tx_fix_data) is prepared
    .tx_fix_data(tx_fix_data)
);

always@(*) begin
    case (state)
        LOGON : begin
            next_delay_ack_counter = 0;
            if (need_ack) begin
                flag = ACK;
                next_state = CONNECT;
                rx_tcp_enable = 1;
                next_need_ack = 0;
            end
            else begin
                flag = SYN;
                next_state = LOGON;
                rx_tcp_enable = 1;
                next_need_ack = 1;
            end
        end
        CONNECT : begin
            if (tx_enable) begin
                next_delay_ack_counter = 0;
                if (tcp_decode_valid) begin
                    next_need_ack = 1;
                end
                else begin
                    next_need_ack = need_ack;
                end
                if (need_ack) begin
                    flag = PUSH | ACK;
                    next_state = CONNECT;
                    rx_tcp_enable = 1;
                end
                else if (!need_ack) begin
                    flag = PUSH;
                    next_state = CONNECT;
                    rx_tcp_enable = 1;
                end
            end
            else begin
                if (delay_ack_counter == 32'd1000000 && need_ack) begin
                    if (tcp_decode_valid) begin
                        next_need_ack = 1;
                    end
                    else begin
                        next_need_ack = 0;
                    end
                    flag = ACK;
                    next_state = CONNECT;
                    next_delay_ack_counter = 0;
                    rx_tcp_enable = 1;
                end
                else begin
                    if (tcp_decode_valid) begin
                        next_need_ack = 1;
                    end
                    else begin
                        next_need_ack = need_ack;
                    end
                    flag = ACK;
                    next_state = CONNECT;
                    next_delay_ack_counter = delay_ack_counter + 1;
                    rx_tcp_enable = 0;
                end
            end

        end
        default : begin
            flag = SYN;
            next_state = CONNECT;
            next_delay_ack_counter = 0;
            rx_tcp_enable = 0;
            next_need_ack = 0;
        end
    endcase
end

always@(posedge clk) begin
    if (~rst_n) begin
        state <= 0;
        delay_ack_counter <= 0;
        need_ack <= 0;
    end
    else begin
        state <= next_state;
        delay_ack_counter <= next_delay_ack_counter;
        need_ack <= next_need_ack;
    end
end
endmodule
