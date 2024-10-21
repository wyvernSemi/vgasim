// =============================================================
//
// Behavioural component for HDMI or VGA display
//
// Copyright (c) 2024 Simon Southwell. Confidential
//
// This file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this file. If not, see <http://www.gnu.org/licenses/>.
//
// =============================================================

`include "display_defs.vh"

module display
#(parameter                   NODE = 0
)
(
  input                       clk,

  input                       hsync,
  input                       vsync,

  input  [9:0]                red,
  input  [9:0]                green,
  input  [9:0]                blue
);

wire [31:0]                   addr;
wire [31:0]                   wdata;
wire                          wr;
wire                          rd;
wire                          update;

reg  [31:0]                   rdata;
reg                           updateresp;

// ---------------------------------------------------------
 // Virtual Processor
// ---------------------------------------------------------

  VProc vp
  (
    .Clk                      (~clk),
    .Addr                     (addr),
    .WE                       (wr),
    .RD                       (rd),
    .DataOut                  (wdata),
    .DataIn                   (rdata),
    .WRAck                    (wr),
    .RDAck                    (rd),
    .Interrupt                (3'b000),
    .Update                   (update),
    .UpdateResponse           (updateresp),
    
    .BE                       (),
    .Burst                    (),
    .BurstFirst               (),
    .BurstLast                (),
    
    .Node                     (NODE[3:0])
  );

// ---------------------------------------------------------
// Process to map VProc accesses to ports and simulation
// control.
// ---------------------------------------------------------

// Addressable read/write state from VProc
always @(update)
begin
  // Default read data value
  rdata                        = 32'h00000000;

  // Process when an access is valid
  if (wr === 1'b1 || rd === 1'b1)
  begin
    case(addr)

    `DISP_RED:      rdata[9:0] = red;
    `DISP_GREEN:    rdata[9:0] = green;
    `DISP_BLUE:     rdata[9:0] = blue;
    `DISP_HSYNC:    rdata[0]   = hsync;
    `DISP_VSYNC:    rdata[0]   = vsync;
    `DISP_NODE_NUM: rdata      = NODE;

    `DISP_STOP:
      if (wr === 1'b1) $stop;

    `DISP_FINISH:
      if (wr === 1'b1) $finish;

    default:
    begin
        $display("%m: ***Error. display---access to invalid address (%h) from VProc", addr);
        $stop;
    end
    endcase
  end

  // Finished processing for this delta update, so acknowledge
  // to VProc by inverting updateresp
  updateresp = ~updateresp;
end

endmodule