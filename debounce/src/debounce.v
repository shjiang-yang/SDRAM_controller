// ================================================
// 
// designer:            yang shjiang
// date:                2020-07-25
// description:         the debounce module
// 
// ================================================

module debounce #(
    parameter           CLK_CYC =   10
)(
    // system signals
    input               sysclk      ,
    // key
    input               key_in      ,
    // output
    output              key_out     
);

// ============================================
// ******** define params/signals *********
// ============================================
localparam              CNT_END     =   10_000_000/CLK_CYC  ;
localparam              CNT_WIDTH   =   32     ;

reg     [CNT_WIDTH-1:0] cnt =   'd0     ;
reg     [ 2:0]          key_in_r        ;

wire                    trig            ;

// ============================================
// ********** main code ********************
// ============================================
// detect trig
always @(posedge sysclk) begin
    key_in_r    <=  {key_in_r[1:0], key_in} ;
end

assign trig = key_in_r[2] ^ key_in_r[1] ;

// cnt
always @(posedge sysclk) begin
    if (trig == 1'b1)
        cnt     <=  'd0 ;
    else if (cnt == CNT_END)
        cnt     <=  cnt ;
    else
        cnt     <=  cnt + 'd1   ;
end

// key_out
assign key_out = (cnt == CNT_END) ? key_in_r[2] : key_out   ;


endmodule