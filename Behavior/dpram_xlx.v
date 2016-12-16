`timescale 1ns/1ps

module dpram_xlx  #(
    parameter              ADDRWIDTH = 4,
    parameter              DATAWIDTH = 8,
    parameter [ADDRWIDTH:0] DEPTH = 16
) (
	clka,
	ena,
	wea,
	addra,
	dina,
	douta,
	clkb,
	enb,
	web,
	addrb,
	dinb,
	doutb
);


input clka;
input ena;
input [0 : 0] wea;
input [ADDRWIDTH-1 : 0] addra;
input [DATAWIDTH-1 : 0] dina;
output[DATAWIDTH-1 : 0] douta;
input clkb;
input enb;
input [0 : 0] web;
input [ADDRWIDTH-1 : 0] addrb;
input [DATAWIDTH-1 : 0] dinb;
output[DATAWIDTH-1 : 0] doutb;

// synthesis translate_off

      BLK_MEM_GEN_V4_3 #(
		.C_ADDRA_WIDTH(ADDRWIDTH),
		.C_ADDRB_WIDTH(ADDRWIDTH),
		.C_ALGORITHM(1),
		.C_BYTE_SIZE(9),
		.C_COMMON_CLK(0),
		.C_DEFAULT_DATA("0"),
		.C_DISABLE_WARN_BHV_COLL(0),
		.C_DISABLE_WARN_BHV_RANGE(0),
		.C_FAMILY("spartan6"),
		.C_HAS_ENA(1),
		.C_HAS_ENB(1),
		.C_HAS_INJECTERR(0),
		.C_HAS_MEM_OUTPUT_REGS_A(0),
		.C_HAS_MEM_OUTPUT_REGS_B(0),
		.C_HAS_MUX_OUTPUT_REGS_A(0),
		.C_HAS_MUX_OUTPUT_REGS_B(0),
		.C_HAS_REGCEA(0),
		.C_HAS_REGCEB(0),
		.C_HAS_RSTA(0),
		.C_HAS_RSTB(0),
		.C_HAS_SOFTECC_INPUT_REGS_A(0),
		.C_HAS_SOFTECC_OUTPUT_REGS_B(0),
		.C_INITA_VAL("0"),
		.C_INITB_VAL("0"),
		.C_INIT_FILE_NAME("no_coe_file_loaded"),
		.C_LOAD_INIT_FILE(0),
		.C_MEM_TYPE(2),
		.C_MUX_PIPELINE_STAGES(0),
		.C_PRIM_TYPE(1),
		.C_READ_DEPTH_A(DEPTH),
		.C_READ_DEPTH_B(DEPTH),
		.C_READ_WIDTH_A(DATAWIDTH),
		.C_READ_WIDTH_B(DATAWIDTH),
		.C_RSTRAM_A(0),
		.C_RSTRAM_B(0),
		.C_RST_PRIORITY_A("CE"),
		.C_RST_PRIORITY_B("CE"),
		.C_RST_TYPE("SYNC"),
		.C_SIM_COLLISION_CHECK("ALL"),
		.C_USE_BYTE_WEA(0),
		.C_USE_BYTE_WEB(0),
		.C_USE_DEFAULT_DATA(0),
		.C_USE_ECC(0),
		.C_USE_SOFTECC(0),
		.C_WEA_WIDTH(1),
		.C_WEB_WIDTH(1),
		.C_WRITE_DEPTH_A(DEPTH),
		.C_WRITE_DEPTH_B(DEPTH),
		.C_WRITE_MODE_A("WRITE_FIRST"),
		.C_WRITE_MODE_B("WRITE_FIRST"),
		.C_WRITE_WIDTH_A(DATAWIDTH),
		.C_WRITE_WIDTH_B(DATAWIDTH),
		.C_XDEVICEFAMILY("spartan6"))
	inst (
		.CLKA(clka),
		.ENA(ena),
		.WEA(wea),
		.ADDRA(addra),
		.DINA(dina),
		.DOUTA(douta),
		.CLKB(clkb),
		.ENB(enb),
		.WEB(web),
		.ADDRB(addrb),
		.DINB(dinb),
		.DOUTB(doutb),
		.RSTA(),
		.REGCEA(),
		.RSTB(),
		.REGCEB(),
		.INJECTSBITERR(),
		.INJECTDBITERR(),
		.SBITERR(),
		.DBITERR(),
		.RDADDRECC());


// synthesis translate_on

// XST black box declaration
// box_type "black_box"
// synthesis attribute box_type of dpram_xlx is "black_box"

endmodule

