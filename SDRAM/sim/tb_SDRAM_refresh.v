// ====================================================
// 
// designer:        yang shjiang
// date:            2020-07-21
// description:     to test sdram refresh module
// 
// ====================================================
`timescale 1ns/1ns

module tb_SDRAM_refresh;

// ===================================================\
// *********** define params and signals **********
// ===================================================/
reg                 sysclk_100M         ;
reg                 rst_n               ;
reg                 arbit_refresh_ack   ;

wire    [ 3:0]      cmd_reg             ;
wire                arbit_refresh_req   ;
wire                refresh_end         ;


// ===================================================\
// ****************** main code *******************
// ===================================================/
initial begin
    sysclk_100M         = 0     ;
    rst_n               = 0     ;
    arbit_refresh_ack   = 0     ;
    #100;
    rst_n               = 1     ;
    #7910;
    arbit_refresh_ack   = 1     ;
    #80;
    arbit_refresh_ack   = 0     ;
    #100;
    $stop;
end

always #5 sysclk_100M = ~ sysclk_100M;



SDRAM_refresh SDRAM_refresh_inst(
    // system signal 
    .sysclk_100M            (   sysclk_100M         )   ,        // note: ~sdram_clk
    .rst_n                  (   rst_n               )   ,
    // sdram
    .cmd_reg                (   cmd_reg             )   ,
    // arbit
    .arbit_refresh_ack      (   arbit_refresh_ack   )   ,
    .arbit_refresh_req      (   arbit_refresh_req   )   ,
    .refresh_end            (   refresh_end         )
);

endmodule