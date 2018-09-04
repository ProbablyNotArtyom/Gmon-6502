

Start_OS:	
			sei
			.if (BootMessage) jmp MonitorBoot 
			jmp Main

		.var CommandCount	= $08	// Number of commands 
			
//------------Monitor Functions--------------		
			
KEYin:								// Waits for a key input
!:			lda ACIA1sta          
			and #$08
			beq !-
			lda ACIA1dat   
			rts                    
		
PRWord:        						// Prints word AAXX   
			jsr PRByte				
			txa
PRByte:		pha						// Prints byte AA	
			lsr						
			lsr						
			lsr						
			lsr						
			jsr PRHex						
			pla					
PRHex:		and #%00001111			// Prints digit A
			tay
			lda HEX,y				
			jmp Write				

//-----------------Monitor-------------------	

MonitorBoot:      
			lda #$00
			jsr SETCursor  
			ldx #$00
!:			lda Porttxt,x
			cmp #$00
			beq Main
			jsr Write
			inx			
			jmp !-  			  
Main:		
			ldx #$FF
			txs
Input:		ldy #$00				// Set Y to zero to start tracking input length
			sty Parse
			jsr CReturn
			lda #MONPrompt
			jsr Write
			jsr BFlush				// Empty the input buffer
Input1:		jsr KEYin				// Input the current key
			
		.if (Emulated){
			cmp #$1B 				// Escape (Emulator)
		} else {  
			cmp #$03			  	// F1 (F1)
		}
            bne !+           
            jmp BAS

!:          cmp #$0D				// Is it an enter (Carridge Return)?
			beq Input4				// If yes, then we are done inputing text
			cmp #$08				// If not, then check if it is a backspace			
			beq Input3				// If it is, then skip to the backspace routine			
Input2:		cpy #$FF				// Is the input length about to be a full page long?
			bne !+					// If not, then continue to input characters
			jmp Input4				// If so, then exit the input routine		
!:			sta Buffer,y			// Store the input in the buffer
			jsr Write
			iny						// Increase the character pointer
			jmp Input1				// Input another character
			
Input3:		cpy #$00        	      
            beq Input1	        	// If there are no characters in the buffer, then skip the backspace routine
            sta Buffer,y
            dey                  	// Purge the last input character
            lda #$00
                        
            lda LCDCursor         	// Backup one character on the screen  
            clc
            sbc #$00
            jsr SETCursor
            
            lda #$20              	// Print space 
            jsr Write            
            
            lda LCDCursor   	  	// Backup one character on the screen, as printing the space moved us up one
            clc
            sbc #$00
            jsr SETCursor
            jmp Input1
Input4:		lda #$0D	
			sta Buffer,y	
Main1:																						
			ldy #$FF				// Reset X for indexed addressing in the loop
			
Main2:		
			iny
Main3:		lda	Buffer,y			// Grab a character from the input buffer
			cpy #$FF
			beq Main1
			ldx #$FF					
!:			inx						// Increase index for the command finder loop
			cpx #CommandCount		// Has the loop already compared the input to all of the avalible digits?
			beq !+					// If so, then the hex input is over
			cmp	CMD,x				// Compare it to the avalible commands
			bne !-
			jmp Main5
!:			ldx #$FF
!:			inx
			cpx #16
			beq Main2
			cmp HEX,x
			bne !-
			
			lda #$00
			sty WORDInput
			sty WORDInput_H
			dey
MNT:		iny
			lda Buffer,y
			ldx #$FF
!:			inx						// Increase index for the command finder loop
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq Main3				// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-
			
			txa				
			ldx #$04
!:			asl WORDInput	
			rol WORDInput_H	
			dex	
			bne !-	
			ora WORDInput	
			sta WORDInput			
			jmp MNT												
Main4:													
Main5:		sty Parse
			txa
			asl
			tax								
			lda #>Main7				// Push high byte of return address		
			pha			
			lda #<Main7-1			// Push low byte of return address	
			pha			
