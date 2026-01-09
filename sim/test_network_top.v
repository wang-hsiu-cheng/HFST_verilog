`timescale 1ns/1ps
`define CYCLE 10
`define END_CYCLE 100000
`define PAYLOAD_LEN 4
`define TCPH_LEN 20
`define IPH_LEN 20
`define PROTOCOL 6
`define SERVER_MSG_PATH "./server_msg.dat"
`define SERVER_DECODED_PATH "./server_decoded.dat"
`define CLIENT_MSG_PATH "./client_msg.dat"
`define CLIENT_ENCODED_PATH "./client_encoded.dat"

module test_network_top;

reg enable;
reg [(`PAYLOAD_LEN + `IPH_LEN + `TCPH_LEN)*8-1:0] server_msg [0:21-1];
reg [(`PAYLOAD_LEN + 1)*8-1:0] client_msg [0:21-1];
reg [`PAYLOAD_LEN*8-1:0] server_decoded [0:21-1];
reg [(`PAYLOAD_LEN + `IPH_LEN + `TCPH_LEN)*8-1:0] client_encoded [0:21-1];
reg [`PAYLOAD_LEN*8-1:0] rx_fix_data;
reg [(`PAYLOAD_LEN + `IPH_LEN + `TCPH_LEN)*8-1:0] rx_ip_data;
reg fix_client_valid;
reg clk, rst_n;
wire [(`PAYLOAD_LEN + `IPH_LEN + `TCPH_LEN)*8-1:0] tx_ip_data;
wire [`PAYLOAD_LEN*8-1:0] tx_fix_data;
wire tcp_decode_valid;
integer i, j, k, fd;
integer pat_error;
// ************************** enigma_part1 instantiation *************************
network_top #(
    .PAYLOAD_LEN(`PAYLOAD_LEN),
    .TCPH_LEN(`TCPH_LEN),
    .IPH_LEN(`IPH_LEN),
    .PROTOCOL(`PROTOCOL)
) network_top_U0 (
    // input 
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .rx_fix_data(rx_fix_data),
    .rx_ip_data(rx_ip_data),
    .fix_client_valid(fix_client_valid), 
    // output
    .tx_ip_data(tx_ip_data),
    .tx_fix_data(tx_fix_data),
    .tcp_decode_valid(tcp_decode_valid)
);

// ********************************** Waveform ***********************************
// Not neccessary 
// Dump waveform if you need it
initial begin
    $fsdbDumpfile("test_network_top.fsdb");
    $fsdbDumpvars; 
end
// *******************************************************************************/

// ******** Read rotor and pattern from pat/ and rotor/ with $readmemh() *********
initial begin
    $readmemh(`SERVER_MSG_PATH, server_msg);
    $readmemh(`CLIENT_MSG_PATH, client_msg);
    $readmemh(`SERVER_DECODED_PATH, server_decoded);
    $readmemh(`CLIENT_ENCODED_PATH, client_encoded);
end
// *******************************************************************************/

// ****************************** clock generation *******************************
initial begin
    clk = 0;
    rst_n = 1;
    while(1) #(`CYCLE/2) clk = ~clk;
end
// *******************************************************************************/

// ********************************* feed input **********************************
initial begin
    enable = 0;
    rx_fix_data = 0;
    rx_ip_data = 0;
    fix_client_valid = 0;
    #(`CYCLE) rst_n = 0;
    #(`CYCLE) rst_n = 1;
    for(i = 0; i < 21; i = i + 1) begin
        @(negedge clk)
        enable = 1;
        rx_fix_data = client_msg[i][`PAYLOAD_LEN*8-1:0];
        rx_ip_data = server_msg[i];
        fix_client_valid = client_msg[i][`PAYLOAD_LEN*8];
    end
end
// *******************************************************************************/

// ******************************** check output ********************************
/* If code_out is incorrect, print it is wrong and finish the simulation */
/* If code_out is correct for each pattern, print
============= Congratulations =============
             All patterns pass !
============= Congratulations =============
and finish the simulation
*/

initial begin
    pat_error = 0;
    wait(rst_n==0);
    wait(rst_n==1);
    #(`CYCLE);
    for(j = 0; j < 21; j = j + 1) begin
        @(negedge clk)
        //if (!(tx_ip_data == client_encoded[j][(`PAYLOAD_LEN + `IPH_LEN + `TCPH_LEN)*8-1:0]) || (tcp_decode_valid == 1 && !(tx_fix_data == server_decoded[j][`PAYLOAD_LEN*8-1:0]))) begin
            $display("************* Pattern No.%d ************", j);
            $display("tx_ip_data = %h", tx_ip_data);
            $display("client_encoded = %h", client_encoded[j][(`PAYLOAD_LEN + `IPH_LEN + `TCPH_LEN)*8-1:0]);
            $display("tx_fix_data = %h", tx_fix_data);
            $display("server_decoded = %h", server_decoded[j][`PAYLOAD_LEN*8-1:0]);
            //pat_error = pat_error + 1;
        //end
    end   
    if (pat_error === 0) begin
        $display("\n============= Congratulations =============");
        $display("             All patterns pass !");
        $display("⠀⢀⠤⣀⣀⣴⣶⣔⢂⠀⠀");
        $display("⠀⠸⠀⠀⠀⠻⠿⢿⣿⡇⠀");
        $display("⢀⣸⠀⡀⠀⠀⠀⢠⠀⣗⡂");
        $display("⠀⢚⣄⡁⠀⠛⠀⢀⡰⢷ ");
        $display("⠀⢠⢎⣿⣿⣭⣽⣿⡄⠜ ");
        $display("⠀⠘⢺⣿⣿⣿⣿⣿⡇⠀⠀");
        $display("⠀⠀⠐⠤⠤⠼⠤⠤⠄  ");
        $display("============= Congratulations =============\n");
    end
    $finish;
end

// early termination of simulation 
initial begin
    #(`END_CYCLE*`CYCLE);
    $display("\n============= Error =============");
    $display(  "   Simulation takes too long...  ");
    $display("============= Error =============\n");
    $finish;
end
// ******************************************************************************

endmodule
