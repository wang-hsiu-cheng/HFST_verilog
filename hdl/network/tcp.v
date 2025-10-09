module tcp
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
    input [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] rx_tcp_data,
    output reg tx_enable,
    output reg [PAYLOAD_LEN*8-1:0] tx_fix_data,
    output reg [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tx_tcp_data
);

localparam FIN = 6'b000001, SYN = 6'b000010, RST = 6'b000100, PUSH = 6'b001000, ACK = 6'b010000, URG = 6'b100000;
localparam DSTPORT = 16'd9000, HDRLEN = TCPH_LEN >> 2, URGPTR = 0;
reg [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tx_tcp_reg, tx_tcp_reg_1;
reg [PAYLOAD_LEN*8-1:0] tx_fix_reg;
reg [PSEUDO_HEADER_LEN*8-1:0] pseudo_pi_header;
reg [31:0] seq_num, last_seq_num, ack, last_ack;
reg [15:0] adv_window, last_adv_window;
wire [5:0] rcv_flag;
reg tx_enable_reg;
wire [15:0] rand_val, data_checksum;

reg [15:0] rcv_dst_port, rcv_src_port;

checksum # (
    .SIZE((PAYLOAD_LEN + TCPH_LEN + PSEUDO_HEADER_LEN)*8)
) CSUM_0 (
    // input
    .clk(clk),
    .rst_n(rst_n),
    .data({pseudo_pi_header, tx_tcp_reg}),
    // output
    .data_checksum(data_checksum)
);

random RANDOM_0 (
    .clk(clk),
    .rst_n(rst_n),
    .rnd(rand_val)
);

always@(*) begin
    if (flag == SYN) begin
        tx_tcp_reg_1[127:0] = tx_tcp_reg[127:0];
        tx_tcp_reg_1[143:128] = data_checksum;
        tx_tcp_reg_1[(PAYLOAD_LEN + TCPH_LEN)*8-1:144] = tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1:144];

        pseudo_pi_header[31:0] = SRCADDR;
        pseudo_pi_header[63:32] = DESADDR;
        pseudo_pi_header[71:64] = 0;
        pseudo_pi_header[79:72] = PROTOCOL;
        pseudo_pi_header[95:80] = TCPH_LEN + PAYLOAD_LEN;
        seq_num = {rand_val, rand_val};
        ack = 0;
        if (last_adv_window != 0) begin
            adv_window = 0;
        end
        else begin
            adv_window = 302;
        end
        tx_tcp_reg[15:0] = rand_val + 16'd1024;
        tx_tcp_reg[31:16] = DSTPORT;
        tx_tcp_reg[63:32] = seq_num;
        tx_tcp_reg[95:64] = ack;
        tx_tcp_reg[99:96] = HDRLEN;
        tx_tcp_reg[105:100] = 6'd0;
        tx_tcp_reg[111:106] = flag;
        tx_tcp_reg[127:112] = adv_window;
        tx_tcp_reg[143:128] = 0;
        tx_tcp_reg[159:144] = URGPTR;
        tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1:160] = rx_fix_data;
    end 
    else begin
        tx_tcp_reg_1[127:0] = tx_tcp_reg[127:0];
        tx_tcp_reg_1[143:128] = data_checksum;
        tx_tcp_reg_1[(PAYLOAD_LEN + TCPH_LEN)*8-1:144] = tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1:144];

        pseudo_pi_header[31:0] = SRCADDR;
        pseudo_pi_header[63:32] = DESADDR;
        pseudo_pi_header[71:64] = 0;
        pseudo_pi_header[79:72] = PROTOCOL;
        pseudo_pi_header[95:80] = TCPH_LEN + PAYLOAD_LEN;
        seq_num = last_seq_num + 1;
        ack = last_ack + 1;
        if (last_adv_window != 0) begin
            adv_window = 0;
        end
        else begin
            adv_window = 302;
        end
        tx_tcp_reg[15:0] = rand_val + 16'd1024;
        tx_tcp_reg[31:16] = DSTPORT;
        tx_tcp_reg[63:32] = seq_num;
        tx_tcp_reg[95:64] = ack;
        tx_tcp_reg[99:96] = HDRLEN;
        tx_tcp_reg[105:100] = 6'd0;
        tx_tcp_reg[111:106] = flag;
        tx_tcp_reg[127:112] = adv_window;
        tx_tcp_reg[143:128] = 0;
        tx_tcp_reg[159:144] = URGPTR;
        tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1:160] = rx_fix_data;
    end
end

always@(*) begin
    tx_fix_reg = rx_tcp_data[(PAYLOAD_LEN + TCPH_LEN)*8-1:160];
    rcv_src_port = rx_tcp_data[15:0];
    rcv_dst_port = rx_tcp_data[31:16];
    //rcv_flag = rx_tcp_data[111:106];
    if ((rx_tcp_data[111:106] & PUSH) == PUSH) begin
        tx_enable_reg = 1;
    end
    else begin
        tx_enable_reg = 0;
    end
end

always@(posedge clk) begin
    if (~rst_n) begin
        tx_tcp_data <= 0;
        tx_fix_data <= 0;
        tx_enable <= 0;
        last_adv_window <= 302;
        last_seq_num <= 0;
        last_ack <= 0;
    end
    else begin
        tx_tcp_data <= tx_tcp_reg_1;
        tx_fix_data <= tx_fix_reg;
        tx_enable <= tx_enable_reg;
        last_adv_window <= adv_window;
        last_seq_num <= seq_num;
        last_ack <= ack;
    end
end
endmodule
