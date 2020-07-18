// ==================================================
// 
// designer:            yang shjiang
// date:                2020-07-18
// description:         to test the SDRAM_init_timing.v 
// 
// ==================================================

`timescale 1ns/1ns


module tb_SDRAM_init_timing;

// ==================================================\
// *********** define parameter and signal *****
// ==================================================/
reg     sysclk_100M     ;
reg     rst_n           ;

wire                sdram_clk       ;
wire                sdram_cke       ;
wire                sdram_cs_n      ;
wire                sdram_ras_n     ;
wire                sdram_cas_n     ;
wire                sdram_we_n      ;
wire        [1:0]   sdram_ba        ;
wire        [1:0]   sdram_dqm       ;
wire        [12:0]  sdram_addr      ;
wire        [15:0]  sdram_dq        ;
wire                init_end_flag   ;




// ==================================================\
// ***************** main code *****************
// ==================================================/
initial begin
    sysclk_100M     =   1'b0    ;
    rst_n           =   1'b0    ;
    #100;
    rst_n           =   1'b1    ;
    #210_000;
    $stop;
end

always #5 sysclk_100M = ~sysclk_100M;


SDRAM_init_timing   SDRAM_init_timing_inst(
    // system signal
    .sysclk_100M        (   sysclk_100M     )   ,
    .rst_n              (   rst_n           )   ,
    // SDRAM
    .sdram_clk          (   sdram_clk       )   ,
    .sdram_cke          (   sdram_cke       )   ,
    .sdram_cs_n         (   sdram_cs_n      )   ,
    .sdram_ras_n        (   sdram_ras_n     )   ,
    .sdram_cas_n        (   sdram_cas_n     )   ,
    .sdram_we_n         (   sdram_we_n      )   ,
    .sdram_ba           (   sdram_ba        )   ,
    .sdram_dqm          (   sdram_dqm       )   ,
    .sdram_addr         (   sdram_addr      )   ,
    .sdram_dq           (   sdram_dq        )   ,
    // init end flag
    .init_end_flag      (   init_end_flag   )
);



endmodule