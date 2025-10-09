module ip
#(
    parameter PAYLOAD_LEN = 262,
    parameter TCPH_LEN = 20,
    parameter IPH_LEN = 20,
    parameter PROTOCOL = 6,
    parameter SRCADDR = 32'h7f000001,
    parameter DESADDR = 32'h7f000001
)
(
    input clk,
    input rst_n,
    input [(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1:0] rx_ip_data,
    input [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] rx_tcp_data,
    output reg [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tx_tcp_data,
    output reg [(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1:0] tx_ip_data
);

localparam VERSION = 4'd4, HEADER_LEN = 4'd5, TOS = 8'd0, FLAG = 3'd0, OFFSET = 13'd0, TTL = 8'd64;
reg [2415:0] tx_ip_reg, tx_ip_reg_1;
reg [2256:0] tx_tcp_reg;
reg [15:0] length, ldent, next_ldent;
wire [15:0] data_checksum;

checksum # (
    .SIZE((PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8)
) CSUM_0 (
    // input
    .clk(clk),
    .rst_n(rst_n),
    .data(tx_ip_reg),
    // output
    .data_checksum(data_checksum)
);

always@(*) begin
    // encoder
    tx_ip_reg_1[79:0] = tx_ip_reg[79:0];
    tx_ip_reg_1[95:80] = data_checksum;
    tx_ip_reg_1[2415:96] = tx_ip_reg[2415:96];

    length = PAYLOAD_LEN + TCPH_LEN + HEADER_LEN * 4;
    tx_ip_reg[3:0] = VERSION;
    tx_ip_reg[7:4] = HEADER_LEN;
    tx_ip_reg[15:8] = TOS;
    tx_ip_reg[31:16] = length;
    tx_ip_reg[47:32] = ldent;
    tx_ip_reg[50:48] = FLAG;
    tx_ip_reg[63:51] = OFFSET;
    tx_ip_reg[71:64] = TTL;
    tx_ip_reg[79:72] = PROTOCOL;
    tx_ip_reg[127:96] = SRCADDR;
    tx_ip_reg[159:128] = DESADDR;
    tx_ip_reg[2415:160] = rx_tcp_data;
    next_ldent = ldent + 1;
    // decoder
    tx_tcp_reg = rx_ip_data[2415:160];
end

always@(posedge clk) begin
    if (~rst_n) begin
        ldent <= 0;
        tx_ip_data <= 0;
        tx_tcp_data <= 0;
    end
    else begin
        ldent <= next_ldent;
        tx_ip_data <= tx_ip_reg_1;
        tx_tcp_data <= tx_tcp_reg;
    end
end
endmodule
