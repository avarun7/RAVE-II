module rob_TOP #(parameter ARCHFILE_SIZE=32,
                 parameter PHYSFILE_SIZE=256,
                 parameter ROB_SIZE=128)(
    input clk, rst,

    input uop_update,
    input [$clog2(ARCHFILE_SIZE)-1:0] uop_dest_arch_in,
    input [$clog2(PHYSFILE_SIZE)-1:0] uop_dest_phys_in, uop_dest_oldphys_in,
    input except,

    input uop_finish,
    input [$clog2(ROB_SIZE)-1:0] uop_finish_rob_entry,

    output retire_uop,
    output [$clog2(ARCHFILE_SIZE)-1:0] uop_dest_arch_out,
    output [$clog2(PHYSFILE_SIZE)-1:0] uop_dest_phys_out, uop_dest_oldphys_out,

    output [$clog2(ROB_SIZE)-1:0] next_rob_entry,

    output rob_full
);

    rob #(.ARCHFILE_SIZE(ARCHFILE_SIZE), .PHYSFILE_SIZE(PHYSFILE_SIZE), .ROB_SIZE(ROB_SIZE))
            rob(.clk(clk), .rst(rst),
                .uop_update(uop_update),
                .uop_dest_arch_in(uop_dest_arch_in),
                .uop_dest_phys_in(uop_dest_phys_in), .uop_dest_oldphys_in(uop_dest_oldphys_in),
                .except(except),
                .uop_finish(uop_finish),
                .uop_finish_rob_entry(uop_finish_rob_entry),
                .retire_uop(retire_uop),
                .uop_dest_arch_out(uop_dest_arch_out),
                .uop_dest_phys_out(uop_dest_phys_out), .uop_dest_oldphys_out(uop_dest_oldphys_out),
                .next_rob_entry(next_rob_entry),
                .rob_full(rob_full));



    `ifdef DEBUG
        integer cycle_cnt;
        integer fullfile, sparsefile, retirefile;

        integer i;

        initial begin
            cycle_cnt = 0;
            fullfile = $fopen("./out/rob_full.dump");
            sparsefile = $fopen("./out/rob_sparse.dump");
            retirefile = $fopen("./out/uop_retire.dump");
        end

        always@(posedge clk) begin
            $fdisplay(fullfile, "cycle number: %d", cycle_cnt);
            $fdisplay(fullfile, "[====ROB UPDATES====]");
            $fdisplay(fullfile, "UPDATE FROM MAPPER: %b\t--\talloc([(spec(archR%0d)<-physR%0d), free(physR%0d)])", uop_update, uop_dest_arch_in, uop_dest_phys_in, uop_dest_oldphys_in);
            $fdisplay(fullfile, "UPDATE FROM RING:   %b\t--\trdy(ROB%0d)", uop_finish, uop_finish_rob_entry);
            $fdisplay(fullfile, "UPDATE FROM ROB:    %b\t--\tretire(ROB%0d)", retire_uop, uop_finish_rob_entry);
            $fdisplay(fullfile, "UPDATE FROM ROB:    %b\t--\tnonspec(archR%0d) <- physR%0d", retire_uop, uop_dest_arch_out, uop_dest_phys_out);
            $fdisplay(fullfile, "UPDATE FROM ROB:    %b\t--\tfree(physR%0d)", retire_uop, uop_dest_oldphys_out);
            $fdisplay(fullfile, "[====ROB METADATA====]");
            $fdisplay(fullfile, "rd_ptr -> ROB%0d", rob.rd_ptr);
            $fdisplay(fullfile, "wr_ptr -> ROB%0d", rob.wr_ptr);
            $fdisplay(fullfile, "full: %b", rob_full);
            $fdisplay(fullfile, "empty: %b", rob.rob_empty);
            $fdisplay(fullfile, "[====ROB ENTRIES====]");
            for(i = 0; i < ROB_SIZE/2; i = i + 1) begin
                $fdisplay(fullfile, "ROB%0d\t= [(spec(archR%0d)\t<-\tphysR%0d),\tfree(physR%0d)],  \tRDY:%b\t\t\t\t\tROB%0d\t= [(spec(archR%0d)\t<-\tphysR%0d),\tfree(physR%0d)],  \tRDY:%b",
                            i, rob.rob_entries[i][$clog2(ARCHFILE_SIZE)+(2*$clog2(PHYSFILE_SIZE))-1:(2*$clog2(PHYSFILE_SIZE))],
                               rob.rob_entries[i][(2*$clog2(PHYSFILE_SIZE))-1:$clog2(PHYSFILE_SIZE)],
                               rob.rob_entries[i][$clog2(PHYSFILE_SIZE)-1:0], rob.rdyvect[i],
                            i+ROB_SIZE/2, rob.rob_entries[i+ROB_SIZE/2][$clog2(ARCHFILE_SIZE)+(2*$clog2(PHYSFILE_SIZE))-1:(2*$clog2(PHYSFILE_SIZE))],
                               rob.rob_entries[i+ROB_SIZE/2][(2*$clog2(PHYSFILE_SIZE))-1:$clog2(PHYSFILE_SIZE)],
                               rob.rob_entries[i+ROB_SIZE/2][$clog2(PHYSFILE_SIZE)-1:0], rob.rdyvect[i+ROB_SIZE/2]);
            end
            $fdisplay(fullfile, "\n\n");

            if(uop_update || uop_finish || retire_uop) begin
                $fdisplay(sparsefile, "cycle number: %d", cycle_cnt);
                $fdisplay(sparsefile, "[====ROB UPDATES====]");
                if(uop_update) begin
                    $fdisplay(sparsefile, "UPDATE FROM MAPPER: %b\t--\talloc([(spec(archR%0d)<-physR%0d), free(physR%0d)])", uop_update, uop_dest_arch_in, uop_dest_phys_in, uop_dest_oldphys_in);
                end
                if(uop_finish) begin
                    $fdisplay(sparsefile, "UPDATE FROM RING:   %b\t--\trdy(ROB%0d)", uop_finish, uop_finish_rob_entry);
                end
                if(retire_uop) begin
                    $fdisplay(sparsefile, "UPDATE FROM ROB:    %b\t--\tretire(ROB%0d)", retire_uop, uop_finish_rob_entry);
                    $fdisplay(sparsefile, "UPDATE FROM ROB:    %b\t--\tnonspec(archR%0d) <- physR%0d", retire_uop, uop_dest_arch_out, uop_dest_phys_out);
                    $fdisplay(sparsefile, "UPDATE FROM ROB:    %b\t--\tfree(physR%0d)", retire_uop, uop_dest_oldphys_out);
                end
                $fdisplay(sparsefile, "[====ROB METADATA====]");
                $fdisplay(sparsefile, "rd_ptr -> ROB%0d", rob.rd_ptr);
                $fdisplay(sparsefile, "wr_ptr -> ROB%0d", rob.wr_ptr);
                $fdisplay(sparsefile, "full: %b", rob_full);
                $fdisplay(sparsefile, "empty: %b", rob.rob_empty);
                if(~rob.rob_empty) begin
                    $fdisplay(sparsefile, "[====ROB ENTRIES====]");
                    for(i = rob.rd_ptr; i != rob.wr_ptr; i = (i + 1)%ROB_SIZE) begin
                        $fdisplay(sparsefile, "ROB%0d\t= [(spec(archR%0d)<-physR%0d), free(physR%0d)]",
                                    i, rob.rob_entries[i][$clog2(ARCHFILE_SIZE)+(2*$clog2(PHYSFILE_SIZE))-1:(2*$clog2(PHYSFILE_SIZE))],
                                    rob.rob_entries[i][(2*$clog2(PHYSFILE_SIZE))-1:$clog2(PHYSFILE_SIZE)],
                                    rob.rob_entries[i][$clog2(PHYSFILE_SIZE)-1:0]);
                    end
                end
                $fdisplay(sparsefile, "\n\n");
            end

            cycle_cnt = cycle_cnt + 1;
        end
    `endif

endmodule