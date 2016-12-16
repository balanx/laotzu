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
//    write function
//
//-------------------------------------------------------------------------
// History :
// 10/15/2016
//    initial draft
//
//-------------------------------------------------------------------------

module asyn_fifo_write #(
    parameter                  ADDRWIDTH = 6,
    parameter   [ADDRWIDTH:0]  FIFODEPTH = 44,
    parameter   [ADDRWIDTH:0]  MINBIN2   = 0,
    parameter   [ADDRWIDTH:0]  MAXBIN2   = 7
) (
    input  wire                    w_clk    ,
    input  wire                    w_rst_n  ,
    input  wire                    w_en     ,
    input  wire [ADDRWIDTH:0]      r2w_ptr  ,
    output reg  [ADDRWIDTH-1:0]    wbin     ,
    output reg  [ADDRWIDTH:0]      wptr     ,
    output                         inc      ,
    output reg                     w_full   ,
    output reg  [ADDRWIDTH:0]      w_counter,
    output reg                     w_error
);

//
assign  inc  = w_en && !w_full;

//---------------------------------------------------------------
// "wbin2" is double the amount of "wbin"
// e.g. deepth = 10
//      wbin   = 0~9
//      wbin2  = 6~15, 16~25
//      offset = 6
//---------------------------------------------------------------
reg  [ADDRWIDTH:0]  wbin2;
wire [ADDRWIDTH:0]  wbnext = (wbin2>=MINBIN2 && wbin2<MAXBIN2) ?
                             (wbin2 + 1'b1) : MINBIN2;
//
always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        wbin2 <= MINBIN2;
    else if (inc)
        wbin2 <= wbnext;

//---------------------------------------------------------------
// memory address
//---------------------------------------------------------------
always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        wbin <= {ADDRWIDTH{1'b0}};
    else if (inc)
        wbin <= wbnext[ADDRWIDTH] ? wbnext[ADDRWIDTH-1:0] :
                    (wbnext[ADDRWIDTH-1:0] - MINBIN2[ADDRWIDTH-1:0]);

//---------------------------------------------------------------
// GRAY pointer
//---------------------------------------------------------------
// binary-to-gray conversion
wire [ADDRWIDTH:0]  wptr_gray = {1'b0,wbnext[ADDRWIDTH:1]} ^ wbnext;

always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        wptr <= (MINBIN2>>1) ^ MINBIN2;
    else if (inc)
        wptr <= wptr_gray;

//---------------------------------------------------------------
// from other-side
//---------------------------------------------------------------
reg [ADDRWIDTH:0] r2w_bin;

always @(r2w_ptr)
begin: GrayToBin
    integer i;
    for (i=ADDRWIDTH; i>=0; i=i-1)
        r2w_bin[i] = ^(r2w_ptr>>i);
end

//---------------------------------------------------------------
// output signals
//---------------------------------------------------------------
wire [ADDRWIDTH:0] distance = ( (wbin2 >= r2w_bin) ?
                                (wbin2  - r2w_bin) :
                                (wbin2  - r2w_bin - (MINBIN2<<1) )
                              ) + inc;
//
always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        w_counter <= {(ADDRWIDTH+1){1'b0}};
    else
        w_counter <= distance;

//
always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        w_full <= 1'b0;
    else
        w_full <= (distance == FIFODEPTH);

//
always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        w_error <= 1'b0;
    else
        w_error <= (w_counter > FIFODEPTH);

//
endmodule
