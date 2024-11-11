#!/bin/bash

iverilog -o sim \
TOP.v \
frontend/frontend_TOP.v \
frontend/bp/cachelinebp_TOP.v \
frontend/bp/pcbp_TOP.v \
frontend/c_TOP.v \
frontend/d1_TOP.v \
frontend/d2_TOP.v \
frontend/decode/decode_TOP.v \
frontend/decode/predecode_TOP.v \
frontend/f1_TOP.v \
frontend/f2_TOP.v \
frontend/icache/idatastore_TOP.v \
frontend/icache/imetastore_TOP.v \
frontend/icache/itagstore_TOP.v \
frontend/icache/itlb_TOP.v \
l2cache/l2cache_TOP.v \
mapper/mapper_TOP.v \
ooo_engine/ooo_engine_TOP.v \
regfile/regfile_TOP.v \
regfile/archregfile/archregfile_TOP.v \
regfile/physregfile/physregfile_TOP.v \
rob/rob_TOP.v

