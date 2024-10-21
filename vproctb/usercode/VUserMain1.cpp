// =============================================================
//
// VProc user code for Video controller test bench's display_defs
// model
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

#include <stdio.h>
#include <stdint.h>

#include "VProcClass.h"
#include "display_defs.h"

static int node = 1;

// ----------------------------------------------------------------------------
// VProc node 1 main entry point
// ----------------------------------------------------------------------------

extern "C" void VUserMain1(void)
{
    VProc* vp =  new VProc(node);
    
    uint32_t rdata;
    uint32_t hsync;
    uint32_t vsync;
    
    //vp->tick(400000);
    
    // Sample initial sync values
    vp->read(DISP_HSYNC, &hsync, DELTA_CYCLE);
    vp->read(DISP_VSYNC, &vsync, DELTA_CYCLE);
    vp->tick(1);
    
    for (int cycles = 0; cycles < 1000000; cycles++)
    {
        vp->read(DISP_HSYNC, &rdata, DELTA_CYCLE);
        if (rdata != hsync)
        {
            hsync = rdata;
            //if (hsync == 0)
            //    VPrint(".");
        }
        
        vp->read(DISP_VSYNC, &rdata, DELTA_CYCLE);
        if (rdata != vsync)
        {
            vsync = rdata;
            //if (vsync == 0)
            //    VPrint("\n");
        }
        
        vp->tick(1);
    }
    
    // Stop the simulation
    vp->write(DISP_FINISH, 1);
    
    vp->tick(GO_TO_SLEEP);
}