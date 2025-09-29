module tcp
#(
    parameter PAYLOAD_LEN = 262,
    parameter TCPH_LEN = 20,
    parameter IPH_LEN = 20,
    parameter PROTOCOL = 6,
    parameter SRCADDR = 32'h7f000001, DESADDR = 32'h7f000001;
)
(
    input clk,
    input rst_n,
    input flag,
    input rx_enable,
    input [PAYLOAD_LEN*8-1:0] rx_fix_data,
    input [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] rx_tcp_data,
    output tx_enable,
    output [PAYLOAD_LEN*8-1:0] tx_fix_data,
    output [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tx_tcp_data,
);

checksum # (
    .SIZE((PAYLOAD_LEN + TCPH_LEN)*8 + 96);
) CSUM_0 (
    .data({pseudo_pi_header, tx_tcp_reg}),
    .data_checksum(data_checksum)
);

random RANDOM_0 (
    .clk(clk),
    .rst_n(rst_n),
    .rnd(rand_val)
);
localparam FIN = 6'000001, SYN = 6'000010, RST = 6'000100, PUSH = 6'001000, ACK = 6'010000, URG = 6'100000;
localparam DSTPORT = 16'd9000, HDRLEN = TCPH_LEN >> 2, URGPTR = 0;
reg [(PAYLOAD_LEN + TCPH_LEN)*8-1:0] tx_tcp_reg, tx_tcp_reg_1;
reg [PAYLOAD_LEN*8-1:0] tx_fix_reg;
reg [95:0] pseudo_pi_header;
reg [31:0] seq_num, ack;
reg [15:0] adv_window, last_adv_window;
wire [5:0] rcv_flag;
reg before_checksum;
wire [15:0] rand_val, data_checksum;

reg [15:0] rcv_dst_port, rcv_src_port;

always@(*) begin
    if (flag == SYN) begin
        if (before_checksum) begin
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
            tx_tcp_reg_1 = tx_tcp_reg;
        end
        else begin
            pseudo_pi_header = pseudo_pi_header;
            seq_num = seq_num;
            ack = ack;
            adv_window = last_adv_window;
            tx_tcp_reg1[127:0] = tx_tcp_reg1[127:0];
            tx_tcp_reg1[143:128] = data_checksum;
            tx_tcp_reg1[(PAYLOAD_LEN + TCPH_LEN)*8-1:144] = tx_tcp_reg1[(PAYLOAD_LEN + TCPH_LEN)*8-1:144];
        end
    end 
    else begin
        if (before_checksum) begin
            pseudo_pi_header[31:0] = SRCADDR;
            pseudo_pi_header[63:32] = DESADDR;
            pseudo_pi_header[71:64] = 0;
            pseudo_pi_header[79:72] = PROTOCOL;
            pseudo_pi_header[95:80] = TCPH_LEN + PAYLOAD_LEN;
            seq_num = seq_num + 1;
            ack = ack + 1;
            if (last_adv_window != 0) begin
                adv_window = 0;
            end
            else begin
                adv_window = 302;
            end
            tx_tcp_reg[15:0] = rcv_dst_port;
            tx_tcp_reg[31:16] = rcv_src_port;
            tx_tcp_reg[63:32] = seq_num;
            tx_tcp_reg[95:64] = ack;
            tx_tcp_reg[99:96] = HDRLEN;
            tx_tcp_reg[105:100] = 6'd0;
            tx_tcp_reg[111:106] = flag;
            tx_tcp_reg[127:112] = adv_window;
            tx_tcp_reg[143:128] = 0;
            tx_tcp_reg[159:144] = URGPTR;
            tx_tcp_reg[(PAYLOAD_LEN + TCPH_LEN)*8-1:160] = rx_fix_data;
            tx_tcp_reg_1 = tx_tcp_reg;
        end
        else begin
            pseudo_pi_header = pseudo_pi_header;
            seq_num = seq_num;
            ack = ack;
            adv_window = last_adv_window;
            tx_tcp_reg1[127:0] = tx_tcp_reg1[127:0];
            tx_tcp_reg1[143:128] = data_checksum;
            tx_tcp_reg1[(PAYLOAD_LEN + TCPH_LEN)*8-1:144] = tx_tcp_reg1[(PAYLOAD_LEN + TCPH_LEN)*8-1:144];
        end
    end
end

always@(*) begin
    tx_fix_reg = rx_tcp_data[(PAYLOAD_LEN + TCPH_LEN)*8-1:160];
    rcv_src_port = rx_tcp_data[15:0];
    rcv_dst_port = rx_tcp_data[31:16];
    rcv_flag = rx_tcp_reg[111:106];
    if (rcv_flag & PUSH == PUSH) begin
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
        before_checksum <= 0;
        last_adv_window <= 302;
    end
    else begin
        tx_tcp_data <= tx_tcp_reg_1;
        tx_fix_data <= tx_fix_reg;
        tx_enable <= tx_enable_reg;
        before_checksum <= ~before_checksum;
        last_adv_window <= adv_window;
    end
end
endmodule
