`timescale 1ns/1ns

module testbench;

parameter ADDRWIDTH = 4;


wire        w_error, r_error;
reg         rst_n = 1'b0;
reg         w_clk = 1'b0;
reg         r_clk = 1'b0;
wire  #2    w_en  = !w_full;
reg         r_en  = 1'b0;
wire        w_full;
wire        r_valid;
wire [ADDRWIDTH:0] r_counter;
wire [ADDRWIDTH:0] w_counter;

wire [7:0] dout;
reg  [7:0] din = 8'd0, expected = 8'd0;

//
`include  `PATTERN

//========================================
//
// Instantiation: asyn_fifo_xlx
//
//========================================

asyn_fifo_xlx  #(
    .FWFTEN    ( FWFTEN    ),
    .ADDRWIDTH ( ADDRWIDTH ),
    .DATAWIDTH ( 8 ),
    .FIFODEPTH ( FIFODEPTH )
) dut (
    .w_rst_n   ( rst_n     ), // I
    .w_clk     ( w_clk     ), // I
    .w_en      ( w_en      ), // I
    .w_full    ( w_full    ), // O
    .w_error   ( w_error   ), // O
    .w_counter ( w_counter ), // O [ADDRWIDTH:0]
    .w_data    ( din       ), // I [DATAWIDTH-1:0]
    .r_rst_n   ( rst_n     ), // I
    .r_clk     ( r_clk     ), // I
    .r_en      ( r_en      ), // I
    .r_valid   ( r_valid   ), // O
    .r_error   ( r_error   ), // O
    .r_counter ( r_counter ), // O [ADDRWIDTH:0]
    .r_data    ( dout      )  // O [DATAWIDTH-1:0]
); // instantiation of asyn_fifo_xlx


always #5 w_clk = !w_clk;
always #3 r_clk = !r_clk;


initial begin
    $dumpfile("fifo.dump");
    $dumpvars(0,testbench);
end

initial begin
    #10 rst_n = 1'b1;
    @(negedge w_clk)
        din  = 8'hFF;
    repeat(100) @(negedge w_clk)
        if (!w_full) din = din + 1'b1;
end

initial begin
    // test FULL
    @(posedge w_full);
    @(negedge r_clk) r_en = 1'b1;
    // test Empty
    if (FWFTEN == 0) wait(r_valid == 1);
    @(r_valid == 0);
    // test FWFT
    @(negedge r_clk) r_en = 1'b0;
    //
    if (FWFTEN == 0) wait(w_full == 1);
    else @(dout);
    @(negedge r_clk) r_en = 1'b1;
    //
    #360 $finish;
end

initial begin
    $display("\n  Time : w_full (r_valid, dout) (w_counter, r_counter) (r_addr, rbin2) - (rptr-b, rptr-d)");
    forever @(negedge r_clk) begin
        $display("%6.0f : %b      (%b          %h)    (%2d           %2d)   (%2d         %2d) -   %b      %d", $time,
            w_full, r_valid, dout, w_counter, r_counter, dut.r_ram_addr,
            dut.fifo_controller_inst.read_inst.rbin2,
            dut.fifo_controller_inst.read_inst.rptr, dut.fifo_controller_inst.read_inst.rptr);

        if (r_valid && (expected != dout) ) begin
            $display("data mismatched at time %6.3f : dout = %h, expected = %h", $time, dout, expected);
            expected = dout;
        end
        if (r_valid && r_en)
            expected = expected + 1'b1;
    end
end
//
endmodule
