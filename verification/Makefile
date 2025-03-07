TOPLEVEL_LANG ?= verilog

PYTHON = /usr/bin/python3  # Use the correct path to your Python interpreter
COCOTB_CONFIG = /cygdrive/c/Users/megan/RAVE-II/.venv/Scripts/cocotb-config  # Use the correct path to cocotb-config

# Add your design files here
VERILOG_SOURCES += $(PWD)/logical_FU.v
# If you have multiple design files:
# VERILOG_SOURCES += $(PWD)/../hdl/another_file.v

# Set your design's top module name
TOPLEVEL = logical_FU

# Python test file (without .py extension)
MODULE = testbench
# TESTCASE = run_processor_test

# Specify simulator
SIM ?= icarus

# Define individual test cases
TESTCASES = run_processor_test1 run_processor_test2

.PHONY: all $(TESTCASES)

all: $(TESTCASES)

# Define separate make commands for each test
run_processor_test1:
	$(MAKE) sim TESTCASE=run_processor_test1 RESULTS_FILE=results_run1.xml

run_processor_test2:
	$(MAKE) sim TESTCASE=run_processor_test2 RESULTS_FILE=results_run2.xml

# Include cocotb's make rules
include $(shell cocotb-config --makefiles)/Makefile.sim