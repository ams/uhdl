// OPCS --- OLD PC SAVE SHIFTER
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-06-24 04:24:21 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module OPCS
  (input wire	     state_fetch,

   input wire [13:0] pc,
   input wire	     opcclk,
   input wire	     opcinh,
   output reg [13:0] opc,

   input wire	     clk,
   input wire	     reset);

   wire		     opcclka;

   ////////////////////////////////////////////////////////////////////////////////

   assign opcclka = (state_fetch | opcclk) & ~opcinh;

   always @(posedge clk)
     if (reset)
       opc <= 0;
     else if (opcclka)
       opc <= pc;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
