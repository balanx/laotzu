`timescale 1ns/1ns

`define  NOP        w_ctrl = 3'd0
`define  WRITE      w_ctrl = 3'd1
`define  EOF_WITH_WRITE    w_ctrl = 3'd2
`define  EOF_WITHOUT_WRITE w_ctrl = 3'd3
`define  HEAD       w_ctrl = 3'd4
`define  FINAL_HEAD w_ctrl = 3'd5
`define  DISCARD    w_ctrl = 3'd6

module testbench;

parameter ADDRWIDTH = 4;


wire        w_error, r_error;
reg         rst_n = 1'b0;
reg         w_clk = 1'b0;
reg         r_clk = 1'b0;
reg  [2:0]  w_ctrl = 3'b0;
reg         r_en  = 1'b0;
wire        w_full;
wire        r_valid;
wire [ADDRWIDTH:0] r_counter;
wire [ADDRWIDTH:0] w_counter;

wire [7:0]  dout;
reg  [7:0]  din = 8'd0, expected = 8'd0;

//
`include  `PATTERN


always #5 w_clk = !w_clk;
always #3 r_clk = !r_clk;


initial begin
    $dumpfile("fifo.dump");
    $dumpvars(0,testbench);
end


initial begin
    $display("\n  Time : w_full (r_valid, dout) (w_counter, r_counter) (r_addr, rbin2) - (rptr-b, rptr-d)");
    forever @(posedge r_clk) begin
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

endmodule
