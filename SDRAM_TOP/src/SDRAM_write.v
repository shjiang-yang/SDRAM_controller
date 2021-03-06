// ====================================================
// 
// designer:        yang shjiang
// date:            2020-07-21
// description:     sdram write module
// 
// ====================================================


module SDRAM_write(
    // system singals
    input                       sysclk_100M     ,
    input                       rst_n           ,
    // arbit
    output  reg                 arbit_write_req ,
    input                       arbit_write_ack ,
    output  reg                 arbit_prech_end ,
    output  reg                 write_end       ,
    // from refresh module
    input                       refresh_req     ,
    // sdram
    output  reg     [ 3:0]      cmd_reg         ,
    output  reg     [12:0]      sdram_addr      ,
    output  reg     [ 1:0]      sdram_bank_addr ,
    // others
    input                       write_trig      ,
    output  reg                 data_vld        
);


// =====================================================\
// ********* define parrams and signals ************
// =====================================================/
localparam          S_IDLE      =   5'b0_0001   ;
localparam          S_REQ       =   5'b0_0010   ;
localparam          S_ACT       =   5'b0_0100   ;
localparam          S_WRITE     =   5'b0_1000   ;
localparam          S_PRECHG    =   5'b1_0000   ;

localparam          ACTIVE_CMD  =   4'b0011     ;
localparam          WRITE_CMD   =   4'b0100     ;
localparam          NOP         =   4'b0111     ;
localparam          PRECHARGE   =   4'b0010     ;


localparam          ACT_END     =   1           ;
localparam          BURST_END   =   3           ;
localparam          PRECH_END   =   2           ;
localparam          WRITE_TIMEs =   2           ;


reg     [ 4:0]      state       ;
reg                 act_cnt     ;
reg     [ 1:0]      burst_cnt   ;
reg     [ 7:0]      write_cnt   ;
reg     [ 1:0]      prech_cnt   ;
wire                row_end     ;
reg     [12:0]      row_addr    ;
reg     [ 6:0]      col_addr_p  ;
reg     [ 2:0]      trig_r      ;

wire                trig_rise   ;


// =====================================================\
// **************** main code **********************
// =====================================================/
// trig_rise
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        trig_r  <=  3'b000  ;
    else
        trig_r  <=  {trig_r[1:0], write_trig}   ;
end

assign trig_rise = trig_r[1] & (~trig_r[2]);

