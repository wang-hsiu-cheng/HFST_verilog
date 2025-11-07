module checksum
# (
  parameter SIZE = 64
)
(
  input [SIZE-1:0] data,
  output reg [15:0] data_checksum
);
localparam PACK = SIZE>>4;
//reg [15:0] sum[0:PACK];
integer i;

always@(*) begin
  /*sum[0] = data & 16'hffff;
  for (i = 0; i < SIZE-16; i = i + 16) begin
    sum[i>>4+1] = sum[i>>4] + ((data >> (i+16)) & 16'hffff);
  end
  data_checksum = ~((sum[PACK-1] >> 16) + (sum[PACK-1] & 16'hffff)) & 16'hffff;*/
  data_checksum = 0;
end

endmodule
