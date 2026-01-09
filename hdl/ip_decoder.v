module ip_decoder
#(
  parameter PAYLOAD_LEN = 262,
  parameter TCPH_LEN = 20,
  parameter IPH_LEN = 20,
  parameter PROTOCOL = 6,
  parameter SRCADDR = 32'hc0a84104,
  parameter DESADDR = 32'hc0a84103
)
(
  input clk,
  input rst_n,
  input [(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1:0] rx_ip_data,
  output reg [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tx_tcp_data,
  output reg ip_decode_valid
);

localparam VERSION = 4'd4, HEADER_LEN = 4'd5, TOS = 8'd0, FLAG = 3'd0, OFFSET = 13'd0, TTL = 8'd64;
reg [(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1:0] tx_ip_reg;
reg [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tx_tcp_reg;
reg [16-1:0] length;
reg [16-1:0] ident, last_ident;
reg [(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1:0] checksum_in;
reg ip_decode_valid_reg;
wire [16-1:0] data_checksum;

checksum # (
  .SIZE((PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8)
) CSUM_0 (
  // input
  .data(checksum_in),
  // output
  .data_checksum(data_checksum)
);

always@(*) begin
  checksum_in = {rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-:80], 16'd0, rx_ip_data[(PAYLOAD_LEN + TCPH_LEN)*8-1+64:0]} >> ((PAYLOAD_LEN + TCPH_LEN + IPH_LEN - length)*8);
  length = rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-16-:16];
  ident = rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-32-:16];
  if (
    rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-:4] == VERSION //&& 
      //rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-4-:4] == HEADER_LEN && 
      //rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-8-:8] == TOS && 
      //ident > last_ident &&
      //rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-72-:8] == PROTOCOL && 
      //rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-96-:32] == SRCADDR &&
      //rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-128-:32] == DESADDR 
      //&&
      //rx_ip_data[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-80-:16] == data_checksum
      ) begin
    tx_tcp_reg = rx_ip_data[(PAYLOAD_LEN + TCPH_LEN)*8-1:0];
    ip_decode_valid_reg = 1;
  end else begin
    tx_tcp_reg = 0;
    ip_decode_valid_reg = 0;
  end
end

always@(posedge clk) begin
  if (~rst_n) begin
    last_ident <= 0;
    ip_decode_valid <= 0;
    tx_tcp_data <= 0;
  end
  else begin
    last_ident <= ident;
    ip_decode_valid <= ip_decode_valid_reg;
    tx_tcp_data <= tx_tcp_reg;
  end
end
endmodule
