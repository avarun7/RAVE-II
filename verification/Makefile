TOPLEVEL_LANG ?= verilog

#PYTHON = /usr/bin/python3  # Use the correct path to your Python interpreter
#COCOTB_CONFIG = /cygdrive/c/Users/megan/RAVE-II/.venv/Scripts/cocotb-config  # Use the correct path to cocotb-config

PYTHON = /mnt/c/Users/megan/RAVE-II/verification/.venv/bin/python3
COCTB_CONFIG = /mnt/c/Users/megan/RAVE-II/verification/.venv/bin/cocotb-config

# # TEST LOGICAL FU
# VERILOG_SOURCES += $(PWD)/logical_FU.v
# TESTCASE = run_logical_test
# export TOPLEVEL = logical_FU

# TEST ARITHMETIC FU
VERILOG_SOURCES += $(PWD)/arithmetic_FU.v
TESTCASE = run_arithmetic_test
export TOPLEVEL = arithmetic_FU

# Python test file (without .py extension)
MODULE = testbench

# Specify simulator
SIM ?= icarus

# Include cocotb's make rules
include $(shell cocotb-config --makefiles)/Makefile.sim

# TESTCASES = check_dut_signals basic_dut_test run_arithmetic_test run_logical_test
# Set the appropriate toplevel based on the testcase
#override TOPLEVEL := $(if $(filter $(TESTCASE),run_logical_test),logical_FU,arithmetic_FU)
# TOPLEVEL := $(if $(findstring run_logical_test,$(TESTCASES)),logical_FU,arithmetic_FU)
# export TOPLEVEL