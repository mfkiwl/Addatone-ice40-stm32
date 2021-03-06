`timescale 1ns/1ns

module Test_Bench;

	wire debug, test;
	reg clock = 1'b0;
	reg reset_n = 1'b0;
	wire o_DAC_MOSI, o_DAC_SCK, o_DAC_CS;
	reg i_ADC_Data, i_ADC_Clock, i_ADC_CS;


//	HSOSC	#(.CLKHF_DIV (2'b00)) int_osc (
//		.CLKHFPU (1'b1),  // I
//		.CLKHFEN (1'b1),  // I
//		.CLKHF   (clock)   // O
//	);

	top dut (
		.i_Clock(clock),
		.reset_n(reset_n),
		.debug(debug),
		.test(test),
		.i_ADC_Data(i_ADC_Data),
		.i_ADC_Clock(i_ADC_Clock),
		.i_ADC_CS(i_ADC_CS),
		.o_DAC_MOSI(o_DAC_MOSI),
		.o_DAC_SCK(o_DAC_SCK),
		.o_DAC_CS(o_DAC_CS)
	);

	reg [15:0] data_packet [4:0];
	integer i, p;

	task Send_ADC;
	//	input [0:15] packet;

		begin
			i_ADC_CS = 1'b0;
			for (p = 0; p < 7; p = p + 1) begin
				for (i = 16; i > 0; i = i - 1) begin
					#375
					i_ADC_Clock <= 1'b0;
					i_ADC_Data <= data_packet[p][i - 1];
					#375
					i_ADC_Clock <= 1'b1;
				end
			end
			#375
			i_ADC_Clock = 1'b0;
			i_ADC_Data = 1'b0;
			i_ADC_CS = 1'b1;
		end
	endtask

	always
		#41.6666666 clock = !clock;			// 48MHz clock

	initial begin
		i_ADC_CS = 1'b1;
		i_ADC_Clock = 1'b0;
		i_ADC_Data = 1'b0;

		data_packet[0] = {16'h007B};		// Frequency
		data_packet[1] = {16'h0067};		// Harmonic_Scale[0] Rate of attenuation of harmonic scaling (lower means more harmonics)
		data_packet[2] = {16'd506};		// Scale_Initial[0] Starting value for scaling (lower if there are more harmonics)
		data_packet[3] = {16'h0020};		// Harmonic_Scale[1]
		data_packet[4] = {16'h0500};		// Scale_Initial[1]
		data_packet[5] = {16'h0000};		// Freq_Scale
		data_packet[6] = {16'h0032};		// Harmonic_Count

		reset_n = 1'b0;
		#100
		reset_n = 1'b1;

		#50
		Send_ADC();

		//#10000
		//$finish();
	end
endmodule

