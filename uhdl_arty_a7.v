// uhdl_arty_a7.v --- ---!!!

`timescale 1ns/1ps
`default_nettype none

`define enable_mmc
`define enable_vga
`define enable_ps2
`define enable_spy_port

module uhdl_arty_a7(/*AUTOARG*/
   // Outputs
   ddr3_dm, ddr3_odt, ddr3_ba, ddr3_cs_n, ddr3_cas_n, ddr3_ras_n,
   ddr3_we_n, ddr3_reset_n, ddr3_ck_p, ddr3_ck_n, ddr3_cke, rs232_txd,
   led, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, mmc_cs, mmc_do,
   mmc_sclk, uart_txd,
   // Inouts
   ddr3_dq, ddr3_dqs_p, ddr3_dqs_n, ddr3_addr, ms_ps2_clk,
   ms_ps2_data,
   // Inputs
   rs232_rxd, sysclk, kb_ps2_clk, kb_ps2_data, mmc_di, switch, button,
   uart_rxd
   );
   
   
   /// DDR3 interface
   // data interface
   inout [15:0] ddr3_dq;
   inout [1:0] ddr3_dqs_p;
   inout [1:0] ddr3_dqs_n;
   inout [13:0] ddr3_addr;
   output [1:0] ddr3_dm;
   output wire ddr3_odt;
   
   // command interface
   output [2:0] ddr3_ba; 
   output wire ddr3_cs_n;
   output wire ddr3_cas_n;
   output wire ddr3_ras_n;
   output wire ddr3_we_n;
   
   output wire ddr3_reset_n;
   
   // clock
   output wire ddr3_ck_p;
   output wire ddr3_ck_n;
   output wire ddr3_cke;
   
   input wire rs232_rxd;
   output wire rs232_txd;
   output [15:0] led;
   input wire sysclk;
   input wire kb_ps2_clk;
   input wire kb_ps2_data;
   inout wire ms_ps2_clk;
   inout wire ms_ps2_data;
   output wire vga_hsync;
   output wire vga_vsync;
   output wire vga_r;
   output wire vga_g;
   output wire vga_b;
   output wire mmc_cs;
   output wire mmc_do;
   output wire mmc_sclk;
   input wire mmc_di;
   input wire [3:0] switch;
   input wire [3:0] button;
   output wire uart_txd;
   input wire uart_rxd;
   ////////////////////////////////////////////////////////////////////////////////
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			boot;			// From support of support_arty_a7.v
   wire [15:0]		busint_spyout;		// From uhdl_common of uhdl_common.v
   wire			dcm_reset;		// From support of support_arty_a7.v
   wire [4:0]		disk_state;		// From uhdl_common of uhdl_common.v
   wire			fetch;			// From uhdl_common of uhdl_common.v
   wire			halt;			// From support of support_arty_a7.v
   wire			interrupt;		// From support of support_arty_a7.v
   wire			lpddr_reset;		// From support of support_arty_a7.v
   wire [13:0]		mcr_addr;		// From uhdl_common of uhdl_common.v
   wire [48:0]		mcr_data_out;		// From rc of ram_controller_X7.v, ...
   wire			mcr_done;		// From rc of ram_controller_X7.v
   wire			mcr_ready;		// From rc of ram_controller_X7.v
   wire			mcr_write;		// From uhdl_common of uhdl_common.v
   wire [23:0]		o_bd_addr;		// From uhdl_common of uhdl_common.v
   wire [5:0]		o_bda;			// From uhdl_common of uhdl_common.v
   wire [13:0]		o_pc;			// From uhdl_common of uhdl_common.v
   wire			prefetch;		// From uhdl_common of uhdl_common.v
   wire			reset;			// From support of support_arty_a7.v
   wire [21:0]		sdram_addr;		// From uhdl_common of uhdl_common.v
   wire			sdram_calib_done;	// From rc of ram_controller_X7.v
   wire			sdram_clk_out;		// From rc of ram_controller_X7.v
   wire [31:0]		sdram_data_cpu2rc;	// From uhdl_common of uhdl_common.v
   wire [31:0]		sdram_data_out;		// From rc of ram_controller_X7.v
   wire			sdram_done;		// From rc of ram_controller_X7.v
   wire			sdram_ready;		// From rc of ram_controller_X7.v
   wire			sdram_req;		// From uhdl_common of uhdl_common.v
   wire			sdram_write;		// From uhdl_common of uhdl_common.v
   wire			spy_rd;			// From uhdl_common of uhdl_common.v
   wire [3:0]		spy_reg;		// From uhdl_common of uhdl_common.v
   wire			spy_wr;			// From uhdl_common of uhdl_common.v
   wire			vga_blank;		// From uhdl_common of uhdl_common.v
   wire [14:0]		vram_cpu_addr;		// From uhdl_common of uhdl_common.v
   wire [31:0]		vram_cpu_data_out;	// From rc of ram_controller_X7.v, ...
   wire			vram_cpu_done;		// From rc of ram_controller_X7.v
   wire			vram_cpu_ready;		// From rc of ram_controller_X7.v
   wire			vram_cpu_req;		// From uhdl_common of uhdl_common.v
   wire			vram_cpu_write;		// From uhdl_common of uhdl_common.v
   wire [14:0]		vram_vga_addr;		// From uhdl_common of uhdl_common.v
   wire [31:0]		vram_vga_data_out;	// From rc of ram_controller_X7.v
   wire			vram_vga_ready;		// From rc of ram_controller_X7.v
   wire			vram_vga_req;		// From uhdl_common of uhdl_common.v
   // End of automatics
   wire [2:0] cpu_st;
   wire [2:0] rst_st;
   wire [11:0] bdst;
   ////////////////////////////////////////////////////////////////////////////////
   wire clk50;
   wire [31:0] vram_cpu_data_in;
   wire [31:0] sdram_data_rc2cpu;
   //wire clk_vga_in;
   wire local_reset;
   wire clk_dram_in;
   //wire sysclk;
   wire vga_clk;
   wire vga_clk_locked;
   wire cpu_clk;
   wire clk_dram;
   wire machrun;
   //wire ref_clk_in;
   wire ref_clk;
   wire main_clk;
   wire promdis;
   wire [13:0] pc;
   wire [25:0] o_lc;
   wire [23:0] bd_addr;
   wire [5:0] bd_cmds;
   
   reg main_uart_rx;
   
   always @(*) begin
     main_uart_rx = switch[3] ? uart_rxd : rs232_rxd;
   end
   
   
   reg rs1;
   reg rs2;
   
   always @(posedge main_clk) begin
     rs1 <= local_reset;
     rs2 <= rs1;
   end
   
   assign uart_txd = rs232_txd;
   
   //BUFG vgaclk_bufg(.I(sysclk), .O(clk_vga_in));
   //BUFG clkdram_bg(.I(sysclk), .O(clk_dram_in));
   //BUFG sysclk_bufg(.I(sysclk), .O(sys_clk_in));
   //BUFG refclk_bufg(.I(sysclk), .O(ref_clk_in));
   BUFG reset_bufg(.I(rs2), .O(reset));
   
   sysclk_wiz sys_inst (.clk_in1(sysclk), .clk50(clk50), .clk_dram(clk_dram), .clk_ref(ref_clk), .reset(1'b0));
   
   clk_wiz clocking_inst(.CLK_50(sysclk), /*.CLK_VGA(vga_clk), */.CLK_HDVGA(vga_clk), /*.clk_dram(clk_dram),*/ .RESET(dcm_reset), .LOCKED(vga_clk_locked));
   
   //clk_wiz_dram clk_inst(.clk_in(clk_dram_in), .clk_dram(clk_dram), .reset(dcm_reset));
   //clk_wiz_0 clk_inst_a(.clk_in(ref_clk_in), .ref_clk_out(ref_clk), .reset(dcm_reset));
   reg [0:0] clkcnt;
   //reg [3:0] clkcnt;
   initial clkcnt = 0;
   always @(posedge main_clk)
     clkcnt <= ~clkcnt;
   BUFG cpuclk_bufg(.I(clkcnt[0]), .O(cpu_clk));
   
   support_arty_a7 support (
      .sysclk(clk50),
      .button_r(button[3]),
      .button_b(button[2]),
      .button_h(button[1]),
      .button_c(button[0]),
      .cpu_st(cpu_st),
      .rst_st(rst_st),
      // Outputs
      .boot				(boot),
      .dcm_reset			(dcm_reset),
      .halt				(halt),
      .interrupt			(interrupt),
      .lpddr_reset			(lpddr_reset),
      .reset				(local_reset),
      // Inputs
      .cpu_clk				(cpu_clk),
      .lpddr_calib_done			(sdram_calib_done)
   );
   
   ram_controller_X7 rc (
      .sdram_data_in        (sdram_data_cpu2rc),
      .sdram_data_out       (sdram_data_rc2cpu),
      .vram_cpu_data_in     (vram_cpu_data_out),
      .vram_cpu_data_out    (vram_cpu_data_in),
      // DDR3
      .ddr3_addr            (ddr3_addr),  // output [13:0]		ddr3_addr
      .ddr3_ba              (ddr3_ba),  // output [2:0]		ddr3_ba
      .ddr3_cas_n           (ddr3_cas_n),  // output			ddr3_cas_n
      .ddr3_ck_n            (ddr3_ck_n),  // output [0:0]		ddr3_ck_n
      .ddr3_ck_p            (ddr3_ck_p),  // output [0:0]		ddr3_ck_p
      .ddr3_cke             (ddr3_cke),  // output [0:0]		ddr3_cke
      .ddr3_ras_n           (ddr3_ras_n),  // output			ddr3_ras_n
      .ddr3_reset_n         (ddr3_reset_n),  // output			ddr3_reset_n
      .ddr3_we_n            (ddr3_we_n),  // output			ddr3_we_n
      .ddr3_dq              (ddr3_dq),  // inout [15:0]		ddr3_dq
      .ddr3_dqs_n           (ddr3_dqs_n),  // inout [1:0]		ddr3_dqs_n
      .ddr3_dqs_p           (ddr3_dqs_p),
      .ddr3_cs_n            (ddr3_cs_n),
      .ddr3_dm              (ddr3_dm),
      .ddr3_odt             (ddr3_odt),
      // outputs
      .vram_vga_data_out	(vram_vga_data_out[31:0]),
      .sdram_calib_done		(sdram_calib_done),
      .sdram_done			(sdram_done),
      .sdram_ready			(sdram_ready),
      .vram_cpu_done		(vram_cpu_done),
      .vram_cpu_ready		(vram_cpu_ready),
      .vram_vga_ready		(vram_vga_ready),
      // Inputs
      //.mcr_addr				(mcr_addr[13:0]),
      .vram_cpu_addr		(vram_cpu_addr[14:0]),
      .vram_vga_addr		(vram_vga_addr[14:0]),
      .sdram_addr			(sdram_addr[21:0]),
      .fetch				(fetch),
      .sdram_reset			(lpddr_reset),
      .machrun				(machrun),
      //.mcr_write			(mcr_write),
      .prefetch				(prefetch),
      .reset				(reset),
      .sdram_req			(sdram_req),
      .sdram_write			(sdram_write),
      .cpu_clk				(cpu_clk),
      .sdram_clk            (sysclk),
      .sdram_clk_out        (main_clk),
      .ref_clk              (ref_clk),
      .vga_clk				(vga_clk),
      .vram_cpu_req			(vram_cpu_req),
      .vram_cpu_write		(vram_cpu_write),
      .vram_vga_req			(vram_vga_req)
   );

   uhdl_common uhdl_common(
        // Outputs
        .sdram_addr		(sdram_addr[21:0]),
        .sdram_data_cpu2rc	(sdram_data_cpu2rc[31:0]),
        .sdram_req		(sdram_req),
        .sdram_write		(sdram_write),
        .vram_cpu_addr	(vram_cpu_addr[14:0]),
        .vram_cpu_data_out	(vram_cpu_data_out[31:0]),
        .vram_cpu_req	(vram_cpu_req),
        .vram_cpu_write	(vram_cpu_write),
        .spy_reg		(spy_reg[3:0]),
        .busint_spyout	(busint_spyout[15:0]),
        .spy_rd		(spy_rd),
        .spy_wr		(spy_wr),
        .disk_state		(disk_state[4:0]),
        .fetch		(fetch),
        .prefetch		(prefetch),
        //.mcr_addr		(mcr_addr[13:0]),
        //.mcr_data_out	(mcr_data_out[48:0]),
        //.mcr_write		(mcr_write),
        .mmc_cs		(mmc_cs),
        .mmc_do		(mmc_do),
        .mmc_sclk		(mmc_sclk),
        .vram_vga_addr	(vram_vga_addr[14:0]),
        .vram_vga_req	(vram_vga_req),
        .vga_blank		(vga_blank),
        .vga_r		(vga_r),
        .vga_g		(vga_g),
        .vga_b		(vga_b),
        .vga_hsync		(vga_hsync),
        .vga_vsync		(vga_vsync),
        .rs232_txd		(rs232_txd),
        .bdst		(bdst[11:0]),
        .o_pc		(pc[13:0]),
        .o_lc		(o_lc[25:0]),
        .o_bd_addr		(bd_addr[23:0]),
        .o_bda		(bd_cmds[5:0]),
        .promdis		(promdis),
         // Inouts
        .ms_ps2_clk		(ms_ps2_clk),
        .ms_ps2_data		(ms_ps2_data),
         // Inputs
        .sdram_data_rc2cpu	(sdram_data_rc2cpu[31:0]),
        .sdram_done		(sdram_done),
        .sdram_ready		(sdram_ready),
        .vram_cpu_data_in	(vram_cpu_data_in[31:0]),
        .vram_cpu_done	(vram_cpu_done),
        .vram_cpu_ready	(vram_cpu_ready),
        .cpu_clk		(cpu_clk),
        .boot		(boot),
        .halt		(halt),
        .interrupt		(interrupt),
        .mcr_data_in(48'b0),
        .mcr_ready(0),
        .mcr_done(0),
        //.mcr_data_in		(mcr_data_in[48:0]),
        //.mcr_ready		(mcr_ready),
        //.mcr_done		(mcr_done),
        .mmc_di		(mmc_di),
        .vram_vga_data_out	(vram_vga_data_out[31:0]),
        .vram_vga_ready	(vram_vga_ready),
        .vga_clk		(vga_clk),
        .kb_ps2_clk		(kb_ps2_clk),
        .kb_ps2_data		(kb_ps2_data),
        .rs232_rxd		(main_uart_rx),
        .clk50		(main_clk),
        .reset		(reset)
   );
   
   led_controller lc (
     .sysclk (sysclk),
     .led (led),
     .reset (reset),
     .rst_st (rst_st),
     .cpu_st(cpu_st),
     .bdst(bdst),
     .sdram_reset(lpddr_reset),
     .prom_disable(promdis),
     .ddr_calib_done (sdram_calib_done),
     .pc (pc),
     .lc (o_lc),
     .boot(boot),
     .switches(switch),
     .bd_addr (bd_addr),
     .bd_cmds (bd_cmds)
   );
endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
