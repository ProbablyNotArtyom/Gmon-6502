//------------------Origin------------------
				
			*=RomStart				// For use with Symon
KStart:			
//----------------Jump Table----------------

Mntr:		jmp MON

B:			jmp Write
C:			jmp Delay
E:			jmp CReturn
K:			jmp *
L:			jmp SETCursor

//-------------Initialization---------------

INIT:							
			sei					// Disable IRQ
			cld					// Clear decimal flag
			ldx #$FF			// Load X with stack pointer
			txs					// Init stack pointer
			ldx #$00			// Flush X
			ldy #$00 			// Flush Y
IOInit:			
			lda #$1F			// 19.2K/8/1
			sta ACIA1ctl		// control reg 
			lda #$0B			// N parity/echo off/rx int off/ dtr active low
			sta ACIA1cmd		// command reg 				
			jmp Mntr
				
//----------------Functions-----------------	
			
Write: 												
			pha
!:			lda ACIA1sta
			and #$10
			beq !-
			pla
			sta ACIA1dat
			rts                      									

Read:
!:			lda ACIA1sta          
			and #$08
			beq !-
			lda ACIA1dat   
			rts     

SETCursor:
			rts
	
Delay:          				// Delay for X milliseconds (Accumulator is loaded with # of ms to be delayed)
			sta GTmp      		// Store input Valur in temporary storage
            txa           
            pha           
            tya           
            pha           
    	.if (Clock>1) {
            lda #$00
            sta GTmp3
    	}
L1:         ldx GTmp      		// Pull input value from storage into X
            ldy #190      		// Load Y with #190
!:			dey           		// Decrease y (First trimmer loop)
            bne !-     			// JMP back 190 times
L2:              
			dex           		// Decrease x (Input value, # of milliseconds)
            beq return   		// If X == 0 , goto return
            nop           		// Else, NOP
            ldy #198      		// Load y with 198 (Second trimmer loop)
!:          dey           		// Decrease y 
            bne !-     			// JMP back 198 times
            jmp L2     			// Jump back to L2 

return:             			
		.if (Clock>1) {
			inc GTmp3
			lda GTmp3
			cmp #Clock
			beq !+
			jmp L1
		}
!:			pla           
            tay           
            pla           
            tax           
            lda GTmp      		// Load A with input value for return
			rts 		
			
CReturn:						// Carridge return// reads current position, refrences table, writes new position
			lda #$0D
			jsr Write
			lda #$0A
			jmp Write																																			
																																																
//-----------------Handlers------------------

IRQ:		sei					// Handler for IRQ
			pha				
			txa				
			pha				
			tya				
			pha							
			jmp (IRQlo)			// Jump to software IRQ vector					
ENDirq:		pla				
			tay				
			pla				
			tax				
			pla								
			cli								
			rti
			
NMI:		sei					// Handler for NMI
			pha
			txa
			pha
			tya
			pha
			jmp (NMIlo)			// Jump to software NMI vector
ENDnmi:		pla
			tay
			pla
			tax
			pla
			cli
			rti
	  
//-----------------Monitor------------------			
		
MON:			
		#import "G'Mon.asm"			
				
//------------------BASIC-------------------				

BAS:
	.if (Basic) {
		#import "TinyBasic.asm"			
	} else {	
		rts		
	}			
				     	
//-----------------Vectors------------------	
KEnd:	          	
			*=$FFFa
			
			.byte <NMI, >NMI, <INIT, >INIT, <IRQ, >IRQ						// NMI, Reset, and IRQ Vectors Lo, Hi
			
//-----------------Compiler-----------------

			.var KSize = KEnd - KStart
			.var KPCS = (KSize / HexRomSize)*100

			.print ""
			.print "       G'Mon       "
			.print "-------------------"
			.print " Pseudon 2017 v0.7"
			.print ""
			.print "=-=-=-=-=-=-=-=-=-="
			.print " Funtion Addresses"
			.print "=-=-=-=-=-=-=-=-=-="
			.print "Write       = $"+toHexString(B)
			.print "SETCursor   = $"+toHexString(L)
			.print "CReturn     = $"+toHexString(E)
			.print "Delay       = $"+toHexString(C)
			.print "- - - - - - - - - -"
			.print "=-=-=-=-=-=-=-=-=-="
			.print "   O/S Addresses"
			.print "=-=-=-=-=-=-=-=-=-="
			.print "Monitor J   = $"+toHexString(MON)
			.print "Monitor A   = $"+toHexString(Start_OS)
			.print "=-=-=-=-=-=-=-=-=-="
			.print " Extra Information "
			.print "=-=-=-=-=-=-=-=-=-="
			.print "$"+toHexString(KSize)+" used of $"+toHexString(HexRomSize)
			.print toIntString(KPCS)+"% Full"
			.print "=-=-=-=-=-=-=-=-=-="
			.print "    System Info    "
			.print "=-=-=-=-=-=-=-=-=-="
			.print "ROM Start   = $"+toHexString(RomStart)
			.print "ROM Size    = "+toIntString(RomSize)+"Kb"
			.print "Clock Speed = "+toIntString(Clock)+" MHz"

			