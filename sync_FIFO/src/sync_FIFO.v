// ==================================================
// 
// designer:        yang shjiang
// date:            2020-07-22
// description:     sync FIFO
// 
// ==================================================


module sync_FIFO #(
    parameter           DEPTH   =   4   ,
    parameter           WIDTH   =   8   
)(
    // system signals
    input               sysclk_100M     ,
    input               rst_n           ,
    // write port
    output              full            ,
    input               write_en        ,
    input       [ 7:0]  write_data      ,
    // read port
    output              empty           ,
    input               read_en         ,
    output  reg [ 7:0]  read_data       
);

// ================================================
// ********* define params and signals *********
// ================================================
localparam                  DEPTH_BIT   =   $clog2(DEPTH)   ;

reg     [ WIDTH-1:0]      mem[DEPTH-1:0]      ;
reg     [DEPTH_BIT:0]     write_pointer       ;
reg     [DEPTH_BIT:0]     read_pointer        ;

wire                      least_eq            ;



// ================================================
// **************** main code ***************
// ================================================
// write_pointer
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        write_pointer   <=  'd0    ;
    else if (write_en == 1'b1 && full == 1'b0)
        write_pointer   <=  write_pointer + 'd1    ;
end

// mem
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0) begin: init_mem
        integer i;
        for (i=0; i<=DEPTH; i=i+1) mem[i] <= 'd0;
    end
    else if (write_en == 1'b1 && full == 1'b0)
        mem[write_pointer[DEPTH_BIT-1:0]]  <=  write_data  ;
end

// read_pointer
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        read_pointer   <=  'd0    ;
    else if (read_en == 1'b1 && empty == 1'b0)
        read_pointer   <=  read_pointer + 'd1    ;
end

// read_data
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        read_data   <=  'd0    ;
    else if (read_en == 1'b1 && empty == 1'b0)
        read_data   <=  mem[read_pointer[DEPTH_BIT-1:0]]   ;
end

// full
assign least_eq = (write_pointer[DEPTH_BIT-1:0] == read_pointer[DEPTH_BIT-1:0]) ? 1'b1 : 1'b0   ;
assign full = (write_pointer[DEPTH_BIT] ^ read_pointer[DEPTH_BIT]) & least_eq   ;

// empty
assign empty = (write_pointer == read_pointer) ? 1'b1 : 1'b0;

endmodule