Main6:          				  	// RTS into the command by pushing the address of the code into the stack
            lda JCMD,x
            sta GTmp 
            inx
            lda JCMD,x
            pha
            lda GTmp 
            pha
            rts           
Main7:
			jmp Input
BFlush:
			ldx #$FF
			lda #$00
!:			inx
			sta Buffer,x
			cpx #$FF
			bne !-
			rts

//-------------Monitor Funtions--------------

View:		
			jsr CReturn
			lda WORDInput_H
			ldx WORDInput
			jsr PRWord
			lda #$20
			jsr Write
			lda #'-'
			jsr Write
V0:			lda #$20
			jsr Write
			ldx #$00
			lda (WORDInput,x)
			jsr PRByte
			jsr IAddr
			rts
			
Range:		
			ldy #$00
			sty LISTEnd_H
			sty LISTEnd
			ldy Parse
R0:			iny
			lda Buffer,y
			ldx #$FF
!:			inx						// Increase index for the command finder loop
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq R1					// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-
			
			txa				
			ldx #$04
!:			asl LISTEnd	
			rol LISTEnd_H	
			dex	
			bne !-	
			ora LISTEnd	
			sta LISTEnd			
			jmp R0	
R1:			lda WORDInput
			cmp LISTEnd
			bne !+
			lda WORDInput_H		
			cmp LISTEnd_H		
			bne !+
			jmp View
!:			jsr View
			ldy #$FF
			sty GTmp
!:			
			lda WORDInput
			cmp LISTEnd
			bne R3
			lda WORDInput_H		
			cmp LISTEnd_H		
			bne R3		
			jmp V0	 

R3:			jsr V0
			ldy GTmp
			iny			
			sty GTmp	
			cpy #$0E			
			bne !-			
			jmp R1		

Deposit:	
			ldy #$00
			sty LISTEnd_H
			sty LISTEnd
			ldy Parse
Dp0:		iny
			lda Buffer,y
			cmp #$0D
			bne !+
			jmp Dp2
!:			ldx #$FF
!:			inx						// Increase index for the command finder loop
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq Dp1					// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-

			txa				
			ldx #$04
!:			asl LISTEnd	
			dex	
			bne !-	
			ora LISTEnd	
			sta LISTEnd			
			jmp Dp0
Dp1:		
			ldx #$00
			lda LISTEnd
			sta (WORDInput,x)
			jsr IAddr
			jmp Dp0
Dp2:		ldx #$00
			lda LISTEnd
			sta (WORDInput,x)
			jmp IAddr
		
Goto:		
			lda #>Main7
			pha
			lda #<Main7
			pha
			jmp (WORDInput)		

EERR:			
			jsr CReturn				// If @ isn't the first command issued, then exit routine W/ error
			ldx #$00
!:			lda Er0,x
			cmp #$00
			beq !+			
			jsr Write
			inx
			jmp !-
!:			pla						// Pull the return values put in by the jsr in order to keep the stack from filling up
			pla	
			jmp Main				// Return to the Monitor and dont execute other commands in the string
													
DText:								// Dump text to memory main routine								
			ldx Parse			
			inx						// Once we have found it, increase the index to get to the input characters
			inx
			ldy #$00				// Load Y with zero to set up the loop
DText0:		lda $300,x				// Load A with the first character in the buffer
			sta (WORDInput),y		// Store it in the output location										
			inx						// Increase the input index					
			cmp #$0D				// See if we have reached the end of the input yet																																									
			beq DText1				// If it is not the end of the input, then loop back around								
										
			jsr IAddr								
			jmp DText0							
										
DText1:		jsr IAddr								
			rts						// If so, then exit the command loop and return to the monitor								
											
RText:								// Read text from memory main routine				
			ldx #$00   				// Load X with zero to setup the loop
			stx GTmp4
			ldx Parse
