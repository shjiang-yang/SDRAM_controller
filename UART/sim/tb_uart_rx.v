//===============================================
// 
// designer:        yang shjiang
// date:            2020-07-15
// description:     the testbench of uart receive module
//
//===============================================

`timescale 1ns/1ns

`define SIM


module tb_uart_rx;

reg             sclk_50M    ;
reg             s_rst_n     ;
reg             rx          ;

wire    [7:0]   rx_data     ;
wire            done_flag   ;

reg     [7:0]   mem[3:0]   ;


initial $readmemh("./tx_data.txt", mem);

initial begin
    // mem[0] = 8'h55;
    // mem[1] = 8'h12;
    // mem[2] = 8'h34;
    // mem[3] = 8'haa;

    sclk_50M    =   1'b0    ; 
    s_rst_n     =   1'b1    ;
    rx          =   1'b1    ;
    #100                    ;
    s_rst_n     =   1'b0    ;
    #100                    ;
    s_rst_n     =   1'b1    ;
    #100                    ;
    tx_byte()               ;
    #1500                   ;
    $stop                   ;
end

always #10  sclk_50M = ~sclk_50M    ;


task    tx_byte();
    integer i ;
    for (i = 0; i<4; i=i+1) begin
        uart_tx(mem[i]);
    end
endtask


task  uart_tx(
    input   [7:0]   tx_data
    );
    integer i ;
    for(i=0; i<10; i=i+1) begin
        case (i)
            0:  rx <= 1'b0           ;
            1:  rx <= tx_data[0]     ;
            2:  rx <= tx_data[1]     ;
            3:  rx <= tx_data[2]     ;
            4:  rx <= tx_data[3]     ;
            5:  rx <= tx_data[4]     ;
            6:  rx <= tx_data[5]     ;
            7:  rx <= tx_data[6]     ;
            8:  rx <= tx_data[7]     ;
            9:  rx <= 1'b1           ;
            default: rx <= 1'b1      ;
        endcase
        #1120                         ;
    end
endtask




uart_rx DUT(
    //system signal
    .sclk_50M        (  sclk_50M        )     ,
    .s_rst_n         (  s_rst_n         )     ,
    //uart interface
    .rx              (  rx              )     ,
    //others
    .rx_data         (  rx_data         )     ,
    .done_flag       (  done_flag       )     
);

endmodule