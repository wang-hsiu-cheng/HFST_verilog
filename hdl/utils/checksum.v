module checksum
# (
    parameter SIZE = 16
)
(
    input clk,
    input rst_n,
    input [SIZE-1:0] data,
    output reg [15:0] data_checksum
);

reg [15:0] checksum_reg, checksum_reg_1, checksum_reg_2;
reg [15:0] segment;
reg [15:0] sum;
integer i;

always@(*) begin
    sum = 0;
    for (i = 0; i < SIZE; i = i + 16) begin
        segment = (data >> i) & 16'hffff;
        sum = sum + segment;
    end
    checksum_reg = sum;
    checksum_reg_1 = (checksum_reg >> 16) + (checksum_reg & 16'hffff);
    checksum_reg_2 = ~checksum_reg_1 & 16'hffff;
end

always@(posedge clk) begin
    if (~rst_n) begin
        data_checksum <= 0;
    end
    else begin
        data_checksum <= checksum_reg_2;
    end
end

endmodule
