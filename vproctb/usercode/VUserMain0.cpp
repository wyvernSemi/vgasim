// =============================================================
//
// VProc user code for Video controller test bench's processor
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

extern "C" {
#include "mem.h"
}

static const int node = 0;

// ----------------------------------------------------------------------------
// Initialise video controller
// ----------------------------------------------------------------------------

static void initvid (VProc* vp)
{
    // Magic numbers for 640x480, cribbed from videomode.h
    vp->write(0x20, (640 << 16) | 480); vp->tick(2);
    vp->write(0x24, (656 << 16) | 490); vp->tick(2);
    vp->write(0x28, (752 << 16) | 492); vp->tick(2);
    vp->write(0x2c, (800 << 16) | 521); vp->tick(2);

    vp->write(0x0c, 5); vp->tick(2);

    uint32_t addr = 0x400;
    uint32_t data[16] = {0x000000, 0x800000, 0x008000, 0x808000,
                         0x000080, 0x800080, 0x008080, 0x555555,
                         0xaaaaaa, 0xff0000, 0x00ff00, 0xffff00,
                         0x0000ff, 0xff00ff, 0x00ffff, 0xffffff};

    // Write palette values
    for (int idx = 0; idx < 16; idx++)
    {
        vp->write(addr, data[idx]); vp->tick(2);
        addr += 4;
    }
    
    vp->write(0x00, 5); vp->tick(2);
}
// ----------------------------------------------------------------------------
// VProc node 0 main entry point
// ----------------------------------------------------------------------------

extern "C" void VUserMain0(void)
{
    // Create Vproc access object for this node
    VProc* vp = new VProc(node);

    // Wait for a while for reset to complete
    vp->tick(20);

    // Write some stuff to memory from 0x00000000
    for (int idx = 0; idx < 76680; idx++)
    {
        WriteRamWord(idx * 4, 0x808080 + idx, 0, 0);
    }

    // Initialise controller
    initvid(vp);

    // Sleep forever
    while(true)
        vp->tick(GO_TO_SLEEP);
}