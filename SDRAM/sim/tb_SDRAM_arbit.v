// ======================================================
// 
// designer:            yang shjiang
// date:                2020-07-24
// description:         to test the sdram arbit module
// 
// ======================================================
`timescale 1ns/1ns

module tb_SDRAM_arbit;

// ===============================================
// ********* define params and signals ******
// ===============================================
reg                     sysclk_100M     ;
reg                     rst_n           ;
reg                     write_trig      ;
reg             [ 7:0]   w_dq           ;

wire            [15:0]  dq              ;

wire                    CLK             ;
wire                    CKE             ;
wire                    cs_n            ;
wire                    ras_n           ;
wire                    cas_n           ;
wire                    we_n            ;
wire            [12:0]  addr            ;
wire            [ 1:0]  ba              ;
wire            [ 1:0]  dqm             ;
wire                    write_data_vld  ;
wire                    read_data_vld   ;
wire            [ 7:0]  r_dq            ;

// ===============================================
// ********* define params and signals ******
// ===============================================
initial begin
    sysclk_100M     = 0     ;
    rst_n           = 0     ;
    write_trig      = 0     ;
    w_dq            = 8'hdd ;
    #100;
    rst_n           = 1     ;
    #200_000;
    #100;
    write_trig      = 1     ;
    forever begin
        w_dq              = 8'haa ;
        #10;
        w_dq              = 8'haa ;
        #10;
        w_dq              = 8'haa ;
        #10;
        w_dq              = 8'haa ;
        #10;
    end
    $stop;
end


always #5 sysclk_100M = ~sysclk_100M    ;




SDRAM_arbit SDRAM_arbit_inst(
    // system signals
    .sysclk_100M            (   sysclk_100M     )   ,
    .rst_n                  (   rst_n           )   ,
    // sdram interface
    .CLK                    (   CLK             )   ,
    .CKE                    (   CKE             )   ,
    .cs_n                   (   cs_n            )   ,
    .ras_n                  (   ras_n           )   ,
    .cas_n                  (   cas_n           )   ,
    .we_n                   (   we_n            )   ,
    .addr                   (   addr            )   ,
    .ba                     (   ba              )   ,
    .dqm                    (   dqm             )   ,
    .dq                     (   dq              )   ,
    // write fifo
    .write_trig             (   write_trig      )   ,  // full
    .write_data_vld         (   write_data_vld  )   ,  // w_fifo ren
    .w_dq                   (   w_dq            )   ,
    // read fifo
    .read_data_vld          (   read_data_vld   )   ,  // r_fifo_wen
    .r_dq                   (   r_dq            )   
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