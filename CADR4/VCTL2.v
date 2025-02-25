// VCTL2 --- VMA/MD CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-08-16 06:38:11 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module VCTL2
  (input wire	     state_decode,
   input wire	     state_mmu,
   input wire	     state_read,
   input wire	     state_write,

   input wire [31:0] vma,
   input wire [48:0] ir,
   input wire	     destmdr,
   input wire	     destmem,
   input wire	     destvma,
   input wire	     dispwr,
   input wire	     dmapbenb,
   input wire	     ifetch,
   input wire	     irdisp,
   input wire	     loadmd,
   input wire	     memprepare,
   input wire	     memstart,
   input wire	     nopa,
   input wire	     srcmap,
   input wire	     srcmd,
   input wire	     wrcyc,
   output wire	     mdsel,
   output wire	     memdrive,
   output wire	     memrd,
   output wire	     memwr,
   output wire	     vm0rp,
   output wire	     vm0wp,
   output wire	     vm1rp,
   output wire	     vm1wp,
   output wire	     vmaenb,
   output wire	     vmasel,
   output wire	     wmap,

   input wire	     clk,
   input wire	     reset);

   wire		     early_vm0_rd;
   wire		     early_vm1_rd;
   wire		     normal_vm0_rd;
   wire		     normal_vm1_rd;
   wire		     use_md;
   wire		     mapwr0;
   wire		     mapwr1;
   wire		     lm_drive_enb;

   ////////////////////////////////////////////////////////////////////////////////

   assign mapwr0 = wmap & vma[26];
   assign mapwr1 = wmap & vma[25];
   assign early_vm0_rd = (irdisp && dmapbenb) | srcmap;
   assign early_vm1_rd = (irdisp && dmapbenb) | srcmap;
   assign normal_vm0_rd = wmap;
   assign normal_vm1_rd = 1'b0;
   assign vm0rp = (state_decode && early_vm0_rd) | (state_write && normal_vm0_rd) | (state_write && memprepare);
   assign vm1rp = (state_read && early_vm1_rd) | (state_mmu && normal_vm1_rd) | (state_mmu && memstart);
   assign vm0wp = mapwr0 & state_write;
   assign vm1wp = mapwr1 & state_mmu;
   assign vmaenb = destvma | ifetch;
   assign vmasel = ~ifetch;
   assign lm_drive_enb = 0;
   assign memdrive = wrcyc & lm_drive_enb;
   assign mdsel = destmdr & ~loadmd;
   assign use_md = srcmd & ~nopa;
   assign {wmap, memwr, memrd}
     = ~destmem ? 3'b000 :
       (ir[20:19] == 2'b01) ? 3'b001 :
       (ir[20:19] == 2'b10) ? 3'b010 :
       (ir[20:19] == 2'b11) ? 3'b100 :
       3'b000 ;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("..")
// End:
