// ==================================================
// 
// designer:        yang shjiang
// date:            2020-07-22
// description:     to test sync FIFO
// 
// ==================================================
`timescale 1ns/1ns

module tb_sync_FIFO;

// ================================================
// ********* define params and signals *********
// ================================================
localparam          DEPTH   =   4   ;
localparam          WIDTH   =   8   ;

reg                 sysclk_100M     ;
reg                 rst_n           ;
reg                 write_en        ;
reg     [ 7:0]      write_data      ;
reg                 read_en         ;

wire                full            ;
wire                empty           ;
wire    [ 7:0]      read_data       ;

// ================================================
// **************** main code ***************
// ================================================
initial begin
    sysclk_100M = 0 ;
    rst_n       = 0 ;
    write_en    = 0 ;
    read_en     = 0 ;
    #100;
    rst_n       = 1 ;
    #100;
    write('haa);
    write('hbb);
    write('hcc);
    write('hdd);
    write('hee);
    #100;
    #10;
    read;
    write('hff);
    read;
    read;
    read;
    write('h00);
    write('h55);
    write('h22);
    write('h33);
    write('h88);
    read;
    read;
    read;
    read;
    read;
    read;
end


task write (
        input [7:0] data
    );
    begin
    write_en    = 1 ;
    write_data  = data;
    #10;
    write_en    = 0 ;
    #10;
    end
endtask

task read ();
    begin
    read_en     = 1 ;
    #10;
    read_en     = 0 ;
    #10;
    end
endtask

always #5 sysclk_100M = ~sysclk_100M;



sync_FIFO #(
    .DEPTH              (   DEPTH       )     ,
    .WIDTH              (   WIDTH       )     
) sync_FIFO_inst (
    // system signals
    .sysclk_100M        (   sysclk_100M )     ,
    .rst_n              (   rst_n       )     ,
    // write port
    .full               (   full        )     ,
    .write_en           (   write_en    )     ,
    .write_data         (   write_data  )     ,
    // read port
    .empty              (   empty       )     ,
    .read_en            (   read_en     )     ,
    .read_data          (   read_data   )     
);


endmodule