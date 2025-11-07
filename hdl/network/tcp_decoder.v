module tcp_decoder
#(
    parameter PAYLOAD_LEN = 262,
    parameter PSEUDO_HEADER_LEN = 12,
    parameter TCPH_LEN = 20,
    parameter IPH_LEN = 20,
    parameter PROTOCOL = 6,
    parameter SRCADDR = 32'h7f000001,
    parameter DESADDR = 32'h7f000001
)
(
    input clk,
    input rst_n,
    input ip_decode_valid,
    input [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] rx_tcp_data,
    output reg tx_enable,
    output reg [PAYLOAD_LEN*8-1:0] tx_fix_data
);

localparam FIN = 6'b000001, SYN = 6'b000010, RST = 6'b000100, PUSH = 6'b001000, ACK = 6'b010000, URG = 6'b100000;
localparam DSTPORT = 16'd9000, HDRLEN = TCPH_LEN >> 2, URGPTR = 0;
reg [PAYLOAD_LEN*8-1:0] tx_fix_reg;
reg [PSEUDO_HEADER_LEN*8-1:0] pseudo_pi_header;
reg [(PAYLOAD_LEN + TCPH_LEN + PSEUDO_HEADER_LEN)*8-1:0] checksum_in;
reg [31:0] seq_num, last_seq_num, ack, last_ack;
reg [15:0] adv_window, last_adv_window;
reg tx_enable_reg;
reg [15:0] rcv_dst_port, rcv_src_port;
wire [15:0] data_checksum;

checksum # (
  .SIZE((PAYLOAD_LEN + TCPH_LEN + PSEUDO_HEADER_LEN)*8)
) CSUM_0 (
  // input
  .data(checksum_in),
  // output
  .data_checksum(data_checksum)
);

always@(*) begin
  pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-:32] = SRCADDR;
  pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-32-:32] = DESADDR;
  pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-64-:8] = 0;
  pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-72-:8] = PROTOCOL;
  pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-80:0] = TCPH_LEN + PAYLOAD_LEN;
  checksum_in = {pseudo_pi_header, rx_tcp_data[(PAYLOAD_LEN + TCPH_LEN)*8-1-:128], 16'd0, rx_tcp_data[(PAYLOAD_LEN + TCPH_LEN)*8-1-144-:16]};
  if ((rx_tcp_data[(PAYLOAD_LEN + TCPH_LEN)*8-1-106-:6] & PUSH) == PUSH && rx_tcp_data[(PAYLOAD_LEN + TCPH_LEN)*8-1-128-:16] == data_checksum && ip_decode_valid) begin
    tx_enable_reg = 1;
    tx_fix_reg = rx_tcp_data[(PAYLOAD_LEN + TCPH_LEN)*8-1-160:0];
    rcv_src_port = rx_tcp_data[(PAYLOAD_LEN + TCPH_LEN)*8-1-16-:16];
    rcv_dst_port = rx_tcp_data[(PAYLOAD_LEN + TCPH_LEN)*8-1-:16];
  end else begin
    tx_enable_reg = 0;
    tx_fix_reg = 0;
    rcv_src_port = 0;
    rcv_dst_port = 0;
  end
end

always@(posedge clk) begin
  if (~rst_n) begin
    tx_fix_data <= 0;
    tx_enable <= 0;
    //last_seq_num <= 0;
    //last_ack <= 0;
  end else begin
    tx_fix_data <= tx_fix_reg;
    tx_enable <= tx_enable_reg;
    //last_seq_num <= seq_num;
    //last_ack <= ack;
  end
end
endmodule
