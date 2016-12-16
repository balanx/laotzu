/*
Copyright (C) 2016  tobalanx@qq.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

//-------------------------------------------------------------------------
// https://github.com/balanx/laotzu
//
// Description : submodule of asyn_fifo_controller
//    read function
//
//-------------------------------------------------------------------------
// History :
// 10/15/2016
//    initial draft
//
//-------------------------------------------------------------------------

module asyn_fifo_read #(
    parameter                  FWFTEN    = 1,  // 0 : disable
    parameter                  ADDRWIDTH = 6,
    parameter   [ADDRWIDTH:0]  FIFODEPTH = 44,
    parameter   [ADDRWIDTH:0]  MINBIN2   = 0,
    parameter   [ADDRWIDTH:0]  MAXBIN2   = 7
) (
    input  wire                    r_clk    ,
    input  wire                    r_rst_n  ,
    input  wire                    r_en     ,
    input  wire [ADDRWIDTH:0]      w2r_ptr  ,
    output reg  [ADDRWIDTH-1:0]    rbin     ,
    output reg  [ADDRWIDTH:0]      rptr     ,
    output                         inc      ,
    output reg                     r_valid  ,
    output reg  [ADDRWIDTH:0]      r_counter,
    output reg                     r_error
);

//
wire    zero = (r_counter == {(ADDRWIDTH+1){1'b0}} );
// FWFT (First Word Fall Through)
wire    fwft = FWFTEN ? (!r_valid && !zero) : 1'b0;
//
assign  inc  = (r_en && !zero) || fwft;

//---------------------------------------------------------------
// "rbin2" is double the amount of "rbin"
//---------------------------------------------------------------
reg  [ADDRWIDTH:0]  rbin2;
wire [ADDRWIDTH:0]  rbnext = (rbin2>=MINBIN2 && rbin2<MAXBIN2) ?
                             (rbin2 + 1'b1) : MINBIN2;
//
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        rbin2 <= MINBIN2;
    else if (inc)
        rbin2 <= rbnext;

//---------------------------------------------------------------
// memory address
//---------------------------------------------------------------
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        rbin <= {ADDRWIDTH{1'b0}};
    else if (inc)
        rbin <= rbnext[ADDRWIDTH] ? rbnext[ADDRWIDTH-1:0] :
                    (rbnext[ADDRWIDTH-1:0] - MINBIN2[ADDRWIDTH-1:0]);

//---------------------------------------------------------------
// GRAY pointer
//---------------------------------------------------------------
// binary-to-gray conversion
wire [ADDRWIDTH:0]  rptr_gray = {1'b0,rbnext[ADDRWIDTH:1]} ^ rbnext;

always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        rptr <= (MINBIN2>>1) ^ MINBIN2;
    else if (inc)
        rptr <= rptr_gray;

//---------------------------------------------------------------
// from other-side
//---------------------------------------------------------------
reg [ADDRWIDTH:0] w2r_bin;

always @(w2r_ptr)
begin: GrayToBin
    integer i;
    for (i=ADDRWIDTH; i>=0; i=i-1)
        w2r_bin[i] = ^(w2r_ptr>>i);
end

//---------------------------------------------------------------
// output signals
//---------------------------------------------------------------
wire [ADDRWIDTH:0] distance = ( (w2r_bin >= rbin2) ?
                                (w2r_bin  - rbin2) :
                                (w2r_bin  - rbin2 - (MINBIN2<<1) )
                              ) - inc;

// "r_counter" is precise.
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        r_counter <= {(ADDRWIDTH+1){1'b0}};
    else
        r_counter <= distance;


// "r_valid" is alignment with "dout" because of FWFT
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        r_valid <= 1'b0;
    else if (r_en || fwft)
        r_valid <= !zero;

//
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        r_error <= 1'b0;
    else
        r_error <= (r_counter > FIFODEPTH);

//
endmodule