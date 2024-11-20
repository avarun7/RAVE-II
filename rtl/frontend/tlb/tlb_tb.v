module tlb_tb;

    reg [31:0] address;
    reg RW_in, is_mem_request;

    reg [19:0] VP_0, VP_1, VP_2, VP_3, VP_4, VP_5, VP_6, VP_7;
    reg [19:0] PF_0, PF_1, PF_2, PF_3, PF_4, PF_5, PF_6, PF_7;
    reg [7:0] entry_v, entry_P,  entry_RW, entry_PCD;
    reg [159:0] VP, PF;

    wire [19:0] PF_out;
    wire miss, hit, protection_exception, PCD_out;

    localparam cycle_time = 6;
    reg clk;
    initial begin
        clk = 0;
        forever
            #(cycle_time / 2) clk = ~clk;
    end

initial
	begin		
		//initialize
		$display("INITIALIZING...\n");
		VP_0 = 20'h00000;
		VP_1 = 20'h02000;
		VP_2 = 20'h04000;
		VP_3 = 20'h0b000;
		VP_4 = 20'h0c000;
		VP_5 = 20'h0a000;
		VP_6 = 20'h06000;
		VP_7 = 20'h03000;

		PF_0 = 20'h00000;
		PF_1 = 20'h00002;
		PF_2 = 20'h00005;
		PF_3 = 20'h00004;
		PF_4 = 20'h00007;
		PF_5 = 20'h00005;
		PF_6 = 20'h00006;
		PF_7 = 20'h00003;

		entry_v = 8'b10111111;
		entry_P = 8'b11110111;
		entry_RW= 8'b11010101;
		entry_PCD = 8'b00000011;

		VP = {VP_7, VP_6, VP_5, VP_4, VP_3, VP_2, VP_1, VP_0};
		PF = {PF_7, PF_6, PF_5, PF_4, PF_3, PF_2, PF_1, PF_0};
		#(cycle_time)

	/*
		Sample Initialized Values, TLB Entries
			Virtual Page		Physical Page		Valid		Present		R/W	PCD
			20'h00000		20'h00000		1		1		0	0
			20'h02000		20'h00002		1		1		1	0
			20'h04000		20'h00005		1		1		1	0
			20'h0b000		20'h00004		1		1		1	0
			20'h0c000		20'h00007		1		1		1	0
			20'h0a000		20'h00005		1		1		1	0
	
		custom:	20'h06000		20'h00006		0		1		1	1
			20'h03000		20'h00003		1		1		1	1

	*/	$display("\n VVVVVVVVVVVVVV INIT COMPLETE VVVVVVVVVVVVVV\n");
		
		$display("case: nominal\n");
		address = 32'h03000AAA;
		RW_in = 1; 
		is_mem_request = 0;
		#(cycle_time)

		$display("case: valid but not present\n");
		address = 32'h0b000234;
		RW_in = 0;
		is_mem_request = 1;
		#(cycle_time)

		$display("case: pure miss\n");
		address = 32'hFFFFFFFF;
		RW_in = 1;
		is_mem_request = 1;
		#(cycle_time)

		$display("case: pure miss but should still be a hit since not a mem request\n");
                address = 32'hFFFFFFFF;
                RW_in = 1;
                is_mem_request = 0;
                #(cycle_time)

		$display("case: present but not valid\n");
		address = 32'h06000432;
		RW_in = 1;
		is_mem_request = 1;
		#(cycle_time)

		$display("case: present and valid but RW doesn't match\n");
		address = 32'h0a000777;
		RW_in = 1;
		is_mem_request = 1;
		#(cycle_time)

		$display("case: both protection and page fault\n");
		address = 32'h06000ABC;
		RW_in = 0;
		is_mem_request = 1;
		#(cycle_time)

		$display("case: both protection and page fault but hit since not mem request\n");
                address = 32'h06000ABC;
                RW_in = 0;
                is_mem_request = 0;
                #(cycle_time)

    	
		$display("\n^^^^^^^^^^^^^^^^^^^^^ END TEST ^^^^^^^^^^^^^^^^^^^^^\n");
		$finish;
	end

	always @(posedge clk) begin
		$display("inputs:");
		$display("\t address: %h", address);
		$display("\t RW_in:   %h", RW_in);
		$display("\t is_mem_request:   %h", is_mem_request);


		$display("outputs:");
		$display("\t PF_out:  		%h", PF_out);
		$display("\t PCD:			%h", PCD_out);
		$display("\t miss:  		%h", miss);
		$display("\t hit: 			%h", hit);
		$display("\t protection_exception: 	%h", protection_exception);
		
		$display("---------------------------------------\n");    
	end

   	// Dump all waveforms
   	initial
		begin
	 	$vcdplusfile("tlb.dump.vpd");
	 	$vcdpluson(0, tlb_tb); 
	end

	TLB tlb_test(.clk(clk), .address(address), .RW_in(RW_in), .is_mem_request(is_mem_request),
		.VP(VP), .PF(PF), .entry_v(entry_v), .entry_P(entry_P), .entry_RW(entry_RW), 
		.entry_PCD(entry_PCD), .PF_out(PF_out), .PCD_out(PCD_out), .miss(miss), .hit(hit), 
		.protection_exception(protection_exception));

endmodule