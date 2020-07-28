// ================================================
// 
// designer:            yang shjiang
// date:                2020-07-25
// description:         to test the debounce module
// 
// ================================================


module tb_debounce;


// ============================================
// ******** define params/signals *********
// ============================================
reg         sysclk  ;
reg         key_in  ;

reg [31:0]  rand    ;


// ============================================
// ********** main code ********************
// ============================================
initial begin
    sysclk  =   0   ;
    key_in  =   1   ;
    #100;
    key_in  =   0   ;
    bounce(10);
    bounce(11);
    bounce(13);
    bounce(15);
    #10_000_000;
    #1000;
    $stop;
end

always #5 sysclk = ~sysclk  ;

task bounce(
        input   [31:0]  seed
    );
        begin
            rand    =   $dist_uniform (seed, 'd10, 'd1_000)    ;
            key_in  =   ~key_in ;
            #rand;
            key_in  =   ~key_in ;
            rand    =   $dist_uniform (seed+1, 'd10, 'd1_000)   ;
            #rand;
        end
endtask


debounce #(
    .CLK_CYC                (   10          )
) debounce_inst(
    // system signals
    .sysclk                 (   sysclk      )   ,
    // key
    .key_in                 (   key_in      )   ,
    // output
    .key_out                (   key_out     )   
);
endmodule