!:			lda $300,x				// Load A with the first value in the input buffer
			inx						// Increase the index
			cpx #$FF
			beq RText6
			cmp #'-'				// Compare it with the option signifier ("-")
			bne !-					// Loop back until we have found any options
			
			lda $300,x				// Load the first digit from the buffer		
			and #%00001111			// Convert digit from ascii to a raw number
			sta GTmp3				// Store it for later
			inx						// If an option is found, then increase the index (Only option is number of Carridge Returns before the routine ends)
			lda $300,x				// Load the second digit from the buffer		
			cmp #$0D				
			beq !+					// If there is a CR there, then jump to start the routine (end of string)
			cmp #$20
			beq !+					// If there is a space there, then jump to start the routine (end of option)
			and #%00001111			// Convert digit from ascii to a raw number
			tay						// Save second digit in Y
			lda GTmp3				// Load first digit in A
			sty GTmp3				// Store second digit in GTmp
			asl						// Shift the first digit left 4 times 
			asl
			asl
			asl
			ora GTmp3				// Combine the two digits into one hex number
			sta GTmp3				// Store it in a buffer			
!:			sed						// Set decimal flag (Converting Decimal into Hex)
			lda GTmp3				// Load the Decimal number
			sec						// Set carry
			sbc #$01				// Subtract one in decimal mode (No A-F)
			sta GTmp3				// Store it back
			cld						// Clear decimal to increase the Hex output
			inc GTmp4				// Increase the output		
			cmp #$00				// If the Decimal number hits zero, then the conversion is complete. Code falls into the main loop
			bne !-										
RText6:		
			lda Buffer
			cmp #'X'				// If the command is the first command in the buffer, then skip DAddr, or else it will print #$0D and finish
			beq !+		
!:			jsr CReturn				// Trigger a Carridge Return to put the output on the next line																																					
			ldy #$00				// Load Y with zero to keep from messing with the index
			ldx #$00				// Load X with zero to setup the loop's overflow detect
!:			lda (WORDInput),y		// Load the first character from memory			
			cmp #$0D				// Check to see if a Carridge Return has been fetched
			bne RText0				// If not, continue with execution
			jmp RText3				// Then end the routine
RText0:		jsr Write				// Write it to the screen
			inx						// Increase the overflow tracker
			cpx #$FF				// If 256 characters have already been printed, then exit the routine
			beq RText3
RText1:		cmp #$0D				// If a Carridge Return is being printed, then exit the routine
			beq RText3			
RText2:		jsr IAddr				// If the loop continues, then increase the address pointer and jump back to the start of the loop
			jmp !-			
RText3:		
			lda GTmp4				// Load A with GTmp (# of times to repeat)
			cmp #$00				// If GTmp == #$00, then there was no option input, so exit the routine
			beq RText4				
			dec GTmp4				// If there was, then decrease the repeat number (we just did one cycle)
			lda GTmp4				// Fetch the decreased value
			cmp #$00				// If the number is not yet zero, then skip the check for Carridge Returns and do another cycle
			bne RText5				// If the number is zero, then fall into the exit routine
RText4:		jsr IAddr				// Increase the address pointer for next command
			jmp Main				// Exit the routine								
RText5:		
			jsr CReturn
			jsr IAddr
			jmp !-
IAddr:								// Increase the address pointer routine							
			lda WORDInput			// Load A with Addrptr		
			cmp #$FF				// See if increasing it will cause an overflow
			bne !+					// If it won't, then increase the low byte and continue
			clc						// If it will, then increase the high byte and the low byte causing the low byte to overflow as #$00, thus increasing the memory page			
			lda WORDInput_H		
			adc #$01		
			sta WORDInput_H		
!:			clc
			lda WORDInput
			adc #$01
			sta WORDInput
			rts						// Return to code			
DAddr:								// Decrease the address pointer routine					
			lda WORDInput			// Load A with Addrptr		
			cmp #$00				// See if Decreasing it will cause an underflow
			bne !+					// If it won't, then decrease the low byte and continue
			sec						// If it will, then decrease the high byte and the low byte causing the low byte to underflow as #$FF, thus decreasing the memory page			
			lda WORDInput_H		
			sbc #$01		
			sta WORDInput_H		
