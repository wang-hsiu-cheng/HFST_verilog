module random (
    input  wire       clk,
    input  wire       rst_n,
    output reg [15:0]  rnd
);

    // taps: 16,14,13,11  → bits [15],[13],[12],[10]
    assign feedback = rnd[15] ^ rnd[13] ^ rnd[12] ^ rnd[10];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
        rnd <= 16'h1;          // seed (must not be 0)
        else
        rnd <= {rnd[14:0], feedback};
    end
endmodule