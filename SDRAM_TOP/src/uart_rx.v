//===============================================
// 
// designer:        yang shjiang
// date:            2020-07-13
// description:     uart receive module
//
//===============================================

module uart_rx #(
    parameter           BAUD_RATE   =   115200
)(
    //system signal
    input               sclk_100M       ,
    input               s_rst_n         ,
    //uart interface
    input               rx              ,
    //others
    output  reg [7:0]   rx_data         ,
    output  reg         done_flag       
);


//================================================================\
// ********* define parameter and internal signal **********
//================================================================/
localparam      BAUD_END        =       (1_000_000_000)/(BAUD_RATE * 10)-1            ;

localparam      BAUD_M          =       (BAUD_END+1)/2-1    ;
localparam      BIT_NUM         =       8                   ;

reg                 rx_r1       ;
reg                 rx_r2       ;
reg                 rx_r3       ;
reg                 rx_flag     ;
reg     [12:0]      baud_cnt    ;
reg                 bit_flag    ;
reg     [3:0]       bit_cnt     ;
wire                rx_start    ;


//================================================================\
// ******************** main code **************************
//================================================================/
always @(posedge sclk_100M) begin
    rx_r1   <=      rx      ;
    rx_r2   <=      rx_r1   ;
    rx_r3   <=      rx_r2   ;
end


assign rx_start =   (~rx_r2) & rx_r3    ;


always @(posedge sclk_100M or negedge s_rst_n) begin
    if (s_rst_n == 1'b0)
        rx_flag     <=      1'b0    ;
    else if (rx_start == 1'b1)
        rx_flag     <=      1'b1    ;
    else if (bit_cnt == 4'd0 && baud_cnt == BAUD_END)
        rx_flag     <=      1'b0    ;
    else
        rx_flag     <=      rx_flag ;
end


always @(posedge sclk_100M or negedge s_rst_n) begin
    if (s_rst_n == 1'b0)
        baud_cnt    <=      13'd0   ;
    else if (baud_cnt == BAUD_END)
        baud_cnt    <=      13'd0   ;
    else if (rx_flag == 1'b1)
        baud_cnt    <=  baud_cnt + 13'd1;
    else
        baud_cnt    <=      13'd0   ;
end


always @(posedge sclk_100M or negedge s_rst_n) begin
    if (s_rst_n == 1'b0)
        bit_flag    <=      1'b0    ;
    else if (baud_cnt == BAUD_M)
        bit_flag    <=      1'b1    ;
    else
        bit_flag    <=      1'b0    ;
end


always @(posedge sclk_100M or negedge s_rst_n) begin
    if (s_rst_n == 1'b0)
        bit_cnt     <=      4'd0    ;
    else if (rx_flag == 1'b0)
        bit_cnt     <=      4'd0    ;
    else if (bit_cnt == BIT_NUM && bit_flag == 1'b1)
        bit_cnt     <=      4'd0    ;
    else if (bit_flag == 1'b1)
        bit_cnt     <=  bit_cnt + 4'd1  ;
end


always @(posedge sclk_100M or negedge s_rst_n) begin
    if (s_rst_n == 1'b0)
        rx_data     <=      8'd0    ;
    else if (bit_flag == 1'b1)
        rx_data     <=  {rx_r3, rx_data[7:1]}   ;
end


always @(posedge sclk_100M or negedge s_rst_n) begin
    if (s_rst_n == 1'b0) 
        done_flag   <=      1'b0    ;
    else if (bit_flag == 1'b1 && bit_cnt == BIT_NUM)
        done_flag   <=      1'b1    ;
    else
        done_flag   <=      1'b0    ;
end

endmodule