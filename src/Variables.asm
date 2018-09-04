//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//               Evaluations
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
		
		.if (Emulated) {
			.eval (RomStart = $C000)
			.eval RomSize = 16
		}
		
		.var HexRomSize = RomSize*1024
		
		.if (!TBASPrompt) {
			.eval BASPrompt = $00
		}
		
//-------------ACIA (Emulated)--------------		
		
		.var ACIA1dat		= $8800
		.var ACIA1sta		= $8801
		.var ACIA1cmd		= $8802
		.var ACIA1ctl		= $8803

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-	
//----------Zero Page Assignments-----------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-					
					
		.var IRQlo 			= $00
		.var IRQhi 			= $01
		.var NMIlo 			= $02
		.var NMIhi 			= $03
//- - - - - - - - - Monitor - - - - - - - -	
		.var N1L			= $04		// length of first number from floating point input routine
		.var N2L			= $05		// length of second number from floating point input routine		
		.var SIGN			= $06		// sign buffer from floating point input routine
		.var Pullfrom		= $07		// Inidrect value for the ASCIItoFP routine to decide where to pull the strings from
		.var Pullfrom_H		= $08
		.var XOut			= $09		// Exponent output from the ASCIItoFP routine
		.var M1Out			= $0A		// Mantissa output byte 1
		.var M2Out			= $0B		// Mantissa output byte 2
		.var M3Out			= $0C		// Mantissa output byte 3
		.var NBuff			= $0D		// Buffer for loader in ASCIItoFP
		.var INLength		= $0E		// Length of the input for ASCIItoFP
//- - - - - - - - - - - - - - - - - - - - - 		
		.var ADDRS			= $09
		.var ADDRSHI 		= $0A
		.var TEST 			= $0B
		.var GTmp 			= $0C
		.var GTmp2 			= $0D
		.var GTmp3 			= $0E
		.var GTmp4			= $0F
		.var LCDCursor 		= $10
		
		.var lastkey		= $11
		.var actkey 		= $12
		.var CGRAMCursor    = $14
//- - - - - - - - - Monitor - - - - - - - -			
		.var Parse			= $20		// The location that the currently executing command was at in the input buffer	
		.var WORDInput		= $21
		.var WORDInput_H	= $22
		.var LISTEnd		= $23
		.var LISTEnd_H		= $24
//- - - - - Floating Point (WOZ) - - - - - 		
		.var sign   = $40
      	.var x2     = $41         	// exponent 2
    	.var m2     = $42         	// mantissa 2
    	.var x1     = $45         	// exponent 1
      	.var m1     = $46         	// mantissa 1
      	.var e      = $49         	// scratch
      	.var zz     = $4D
      	.var t      = $51
      	.var sexp   = $55
      	.var int    = $59
      	
      	.var ovflo  = $5A           // overflow byte for the accumulator when it is shifted left or multiplied by ten.
        .var msb    = $5B           // most-significant byte of the accumulator.
        .var nmsb   = $5C           // next-most-significant byte of the accumulator.
        .var nlsb   = $5D           // next-least-significant byte of the accumulator.
        .var lsb    = $5E           // least-significant byte of the accumulator.
        .var bexp   = $5F           // contains the binary exponent, bit seven is the sign bit.
        .var char   = $60           // used to store the character input from the keyboard.
        .var mflag  = $61           // set to $ff when a minus sign is entered.
        .var dpflag = $62           // decimal point flag, set when decimal point is entered.
        .var esign  = $63           // set to $ff when a minus sign is entered for the exponent.
        .var mem    = $5A           // start of memory used by the conversion program
        .var acc    = $5A           // ???
        .var accb   = $6A           // ???
        .var temp   = $64           // temporary storage location.
        .var eval   = $65           // value of the decimal exponent entered after the "e."
        .var dexp   = $71           // current value of the decimal exponent.
        .var bcda   = $7A           // bcd accumulator (5 bytes)
        .var bcdn   = $7F           // ???
//- - - - - - - - - - - - - - - - - - - - -        
        .var MBuffer    = $E0		// Output for FPtoASCII, goes until $FF and copies over the scanresult from keyboard scan 

		.var Scanresult = $F0

		.var SCREEN 	= $0200 	// Mirror for the character output of the LCD, used for "Fake DMA" into the LCD's memory
									// Reaches for 80 bytes until $024F
		.var CHAR		= $02A0		// Lets you see what is on the LCD at any time (Unless a program directly writes to the LCD)
		// Memory from $0200 to $024F are reserved for the Mirror of the LCD screen used by software control commands
		// $250 to $29F are reserved for the buffer used by the command used to scroll the screen
		// $2A0 to $2DF are reserved for tghe software-tracked CGRAM values
		.var Buffer		= $0300		// Monitor input buffer
