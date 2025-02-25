// mmc_wrapper.v --- ---!!!

/* verilator lint_off WIDTH */

`timescale 1ns/1ps
`default_nettype none

module mmc_wrapper
  (input wire 	     mmc_clk,
   input wire 	     mmc_di,
   output wire 	     mmc_cs,
   output wire 	     mmc_do,
   output wire 	     mmc_sclk,
   input wire [47:0] cmd,

   input wire [7:0]  data_in,
   input wire 	     init,
   input wire 	     rd,
   input wire 	     send,
   input wire 	     speed,
   input wire 	     stop,
   input wire 	     wr,
   output wire [3:0] state_out,
   output wire [7:0] data_out,
   output wire 	     done,

   input wire 	     clk,
   input wire 	     reset);

   reg [13:0] mmc2sampled0, mmc2sampled1;
   reg [62:0] sampled2mmc0, sampled2mmc1;

   wire [13:0] mmc2sample;
   wire [3:0] mmc2state_out;
   wire [47:0] cmd2mmc;
   wire [62:0] sample2mmc;
   wire [7:0] data_in2mmc;
   wire [7:0] mmc2mmc_data_out;
   wire mmc2mmc_done;
   wire rd2mmc, wr2mmc, init2mmc, send2mmc, stop2mmc, speed2mmc;

   /*AUTOWIRE*/
   /*AUTOREG*/

   ////////////////////////////////////////////////////////////////////////////////

   assign sample2mmc = { cmd, data_in, speed, stop, send, init, wr, rd };

   always @(posedge mmc_clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	sampled2mmc0 <= 63'h0;
	sampled2mmc1 <= 63'h0;
	// End of automatics
     end else begin
	sampled2mmc0 <= sample2mmc;
	sampled2mmc1 <= sampled2mmc0;
     end

   assign rd2mmc = sampled2mmc1[0];
   assign wr2mmc = sampled2mmc1[1];
   assign init2mmc = sampled2mmc1[2];
   assign send2mmc = sampled2mmc1[3];
   assign stop2mmc = sampled2mmc1[4];
   assign speed2mmc = sampled2mmc1[5];
   assign data_in2mmc = sampled2mmc1[13:6];
   assign cmd2mmc = sampled2mmc1[62:14];
   assign mmc2sample = { mmc2state_out, mmc2mmc_data_out, mmc2mmc_done };

   always @(posedge clk)
     if (reset) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	mmc2sampled0 <= 14'h0;
	mmc2sampled1 <= 14'h0;
	// End of automatics
     end else begin
	mmc2sampled0 <= mmc2sample;
	mmc2sampled1 <= mmc2sampled0;
     end

   assign done = mmc2sampled1[0];
   assign data_out = mmc2sampled1[8:1];
   assign state_out = mmc2sampled1[13:9];

   mmc mmc
     (
      .clk(mmc_clk),
      .speed(speed2mmc),
      .rd(rd2mmc),
      .wr(wr2mmc),
      .init(init2mmc),
      .send(send2mmc),
      .stop(stop2mmc),
      .cmd(cmd2mmc),
      .data_in(data_in2mmc),
      .data_out(mmc2mmc_data_out),
      .done(mmc2mmc_done),
      .state_out(mmc2state_out),
      /*AUTOINST*/
      // Outputs
      .mmc_sclk				(mmc_sclk),
      .mmc_cs				(mmc_cs),
      .mmc_do				(mmc_do),
      // Inputs
      .mmc_di				(mmc_di),
      .reset				(reset));

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
