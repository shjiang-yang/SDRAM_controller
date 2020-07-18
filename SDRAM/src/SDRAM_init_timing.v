// ==================================================
// 
// designer:            yang shjiang
// date:                2020-07-18
// description:         to initial the SDRAM 
// 
// ==================================================

module SDRAM_init_timing(
    // system signal
    input                   sysclk_100M     ,
    input                   rst_n           ,
    // SDRAM
    output                  sdram_clk       ,
    output                  sdram_cke       ,
    output                  sdram_cs_n      ,
    output                  sdram_ras_n     ,
    output                  sdram_cas_n     ,
    output                  sdram_we_n      ,
    output          [1:0]   sdram_ba        ,
    output          [1:0]   sdram_dqm       ,
    output          [12:0]  sdram_addr      ,
    inout           [15:0]  sdram_dq        ,
    // init end flag
    output                  init_end_flag
);


// ==================================================\
// *********** define parameter and signal *****
// ==================================================/
localparam              POWERUP_TIME    =   20000   ;
localparam              CMD_CNT         =   13      ;

// CMD -- cs_n, ras_n, cas_n, we_n
localparam              NOP         =   4'b0111 ;
localparam              PRECHARGE   =   4'b0010 ;
localparam              REFRESH     =   4'b0001 ;
localparam              MODEREG_SET =   4'b0000 ;

reg     [14:0]      powerup_cnt     ;
reg     [4:0]       cmd_cnt         ;
wire                powerup_done    ;
reg     [3:0]       cmd_bus         ;


// ==================================================\
// ***************** main code *****************
// ==================================================/

assign  sdram_clk   =   ~sysclk_100M    ;
assign  sdram_cke   =   1'b1            ;
assign  sdram_ba    =   2'b00           ;
assign  sdram_dqm   =   2'b00           ;
assign  sdram_dq    =   16'hzzzz        ;
assign  {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = cmd_bus;


// power up
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        powerup_cnt     <=  11'd0   ;
    else if (powerup_cnt == POWERUP_TIME)
        powerup_cnt     <=  POWERUP_TIME   ;
    else
        powerup_cnt     <= powerup_cnt + 11'd1;
end

assign  powerup_done = (powerup_cnt == POWERUP_TIME) ? 1'b1 : 1'b0;


// cmd_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        cmd_cnt     <= 4'd0     ;
    else if (cmd_cnt == CMD_CNT)
        cmd_cnt     <= CMD_CNT  ;
    else if (powerup_done == 1'b1)
        cmd_cnt     <=  cmd_cnt + 4'd1;
end


// give cmd
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        cmd_bus    <=   NOP ;
    else
        case (cmd_cnt)
            0:  cmd_bus     <=   NOP         ;
            1:  cmd_bus     <=   PRECHARGE   ;
            3:  cmd_bus     <=   REFRESH     ;
            7:  cmd_bus     <=   REFRESH     ;
           11:  cmd_bus     <=   MODEREG_SET ;
            default: cmd_bus <= cmd_bus      ;
        endcase
end


// init end flag
assign init_end_flag = (cmd_cnt == CMD_CNT) ? 1'b1 : 1'b0;


// address
assign sdram_addr = (cmd_cnt == 12) ? 13'b0_0000_0011_0010 : 13'b0_0100_0000_0000;

endmodule