// ================================================
// 
// designer:            yang shjiang
// date:                2020-07-25
// description:         the sdram top module
// 
// ================================================

module SDRAM_top(
    // system singal
    input                   osc_clk_50      ,
    input                   key_rst_n       ,
    // uart interface
    input                   rx_232          ,
    output                  tx_232          ,
    // sdram interface
    output                  CLK             ,
    output                  CKE             ,
    output                  cs_n            ,
    output                  ras_n           ,
    output                  cas_n           ,
    output                  we_n            ,
    output      [12:0]      addr            ,
    output      [ 1:0]      ba              ,
    output      [ 1:0]      dqm             ,
    inout       [15:0]      dq              ,
    // led
    output                  data_trans      
);

// ===============================================
// ********** define params and signals ******
// ===============================================
localparam              CNT_END = 7         ;

reg     [ 2:0]          cnt                 ;

// PLL
wire                    locked              ;
wire                    sysclk_100M         ;

// rst_n
wire                    rst_n               ;
// debounce
wire                    deb_rst_n           ;

// uart_rx
wire    [ 7:0]          rx_data             ;
wire                    rx_done_flag        ;

// write_sync_fifo
wire                    wfifo_full          ;
wire                    wfifo_ren           ;
wire    [ 7:0]          wfifo_rdata         ;

// sdram
// pass

// read_sync_fifo
wire                    rfifo_empty         ;
wire                    rfifo_wen           ;
wire    [ 7:0]          rfifo_wdata         ;
reg                     rfifo_ren           ;

// uart_tx
wire                    tx_done             ;
wire    [ 7:0]          tx_data             ;
reg                    tx_ready            ;


// =============================================
// ************** main code ****************
// =============================================
// PLL
assign sysclk_100M = osc_clk_50 ;
assign locked = 1'b1    ;

// debounce
debounce #(
    .CLK_CYC            (   10              )
) debounce_inst(
    // system signals
    .sysclk             (   sysclk_100M     )    ,
    // key
    .key_in             (   key_rst_n       )    ,
    // output
    .key_out            (   deb_rst_n       )    
);

// rst_n
assign rst_n = locked & deb_rst_n    ;

// uart_rx
uart_rx #(
    .BAUD_RATE          (   115200          )
) uart_rx_inst(
    //system signal
    .sclk_100M          (   sysclk_100M     )    ,
    .s_rst_n            (   rst_n           )    ,
    //uart interface
    .rx                 (   rx_232          )    ,
    //others
    .rx_data            (   rx_data         )    ,
    .done_flag          (   rx_done_flag    )    
);

// w_sync_fifo
sync_FIFO #(
    .DEPTH              (   8               )    ,
    .WIDTH              (   8               )    
) sync_FIFO_w_inst(
    // system signals
    .sysclk_100M        (    sysclk_100M    )    ,
    .rst_n              (    rst_n          )    ,
    // write port
    .full               (    wfifo_full     )    ,
    .write_en           (    rx_done_flag   )    ,
    .write_data         (    rx_data        )    ,
    // read port
    .empty              (                   )    ,
    .read_en            (    wfifo_ren      )    ,
    .read_data          (    wfifo_rdata    )    
);

// sdram_arbit
SDRAM_arbit SDRAM_arbit_inst(
    // system signals
    .sysclk_100M        (   sysclk_100M     )    ,
    .rst_n              (   rst_n           )    ,
    // sdram interface
    .CLK                (   CLK             )    ,
    .CKE                (   CKE             )    ,
    .cs_n               (   cs_n            )    ,
    .ras_n              (   ras_n           )    ,
    .cas_n              (   cas_n           )    ,
    .we_n               (   we_n            )    ,
    .addr               (   addr            )    ,
    .ba                 (   ba              )    ,
    .dqm                (   dqm             )    ,
    .dq                 (   dq              )    ,
    // write fifo
    .write_trig         (   wfifo_full      )    ,  // full
    .write_data_vld     (   wfifo_ren       )    ,  // w_fifo ren
    .w_dq               (   wfifo_rdata     )    ,
    // read fifo
    .read_data_vld      (   rfifo_wen       )    ,  // r_fifo_wen
    .r_dq               (   rfifo_wdata     )    
);

// r_sync_fifo
sync_FIFO #(
    .DEPTH              (   8               )    ,
    .WIDTH              (   8               )    
) sync_FIFO_r_inst(
    // system signals
    .sysclk_100M        (    ~sysclk_100M   )    ,
    .rst_n              (    rst_n          )    ,
    // write port
    .full               (                   )    ,
    .write_en           (    rfifo_wen      )    ,
    .write_data         (    rfifo_wdata    )    ,
    // read port
    .empty              (    rfifo_empty    )    ,
    .read_en            (    rfifo_ren      )    ,
    .read_data          (    tx_data        )    
);

// uart_tx
uart_tx #(
    .BAUD_RATE          (       115200      )
) uart_tx_inst(
    // system signal
    .sys_clk_100M       (   ~sysclk_100M    )    ,
    .rst_n              (   rst_n           )    ,
    // uart interface
    .tx                 (   tx_232          )    ,
    // others
    .tx_ready           (   tx_ready        )    ,  // data_ready
    .tx_done            (   tx_done         )    ,
    .tx_data            (   tx_data         )    
);

// rfifo_ren, tx_ready
always @(posedge CLK or negedge rst_n) begin
    if (rst_n == 'b0)
        begin
        rfifo_ren   <=  1'b0;
        tx_ready    <=  1'b0;
        end
    else if (tx_done == 1'b1 && rfifo_empty == 1'b0 && cnt == 3'd0)
        begin
        rfifo_ren   <=  1'b1;
        tx_ready    <=  rfifo_ren   ;
        end
    else
        begin
        rfifo_ren   <=  1'b0;
        tx_ready    <=  rfifo_ren   ;
        end
end

// cnt
always @(posedge CLK or negedge rst_n) begin
    if (rst_n == 1'b0)
        cnt     <=  3'd0        ;
    else if (tx_done == 1'b1 && rfifo_empty == 1'b0)
        cnt     <=  cnt + 3'd1  ;
    else
        cnt     <=  3'd0        ;
end

// data_trans
assign data_trans = wfifo_ren | rfifo_wen   ;
endmodule