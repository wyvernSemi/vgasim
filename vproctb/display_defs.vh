// =============================================================
//
// Definitions for behavioural component for HDMI or VGA display
// Verilog
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

`ifndef _DISPLAY_DEFS_VH_
`define _DISPLAY_DEFS_VH_

// Memory mapped port address value
`define DISP_RED               32'h00000000
`define DISP_GREEN             32'h00000001
`define DISP_BLUE              32'h00000002
`define DISP_HSYNC             32'h00000003
`define DISP_VSYNC             32'h00000004

// Simulation control addresses
`define DISP_NODE_NUM          32'h00000100
`define DISP_STOP              32'h00000101
`define DISP_FINISH            32'h00000102

`endif