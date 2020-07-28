//===============================================
// 
// designer:        yang shjiang
// date:            2020-07-16
// description:     uart transfer module
//
//===============================================
// `include "config.v"

module uart_tx #(
    parameter           BAUD_RATE   =   115200
)(
    // system signal
    input               sys_clk_100M    ,
    input               rst_n           ,
    // uart interface
    output  reg         tx              ,
    // others
    input               tx_ready        ,  // data_ready
    output              tx_done         ,
    input       [7:0]   tx_data         
);


//====================================================\
// ********* define param and internal signal ******
//====================================================/

localparam  BAUD_END = (1_000_000_000)/(BAUD_RATE * 10) ;


localparam  BIT_END  = 9    ;

wire            tx_trig     ;
reg     [7:0]   tx_data_r   ;
reg             tx_flag     ;
reg     [12:0]  baud_cnt    ;
reg             bit_flag    ;
reg     [3:0]   bit_cnt     ;

reg     [2:0]   tx_ready_r  ;




//====================================================\
// ***************** main code ******************
//====================================================/
// tx_trig
always @(posedge sys_clk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        tx_ready_r <= 3'b000        ;
    else
        tx_ready_r <= {tx_ready_r[1:0], tx_ready};
end

assign tx_trig = tx_ready_r[1] & (~tx_ready_r[2]);


// tx_data_r
always @(posedge sys_clk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        tx_data_r <= 8'd0;
    else if (tx_trig == 1'b1)
        tx_data_r <= tx_data;
end


// tx_flag
always @(posedge sys_clk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        tx_flag <= 1'b0;
    else if (tx_trig == 1'b1)
        tx_flag <= 1'b1;
    else if (bit_flag == 1'b1 && bit_cnt == BIT_END)
        tx_flag <= 1'b0;
end

// tx_done
assign tx_done = ~tx_flag   ;

// baud_cnt
always @(posedge sys_clk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        baud_cnt <= 13'd0;
    else if( baud_cnt == BAUD_END)
        baud_cnt <= 13'd0;
    else if(tx_flag == 1'b1)
        baud_cnt <= baud_cnt + 13'd1;
    else
        baud_cnt <= 13'd0;
end


// bit_flag
always @(posedge sys_clk_100M or negedge rst_n) begin
    if(rst_n == 1'b0)
        bit_flag <= 1'b0;
    else if(baud_cnt == BAUD_END)
        bit_flag <= 1'b1;
    else
        bit_flag <= 1'b0;
end


// bit_cnt
always @(posedge sys_clk_100M or negedge rst_n) begin
    if(rst_n == 1'b0)
        bit_cnt <= 4'd0;
    else if(bit_flag == 1'b1 && bit_cnt == BIT_END)
        bit_cnt <= 4'd0;
    else if(bit_flag == 1'b1)
        bit_cnt <= bit_cnt + 4'd1;
end


// tx
always @(posedge sys_clk_100M or negedge rst_n) begin
    if(rst_n == 1'b0)
        tx <= 1'b1;
    else if(tx_flag == 1'b1)
        case (bit_cnt)
            0: tx <= 1'b0;
            1: tx <= tx_data_r[0];
            2: tx <= tx_data_r[1];
            3: tx <= tx_data_r[2];
            4: tx <= tx_data_r[3];
            5: tx <= tx_data_r[4];
            6: tx <= tx_data_r[5];
            7: tx <= tx_data_r[6];
            8: tx <= tx_data_r[7];
            9: tx <= 1'b1;
            default: tx <= 1'b1;
        endcase
    else
        tx <= 1'b1;
end

endmodule