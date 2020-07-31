// ==================================================
// 
// designer:            yang shjiang
// date:                2020-07-28
// description:         to test the async FIFO
// 
// ==================================================
`timescale 1ns/1ns

module tb_async_FIFO;

reg             rst_n   ;
reg             w_clk   ;
reg             r_clk   ;
reg             wen     ;
reg             ren     ;
reg     [15:0]  din     ;

wire    [ 7:0]  dout    ;
wire    [ 3:0]  data_count;

initial begin
    rst_n   = 0     ;
    w_clk   = 0     ;
    r_clk   = 0     ;
    wen     = 0     ;
    ren     = 0     ;
    din     = 16'hff;
    #100;
    rst_n   = 1     ;
    #100;
    wen     = 1     ;
    ren     = 1     ;
    #5;
    din     = 16'haa;
    #350;
    wen     = 0     ;
    #20;
    ren     = 1     ;
    #300;
    $stop;
end

always #10 w_clk = ~w_clk   ;

always #5  r_clk = ~r_clk   ;






async_FIFO async_FIFO_inst(
    // system signal 
    .rst_n                  (   rst_n       ),
    // write interface
    .w_clk                  (   w_clk       ),
    .wen                    (   wen         ),
    .din                    (   din         ),
    .full                   (   full        ),
    // read interface
    .r_clk                  (   r_clk       ),
    .ren                    (   ren         ),
    .dout                   (   dout        ),
    .empty                  (   empty       ),
    // data num
    .data_count             (   data_count  )
);

endmodule