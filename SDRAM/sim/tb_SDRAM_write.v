// ====================================================
// 
// designer:        yang shjiang
// date:            2020-07-21
// description:     to test sdram write module
// 
// ====================================================
`timescale 1ns/1ns

module tb_SDRAM_write;

// =====================================================\
// ********* define parrams and signals ************
// =====================================================/
reg             sysclk_100M     ;
reg             rst_n           ;

reg             write_trig      ;
reg             arbit_write_ack ;
reg             refresh_req     ;

wire            arbit_write_req ;
wire            write_end       ;
wire    [ 3:0]  cmd_reg         ;
wire    [12:0]  sdram_addr      ;
wire    [ 1:0]  sdram_bank_addr ;
wire            data_vld        ;
wire            arbit_prech_end ;


// =====================================================\
// **************** main code **********************
// =====================================================/
initial begin
    sysclk_100M         = 0 ;
    rst_n               = 0 ;
    arbit_write_ack     = 0 ;
    refresh_req         = 0 ;
    write_trig          = 0 ;
    #100;
    rst_n               = 1 ;
    #100;
    write_trig          = 1 ;
    #500;
    arbit_write_ack     = 1 ;
    #70;
    refresh_req         = 1 ;
    #20;
    arbit_write_ack     = 0 ;
    #600;
    refresh_req         = 0 ;
    #20;
    arbit_write_ack     = 1 ;
    #100;
    $stop;
end

always #5 sysclk_100M = ~sysclk_100M;


SDRAM_write SDRAM_write_inst(
    // system singals
    .sysclk_100M            (   sysclk_100M         ) ,
    .rst_n                  (   rst_n               ) ,
    // arbit
    .arbit_write_req        (   arbit_write_req     ) ,
    .arbit_write_ack        (   arbit_write_ack     ) ,
    .write_end              (   write_end           ) ,
    .arbit_prech_end        (   arbit_prech_end     ) ,
    // from refresh module
    .refresh_req            (   refresh_req         ) ,
    // sdram
    .cmd_reg                (   cmd_reg             ) ,
    .sdram_addr             (   sdram_addr          ) ,
    .sdram_bank_addr        (   sdram_bank_addr     ) ,
    // from data cache
    .write_trig             (   write_trig          ) ,
    .data_vld               (   data_vld            ) 
);

endmodule