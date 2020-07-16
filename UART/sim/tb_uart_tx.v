//===============================================
// 
// designer:        yang shjiang
// date:            2020-07-16
// description:     the testbench of uart transfer module
//
//===============================================

`timescale 1ns/1ns
`define SIM

module tb_uart_tx;

reg             sys_clk_50M     ;
reg             rst_n           ;
reg             tx_ready        ;
reg     [7:0]   tx_data         ;
wire            tx              ;

initial begin
    sys_clk_50M     = 1'b0;
    rst_n           = 1'b0;
    tx_ready        = 1'b0;
    #100;
    rst_n           = 1'b1;
    #117;
    tx_data         = 8'h55;
    #23;
    tx_ready        = 1'b1;
    #44;
    tx_ready        = 1'b0;
    #15000;
    $stop;
end

always #10 sys_clk_50M = ~sys_clk_50M;


uart_tx     uart_tx_inst(
    // system signal
    .sys_clk_50M     (  sys_clk_50M     ),
    .rst_n           (  rst_n           ),
    // uart interface
    .tx              (  tx              ),
    // others
    .tx_ready        (  tx_ready        ),
    .tx_data         (  tx_data         )
);


endmodule