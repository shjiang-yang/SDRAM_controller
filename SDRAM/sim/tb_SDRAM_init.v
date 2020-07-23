// ==================================================
// 
// designer:            yang shjiang
// date:                2020-07-18
// description:         to test the SDRAM_init_timing.v 
// 
// ==================================================

`timescale 1ns/1ns


module tb_SDRAM_init;

// ==================================================\
// *********** define parameter and signal *****
// ==================================================/
reg     sysclk_100M     ;
reg     rst_n           ;

wire        [ 3:0]  cmd_reg         ;
wire        [1:0]   sdram_ba        ;
wire        [12:0]  sdram_addr      ;
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


SDRAM_init   SDRAM_init_inst(
    // system signal
    .sysclk_100M        (   sysclk_100M     )   ,
    .rst_n              (   rst_n           )   ,
    // SDRAM
    .cmd_reg            (   cmd_reg         )   ,
    .sdram_ba           (   sdram_ba        )   ,
    .sdram_addr         (   sdram_addr      )   ,
    // init end flag
    .init_end_flag      (   init_end_flag   )
);



endmodule