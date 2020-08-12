// =======================================================
// 
// designer:                yang shjiang
// date:                    2020-07-29
// description:             to test the sdram top module
// 
// =======================================================
`timescale 1ns/1ns

module tb_SDRAM_TOP;

// ------------- define params and signals -------------------
reg             sysclk_100M ;
reg             rst_n       ;
reg             w_clk       ;
reg             wen         ;
reg     [15:0]  din         ;
reg             r_clk       ;
reg             ren         ;

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
wire    [15:0]  dout        ;

// -------------------- main code ----------------------------

initial begin
    sysclk_100M     = 0;
    rst_n           = 0;
    w_clk           = 0;
    wen             = 0;
    ren             = 0;
    r_clk           = 0;
    din             = 16'h00;
    #100;
    rst_n           = 1;
    #201_000;
    wen             = 1;
    ren             = 1;
    forever begin
        @(posedge w_clk)
        din = din + 16'h01;
    end

end

always #5 sysclk_100M = ~sysclk_100M;

always #100 w_clk = ~w_clk;

always #46 r_clk = ~r_clk;





SDRAM_TOP SDRAM_TOP_inst(
    // system signals
    .sysclk_100M                (   sysclk_100M     )   ,
    .rst_n                      (   rst_n           )   ,
    // sdram interface
    .CLK                        (   CLK             )   ,
    .CKE                        (   CKE             )   ,
    .cs_n                       (   cs_n            )   ,
    .ras_n                      (   ras_n           )   ,
    .cas_n                      (   cas_n           )   ,
    .we_n                       (   we_n            )   ,
    .addr                       (   addr            )   ,
    .ba                         (   ba              )   ,
    .dqm                        (   dqm             )   ,
    .dq                         (   dq              )   ,
    // write fifo interface
    .w_clk                      (   w_clk           )   ,
    .wen                        (   wen             )   ,
    .din                        (   din             )   ,
    // read fifo interface
    .r_clk                      (   r_clk           ),
    .ren                        (   ren             ),
    .dout                       (   dout            )
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