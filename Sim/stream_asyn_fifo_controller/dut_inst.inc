
//========================================
//
// Instantiation: stream_asyn_fifo_xlx
//
//========================================

stream_asyn_fifo_xlx  #(
    .FWFTEN    ( FWFTEN    ),
    .ADDRWIDTH ( ADDRWIDTH ),
    .DATAWIDTH ( 8 ),
    .FIFODEPTH ( FIFODEPTH ),
    .HEADSIZE  ( HEADSIZE  )
) dut (
    .w_rst_n   ( rst_n && !(w_error || r_error)    ), // I
    .w_clk     ( w_clk     ), // I
    .w_ctrl    ( w_ctrl    ), // I [ 2:0]
    .w_full    ( w_full    ), // O
    .w_error   ( w_error   ), // O
    .w_counter ( w_counter ), // O [ADDRWIDTH:0]
    .w_data    ( din       ), // I [DATAWIDTH-1:0]
    .r_rst_n   ( rst_n && !(w_error || r_error)    ), // I
    .r_clk     ( r_clk     ), // I
    .r_en      ( r_en      ), // I
    .r_valid   ( r_valid   ), // O
    .r_error   ( r_error   ), // O
    .r_counter ( r_counter ), // O [ADDRWIDTH:0]
    .r_data    ( dout      )  // O [DATAWIDTH-1:0]
); // instantiation of stream_asyn_fifo_xlx

