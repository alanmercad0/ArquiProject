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

	LDY #$e7

first_row:
	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	STY PPUADDR
	LDX #$02
	STX PPUDATA
	INY
	CPY #$f9
	BNE first_row

	LDY #$08

second_row:
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	STY PPUADDR
	LDX #$02
	STX PPUDATA
	INY
	CPY #$18
	BNE second_row

  LDY #$29 

third_row:
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	STY PPUADDR
	LDX #$02
	STX PPUDATA
	INY
	CPY #$37
	BNE third_row

	LDY #$4b

fourth_row:
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	STY PPUADDR
	LDX #$02
	STX PPUDATA
	INY
	CPY #$55
	BNE fourth_row

	LDY #$6D

fifth_row:
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	STY PPUADDR
	LDX #$02
	STX PPUDATA
	INY
	CPY #$73
	BNE fifth_row

	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTS
.endproc