!:			sec
			lda WORDInput
			sbc #$01
			sta WORDInput
			rts						
													
BConv:								// Convert a number into decimal, hex, or binary format																								
			ldx #$00   				// Load X with zero to setup the loop
			stx GTmp4
!:			lda Buffer,x			// Load A with the first value in the input buffer
			inx						// Increase the index
			cpx #$FF
			beq BERR
			cmp #'-'				// Compare it with the option signifier ("-")
			bne !-					// Loop back until we have found any options			
			lda Buffer,x			// Fetch the input base
			sta GTmp				// Store input base in GTmp
			inx						// Increase index
			lda Buffer,x			// Fetch output base
			sta GTmp2				// Store output base in GTmp2
			lda GTmp				// jump to the apropriate routine based on the input's base
			cmp #'B'				// Is the input base in binary?
			bne !+					// If not, then check if it is in hex
			jsr BBConv				// If it is, then jump to the binary conversion subroutine
			jmp BDEnd
!:			cmp #'H'				// Is the input base in hex?
			bne !+					// If not, then check if it is in decimal
			jmp BHConv				// If it is, then jump to the hex conversion subroutine
!:			cmp #'D'				// Is the input base in decimal?
			bne BERR				// If not, then branch to the error routine and exit, as there are no more supported bases
			jsr BDConv				// If it is, then jump to the decimal conversion subroutine
			jmp BDEnd				// Jump to print the output		
BERR:		jmp EERR				// Jump to the error handling routine
BDConv:																																																					
			lda #$00																																																				
			sta GTmp3				// Make sure GTmp3 is zero so the count starts from zero																																																			
D0:			sed						// Set decimal flag (Converting Decimal into Hex)
			jsr DAddr
			cld						// Clear decimal to increase the Hex output					
			inc GTmp3
			lda WORDInput	
			cmp #$00				// Is the input word zero?
			bne D0					// If not, then repeat
			lda WORDInput_H			// If so, then continue								
			cmp #$00											
			bne D0											
			lda GTmp2				// Once done converting to hex, check the output base
			cmp #'H'				// If it is not hex, then check if it is binary
			bne !+					// If it is hex, then fall into an rts and finish
			jmp BDEnd
!:			cmp #'B'				// If it is binary, then convert the hex output into a binary string
			bne BERR				// If no supported base is input, then branch to the error handling routine			
			lda GTmp3																			
			sta WORDInput																			 																			
BHConv:								
			jsr CReturn						
			lda GTmp2				// Load A with the output base				
			cmp #'B'				// If the output is in binary, then continue			
			bne HD0					// If it is not, then check if it is in decimal			
			lda #$20				// Print a space
			jsr Write
			ldx #$00				// Set up the index for the loop				
			txa						// Set A to zero
!:			asl WORDInput			// Shift a bit of the input number into carry		
			rol 					// Shift the carry into the 1st bit of A (A = 00000000 or 00000001)
			ora #%00110000			// Convert is into ASCII
			jsr Write				// Write it to the screen
			lda #$00				// Set A back to zero so the next bit can be shifted into it
			inx						// Increase the loop count by one
			cpx #$08				// Have we done all 8 digits yet?
			bne !-					// If not, then repeat
			jmp Main				// If so, then jump back to the monitor, as we have already printed the output
HD0:			
			lda GTmp2				// Load A with the output base
			cmp #'D'				// See if the output base is in decimal				
			beq !+					// If it isn't, then exit with an error, as there are no more bases left to check																																
			jmp EERR																																
!:			cld						// Clear decimal flag
			lda #$00	
			sta GTmp4				// Make sure GTmp4 is zero so the count starts from zero																																																			
			sta GTmp3				// Make sure GTmp3 is zero so the count starts from zero				
HD1:		dec WORDInput
			sed						// Set decimal flag
			clc						// Clear carry for addition				
			lda GTmp3			
			cmp #$99			
			bne !+						
			clc			
			lda GTmp4				// Load the output number buffer
			adc #$01				// Add one to it in DECIMAL MODE
			sta GTmp4				// Store it back
