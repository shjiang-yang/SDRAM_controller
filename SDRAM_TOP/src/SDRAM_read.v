// ===============================================
// 
// designer:            yang shjiang
// date:                2020-07-22
// description:         sdram read module
// 
// ===============================================


module SDRAM_read(
    // system signals
    input                       sysclk_100M     ,
    input                       rst_n           ,
    // sdram
    output  reg     [ 3:0]      cmd_reg         ,
    output  reg     [12:0]      sdram_addr      ,
    output  reg     [ 1:0]      sdram_bank_addr ,
    // from refresh
    input                       refresh_req     ,
    // from arbit
    output  reg                 arbit_read_req  ,
    input                       arbit_read_ack  ,
    output  reg                 arbit_read_end  ,
    output  reg                 arbit_prech_end ,
    // others
    input                       read_trig       ,
    output  reg                 data_vld        
);

// ===============================================
// ********** define params and signals ********
// ===============================================
localparam                      BURST_TIMES =   2   ;  // debug
localparam                      ACT_END     =   1   ;
localparam                      READ_END    =   7   ;
localparam                      PRECH_END   =   2   ;

localparam                      READ_CMD    =   4'b0101 ;
localparam                      ACTIVE_CMD  =   4'b0011     ;
localparam                      NOP         =   4'b0111     ;
localparam                      PRECH_CMD   =   4'b0010     ;

localparam                      S_IDLE      =   5'b0_0001   ;
localparam                      S_REQ       =   5'b0_0010   ;
localparam                      S_ACT       =   5'b0_0100   ;
localparam                      S_READ      =   5'b0_1000   ;
localparam                      S_PRECH     =   5'b1_0000   ;

reg                             act_cnt     ;
reg                 [ 1:0]      prech_cnt   ;
reg                 [ 2:0]      read_cnt    ;
reg                 [ 3:0]      burst_cnt   ;
reg                 [ 2:0]      trig_r      ;
reg                 [ 4:0]      state       ;
reg                             row_end     ;
reg                 [12:0]      row_addr    ;
reg                 [ 8:0]      col_addr    ;
reg                             data_vld_r  ;

wire                            trig_rise   ;

// ===============================================
// ************** main code ******************
// ===============================================
// trig detect
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        trig_r  <=  3'b000  ;
    else
        trig_r  <=  {trig_r[1:0], read_trig};
end

assign trig_rise = (~trig_r[2]) & trig_r[1] ;

// state machine
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        state   <= S_IDLE   ;
    else 
    case (state)
        S_IDLE: begin
                if (trig_rise == 1'b1)
                    state   <=  S_REQ   ;
                else 
                    state   <=  S_IDLE  ;
                end
        S_REQ:  begin
                if (arbit_read_ack == 1'b1)
                    state   <=  S_ACT   ;
                else
                    state   <=  S_REQ   ;
                end
        S_ACT:  begin
                if (act_cnt == ACT_END)
                    state   <=  S_READ  ;
                else 
                    state   <=  S_ACT   ;
                end
        S_READ: begin
                if (read_cnt == READ_END && (arbit_read_end == 1'b1 || refresh_req == 1'b1 || row_end == 1'b1) )
                    state   <=  S_PRECH ;
                else
                    state   <=  S_READ  ;
                end
        S_PRECH:begin
                if (prech_cnt == PRECH_END && arbit_read_end == 1'b1)
                    state   <=  S_IDLE  ;
                else if (prech_cnt == PRECH_END && refresh_req == 1'b1)
                    state   <=  S_REQ   ;
                else if (prech_cnt == PRECH_END)
                    state   <=  S_ACT   ;
                else 
                    state   <=  S_PRECH ;
                end
        default:    state   <=  S_IDLE  ;
    endcase
end

// cmd_reg
always @(posedge sysclk_100M) begin
    case (state)
        S_ACT:  begin
                if (act_cnt == 1'b0)
                    cmd_reg <=  ACTIVE_CMD  ;
                else
                    cmd_reg <=  NOP         ;
                end
        S_READ: begin
                if (read_cnt == 3'd0)
                    cmd_reg <=  READ_CMD    ;
                else
                    cmd_reg <=  NOP         ;
                end
        S_PRECH:begin
                if (prech_cnt == 1'b1)
                    cmd_reg <=  PRECH_CMD   ;
                else
                    cmd_reg <=  NOP         ;
                end
        default: cmd_reg    <=  NOP         ;
    endcase
end

// arbit_read_req
always @(posedge sysclk_100M) begin
    case (state)
        S_REQ:      arbit_read_req  <=  1'b1    ;
        default:    arbit_read_req  <=  1'b0    ;
    endcase
end

// sdram_addr
always @(posedge sysclk_100M) begin
    case (state)
        S_ACT:      sdram_addr   <=  row_addr   ;
        S_READ:     sdram_addr   <=  {4'b0000, col_addr}    ;
        default:    sdram_addr   <=  13'b0_0000_0000_0000   ;
    endcase

end

// col_addr
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        col_addr    <=  9'd0    ;
    else if (read_cnt == 3'd6)
        col_addr    <=  col_addr + 9'd4 ;
end

// sdram_bank_addr
// row_addr
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        {sdram_bank_addr, row_addr} <=  15'd0   ;
    else if (state == S_READ && col_addr == 9'b1_1111_1100)
        {sdram_bank_addr, row_addr} <= {sdram_bank_addr, row_addr} + 15'd1;
end

// row_end
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        row_end     <=  1'b0   ;
    else if (col_addr == 9'b1_1111_1101 && row_addr == 13'h1FF)
        row_end     <=  1'b1   ;
    else if (state == S_ACT)
        row_end     <=  1'b0   ;
end

// act_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        act_cnt     <=  1'b0;
    else if (state == S_ACT && act_cnt == ACT_END)
        act_cnt     <=  act_cnt ;
    else if (state == S_ACT)
        act_cnt     <=  act_cnt + 1'b1;
    else
        act_cnt     <=  1'b0;
end

// read_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        read_cnt    <=  3'd0    ;
    else if (state == S_READ && read_cnt == READ_END)
        read_cnt    <=  3'd0;
    else if (state == S_READ)
        read_cnt    <=  read_cnt + 3'd1 ;
    else
        read_cnt    <=  3'd0    ;
end

// prech_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        prech_cnt     <=  2'd0;
    else if (state == S_PRECH && prech_cnt == PRECH_END)
        prech_cnt     <=  prech_cnt ;
    else if (state == S_PRECH)
        prech_cnt     <=  prech_cnt + 2'd1;
    else
        prech_cnt     <=  2'd0;
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
always @(posedge sysclk_100M) begin
    if (read_cnt >= 3'd3 && read_cnt <= 3'd6) begin
        data_vld_r  <=  1'b1        ;
        data_vld    <=  data_vld_r  ;
    end
    else begin
        data_vld_r  <=  1'b0        ;
        data_vld    <=  data_vld_r  ;
    end
end


// burst_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        burst_cnt   <=  4'd0    ;
    else if (burst_cnt == BURST_TIMES)
        burst_cnt   <=  4'd0    ;
    else if (state == S_READ && read_cnt == 3'd5)
        burst_cnt   <=  burst_cnt + 4'd1    ;
end

// arbit_read_end
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        arbit_read_end    <=  1'b0    ;
    else if (read_cnt == 3'd6 && burst_cnt == BURST_TIMES)
        arbit_read_end    <=  1'b1    ;
    else if (state == S_ACT)
        arbit_read_end    <=  1'b0    ;
end


endmodule