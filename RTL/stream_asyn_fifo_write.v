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
// Description : submodule of stream_asyn_fifo_controller
//    write function
//
//-------------------------------------------------------------------------
// History :
// 10/15/2016
//    initial draft
//
//-------------------------------------------------------------------------

module stream_asyn_fifo_write #(
    parameter                  ADDRWIDTH  = 6,
    parameter   [ADDRWIDTH:0]  FIFODEPTH  = 44,
    parameter   [ADDRWIDTH:0]  HEADSIZE   = 0,
    parameter   [ADDRWIDTH:0]  MINBIN2    = 0,
    parameter   [ADDRWIDTH:0]  MAXBIN2    = 7
) (
    input  wire                    w_clk    ,
    input  wire                    w_rst_n  ,
    input  wire [2:0]              w_ctrl   ,  // see below 'command definition'
    input  wire [ADDRWIDTH:0]      r2w_ptr  ,
    output reg  [ADDRWIDTH-1:0]    wbin     ,
    output      [ADDRWIDTH:0]      wptr     ,
    output                         inc      ,
    output reg                     w_full   ,
    output reg  [ADDRWIDTH:0]      w_counter,
    output reg                     w_error
);

// command definition
localparam [2:0]
NOP         = 3'd0,
WRITE       = 3'd1,
EOF_WITH_WRITE    = 3'd2,
EOF_WITHOUT_WRITE = 3'd3,
HEAD        = 3'd4,
FINAL_HEAD  = 3'd5,
DISCARD     = 3'd6;

// NO write when full
wire [2:0] w_ctrl_t = ( w_ctrl == DISCARD ) ? DISCARD :
                        w_full ? NOP : w_ctrl ;
// pointer inc.
assign  inc_t = ( w_ctrl_t == WRITE || w_ctrl_t == EOF_WITH_WRITE ) ;
// RAM write enable
assign  inc   =   inc_t || (w_ctrl_t == HEAD) || (w_ctrl_t == FINAL_HEAD) ;

wire  withouthead  =  ( HEADSIZE == { (ADDRWIDTH+1){1'b0} } ) ;

// end-of-frame-with-write
wire eofww  =  ( w_ctrl_t == EOF_WITH_WRITE ) ;
reg  eofww_d ;

always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        eofww_d <= 1'b0 ;
    else
        eofww_d <= eofww ;

// final-data-without-head
wire fdwoh   =  ( withouthead &&
                  ( eofww_d || w_ctrl_t == EOF_WITHOUT_WRITE )
                );

// final-data-with-head
wire fdwhead =  ( !withouthead &&
                  ( eofww || w_ctrl_t == EOF_WITHOUT_WRITE )
                );

//---------------------------------------------------------------
// "wbin2" is double the amount of "wbin"
// e.g. deepth = 10
//      wbin   = 0~9
//      wbin2  = 6~15, 16~25
//      MINBIN2 = 6
//---------------------------------------------------------------
reg  [ADDRWIDTH:0]  wbin2, wbin2_prev;
wire [ADDRWIDTH:0]  wbnext  = (wbin2>=MINBIN2 && wbin2<MAXBIN2) ?
                              (wbin2 + 1'b1) : MINBIN2;
//
always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        wbin2 <= bin2add(MINBIN2);
    else if ( w_ctrl_t == DISCARD )     // discard
        wbin2 <= bin2add(wbin2_prev);
    else if ( w_ctrl_t == FINAL_HEAD )  // final-head
        wbin2 <= bin2add(wbin2);
    else if ( inc_t )
        wbin2 <= wbnext;

//
reg  [ADDRWIDTH:0] wbin2_prev_t;

always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        wbin2_prev_t <= MINBIN2;
    else if ( eofww_d || w_ctrl_t == EOF_WITHOUT_WRITE )
        wbin2_prev_t <= wbin2;

//
always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        wbin2_prev <= MINBIN2;
    else if ( w_ctrl_t == FINAL_HEAD )  // final-head
        wbin2_prev <= ( eofww_d ? wbin2 : wbin2_prev_t ) ;
    else if ( fdwoh )                 // final-data
        wbin2_prev <= wbin2;

//---------------------------------------------------------------
// memory address
//---------------------------------------------------------------
always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        wbin <= HEADSIZE;
    else if ( w_ctrl_t == DISCARD )           // discard
        wbin <= bin2tobin( bin2add(wbin2_prev) );
    else if ( fdwhead )                     // head position
        wbin <= bin2tobin(wbin2_prev);
    else if ( w_ctrl_t == EOF_WITHOUT_WRITE
             || w_ctrl_t == FINAL_HEAD )      // next frame
        wbin <= bin2tobin( bin2add(wbin2) );
    else if ( inc_t || w_ctrl_t == HEAD )     // +1
        wbin <= (wbin >= MAXBIN2[ADDRWIDTH-1:0]) ? {ADDRWIDTH{1'b0}} : (wbin + 1'b1);

//---------------------------------------------------------------
// to other-side
//---------------------------------------------------------------
assign  wptr = wbin2_prev;

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
                              ) +
                              ( w_ctrl_t == FINAL_HEAD ? HEADSIZE : inc_t );
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
        w_full <= (distance >= FIFODEPTH);

//
always @(posedge w_clk or negedge w_rst_n)
    if (!w_rst_n)
        w_error <= 1'b0;
    else
        w_error <= (w_counter > (FIFODEPTH + HEADSIZE) );

//
function [ADDRWIDTH-1:0] bin2tobin;

input [ADDRWIDTH:0] b2;

begin
    bin2tobin =  b2[ADDRWIDTH] ? b2[ADDRWIDTH-1:0] :
                (b2[ADDRWIDTH-1:0] - MINBIN2[ADDRWIDTH-1:0]);
end
endfunction

//
function [ADDRWIDTH:0] bin2add;

input [ADDRWIDTH:0] b2;

reg   [ADDRWIDTH:0] sum;

begin
    sum = b2 + HEADSIZE;

    if (sum >= b2 && sum <= MAXBIN2)
        bin2add = sum;
    else
        bin2add = sum + MINBIN2 + (~MAXBIN2);
end
endfunction

//
endmodule
