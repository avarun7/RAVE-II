import sys



# Define parameters
memfile_e = "banke_data.hex"
memfile_o = "banko_data.hex"
loaded_memfile_e = "loaded_banke_data.hex"
loaded_memfile_o = "loaded_banko_data.hex"



# Get Arguments
loadpath = sys.argv[2]
loadaddr = int(sys.argv[1].replace('0x', '').replace(':', ''), 16)



# Parse load data
loaddata_e = dict()
loaddata_o = dict()

addr = loadaddr

addr_eo = (addr >> 4) & 1
addr_row = addr >> 5
addr_col = addr & 15

loading_data = loaddata_o if addr_eo else loaddata_e
loading_data[addr_row] = list()
for i in range(0, addr_col):
    loading_data[addr_row].append('X')

with open(loadpath, 'r') as hexfile:
    for line in hexfile:
        byte_list = [line[i:i+2] for i in range(0, len(line), 2)]
        for b in byte_list:
            if b == '\n':
                break

            loading_data[addr_row].append(b)

            addr += 1
            addr_eo = (addr >> 4) & 1
            addr_row = addr >> 5
            addr_col = addr & 15
            if not addr_col:
                loading_data = loaddata_o if addr_eo else loaddata_e
                loading_data[addr_row] = list()

for i in range(addr_col, 16):
    loading_data[addr_row].append('X')



# Insert load data into mem hex
with open(memfile_e, 'r') as oldmem:
    with open(loaded_memfile_e, 'w') as newmem:
        for row, line in enumerate(oldmem):
            if row in loaddata_e.keys():
                loadedline = ""
                line_bytes = [line[i:i+2] for i in range(0, len(line), 2)]
                for col in range(16):
                    loadedline += loaddata_e[row][15-col] if not loaddata_e[row][15-col] == 'X' else line_bytes[col]
                newmem.write(loadedline+"\n")
            else: newmem.write(line)

with open(memfile_o, 'r') as oldmem:
    with open(loaded_memfile_o, 'w') as newmem:
        for row, line in enumerate(oldmem):
            if row in loaddata_o.keys():
                loadedline = ""
                line_bytes = [line[i:i+2] for i in range(0, len(line), 2)]
                for col in range(16):
                    loadedline += loaddata_o[row][15-col] if not loaddata_o[row][15-col] == 'X' else line_bytes[col]
                newmem.write(loadedline+"\n")
            else: newmem.write(line)