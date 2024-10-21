###################################################################
# Makefile for Virtual USB code in Verilator
#
# Copyright (c) 2024 Simon Southwell.
#
# Make file for building VProc Video controller test bench
#
# This code is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# The code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this code. If not, see <http://www.gnu.org/licenses/>.
#
###################################################################

# VProc C/C++ variables
VPROC_REPO    = https://github.com/wyvernSemi/vproc.git
VLIB          = $(CURDIR)/libvproc.a
VPROCDIR      = $(CURDIR)/../../vproc
USRCODEDIR    = $(CURDIR)/usercode
USER_C        = VUserMain0.cpp VUserMain1.cpp
MEMMODEL_REPO = https://github.com/wyvernSemi/mem_model.git
MEMMODELDIR   = $(CURDIR)/../../mem_model
MEM_C         = mem.c mem_model.c
INCLPATHS     = -I$(USRCODEDIR) -I$(VPROCDIR)/code -I$(MEMMODELDIR)/src
VPROCMKFILE   = makefile.verilator
DISPHDR       = display_defs.h

# Simulation variables
FILELIST      = files.tcl
WORKDIR       = work
TRACEOPT      = --trace
SIMOPTS       = --binary -sv --timing                      \
                $(TRACEOPT)                                \
                -Mdir $(WORKDIR)                           \
                -Wno-TIMESCALEMOD -Wno-INITIALDLY -Wno-WIDTH

FINISH        = -GFINISH=1
VCD           = -GVCD_DUMP=1
SIMDEFS       = +define+VPROC_BYTE_ENABLE +define+MEM_EN_TX_BYTEENABLE +define+VPROC_BURST_IF +define+MEM_MODEL_STALL_RX
SIMINCLPATHS  = -I$(CURDIR) -I$(VPROCDIR) -I$(MEMMODELDIR)
TOPMODULE     = test
SIMCFLAGS     = -std=c++20 -Wno-attributes
SIMLDFLAGS    = -Wl,-export-all-symbols -Wl,-whole-archive -L../ -lvproc -Wl,-no-whole-archive -ldl
SIMMAKEFLAGS  = --quiet
SIMEXE        = $(WORKDIR)/V$(TOPMODULE)

#
# GTKWave variables
#
WAVESAVEFILE  = waves.gtkw
WAVEFILE      = waves.vcd

#------------------------------------------------------
# BUILD RULES
#------------------------------------------------------

.PHONY: all, run, rungui, gui, help, clean

all: $(SIMEXE)

#
# Call VProc's Verilator test makefile to compile library into 
# this directory, including the memory model code and user code.
#
$(VLIB): $(USRCODEDIR)/$(DISPHDR) $(VPROCDIR) $(MEMMODELDIR)
	@make --no-print-directory -C $(VPROCDIR)/test     \
              -f $(VPROCMKFILE)                            \
              USRFLAGS="$(INCLPATHS)"                      \
              USRCDIR=$(USRCODEDIR)                        \
              USER_C="$(USER_C)"                           \
              MEMMODELDIR=$(MEMMODELDIR)/src               \
              MEM_C="$(MEM_C)"                             \
              TESTDIR=$(CURDIR)                            \
              $(VLIB)

#
# Compile simulation executable
#
$(SIMEXE): $(VLIB)
	@verilator  -F $(FILELIST) $(SIMOPTS)              \
           $(FINISH)   $(VCD) $(SIMDEFS) $(SIMINCLPATHS)   \
           --top       $(TOPMODULE)                        \
           -MAKEFLAGS "$(SIMMAKEFLAGS)"                    \
           -CFLAGS    "$(SIMCFLAGS)"                       \
           -LDFLAGS   "$(SIMLDFLAGS)"

#
# Check out VProc repo if not at expected location
#
$(VPROCDIR):
	@git clone $(VPROC_REPO) $(VPROCDIR) --recursive
#
# Check out memory model repo if not at expected location
#
$(MEMMODELDIR):
	@git clone $(MEMMODEL_REPO) $(MEMMODELDIR) --recursive

#
# Auto-generate display C/C++ header from Verilog
#
$(USRCODEDIR)/$(DISPHDR): $(DISPHDR:%.h=%.vh)
	@sed "s/32'h/0x/;s/\`/#/;s/Verilog/-- AUTO GENERATED\. DO NOT EDIT\! --/;" $< > $@

#------------------------------------------------------
# EXECUTION RULES
#------------------------------------------------------

run: all
	@$(SIMEXE)

rungui: all
	@$(SIMEXE)
	@if [ -e $(WAVESAVEFILE) ]; then                   \
	    gtkwave -a $(WAVESAVEFILE) $(WAVEFILE);        \
	else                                               \
	    gtkwave $(WAVEFILE);                           \
	fi

gui: rungui

help:
	@$(info make help          Display this message)
	@$(info make               Build C/C++ and HDL code without running simulation)
	@$(info make run           Build and run batch simulation)
	@$(info make rungui/gui    Build and run GUI simulation)
	@$(info make clean         clean previous build artefacts)

#------------------------------------------------------
# CLEANING RULES
#------------------------------------------------------

clean:
	@make --no-print-directory -C $(VPROCDIR)/test -f $(VPROCMKFILE) TESTDIR=$(CURDIR) clean
	@rm -rf $(WORKDIR) $(WAVEFILE) $(USRCODEDIR)/$(DISPHDR)