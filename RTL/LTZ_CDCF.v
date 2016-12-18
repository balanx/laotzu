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
// Description : Clock Domain Crossing Filter
//
//-------------------------------------------------------------------------
// History :
// 10/15/2016
//    initial draft
//
//-------------------------------------------------------------------------

module LTZ_CDCF #(
    parameter                WIDTH   = 1,
    parameter  [WIDTH -1:0]  INITVAL = {WIDTH{1'b0}}
) (
    input                    rst_n ,
    input                    clk   ,
    input      [WIDTH -1:0]  din   ,
    output reg [WIDTH -1:0]  dout
);

//
reg  [WIDTH -1:0]  buff ;
reg         [1:0]  state;

//
always @(posedge clk or negedge rst_n)
if (!rst_n)
    buff <= INITVAL;
else
    buff <= din;

//
always @(posedge clk or negedge rst_n)
if (!rst_n)
    dout <= INITVAL;
else if (state == 2'd3)
    dout <= buff;

// filter and judger
wire  neq = (buff != dout);
wire   eq = (buff == din );

always @(posedge clk or negedge rst_n)
if (!rst_n)
    state <= 2'b0;
else begin
    case (state)
        2'd0 : if (neq) state <= 2'd1;
        2'd1 : if ( eq) state <= 2'd2;
        2'd2 : if ( eq) state <= 2'd3; else state <= 2'd1;
        2'd3 : state <= 2'd0;
    endcase
end

//
endmodule
