// busint.v --- bus interface
//
// Basic bus interface for CADR, does basic arbitration and allows
// disk to be bus master. See SYS:DOC;UNADDR TEXT for how addresses
// are mapped.

module busint(mclk, reset,
              addr, busin, busout, spyin, spyout, spyreg, spyrd, spywr,
              req, ack, write, load,
              interrupt,

              sdram_addr, sdram_data_in, sdram_data_out,
              sdram_req, sdram_ready, sdram_write, sdram_done,

              vram_addr, vram_data_in, vram_data_out,
              vram_req, vram_ready, vram_write, vram_done,

              bd_cmd, bd_start, bd_bsy, bd_rdy, bd_err, bd_addr,
              bd_data_in, bd_data_out, bd_rd, bd_wr, bd_iordy, bd_state_in,

              kb_data, kb_ready,
              ms_x, ms_y, ms_button, ms_ready,

              promdisable, disk_state, bus_state);

   input mclk;
   input reset;
   input [21:0] addr;

   input [31:0] busin;
   input [15:0] spyin;

   output [31:0] busout;
   output [15:0] spyout;
   output [3:0] spyreg;
   output spyrd;
   output spywr;

   input req, write;
   output ack, load, interrupt;

   // Generic block device interface.
   output [1:0] bd_cmd;
   output bd_start;
   input bd_bsy;
   input bd_rdy;
   input bd_err;
   output [23:0] bd_addr;
   input [15:0] bd_data_in;
   output [15:0] bd_data_out;
   output bd_rd;
   output bd_wr;
   input bd_iordy;
   input [11:0] bd_state_in;

   output promdisable;
   output [4:0] disk_state;
   output [3:0] bus_state;

   output [21:0] sdram_addr;
   output [31:0] sdram_data_out;
   input [31:0] sdram_data_in;
   output sdram_req;
   input sdram_ready;
   output sdram_write;
   input sdram_done;

   output [14:0] vram_addr;
   output [31:0] vram_data_out;
   input [31:0] vram_data_in;
   output vram_req;
   input vram_ready;
   output vram_write;
   input vram_done;

   input [15:0] kb_data;
   input kb_ready;

   input [11:0] ms_x, ms_y;
   input [2:0] ms_button;
   input ms_ready;

   parameter [3:0]
     BUS_IDLE = 4'b0000,
     BUS_REQ = 4'b0001,
     BUS_WAIT = 4'b0010,
     BUS_SLAVE = 4'b0100,
     BUS_SWAIT = 4'b1000;

   reg [3:0] state;
   wire [3:0] next_state;

   reg [5:0] timeout_count;

