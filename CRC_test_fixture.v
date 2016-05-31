`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 	PWr
// Engineer:	Kacper Witkowski
//
// Create Date:   20:31:56 05/12/2016
// Design Name:   serdes
// Module Name:   CRC_test
// Project Name:  CRC16
//
// Verilog Test Fixture created by ISE for module: serdes
////////////////////////////////////////////////////////////////////////////////

module CRC_test_fixture;

	// Inputs
	reg [7:0] we;
	reg clk;
	reg reset;

	// Outputs
	wire [7:0] wy;

	// Instantiate the Unit Under Test (UUT)
	serdes uut (
		.we(we), 
		.clk(clk), 
		.reset(reset), 
		.wy(wy)
	);
	
	// internal signals
	reg [2:0] cnt;
	reg [1:0] output_delay1;
	reg [1:0] output_delay2;
	integer input_file, output_file;
	
	initial begin
		// Initialize Inputs
		we = 8'b00000000;
		clk = 1'b0;
		reset = 1'b0;
		repeat(2) @(posedge clk)
		reset = 1'b1;
		//forever #10 clk = ~clk;
	end
	
	always #10 clk=~clk;
	
	initial begin
		input_file = $fopen("input_data.txt", "r");
		output_file = $fopen("output_data.txt", "w");
	end
	
	always @(posedge clk or !reset)
	begin
		if ( !reset )
			begin
			cnt = 0;
			output_delay1 = 0;
			output_delay2 = 1;
			end
		else 
			cnt = cnt + 1;
			
			if (cnt == 7)
				begin
				if (output_delay1 < 3)
					begin
					output_delay1 = output_delay1 + 1;
					$fscanf(input_file, "%h\n", we[7:0]);
					end
						
				else if ((output_delay1 == 3) && !$feof(input_file))
					begin
					$fscanf(input_file, "%h\n", we[7:0]);
					$fwrite(output_file, "%h\n", wy[7:0]);
					end
					
				else if (output_delay2 > 0)
					begin
					$fwrite(output_file, "%h\n", wy[7:0]);
					output_delay2 = output_delay2 - 1;
					end
					
				else
					begin
					$fclose(output_file);
					$fclose(input_file);
					$finish;
					end
				end
	end     
endmodule