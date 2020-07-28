// ===============================================
// 
// designer:            yang shjiang
// date:                2020-07-22
// description:         to test sdram read module
// 
// ===============================================
`timescale 1ns/1ns

module tb_SDRAM_read;


// ===============================================
// ********** define params and signals ********
// ===============================================
reg                     sysclk_100M         ;
reg                     rst_n               ;
reg                     refresh_req         ;
reg                     arbit_read_ack      ;
reg                     read_trig           ;

wire    [ 3:0]          cmd_reg             ; 
wire    [12:0]          sdram_addr          ; 
wire    [ 1:0]          sdram_bank_addr     ; 
wire                    arbit_read_req      ; 
wire                    arbit_read_end      ; 
wire                    data_vld            ; 

// ===============================================
// ********** define params and signals ********
// ===============================================
initial begin
    sysclk_100M     = 0 ;
    rst_n           = 0 ;
    refresh_req     = 0 ;
    arbit_read_ack  = 0 ;
    read_trig       = 0 ;
    #100;
    rst_n           = 1 ;
    #100;
    read_trig       = 1 ;
    #45;
    read_trig       = 0 ;
    #50;
    arbit_read_ack  = 1 ;
    #700;
    refresh_req     = 1 ;
    arbit_read_ack  = 0 ;
    #1000;
    $stop; 
end

always #5 sysclk_100M = ~sysclk_100M    ;



SDRAM_read SDRAM_read_inst (
    // system signals
    .sysclk_100M            (   sysclk_100M         )   ,
    .rst_n                  (   rst_n               )   ,
    // sdram
    .cmd_reg                (   cmd_reg             )   ,
    .sdram_addr             (   sdram_addr          )   ,
    .sdram_bank_addr        (   sdram_bank_addr     )   ,
    // from refresh
    .refresh_req            (   refresh_req         )   ,
    // from arbit
    .arbit_read_req         (   arbit_read_req      )   ,
    .arbit_read_ack         (   arbit_read_ack      )   ,
    .arbit_read_end         (   arbit_read_end      )   ,
    // others
    .read_trig              (   read_trig           )   ,
    .data_vld               (   data_vld            )   
);


endmodule