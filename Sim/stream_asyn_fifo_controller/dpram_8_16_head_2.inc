
parameter FWFTEN     =  1;
parameter FIFODEPTH  = 16;
parameter HEADSIZE   =  2;


`include "./dut_inst.inc"


initial begin
    #10 rst_n = 1'b1;
    // 1st
    @(negedge w_clk) `WRITE; din = 8'h10;
    repeat(8) @(negedge w_clk)
        if (!w_full) din = din + 1'b1;

    @(negedge w_clk) `EOF_WITH_WRITE; din = din + 1'b1;
    @(negedge w_clk) `HEAD; din = 8'he1;
    @(negedge w_clk) `FINAL_HEAD; din = 8'hf1;
    // 2nd
    @(negedge w_clk) `WRITE; din = 8'h20;
    repeat(8) @(negedge w_clk)
        if (!w_full) din = din + 1'b1;
        else wait(w_full == 1'b0);

    @(negedge w_clk) `EOF_WITH_WRITE; din = din + 1'b1;
    @(negedge w_clk) `HEAD; din = 8'he2;
    @(negedge w_clk) `FINAL_HEAD; din = 8'hf2;
    // 3rd, discard
    @(negedge w_clk) `WRITE; din = 8'h30;
    repeat(8) @(negedge w_clk)
        if (!w_full) din = din + 1'b1;
        else wait(w_full == 1'b0);

    @(negedge w_clk) `EOF_WITH_WRITE; din = din + 1'b1;
    @(negedge w_clk) `DISCARD;
    // 4th
    @(negedge w_clk) `WRITE; din = 8'h40;
    repeat(8) @(negedge w_clk)
        if (!w_full) din = din + 1'b1;

    @(negedge w_clk) `EOF_WITHOUT_WRITE;
    @(negedge w_clk) `HEAD; din = 8'he4;
    @(negedge w_clk) `FINAL_HEAD; din = 8'hf4;
    // 5th
    @(negedge w_clk) `WRITE; din = 8'h50;
    repeat(8) @(negedge w_clk)
        if (!w_full) din = din + 1'b1;

    @(negedge w_clk) `EOF_WITHOUT_WRITE;
    @(negedge w_clk) `HEAD; din = 8'he5;
    @(negedge w_clk) `FINAL_HEAD; din = 8'hf5;
    //
    @(negedge w_clk) `NOP;
    #150 $finish;
end


initial begin
    //@(posedge w_full);
    @(negedge r_clk) r_en = 1'b1;
    //
end

