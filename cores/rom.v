// rom.v --- generic ROM

/* verilator lint_off WIDTH */

`timescale 1ns/1ps
`default_nettype none

module rom
  (input wire [ADDRESS_WIDTH-1:0] addr_i,
   output wire [DATA_WIDTH-1:0] q_o,

   input wire 			clk_i,
   input wire 			reset_i);
   
   parameter ADDRESS_WIDTH = 5;
   parameter DATA_WIDTH = 5;
   parameter MEM_DEPTH = 32;
   parameter MEM_FILE = "rom.hex";
   parameter MEM_FILE_FORMAT = "hex";

   ////////////////////////////////////////////////////////////////////////////////

   reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
   reg [DATA_WIDTH-1:0] q = 0;

   initial begin
      if (MEM_FILE_FORMAT == "hex")
	$readmemh(MEM_FILE, mem);
      else if (MEM_FILE_FORMAT == "binary")
	$readmemb(MEM_FILE, mem);
   end

   always @(posedge clk_i)
     q <= mem[addr_i];

   assign q_o = q;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: (".")
// End:
