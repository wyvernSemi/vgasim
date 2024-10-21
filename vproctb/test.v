// =============================================================
//
// Top level VProc based test environment for AXI video controller
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

`timescale 1ps / 1ps

module test
#(parameter
  ACLK_PERIOD_PS              = 12500,
  PIXCLK_PERIOD_PS            = 9260,
  RESET_PERIOD_ACLKS          = 10,
  TIMEOUTCOUNT                = 20000000,
  FINISH                      = 0,
  VCD_DUMP                    = 0
);

reg                           aclk;
reg                           pixclk;
integer                       count;

// Wires for VProc manager interface
wire [31:0]                   vp_awaddr;
wire                          vp_awvalid;
wire                          vp_awready;
wire  [7:0]                   vp_awlen;
wire  [1:0]                   vp_awburst;
wire  [2:0]                   vp_awprot;

wire [31:0]                   vp_wdata;
wire                          vp_wvalid;
wire                          vp_wready;
wire                          vp_wlast;
wire  [3:0]                   vp_wstrb;

wire                          vp_bvalid;
wire                          vp_bready;

wire [31:0]                   vp_araddr;
wire                          vp_arvalid;
wire                          vp_arready;
wire  [7:0]                   vp_arlen;
wire  [2:0]                   vp_arprot;

wire [31:0]                   vp_rdata;
wire                          vp_rvalid;
wire                          vp_rready;

// Wires for Video controller manager read only interface
wire                          vid_axi_arvalid;
wire                          vid_axi_arready;
wire  [0:0]                   vid_axi_arid;
wire [31:0]                   vid_axi_araddr;
wire  [7:0]                   vid_axi_arlen;
wire  [2:0]                   vid_axi_arsize;
wire  [1:0]                   vid_axi_arburst;

wire                          vid_axi_rvalid;
wire                          vid_axi_rready;
wire [31:0]                   vid_axi_rdata;
wire                          vid_axi_rlast;
wire  [0:0]                   vid_axi_rid;

// VProc interrupt request signal
reg  [31:0]                   irq;

// Video controller RGB output signals, common to both VGA and HDMI
wire  [9:0]                   red;
wire  [9:0]                   green;
wire  [9:0]                   blue;

// Video controller VGA specific output signals
wire                          vga_hsync;
wire                          vga_vsync;

// External video processing signals
wire                          ex_vid_aclk;
wire                          ex_vid_aresetn;
wire                          ex_vid_tvalid;
wire                          ex_vid_tready;
wire [23:0]                   ex_vid_tdata;
wire                          ex_vid_tuser;
wire                          ex_vid_tlast;

// ---------------------------------------------------------
// Combinatorial logic
// ---------------------------------------------------------

// Generate a reset signal
wire   nreset                 = (count >= RESET_PERIOD_ACLKS) ? 1'b1 : 1'b0;

`ifdef HDMI
// In HDMI mode, tie-off unused signals
assign vga_hsync              = 1'b0;
assign vga_vsync              = 1'b0;
`else
assign red[9:8]               = 2'b00;
assign green[9:8]             = 2'b00;
assign blue[9:8]              = 2'b00;
`endif

// ---------------------------------------------------------
// Clock generation
// ---------------------------------------------------------

initial
begin
  // If enabled, dump all the signals to a VCD file
  if (VCD_DUMP != 0)
  begin
    $dumpfile("waves.vcd");
    $dumpvars(0, test);
  end

  aclk                        = 1'b1;
  count                       = 0;
  irq                         = 32'h00000000;

  forever # (ACLK_PERIOD_PS/2)
    aclk                      = ~aclk;
end

initial
begin
  pixclk                      = 1'b1;
  forever # (PIXCLK_PERIOD_PS/2)
    pixclk                    = ~pixclk;
end

// ---------------------------------------------------------
// Simulation control
// ---------------------------------------------------------

always @(posedge aclk)
begin
  count                       <= count + 1;

  if (count == TIMEOUTCOUNT)
  begin
    $display("***ERROR: simulation timed out");
    if (FINISH != 0)
    begin
      $finish;
    end
    else
    begin
      $stop;
    end
  end
end

// ---------------------------------------------------------
// AXI bus functional model
// ---------------------------------------------------------

  axi4bfm
  #(.NODE(0)) axivp
  (
    .clk                      (aclk),

    .awaddr                   (vp_awaddr),
    .awvalid                  (vp_awvalid),
    .awready                  (vp_awready),
    .awprot                   (vp_awprot),
    .awlen                    (vp_awlen),

    .wdata                    (vp_wdata),
    .wvalid                   (vp_wvalid),
    .wready                   (vp_wready),
    .wlast                    (vp_wlast),
    .wstrb                    (vp_wstrb),

    .bvalid                   (vp_bvalid),
    .bready                   (vp_bready),

    .araddr                   (vp_araddr),
    .arvalid                  (vp_arvalid),
    .arready                  (vp_arready),
    .arprot                   (vp_arprot),
    .arlen                    (vp_arlen),

    .rdata                    (vp_rdata),
    .rvalid                   (vp_rvalid),
    .rready                   (vp_rready),

    .irq                      (irq)
  );

// ---------------------------------------------------------
// Memory model
// ---------------------------------------------------------

  mem_model_axi mem
  (
    .clk                      (aclk),
    .nreset                   (nreset),

    .awaddr                   (),
    .awvalid                  (1'b0),
    .awready                  (),
    .awburst                  (),
    .awsize                   (),
    .awlen                    (),
    .awid                     (),

    .wdata                    (),
    .wvalid                   (1'b0),
    .wready                   (),
    .wstrb                    (),

    .bvalid                   (),
    .bready                   (1'b1),
    .bid                      (),

    .araddr                   (vid_axi_araddr),
    .arvalid                  (vid_axi_arvalid),
    .arready                  (vid_axi_arready),
    .arburst                  (vid_axi_arburst),
    .arsize                   (vid_axi_arsize),
    .arlen                    (vid_axi_arlen),
    .arid                     (vid_axi_arid),

    .rdata                    (vid_axi_rdata),
    .rvalid                   (vid_axi_rvalid),
    .rready                   (vid_axi_rready),
    .rlast                    (vid_axi_rlast),
    .rid                      (vid_axi_rid)
  );

// ---------------------------------------------------------
// Video controller UUT
// ---------------------------------------------------------

  axivideo #(
  ) vid
  (
     .S_AXI_ACLK              (aclk),
     .S_AXI_ARESETN           (nreset),
     
     // Subordinate register interface
     .S_AXIL_AWVALID          (vp_awvalid),
     .S_AXIL_AWREADY          (vp_awready),
     .S_AXIL_AWADDR           (vp_awaddr),
     .S_AXIL_AWPROT           (vp_awprot),

     .S_AXIL_WVALID           (vp_wvalid),
     .S_AXIL_WREADY           (vp_wready),
     .S_AXIL_WDATA            (vp_wdata),
     .S_AXIL_WSTRB            (vp_wstrb),

     .S_AXIL_BVALID           (vp_bvalid),
     .S_AXIL_BREADY           (vp_bready),
     .S_AXIL_BRESP            (),

     .S_AXIL_ARVALID          (vp_arvalid),
     .S_AXIL_ARREADY          (vp_arready),
     .S_AXIL_ARADDR           (vp_araddr),
     .S_AXIL_ARPROT           (vp_arprot),

     .S_AXIL_RVALID           (vp_rvalid),
     .S_AXIL_RREADY           (vp_rready),
     .S_AXIL_RDATA            (vp_rdata),
     .S_AXIL_RRESP            (),

     // Read interface
     .M_AXI_ARVALID           (vid_axi_arvalid),
     .M_AXI_ARREADY           (vid_axi_arready),
     .M_AXI_ARID              (vid_axi_arid),
     .M_AXI_ARADDR            (vid_axi_araddr),
     .M_AXI_ARLEN             (vid_axi_arlen),
     .M_AXI_ARSIZE            (vid_axi_arsize),
     .M_AXI_ARBURST           (vid_axi_arburst),

     .M_AXI_ARLOCK            (),
     .M_AXI_ARCACHE           (),
     .M_AXI_ARPROT            (),
     .M_AXI_ARQOS             (),

     .M_AXI_RVALID            (vid_axi_rvalid),
     .M_AXI_RREADY            (vid_axi_rready),
     .M_AXI_RDATA             (vid_axi_rdata),
     .M_AXI_RLAST             (vid_axi_rlast),
     .M_AXI_RID               (vid_axi_rid),
     .M_AXI_RRESP             (2'b00),

     // Video interface
     .i_pixclk                (pixclk),
     .o_clock_word            (),

`ifdef	HDMI
     .o_hdmi_red              (red),
     .o_hdmi_grn              (green),
     .o_hdmi_blu              (blue),
`else
     .o_vga_vsync             (vga_vsync),
     .o_vga_hsync             (vga_hsync),
     .o_vga_red               (red[7:0]),
     .o_vga_grn               (green[7:0]),
     .o_vga_blu               (blue[7:0]),
`endif

     // The external video processing pipeline interface
     .M_VID_ACLK              (ex_vid_aclk),
     .M_VID_ARESETN           (ex_vid_aresetn),

     .M_VID_TVALID            (ex_vid_tvalid),
     .M_VID_TREADY            (ex_vid_tready),
     .M_VID_TDATA             (ex_vid_tdata),
     .M_VID_TUSER             (ex_vid_tuser),
     .M_VID_TLAST             (ex_vid_tlast),

     .S_VID_TVALID            (ex_vid_tvalid),
     .S_VID_TREADY            (ex_vid_tready),
     .S_VID_TDATA             (ex_vid_tdata),
     .S_VID_TUSER             (ex_vid_tuser),
     .S_VID_TLAST             (ex_vid_tlast)
  );

// ---------------------------------------------------------
// Video display port for HDMI or VGA
// ---------------------------------------------------------

  display #(.NODE(1)) display
  (
     .clk                     (pixclk),

     .vsync                   (vga_vsync),
     .hsync                   (vga_hsync),
     .red                     (red),
     .green                   (green),
     .blue                    (blue)
  );

endmodule