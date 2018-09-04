// Configuration file for the Kernal and Monitor
		
//-----------------System-------------------

		.var Emulated  = false
		
		.var RomStart  = $E000				// Location of the start of the ROM (origin point)
		.var RomSize   = 8					// Size of the rom in Kilobytes
		.var Clock     = 1					// speed of the 6502 in MHz (for LCD Timing)

//-----------------Monitor------------------

		.var BootMessage = true					// Set to display the Boot message on startup of the monitor	
		.var MONText	 = "G'MON V.07"			// Header shown on boot of the monitor (MAX. 20 bytes)
		.var MONPrompt 	 = '>'					// Prompt character the Monitor uses to signify input
		.var TMONPrompt  = true					// Wether or not to show the prompt in the monitor
		
//------------------BASIC-------------------

		.var Basic		= true					// Enable the basic editor
		
		.var BASText    = "TINY BASIC"			// Basic boot message
		.var BASPrompt  = '>'					// BASIC Prompt character
		.var TBASPrompt = false					// Wether or not to show the prompt in BASIC		
		
//------------------------------------------

		#import "Variables.asm"
		#import "Kernal.asm"
			