!:			clc			
			lda GTmp3				// Load the output number buffer
			adc #$01				// Add one to it in DECIMAL MODE
			sta GTmp3				// Store it back
			cld						// Clear decimal flag so the hex input will count down it's full length
			lda WORDInput				
			cmp #$00				// See if the conversion is done
			bne HD1					// If it isn't, then repeat
			jmp BDEnd				// If it is, then jump to the end routine											
BBConv:														
			ldy #$00																								
			sty GTmp3												
			ldx #$FF				// Load X with zero for use as an index in a loop									
BH:			inx						// Increase the index									
			lda Buffer,x			// Load a character from the input buffer							
			cpx #$FF				// If 256 bytes have been scanned without finding the string, then jump to the error handling routine							
			bne !+					// If not, then check for the characters					
			jmp EERR							
!:			cmp #$30				// Check for a binary number									
			beq !+					// If either a zero or a one was found, then we found the start of the string, so continue								
			cmp #$31													
			beq !+												
			jmp BH					// If the character is neither a one nor a zero, then repeat 																								
!:			lda Buffer,x			// Load A with a digit of the binary string									
			lsr						// Shift bit 0 of the binary string into carry							
			rol GTmp3				// Shift carry into bit 0 of GTmp4									
			inx						// Increase string character index							
			iny						// Increase loop counter						
			cpy #$08				// Do we have all 8 digits in?									
			bne !-					// If not, then repeat																																				
			lda GTmp2				// Once done converting to hex, check the output base
			cmp #'H'				// If it is not hex, then check if it is binary
			bne !+					// If it is hex, then fall into an rts
			lda #$00
			sta GTmp4
			rts
!:			cmp #'D'				// If it is decimal, then convert the hex output into a decimal string
			beq !+					// If no supported base is input, then fall into the error handling routine													
			jmp EERR																										
!:			lda GTmp3											
			sta WORDInput			// Put the input into Addrptr								
			lda #$00								
			sta WORDInput_H								
			jsr HD0					// Jump to subroutine to convert hex to decimal, fall into end routine																																					
BDEnd:					
			jsr CReturn				// Call a CReturn to output on the next line			
			lda #$20
			jsr Write
			lda GTmp4
			beq !+
			lda GTmp4
			jsr PRHex
!:			lda GTmp3
			jsr PRByte
			jmp Main				// Return to the monitor

Version:			
			jsr CReturn			
			jmp MonitorBoot			
						
//---------------Lookup Tables---------------

Er0:
			.text " ?FORMAT ERROR"	// Error report string
			.byte $00				// Terminator byte
HEX:     
			.text "0123456789ABCDEF"// Hex -> ASCII lookup string
CMD:       
			.byte $0D               // Enter (CR)                       		| [HHHH] {Return} 					- Hex dump address 
            .byte $2E               // .										| [HHHH][.HHHH] {Return} 			- Hex dump address range
            .byte $3A               // :										| [HHHH][:DD] {Return} 				- Poke data
            .byte $47               // g - Go									| [HHHH][G] {Return} 				- Run a program
            .byte $56               // v - Version								| [V] {Return} 						- Print version string
            .byte $54				// t - Text Dump							| [HHHH][T][XXXX] {Return} 			- Dump text string XXXX into memory location HHHH
            .byte $58				// x - Read text from memory  				| [HHHH][X}[-X] {Return} 			- Print text string located at HHHH until a CR is printed (X = Number of times to continue after a CR is reached)
            .byte $5A				// z - Convert bases						| [HH][Z][-{I}{O}]					- Convert a number (HH) to a different base (Option is H-Hex D-Decimal B-Binary, I=Input Base, O=Output Base)
JCMD:      																									
			.word View-1			// Enter (CR)
            .word Range-1			// .
            .word Deposit-1			// :
            .word Goto-1			// G
            .word Version-1			// V
            .word DText-1			// T
            .word RText-1			// X
            .word BConv-1			// Z
Porttxt:        
			.text MONText
            .byte $00				// Terminator byte