; File: reset_handler.asm
; Description: This file contains NES assembly code for the reset handler,
;              which is executed when the NES system is powered on or reset.

.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y

.segment "CODE"
.import main
.export reset_handler

; Subroutine: reset_handler
; Description: The reset handler is executed when the NES system is powered on
;              or reset. It initializes various settings, clears the sprite
;              positions in OAM (Object Attribute Memory), and sets up initial
;              values for player_x and player_y in the zero-page.
.proc reset_handler
  SEI
  CLD
  LDX #$00
  STX PPUCTRL
  STX PPUMASK

vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

	LDX #$00
	LDA #$ff
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

vblankwait2:
	BIT PPUSTATUS
	BPL vblankwait2

	; initialize zero-page values
	LDA #$80
	STA player_x
	LDA #$6F
	STA player_y

  JMP main  ; Jump to the main routine to start the game
.endproc
