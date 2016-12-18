
parameter FWFTEN     =  1;
parameter FIFODEPTH  = 10;
parameter HEADSIZE   =  0;


`include "./dut_inst.inc"


initial begin
    #10 rst_n = 1'b1;
    @(negedge w_clk)
        din  = 8'hFF; `WRITE;
    repeat(5) @(negedge w_clk)
        if (!w_full) din = din + 1'b1;
    //
    @(negedge w_clk) `EOF_WITH_WRITE; din = din + 1'b1;
    @(negedge w_clk) `WRITE;
    #20;
    @(negedge w_clk) `DISCARD;
    @(negedge w_clk)
    // 2nd
    `WRITE; if (!w_full) din = din + 1'b1;
    repeat(10) @(negedge w_clk)
        if (!w_full) din = din + 1'b1;
    //
    @(negedge w_clk) `EOF_WITH_WRITE; din = din + 1'b1;
    @(negedge w_clk) `WRITE;
    #100;
    @(negedge w_clk) `DISCARD;
    @(negedge w_clk)
    // 3rd
    `WRITE; if (!w_full) din = din + 1'b1;
    //
    repeat(8) @(negedge w_clk)
        if (!w_full) din = din + 1'b1;
    //
    @(negedge w_clk) `EOF_WITH_WRITE; din = din + 1'b1;
    @(negedge w_clk) `WRITE;
    #50;
    @(negedge w_clk) `DISCARD;
    @(negedge w_clk) w_ctrl = 2'b0;
    //
    #80;
    @(negedge r_clk) r_en = 1'b0;
    @(negedge w_clk) `WRITE; din = din + 1'b1;
    @(negedge w_clk) `EOF_WITH_WRITE; din = din + 1'b1;
    @(negedge w_clk) w_ctrl = 2'd0;
    wait(r_valid == 1);
    @(negedge r_clk) r_en = 1'b1;
    @(negedge r_clk) r_en = 1'b0;
    //
    #20
    @(negedge w_clk) `WRITE; din = din + 1'b1;
    @(negedge w_clk) `EOF_WITH_WRITE; din = din + 1'b1;
    //
    @(negedge w_clk) `WRITE; din = din + 1'b1;
    @(negedge w_clk) `EOF_WITHOUT_WRITE;
    //
    @(negedge w_clk) `WRITE; din = din + 1'b1;
    @(negedge w_clk) `EOF_WITH_WRITE; din = din + 1'b1;
    //
    @(negedge w_clk) w_ctrl = 2'd0;
    wait(r_valid == 1);
    @(negedge r_clk) r_en = 1'b1;
    @(negedge r_clk) r_en = 1'b0;
    @(negedge r_clk) r_en = 1'b1;
    @(negedge r_clk) r_en = 1'b0;
    @(negedge r_clk) r_en = 1'b1;
    //
    #100 $finish;
end


initial begin
    @(posedge w_full);
    @(negedge r_clk) r_en = 1'b1;
    @(negedge r_clk) r_en = 1'b0;
    @(posedge w_full);
    @(negedge r_clk) r_en = 1'b1;
    @(negedge r_clk) r_en = 1'b0;
    @(posedge w_full);
    @(negedge r_clk) r_en = 1'b1;
    //
end