`ifdef debug
   integer debug_xbus;
   integer debug_bus;
   integer debug_detail;

   initial
     begin
        debug_xbus = 0;
        debug_bus = 0;
        debug_detail = 0;
     end
`endif

   wire decode_ok;
   wire decode_dram, decode_disk, decode_tv, decode_io, decode_unibus, decode_spy;

   wire ack;
   wire ack_dram, ack_disk, ack_tv, ack_io, ack_unibus, ack_spy;

   wire interrupt;
   wire interrupt_disk, interrupt_tv, interrupt_io, interrupt_unibus;

   wire disk_busreq2busint;
   wire busgrantin2disk;

   wire dram_reqin;
   wire dram_writein;

   wire [21:0] dram_addr;
   wire [31:0] dram_datain;
   wire [31:0] disk_datain;

   wire [31:0] dataout_dram;
   wire [31:0] dataout_disk;
   wire [31:0] dataout_tv;
   wire [31:0] dataout_io;
   wire [31:0] dataout_unibus;
   wire [31:0] dataout_spy;

   wire [21:0] addrout_diskr;

   wire device_ack;

   wire timed_out;

   wire [7:0] vector;

   xbus_ram dram(
                 .clk(mclk),
                 .reset(reset),
                 .addr(dram_addr),
                 .datain(dram_datain),
                 .dataout(dataout_dram),
                 .req(dram_reqin),
                 .write(dram_writein),
                 .ack(ack_dram),
                 .decode(decode_dram),

                 .sdram_addr(sdram_addr),
                 .sdram_data_in(sdram_data_in),
                 .sdram_data_out(sdram_data_out),
                 .sdram_req(sdram_req),
                 .sdram_ready(sdram_ready),
                 .sdram_write(sdram_write),
                 .sdram_done(sdram_done)
                 );

   wire req_valid;
   assign req_valid = req && state == BUS_REQ;

   wire ackin_disk;
   wire disk_write2busint;
   wire disk_req2busint;
   wire decodein_disk;

   xbus_disk disk(
                  .reset(reset),
                  .clk(mclk),

                  .addrin(addr),
                  .datain(disk_datain),
                  .dataout(dataout_disk),
                  .reqin(req_valid),
                  .writein(write),
                  .ackout(ack_disk),
                  .decodeout(decode_disk),
                  .interrupt(interrupt_disk),

                  .busreqout(disk_busreq2busint),
                  .busgrantin(busgrantin2disk),
                  .addrout(addrout_disk),
                  .reqout(disk_req2busint),
                  .ackin(ackin_disk),
                  .writeout(disk_write2busint),
                  .decodein(decodein_disk),

                  .bd_cmd(bd_cmd),
                  .bd_start(bd_start),
                  .bd_bsy(bd_bsy),
                  .bd_rdy(bd_rdy),
                  .bd_err(bd_err),
                  .bd_addr(bd_addr),
                  .bd_data_in(bd_data_in),
                  .bd_data_out(bd_data_out),
                  .bd_rd(bd_rd),
                  .bd_wr(bd_wr),
                  .bd_iordy(bd_iordy),
                  .bd_state_in(bd_state_in),

                  .disk_state(disk_state)
                  );

   xbus_tv tv(
              .clk(mclk),
              .reset(reset),
              .addr(addr),
              .datain(busin),
              .dataout(dataout_tv),
              .req(req_valid),
              .write(write),
              .ack(ack_tv),
              .decode(decode_tv),
              .interrupt(interrupt_tv),

              .vram_addr(vram_addr),
              .vram_data_in(vram_data_in),
              .vram_data_out(vram_data_out),
              .vram_req(vram_req),
              .vram_ready(vram_ready),
              .vram_write(vram_write),
              .vram_done(vram_done)
              );

   xbus_io io(
              .clk(mclk),
              .reset(reset),
              .addr(addr),
              .datain(busin),
              .dataout(dataout_io),
              .req(req_valid),
              .write(write),
              .ack(ack_io),
              .decode(decode_io),
              .interrupt(interrupt_io),
              .vector(vector),
              .kb_data(kb_data),
              .kb_ready(kb_ready),
              .ms_x(ms_x),
              .ms_y(ms_y),
              .ms_button(ms_button),
              .ms_ready(ms_ready)
              );

   xbus_unibus unibus(
                      .reset(reset),
                      .clk(mclk),
                      .addr(addr),
                      .datain(busin),
                      .dataout(dataout_unibus),
                      .req(req_valid),
                      .write(write),
                      .ack(ack_unibus),
                      .decode(decode_unibus),
                      .interrupt(interrupt_unibus),
                      .promdisable(promdisable),
                      .timeout(timed_out)
                      );

   xbus_spy spy(
                .clk(mclk),
                .reset(reset),
                .addr(addr),
                .datain(busin),
                .dataout(dataout_spy),
                .req(req_valid),
                .write(write),
                .ack(ack_spy),
                .decode(decode_spy),
                .spyin(spyin),
                .spyout(spyout),
                .spyreg(spyreg),
                .spywr(spywr),
                .spyrd(spyrd)
                );

   assign decode_ok = decode_dram | decode_disk | decode_tv |
                      decode_io | decode_unibus | decode_spy;

   assign device_ack = ack_dram | ack_disk | ack_tv | ack_io | ack_unibus | ack_spy |
                       timed_out;

   assign ack = (load || state == BUS_WAIT);

   assign interrupt = interrupt_disk | interrupt_tv |
                      interrupt_io | interrupt_unibus;

   assign busout =
                  (req & decode_dram & ~write) ? dataout_dram :
                  (req & decode_disk & ~write) ? dataout_disk :
                  (req & decode_tv & ~write) ? dataout_tv :
                  (req & decode_io & ~write) ? dataout_io :
                  (req & decode_unibus & ~write) ? dataout_unibus :
                  (req & decode_spy & ~write) ? dataout_spy :
                  (req & timed_out & ~write) ? 32'h00000000 :
                  32'hffffffff;

`ifdef debug
   always @(posedge mclk)
     begin
        if (req && debug_xbus != 0)
          if (write)
            begin
               $display("xbus: write @%o <- %o (0x%x); %t",
                        addr, busin, busin, $time);
            end
          else
            begin
               $display("xbus: read @%o -> %o (0x%x); %t",
                        addr, busout, busout, $time);
            end
     end
`endif

   // Bus control state machine.
   always @(posedge mclk)
     if (reset)
       begin
          state <= BUS_IDLE;
       end
     else
       begin
          state <= next_state;

