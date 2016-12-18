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
// Description : asynchronous stream fifo controller
//
// Attention :
// 1) FIFODEPTH should be even number.
// 2) Frame duration of write-side (include idle)
//    should be at least 6 clock periods of read-side.
//
//-------------------------------------------------------------------------
// History :
// 10/15/2016
//    initial draft
//
//-------------------------------------------------------------------------

module stream_asyn_fifo_controller #(
    parameter               FWFTEN     = 1,  // 0 : disable
    parameter               ADDRWIDTH  = 6,
    parameter [ADDRWIDTH:0] FIFODEPTH  = 44, // should be even number.
    parameter [ADDRWIDTH:0] HEADSIZE   = 0
) (
// write-side
    input                        w_rst_n     ,
    input                        w_clk       ,
    input   [2:0]                w_ctrl      , // 0: nop, 1: write, ...
    output                       w_full      ,
    output                       w_error     ,
    output  [ADDRWIDTH:0]        w_counter   ,
// read-side
    input                        r_rst_n     ,
    input                        r_clk       ,
    input                        r_en        ,
    output                       r_valid     ,
    output                       r_error     ,
    output  [ADDRWIDTH:0]        r_counter   ,

// interface to ram
    output  [ADDRWIDTH-1:0]      w_ram_addr  ,
    output                       w_ram_en    ,
    output  [ADDRWIDTH-1:0]      r_ram_addr  ,
    output                       r_ram_en
);

localparam [ADDRWIDTH:0] MINBIN2   = (1'b1<<ADDRWIDTH) - FIFODEPTH;
localparam [ADDRWIDTH:0] MINGRAY2  = (MINBIN2>>1) ^ MINBIN2;
localparam [ADDRWIDTH:0] MAXBIN2   = (1'b1<<ADDRWIDTH) + FIFODEPTH - 1'b1;

wire [ADDRWIDTH:0]    w2r_ptr ;
wire [ADDRWIDTH:0]    r2w_ptr ;
wire [ADDRWIDTH:0]    rptr    ;
wire [ADDRWIDTH:0]    wptr    ;


stream_asyn_fifo_write  #(
    .ADDRWIDTH  ( ADDRWIDTH  ),
    .FIFODEPTH  ( FIFODEPTH  ),
    .HEADSIZE   ( HEADSIZE   ),
    .MINBIN2    ( MINBIN2    ),
    .MAXBIN2    ( MAXBIN2    )
) write_inst (
    .w_clk      ( w_clk       ),
    .w_rst_n    ( w_rst_n     ),
    .w_ctrl     ( w_ctrl      ),
    .r2w_ptr    ( r2w_ptr     ),
    .wbin       ( w_ram_addr  ),
    .wptr       ( wptr        ),
    .inc        ( w_ram_en    ),
    .w_full     ( w_full      ),
    .w_error    ( w_error     ),
    .w_counter  ( w_counter   )
);


LTZ_CDCF  #(
    .WIDTH      ( ADDRWIDTH + 1 ),
    .INITVAL    ( MINBIN2       )
) w2r_inst (
    .rst_n      ( r_rst_n  ), // I
    .clk        ( r_clk    ), // I
    .din        ( wptr     ), // I [WIDTH -1:0]
    .dout       ( w2r_ptr  )  // O [WIDTH -1:0]
); // instantiation of LTZ_CDCB


stream_asyn_fifo_read  #(
    .FWFTEN     ( FWFTEN    ),
    .ADDRWIDTH  ( ADDRWIDTH ),
    .FIFODEPTH  ( FIFODEPTH ),
    .MINBIN2    ( MINBIN2   ),
    .MAXBIN2    ( MAXBIN2   )
) read_inst (
    .r_clk      ( r_clk       ),
    .r_rst_n    ( r_rst_n     ),
    .r_en       ( r_en        ),
    .w2r_ptr    ( w2r_ptr     ),
    .rbin       ( r_ram_addr  ),
    .rptr       ( rptr        ),
    .inc        ( r_ram_en    ),
    .r_valid    ( r_valid     ),
    .r_error    ( r_error     ),
    .r_counter  ( r_counter   )
);


LTZ_CDCB  #(
    .WIDTH      ( ADDRWIDTH + 1 ),
    .INITVAL    ( MINGRAY2      )
) r2w_inst (
    .rst_n      ( w_rst_n  ), // I
    .clk        ( w_clk    ), // I
    .din        ( rptr     ), // I [WIDTH -1:0]
    .dout       ( r2w_ptr  )  // O [WIDTH -1:0]
); // instantiation of LTZ_CDCB

//
endmodule