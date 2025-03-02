# Define parameters
num_rows = 4096  # Number of rows
num_bytes_per_row = 16  # Bytes per row
output_file_e = "banke_data.hex"
output_file_o = "banko_data.hex"
# Generate and write to file
with open(output_file_e, "w") as f:
    for _ in range(num_rows):
        f.write("00" * num_bytes_per_row + "\n")
print(f"Hex file '{output_file_e}' generated with {num_rows} rows of {num_bytes_per_row} zero bytes.")
with open(output_file_o, "w") as f:
    for _ in range(num_rows):
        f.write("00" * num_bytes_per_row + "\n")

print(f"Hex file '{output_file_o}' generated with {num_rows} rows of {num_bytes_per_row} zero bytes.")