#!/bin/bash

python3 mem_gen.py
cat $1 | while read line 
do
   python3 mem_load.py $line
   mv loaded_banke_data.hex banke_data.hex
   mv loaded_banko_data.hex banko_data.hex
done