// state machine
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        state   <=  S_IDLE  ;
    else case (state)
        S_IDLE:
                if (trig_rise == 1'b1)
                    state   <=  S_REQ   ;
                else
                    state   <=  S_IDLE  ;
        S_REQ:
                if (arbit_write_ack == 1'b1)
                    state   <=  S_ACT   ;
                else
                    state   <=  S_REQ   ;
        S_ACT:
                if (act_cnt == ACT_END)
                    state   <=  S_WRITE ;
                else
                    state   <=  S_ACT   ;
        S_WRITE:
                if (burst_cnt == 2'd3 && (refresh_req == 1'b1 || write_end == 1'b1 || row_end == 1'b1)     )
                    state   <=  S_PRECHG;
                else
                    state   <=  S_WRITE ;
        S_PRECHG:
                if (prech_cnt == PRECH_END && write_end == 1'b1)
                    state   <=  S_IDLE  ;
                else if (prech_cnt == PRECH_END && refresh_req == 1'b1)
                    state   <=  S_REQ   ;
                else if (prech_cnt == PRECH_END)
                    state   <=  S_ACT   ;
        default:    state   <=  S_IDLE  ;
    endcase
end

// row_end
assign row_end = ({col_addr_p, burst_cnt} == 9'b1_1111_1111) ? 1'b1 : 1'b0;

// arbit_write_req
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        arbit_write_req <= 1'b0 ;
    else if (state == S_REQ)
        arbit_write_req <= 1'b1 ;
    else
        arbit_write_req <= 1'b0 ;
end

// write_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        write_cnt   <=  8'd0    ;
    else if (state == S_IDLE)
        write_cnt   <=  8'd0    ;
    else if (burst_cnt == 2'd1 && write_cnt == WRITE_TIMEs)
        write_cnt   <=  8'd0    ;
    else if (burst_cnt == 2'd1)
        write_cnt   <= write_cnt + 8'd1 ;
end

// write_end
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        write_end   <=  1'b0    ;
    else if (burst_cnt == 2'd2 && write_cnt == WRITE_TIMEs)
        write_end   <=  1'b1    ;
    else if (state == S_ACT)
        write_end   <=  1'b0    ;
end

// act_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        act_cnt <=  1'd0;
    else if (state == S_ACT)
        act_cnt <=  1'b1;
    else
        act_cnt <=  1'b0;
end

// prech_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        prech_cnt <=    2'b0;
    else if (state == S_PRECHG && prech_cnt == PRECH_END)
        prech_cnt <=    prech_cnt;
    else if (state == S_PRECHG)
        prech_cnt <=    prech_cnt + 2'd1;
    else
        prech_cnt <=    2'b0;
end

// arbit_prech_end
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        arbit_prech_end <=  1'b0 ;
    else if (prech_cnt == PRECH_END)
        arbit_prech_end <=  1'b1 ;
    else
        arbit_prech_end <=  1'b0 ;
end

// data_vld
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        data_vld    <=  1'b0    ;
    else if (state == S_WRITE)
        data_vld    <=  1'b1    ;
    else
        data_vld    <=  1'b0    ;
end

// burst_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        burst_cnt   <=  2'd0    ;
    else if (state == S_WRITE && burst_cnt == BURST_END)
        burst_cnt   <=  2'd0    ;
    else if (state == S_WRITE)
        burst_cnt   <=  burst_cnt + 2'd1    ;
    else
        burst_cnt   <=  2'd0    ;
end

// cmd_reg, sdram_addr, sdram_bank_addr
always @(posedge sysclk_100M) begin
    case (state)
        S_ACT: 
                if (act_cnt == 1'd0) begin
                    cmd_reg         =       ACTIVE_CMD        ;
                    sdram_addr      =       row_addr          ;
                    sdram_bank_addr =       sdram_bank_addr   ;
                    end
                else begin
                    cmd_reg         =       NOP               ;
                    sdram_addr      =       row_addr          ;
                    sdram_bank_addr =       sdram_bank_addr   ;
                    end
        S_WRITE:
                if (burst_cnt == 2'd0) begin
                    cmd_reg         =       WRITE_CMD         ;
                    sdram_addr      =       {4'b0000,col_addr_p, burst_cnt}    ;
                    sdram_bank_addr =       sdram_bank_addr   ;
                    end
                else begin
                    cmd_reg         =       NOP               ;
                    sdram_addr      =       {4'b0000,col_addr_p, burst_cnt}    ;
                    sdram_bank_addr =       sdram_bank_addr   ;
                    end
        S_PRECHG:
                if (prech_cnt == 1'd1) begin
                    cmd_reg         =       PRECHARGE         ;
                    sdram_addr      =       {4'b0000,col_addr_p, burst_cnt}    ;
                    sdram_bank_addr =       sdram_bank_addr   ;
                    end
                else begin
                    cmd_reg         =       NOP               ;
                    sdram_addr      =       {4'b0000,col_addr_p, burst_cnt}    ;
                    sdram_bank_addr =       sdram_bank_addr   ;
                    end
        default: 
                    begin
                    cmd_reg         =       NOP               ;
                    sdram_addr      =       {4'b0000,col_addr_p, burst_cnt}    ;
                    sdram_bank_addr =       sdram_bank_addr   ;
                    end
    endcase
end

// col_addr_p
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        col_addr_p <= 7'd0;
    else if (state == S_WRITE && burst_cnt == BURST_END)
        col_addr_p <= col_addr_p + 7'd1;
end

// row_addr
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        {sdram_bank_addr, row_addr} <=  15'd0;
    else if (state == S_WRITE && {col_addr_p, burst_cnt} == 9'b1_1111_1111)
        {sdram_bank_addr, row_addr} <=  {sdram_bank_addr, row_addr} + 15'd1;
end

endmodule