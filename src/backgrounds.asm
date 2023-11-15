.include "constants.inc"
.segment "CODE"

.export draw_platform
.proc draw_platform
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA

	; Small Platforms
	LDX #$30
	LDY #$21

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$68
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$69
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$76
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$77
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$84
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$85
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$9A
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$9B
	STA PPUADDR
	STX PPUDATA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Cool guy Sun
	LDA PPUSTATUS  ; Sun 1
	STY PPUADDR
	LDA #$86
	STA PPUADDR
	LDX #$31
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$87
	STA PPUADDR
	LDX #$32
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$A6
	STA PPUADDR
	LDX #$41
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$A7
	STA PPUADDR
	LDX #$42
	STX PPUDATA

	LDA PPUSTATUS ; Sun 2
	STY PPUADDR
	LDA #$98
	STA PPUADDR
	LDX #$31
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$99
	STA PPUADDR
	LDX #$32
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$B8
	STA PPUADDR
	LDX #$41
	STX PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$B9
	STA PPUADDR
	LDX #$42
	STX PPUDATA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	LDX #$64
	LDY #$83
	JSR draw_cloud

	LDX #$91
	LDY #$B0
	JSR draw_cloud

	LDX #$59
	LDY #$78
	JSR draw_cloud

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Each of the following are loops that travel from $Y1 to $Y2 placing down the purple tiles which are stored in X
	LDY #$AD ; Y1 (platform)
	LDX #$30 ; Purple block 

platform: 
	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	STY PPUADDR
	STX PPUDATA

	INY
	CPY #$B3 ; Y2 (platform)
	BNE platform

	LDY #$08 ; Y1 (first row)

first_row:
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	STY PPUADDR
	STX PPUDATA
	INY
	CPY #$18 ; Y2 (first row)
	BNE first_row

	LDY #$29 ; Y1 (second row)

second_row:
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	STY PPUADDR
	STX PPUDATA
	INY
	CPY #$37 ; Y2 (second row)
	BNE second_row

	LDY #$4A ; Y1 (third row)

third_row:
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	STY PPUADDR
	STX PPUDATA
	INY
	CPY #$56 ; Y2 (third row)
	BNE third_row

	LDY #$6C ; Y1 (fourth row)

fourth_row:
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	STY PPUADDR
	STX PPUDATA
	INY
	CPY #$74 ; Y2 (fourth row)
	BNE fourth_row

	LDY #$8D ; Y1 (fifth row)

fifth_row:
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	STY PPUADDR
	STX PPUDATA
	INY
	CPY #$93 ; Y2 (fifth row)
	BNE fifth_row

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDY #$23  ; Load $23 into Y for easy access. This is where the attribute table is located.

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$d9
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$de
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$c1
	STA PPUADDR
	LDA #%00100000
	STA PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$c9
	STA PPUADDR
	LDA #%00000010
	STA PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$c8
	STA PPUADDR
	LDA #%00001000
	STA PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$cc
	STA PPUADDR
	LDA #%0001010
	STA PPUDATA

	LDA PPUSTATUS
	STY PPUADDR
	LDA #$c6
	STA PPUADDR
	LDA #%10100000
	STA PPUDATA

	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTS
.endproc


; Subroutine that uses the values in the X and Y registers to draw a cloud anywhere in the first 5 rows (2x2) of map
.proc draw_cloud
	LDA PPUSTATUS 
	LDA #$20
	STA PPUADDR
	STX PPUADDR ; Draw in initial X value
	LDA #$36 	; Top left tile
	STA PPUDATA

	INX			; Go to next tile

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	STX PPUADDR
	LDA #$37	; Top right tile
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	STY PPUADDR	; Initial Y position (starting bottom half)
	LDA #$45	; Bottom left tile
	STA PPUDATA

	INY			; Go to next tile

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	STY PPUADDR
	LDA #$46	; Bottom middle tile
	STA PPUDATA
	
	INY			; Go to next tile

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	STY PPUADDR
	LDA #$47	; Bottom right tile
	STA PPUDATA

done:
	RTS
.endproc

