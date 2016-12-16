
module asyn_fifo_xlx #(
    parameter                  FWFTEN     = 1,  // 0 : disable
    parameter                  ADDRWIDTH  = 6,
    parameter                  DATAWIDTH  = 8,
    parameter   [ADDRWIDTH:0]  FIFODEPTH  = 44
) (

    input           w_rst_n     ,
    input           w_clk       ,
    input           w_en        ,
    output          w_full      ,
    output          w_error     ,
    output  [ADDRWIDTH:0]  w_counter ,
    input   [DATAWIDTH-1:0]  w_data  ,
// read-side
    input           r_rst_n     ,
    input           r_clk       ,
    input           r_en        ,
    output          r_valid     ,
    output          r_error     ,
    output  [ADDRWIDTH:0]  r_counter ,
    output  [DATAWIDTH-1:0]  r_data

);

wire [ADDRWIDTH-1:0] w_ram_addr;
wire        w_ram_en;
wire [ADDRWIDTH-1:0] r_ram_addr;
wire        r_ram_en;

asyn_fifo_controller  #(
    .FWFTEN     ( FWFTEN    ),
    .ADDRWIDTH  ( ADDRWIDTH ),
    .FIFODEPTH  ( FIFODEPTH )
) fifo_controller_inst (
    .w_rst_n    ( w_rst_n    ), // I
    .w_clk      ( w_clk      ), // I
    .w_en       ( w_en       ), // I
    .w_full     ( w_full     ), // O
    .w_error    ( w_error    ), // O
    .w_counter  ( w_counter  ), // O [ADDRSIZE:0]
    .r_rst_n    ( r_rst_n    ), // I
    .r_clk      ( r_clk      ), // I
    .r_en       ( r_en       ), // I
    .r_valid    ( r_valid    ), // O
    .r_error    ( r_error    ), // O
    .r_counter  ( r_counter  ), // O [ADDRSIZE:0]
    .w_ram_addr ( w_ram_addr ), // O [ADDRSIZE-1:0]
    .w_ram_en   ( w_ram_en   ), // O
    .r_ram_addr ( r_ram_addr ), // O [ADDRSIZE-1:0]
    .r_ram_en   ( r_ram_en   )  // O
); // instantiation of asyn_fifo_controller


dpram_xlx  #(
    .ADDRWIDTH  ( ADDRWIDTH ),
    .DATAWIDTH  ( DATAWIDTH ),
    .DEPTH      ( FIFODEPTH )
) dpram_xlx_inst (
	.clka       (w_clk       ),
	.ena        (w_ram_en    ),
	.wea        (w_ram_en    ),
	.addra      (w_ram_addr  ), // Bus [13: 0]
	.dina       (w_data      ), // Bus [7 : 0]
	.douta      (            ), // Bus [7 : 0]
	.clkb       (r_clk       ),
	.enb        (r_ram_en    ),
	.web        (1'b0        ),
	.addrb      (r_ram_addr  ), // Bus [13: 0]
	.dinb       ( { DATAWIDTH {1'b0} } ), // Bus [7 : 0]
	.doutb      (r_data      )  // Bus [7 : 0]
);

//
endmodule
