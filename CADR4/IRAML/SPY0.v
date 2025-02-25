// SPY0 --- PDP11 EXAMINE CONTROL
//
// ---!!! Add description.
//
// History:
//
//   (20YY-MM-DD HH:mm:ss BRAD) Converted to Verilog.
//	???: Nets added.
//	???: Nets removed.
//   (1978-02-07 05:36:57 TK) Initial.

`timescale 1ns/1ps
`default_nettype none

module SPY0
  (input wire [4:0] eadr,
   input wire	    dbread,
   input wire	    dbwrite,

   output wire	    ldclk,
   output wire	    lddbirh,
   output wire	    lddbirl,
   output wire	    lddbirm,
   output wire	    ldmdh,
   output wire	    ldmdl,
   output wire	    ldmode,
   output wire	    ldopc,
   output wire	    ldscratch1,
   output wire	    ldscratch2,
   output wire	    ldvmah,
   output wire	    ldvmal,
   output wire	    spy_ah,
   output wire	    spy_al,
   output wire	    spy_bd,
   output wire	    spy_disk,
   output wire	    spy_flag1,
   output wire	    spy_flag2,
   output wire	    spy_irh,
   output wire	    spy_irl,
   output wire	    spy_irm,
   output wire	    spy_mdh,
   output wire	    spy_mdl,
   output wire	    spy_mh,
   output wire	    spy_ml,
   output wire	    spy_obh,
   output wire	    spy_obh_,
   output wire	    spy_obl,
   output wire	    spy_obl_,
   output wire	    spy_opc,
   output wire	    spy_pc,
   output wire	    spy_scratch,
   output wire	    spy_sth,
   output wire	    spy_stl,
   output wire	    spy_vmah,
   output wire	    spy_vmal,

   input wire	    clk,
   input wire	    reset);

   ////////////////////////////////////////////////////////////////////////////////

   // Read registers.
   assign {spy_obh, spy_obl, spy_pc, spy_opc, spy_scratch, spy_irh, spy_irm, spy_irl}
     = ({dbread, eadr} == 6'b10_0000) ? 8'b00000001 :
       ({dbread, eadr} == 6'b10_0001) ? 8'b00000010 :
       ({dbread, eadr} == 6'b10_0010) ? 8'b00000100 :
       ({dbread, eadr} == 6'b10_0011) ? 8'b00001000 :
       ({dbread, eadr} == 6'b10_0100) ? 8'b00010000 :
       ({dbread, eadr} == 6'b10_0101) ? 8'b00100000 :
       ({dbread, eadr} == 6'b10_0110) ? 8'b01000000 :
       ({dbread, eadr} == 6'b10_0111) ? 8'b10000000 :
       8'b00000000;
   assign {spy_sth, spy_stl, spy_ah, spy_al, spy_mh, spy_ml, spy_flag2, spy_flag1}
     = ({dbread, eadr} == 6'b10_1000) ? 8'b00000001 :
       ({dbread, eadr} == 6'b10_1001) ? 8'b00000010 :
       ({dbread, eadr} == 6'b10_1010) ? 8'b00000100 :
       ({dbread, eadr} == 6'b10_1011) ? 8'b00001000 :
       ({dbread, eadr} == 6'b10_1100) ? 8'b00010000 :
       ({dbread, eadr} == 6'b10_1101) ? 8'b00100000 :
       ({dbread, eadr} == 6'b10_1110) ? 8'b01000000 :
       ({dbread, eadr} == 6'b10_1111) ? 8'b10000000 :
       8'b00000000;
   assign {spy_bd, spy_disk, spy_obh_, spy_obl_, spy_vmah, spy_vmal, spy_mdh, spy_mdl}
     = ({dbread, eadr} == 6'b11_0000) ? 8'b00000001 :
       ({dbread, eadr} == 6'b11_0001) ? 8'b00000010 :
       ({dbread, eadr} == 6'b11_0010) ? 8'b00000100 :
       ({dbread, eadr} == 6'b11_0011) ? 8'b00001000 :
       ({dbread, eadr} == 6'b11_0100) ? 8'b00010000 :
       ({dbread, eadr} == 6'b11_0101) ? 8'b00100000 :
       ({dbread, eadr} == 6'b11_0110) ? 8'b01000000 :
       ({dbread, eadr} == 6'b11_0111) ? 8'b10000000 :
       8'b00000000;

   // Load registers.
   assign {ldscratch2, ldscratch1, ldmode, ldopc, ldclk, lddbirh, lddbirm, lddbirl}
     = ({dbwrite, eadr} == 6'b10_0000) ? 8'b00000001 :
       ({dbwrite, eadr} == 6'b10_0001) ? 8'b00000010 :
       ({dbwrite, eadr} == 6'b10_0010) ? 8'b00000100 :
       ({dbwrite, eadr} == 6'b10_0011) ? 8'b00001000 :
       ({dbwrite, eadr} == 6'b10_0100) ? 8'b00010000 :
       ({dbwrite, eadr} == 6'b10_0101) ? 8'b00100000 :
       ({dbwrite, eadr} == 6'b10_0110) ? 8'b01000000 :
       ({dbwrite, eadr} == 6'b10_0111) ? 8'b10000000 :
       8'b00000000;
   assign {ldvmah, ldvmal, ldmdh, ldmdl}
     = ({dbwrite, eadr} == 6'b10_1000) ? 4'b0001 :
       ({dbwrite, eadr} == 6'b10_1001) ? 4'b0010 :
       ({dbwrite, eadr} == 6'b10_1010) ? 4'b0100 :
       ({dbwrite, eadr} == 6'b10_1011) ? 4'b1000 :
       4'b0000;

endmodule

`default_nettype wire

// Local Variables:
// verilog-library-directories: ("../..")
// End:
