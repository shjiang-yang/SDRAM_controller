// ==================================================
// 
// designer:            yang shjiang
// date:                2020-07-28
// description:         the async FIFO
// 
// ==================================================

`include "./config.v"

// ----------------- module ------------------------
module async_FIFO(
    // system signal 
    input                                   rst_n       ,
    // write interface
    input                                   w_clk       ,
    input                                   wen         ,
    input           [`FIFO_WIDTH-1:0]       din         ,
    output                                  full        ,
    // read interface
    input                                   r_clk       ,
    input                                   ren         ,
    output  reg     [`FIFO_WIDTH-1:0]       dout        ,
    output                                  empty       ,
    // data num
    output  reg     [`POINTER_WIDTH-1:0]    data_count
);

// -------------- define params and signals ----------------
reg     [`POINTER_WIDTH-1:0]        write_p             ;
wire    [`POINTER_WIDTH-1:0]        write_p_gray        ;
reg     [`POINTER_WIDTH-1:0]        write_p_gray_r      ;
reg     [`POINTER_WIDTH-1:0]        read_p_gray_sync1   ;
reg     [`POINTER_WIDTH-1:0]        read_p_gray_sync2   ;
reg     [`POINTER_WIDTH-1:0]        read_p_sync        ;
reg     [`POINTER_WIDTH-1:0]        read_p_sync_r      ;

reg     [`POINTER_WIDTH-1:0]        read_p              ;
wire    [`POINTER_WIDTH-1:0]        read_p_gray         ;
reg     [`POINTER_WIDTH-1:0]        read_p_gray_r       ;
reg     [`POINTER_WIDTH-1:0]        write_p_gray_sync1  ;
reg     [`POINTER_WIDTH-1:0]        write_p_gray_sync2  ;
reg     [`POINTER_WIDTH-1:0]        write_p_sync        ;
reg     [`POINTER_WIDTH-1:0]        write_p_sync_r      ;

reg     [`FIFO_WIDTH-1:0]           mem[`FIFO_DEPTH-1:0]  ;

// -------------- main code --------------------------------
// ******* write
// write fifo
always @(posedge w_clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin: write_mem
        integer i   ;
        for (i=0; i<`FIFO_DEPTH; i=i+1)
            mem[i] <=   `FIFO_WIDTH'd0      ;
    end
    else if (wen == 1'b1 && full==1'b0)
        mem[write_p[`POINTER_WIDTH-2:0]]    <=  din ;
    else
        mem[write_p[`POINTER_WIDTH-2:0]]    <=  mem[write_p[`POINTER_WIDTH-2:0]]    ;
end


// write_p
always @(posedge w_clk or negedge rst_n) begin
    if (rst_n == 1'b0)
        write_p <=  `POINTER_WIDTH'd0   ;
    else if (wen == 1'b1 && full==1'b0)
        write_p <=  write_p + `POINTER_WIDTH'd1 ;
    else
        write_p <=  write_p ;
end

// write_p_gray
assign write_p_gray = {1'b0, write_p[`POINTER_WIDTH-1:1]} ^ write_p ;

// write_p_gray_r
always @(posedge w_clk)
    write_p_gray_r  <=  write_p_gray    ;

// read_p_gray_sync
always @(posedge w_clk) begin
    read_p_gray_sync1   <=  read_p_gray_r       ;
    read_p_gray_sync2   <=  read_p_gray_sync1   ;
end

// read_p_sync
always @(read_p_gray_sync2) begin: read_sync
    integer i ;
    for (i=`POINTER_WIDTH-1; i>=0; i=i-1) begin
        if (i == `POINTER_WIDTH-1)
            read_p_sync[i] = read_p_gray_sync2[i]   ;
        else
            read_p_sync[i] = read_p_gray_sync2[i] ^ read_p_sync[i+1]    ;
    end
end

// read_p_sync_r
always @(posedge w_clk)
    read_p_sync_r   <=  read_p_sync ;

// full
assign full = ( {~write_p[`POINTER_WIDTH-1], write_p[`POINTER_WIDTH-2:0]} == read_p_sync_r) ? 1'b1 : 1'b0    ;

// --------------------------
// ******* read
// dout
always @(posedge r_clk or negedge rst_n) begin
    if (rst_n == 1'b0)
        dout    <=  `POINTER_WIDTH'd0   ;
    else if (ren == 1'b1 && empty == 1'b0)
        dout    <=  mem[read_p[`POINTER_WIDTH-2:0]]         ;
    else
        dout    <=  dout                ;
end

// read_p
always @(posedge r_clk or negedge rst_n) begin
    if (rst_n == 1'b0)
        read_p  <=  `POINTER_WIDTH'd0   ;
    else if (ren == 1'b1 && empty == 1'b0)
        read_p  <=  read_p + `POINTER_WIDTH'd1  ;
    else 
        read_p  <=  read_p  ;
end

// read_p_gray
assign read_p_gray = {1'b0, read_p[`POINTER_WIDTH-1:1]} ^ read_p    ;

// read_p_gray_r
always @(posedge r_clk)
    read_p_gray_r   <=  read_p_gray ;

// write_p_gray_sync
always @(posedge r_clk) begin
    write_p_gray_sync1  <=  write_p_gray_r      ;
    write_p_gray_sync2  <=  write_p_gray_sync1  ;
end

// write_p_sync
always @(write_p_gray_sync2) begin: write_bin
    integer i ;
    for (i=`POINTER_WIDTH-1; i>=0; i=i-1) begin
        if (i == `POINTER_WIDTH-1)
            write_p_sync[i] = write_p_gray_sync2[i] ;
        else
            write_p_sync[i] = write_p_gray_sync2[i] ^ write_p_sync[i+1] ;
    end
end

// write_p_sync_r
always @(posedge r_clk)
    write_p_sync_r  <=  write_p_sync    ;

// empty
assign empty = (read_p == write_p_sync_r) ? 1'b1 : 1'b0   ;

// data_count
always @(posedge r_clk)
    data_count  <=  write_p_sync_r[`POINTER_WIDTH-1:0] + (~read_p[`POINTER_WIDTH-1:0]) + 1'b1    ;

endmodule