module tcp_encoder
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
    input [5:0] flag,
    input rx_enable,
    input [PAYLOAD_LEN*8-1:0] rx_fix_data,
    output reg [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tx_tcp_data
);

localparam FIN = 6'b000001, SYN = 6'b000010, RST = 6'b000100, PUSH = 6'b001000, ACK = 6'b010000, URG = 6'b100000;
localparam DSTPORT = 16'd9000, HDRLEN = TCPH_LEN >> 2, URGPTR = 0;
reg [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tx_tcp_reg;
reg [(PAYLOAD_LEN + TCPH_LEN + PSEUDO_HEADER_LEN)*8-1:0] checksum_in;
reg [PSEUDO_HEADER_LEN*8-1:0] pseudo_pi_header;
reg [31:0] seq_num, last_seq_num, ack, last_ack;
reg [15:0] adv_window, last_adv_window;
wire [5:0] rcv_flag;
wire [15:0] rand_val, data_checksum;

reg [15:0] rcv_dst_port, rcv_src_port;

checksum # (
    .SIZE((PAYLOAD_LEN + TCPH_LEN + PSEUDO_HEADER_LEN)*8)
) CSUM_0 (
    // input
    .data(checksum_in),
    // output
    .data_checksum(data_checksum)
);

random RANDOM_0 (
    .clk(clk),
    .rst_n(rst_n),
    .rnd(rand_val)
);

always@(*) begin
  checksum_in = 0;
  if (rx_enable) begin
    pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-:32] = SRCADDR;
    pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-32-:32] = DESADDR;
    pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-64-:8] = 0;
    pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-72-:8] = PROTOCOL;
    pseudo_pi_header[PSEUDO_HEADER_LEN*8-1-80:0] = TCPH_LEN + PAYLOAD_LEN;
    if (flag == SYN) begin
      seq_num = {rand_val, rand_val};
      ack = 0;
      tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-:16] = rand_val + 16'd1024;
      tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-160:0] = 0;
      checksum_in = {pseudo_pi_header, tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-:128], 16'd0, tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-144-:16]};
    end else if (flag[3] == 1'b1) begin // PUSH
      seq_num = last_seq_num + 1;
      ack = last_ack + 1;
      tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-:16] = SRCADDR;
      tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-160:0] = rx_fix_data;
      checksum_in = {pseudo_pi_header, tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-:128], 16'd0, tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-144:0]};
    end else if (flag == ACK) begin
      seq_num = last_seq_num + 1;
      ack = last_ack + 1;
      tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-:16] = SRCADDR;
      tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-160:0] = 0;
      checksum_in = {pseudo_pi_header, tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-:128], 16'd0, tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-144-:16]};
    end else begin
      seq_num = last_seq_num + 1;
      ack = last_ack + 1;
      tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-:16] = SRCADDR;
      tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-160:0] = 0;
      checksum_in = {pseudo_pi_header, tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-:128], 16'd0, tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-144-:16]};
    end
    if (last_adv_window != 0) begin
      adv_window = 0;
    end else begin
      adv_window = 302;
    end
    tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-16-:16] = DSTPORT;
    tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-32-:32] = seq_num;
    tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-64-:32] = ack;
    tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-96-:4] = HDRLEN;
    tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-100-:6] = 6'd0;
    tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-106-:6] = flag;
    tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-112-:16] = adv_window;
    tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-128-:16] = data_checksum;
    tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1-144-:16] = URGPTR;
  end else begin
    pseudo_pi_header = 0;
    seq_num = last_seq_num;
    ack = last_ack;
    checksum_in = 0;
    tx_tcp_reg = 0;
    adv_window = 302;
  end
end

always@(posedge clk) begin
  if (~rst_n) begin
    tx_tcp_data <= 0;
    last_adv_window <= 302;
    last_seq_num <= 0;
    last_ack <= 0;
  end
  else begin
    tx_tcp_data <= tx_tcp_reg;
    last_adv_window <= adv_window;
    last_seq_num <= seq_num;
    last_ack <= ack;
  end
end
endmodule