`ifdef debug
          if (next_state != state && next_state == BUS_REQ && debug_bus != 0)
            begin
               $display("busint: BUS_REQ addr %o (decode %b); %t",
                        addr,
                        {decode_dram, decode_disk, decode_tv, decode_io, decode_unibus, decode_spy},
                        $time);
            end
`endif

`ifdef debug
          if (next_state != state && debug_detail > 1)
            begin
               case (next_state)
                 BUS_REQ: $display("busint: BUS_REQ addr %o; %t",
                                   dram_addr, $time);
                 BUS_WAIT: $display("busint: BUS_WAIT addr %o; %t",
                                    dram_addr, $time);
                 BUS_SLAVE: $display("busint: BUS_SLAVE addr %o; %t",
                                     dram_addr, $time);
                 BUS_SWAIT: $display("busint: BUS_SWAIT addr %o; %t",
                                     dram_addr, $time);
                 BUS_IDLE: $display("busint: BUS_IDLE addr %o; %t",
                                    dram_addr, $time);
                 default: $display("busint: ??; %t", $time);
               endcase
            end
`endif

`ifdef debug
          if (next_state != state && debug_detail != 0)
            case (next_state)
              BUS_REQ:
                begin
                   $display("busint: REQ req %b write %b decode_dram %b",
                            req, write, decode_dram);
                   $display("busint: REQ req %b dram_reqin %b dram_writein %b",
                            req, dram_reqin, dram_writein);
                   $display("busint: REQ req %b ack %b; acks %b %b %b %b %b %b",
                            req, device_ack,
                            ack_dram, ack_disk, ack_tv, ack_io, ack_unibus, ack_spy);
                end
              BUS_WAIT:
                $display("busint: WAIT req %b ack %b; acks %b %b %b %b %b %b",
                         req, device_ack,
                         ack_dram, ack_disk, ack_tv, ack_io, ack_unibus, ack_spy);
              BUS_SLAVE:
                begin
                   #1 $display("busint: SLAVE addr %o; %t", dram_addr, $time);
                   #1 $display("busint: slave req %b ack %b; ack_dram %b",
                               req, device_ack, ack_dram);
                end

              BUS_SWAIT: $display("busint: SWAIT addr %o; %t",
                                  dram_addr, $time);

              BUS_IDLE: $display("busint: IDLE ; %t",
                                 $time);
            endcase
`endif
       end

   assign bus_state = state;

   // Basic bus arbiter.
   assign next_state =
                      (state == BUS_IDLE && req) ? BUS_REQ :
                      (state == BUS_IDLE && disk_busreq2busint) ? BUS_SLAVE :
                      (state == BUS_REQ && device_ack) ? BUS_WAIT :
                      (state == BUS_REQ && ~device_ack) ? BUS_REQ :
                      (state == BUS_WAIT && ~req) ? BUS_IDLE :
                      (state == BUS_WAIT && req) ? BUS_WAIT :
                      (state == BUS_SLAVE && ack_dram) ? BUS_SWAIT :
                      (state == BUS_SLAVE && ~ack_dram) ? BUS_SLAVE :
                      (state == BUS_SWAIT && (disk_busreq2busint || ack_dram)) ? BUS_SWAIT :
                      (state == BUS_SWAIT && ~disk_busreq2busint) ? BUS_IDLE :
                      BUS_IDLE;

   assign busgrantin2disk = state == BUS_SLAVE;
   assign load = device_ack & ~write & (state == BUS_REQ);

   // Allow disk to drive DRAM.
   assign dram_addr = state == BUS_SLAVE ? addrout_disk : addr;
   assign dram_reqin = state == BUS_SLAVE ? disk_req2busint : (req && state == BUS_REQ);
   assign dram_writein = state == BUS_SLAVE ? disk_write2busint : (write && state == BUS_REQ);
   assign dram_datain = state == BUS_SLAVE ? dataout_disk : busin;

   assign disk_datain = state == BUS_SLAVE ? dataout_dram : busin;
   assign decodein_disk = busgrantin2disk & decode_dram;
   assign ackin_disk = busgrantin2disk & ack_dram;

   // Bus timeout.
   always @(posedge mclk)
     if (reset)
       timeout_count <= 0;
     else
       if (state == BUS_REQ && ~timed_out)
         timeout_count <= timeout_count + 6'b000001;
       else
         if (state == BUS_WAIT)
           timeout_count <= 0;

   assign timed_out = timeout_count == 6'b111111;

`ifdef debug
   always @(posedge mclk)
     if (timed_out)
       $display("busint: timeout; addr %o; %t", addr, $time);
`endif

endmodule
