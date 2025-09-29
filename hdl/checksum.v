module checksum
# (
    parameter SIZE;
)
(
    input [SIZE-1:0] data,
    output [15:0] data_checksum
);

reg [15:0] checksum_reg, checksum_reg_1, checksum_reg_2;
integer i;

always@(*) begin
    for (i = 0; i < SIZE; i = i + 16) begin
        checksum_reg = checksum_reg + data[i+15:i];
    end
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