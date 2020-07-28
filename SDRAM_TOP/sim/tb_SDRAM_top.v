// ================================================
// 
// designer:            yang shjiang
// date:                2020-07-25
// description:         to test the sdram top module
// 
// ================================================
`timescale 1ns/1ns

module tb_SDRAM_top;

// ===============================================
// ********** define params and signals ******
// ===============================================
reg             osc_clk_50  ;
reg             key_rst_n   ;

reg             rx_232      ;

wire            tx_232      ;
wire            CLK         ;
wire            CKE         ;
wire            cs_n        ;
wire            ras_n       ;
wire            cas_n       ;
wire            we_n        ;
wire    [12:0]  addr        ;
wire    [ 1:0]  ba          ;
wire    [ 1:0]  dqm         ;
wire    [15:0]  dq          ;
wire            data_trans  ;


// =============================================
// ************** main code ****************
// =============================================
initial begin
    osc_clk_50      = 0 ;
    key_rst_n       = 0 ;
    rx_232          = 1 ;
    #10_000_000;
    #100;
    key_rst_n       = 1 ;
    #10_000_000;
    #201_000;
    forever begin
        tx_model(8'haa);
        tx_model(8'hbb);
        tx_model(8'hcc);
        tx_model(8'hdd);
        // #1000;
    end
end

always #5 osc_clk_50 = ~osc_clk_50  ;

task tx_model(
        input [ 7:0] data
    );
    begin
        #10;
        rx_232 = 0 ;
        #8680;
        rx_232 = data[0] ;
        #8680;
        rx_232 = data[1] ;
        #8680;
        rx_232 = data[2] ;
        #8680;
        rx_232 = data[3] ;
        #8680;
        rx_232 = data[4] ;
        #8680;
        rx_232 = data[5] ;
        #8680;
        rx_232 = data[6] ;
        #8680;
        rx_232 = data[7] ;
        #8680;
        rx_232 = 1 ;
        #8680;
    end
endtask








SDRAM_top SDRAM_top_isnt(
    // system singal
    .osc_clk_50             (   osc_clk_50      ),
    .key_rst_n              (   key_rst_n       ),
    // uart interface
    .rx_232                 (   rx_232          ),
    .tx_232                 (   tx_232          ),
    // sdram interface
    .CLK                    (   CLK             ),
    .CKE                    (   CKE             ),
    .cs_n                   (   cs_n            ),
    .ras_n                  (   ras_n           ),
    .cas_n                  (   cas_n           ),
    .we_n                   (   we_n            ),
    .addr                   (   addr            ),
    .ba                     (   ba              ),
    .dqm                    (   dqm             ),
    .dq                     (   dq              ),
    // led
    .data_trans             (   data_trans      )
);

sdram_model_plus sdram_model_plus_inst(
    .Clk                    (   CLK             ),
    .Cke                    (   CKE             ),
    .Cs_n                   (   cs_n            ),
    .Ras_n                  (   ras_n           ),
    .Cas_n                  (   cas_n           ),
    .We_n                   (   we_n            ),
    .Addr                   (   addr            ),
    .Ba                     (   ba              ),
    .Dqm                    (   dqm             ),
    .Dq                     (   dq              ),
    .Debug                  (   1'b1            )
);


endmodule

