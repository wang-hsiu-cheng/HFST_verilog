module ip_encoder
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
  input [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] rx_tcp_data,
  output reg [(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1:0] tx_ip_data
);

localparam VERSION = 4'd4, HEADER_LEN = 4'd5, TOS = 8'd0, FLAG = 3'd0, OFFSET = 13'd0, TTL = 8'd64;
reg [(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1:0] tx_ip_reg;
reg [16-1:0] length;
reg [16-1:0] ident, next_ident;
wire [16-1:0] data_checksum;

checksum # (
  .SIZE((PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8)
) CSUM_0 (
  // input
  .data({tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-:80], 16'd0, tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1+64:0]}),
  // output
  .data_checksum(data_checksum)
);

always@(*) begin
  // encoder
  length = PAYLOAD_LEN + TCPH_LEN + HEADER_LEN * 4;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-:4] = VERSION;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-4-:4] = HEADER_LEN;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-8-:8] = TOS;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-16-:16] = length;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-32-:16] = ident;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-48-:3] = FLAG;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-51-:13] = OFFSET;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-64-:8] = TTL;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-72-:8] = PROTOCOL;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-80-:16] = data_checksum;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-96-:32] = SRCADDR;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN + IPH_LEN)*8-1-128-:32] = DESADDR;
  tx_ip_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1:0] = rx_tcp_data;
  next_ident = ident + 1;
end

always@(posedge clk) begin
  if (~rst_n) begin
    ident <= 0;
    tx_ip_data <= 0;
  end
  else begin
    ident <= next_ident;
    tx_ip_data <= tx_ip_reg;
  end
end
endmodule
