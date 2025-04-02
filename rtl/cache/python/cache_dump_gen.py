# Define parameters
num_rows = 512  # Number of rows
num_bytes_per_row = 16  # Bytes per row
output_file = "cache_dump_string.txt"

# Generate and write to file
i = 0
with open(output_file, "w") as f:
    f.write("$fdisplay(file, \"")
    for i in range(num_rows):
        f.write("$fdisplay(file, \"")
        f.write("$fdisplay(file, \""+ f"0x{i:X},0x%h_0x%h" )  # Format i in hex (uppercase)
        # if i < num_rows - 1:
        #     f.write(",")  # Add a comma except for the last row
    f.write("\",")
    for i in range(num_rows):
        f.write("cache_bank_odd.ts1.tag_store["+str(i)+"],cache_bank_odd.ts1.tag_store[["+str(i)+"]")  # Add a comma except for the last row
        if i < num_rows - 1:
            f.write(",")  # Add a comma except for the last row
    f.write(");")
print(f"Hex file '{output_file}' generated with {num_rows} rows of {num_bytes_per_row} zero bytes.")

#db_odd.mem_bank[i]