module checksum
# (
  parameter SIZE = 64
)
(
  input [SIZE-1:0] data,
  output reg [15:0] data_checksum
);
localparam PACK = SIZE>>4;
reg [15:0] sum[0:PACK-1];
integer i;

always@(*) begin
  for (i = 0; i < PACK; i = i + 1)
    sum[i] = 0;
  sum[0] = data & 16'hffff;
  for (i = 0; i < SIZE-16; i = i + 16) begin
    sum[i>>4+1] = sum[i>>4] + ((data >> (i+16)) & 16'hffff);
  end
  //sum[1] = sum[0] + ((data >> (16)) & 16'hffff);
  //sum[2] = sum[1] + ((data >> (32)) & 16'hffff);
  //sum[3] = sum[2] + ((data >> (48)) & 16'hffff);
  data_checksum = ~((sum[PACK-1] >> 16) + (sum[PACK-1] & 16'hffff)) & 16'hffff;
  //data_checksum = 0;
end

endmodule
