.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir_x: .res 1
player_dir_y: .res 1
sprite1_x: .res 1   ; Allocate memory for sprite 1 position
sprite1_y: .res 1
sprite1_dir_x: .res 1  ; Define direction for sprite 1
sprite1_dir_y: .res 1
sprite2_x: .res 1   ; Allocate memory for sprite 2 position
sprite2_y: .res 1
sprite2_dir_x: .res 1  ; Define direction for sprite 2
sprite2_dir_y: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
.exportzp player_x, player_y, player_dir_x, player_dir_y, sprite1_x, sprite1_y, sprite1_dir_x, sprite1_dir_y, sprite2_x, sprite2_y, sprite2_dir_x, sprite2_dir_y, pad1

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import read_controller1

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00

  JSR read_controller1

  ; update tiles *after* DMA transfer
	JSR update_player
  JSR draw_player

	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

  JSR draw_platform

	; finally, attribute table
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$c2
	STA PPUADDR
	LDA #%01000000
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$e0
	STA PPUADDR
	LDA #%00001100
	STA PPUDATA

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
	STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

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

.proc update_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  
  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  DEC player_x  ; If the branch is not taken, move player left
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  INC player_x
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  DEC player_y
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking
  INC player_y
done_checking:

;   ; Update player_x
;   LDA player_x
;   CMP #$e0
;   BCC not_at_right_edge_x
;   LDA #$00
;   STA player_dir_x    ; Start moving left
;   JMP direction_set_x
; not_at_right_edge_x:
;   LDA player_x
;   CMP #$10
;   BCS direction_set_x
;   LDA #$01
;   STA player_dir_x   ; Start moving right
; direction_set_x:
;   LDA player_dir_x
;   CMP #$01
;   BEQ move_right_x
;   DEC player_x
;   DEC player_x  ; Increase the decrement to move faster in X
;   JMP exit_subroutine_xy
; move_right_x:
;   INC player_x
;   INC player_x  ; Increase the increment to move faster in X

  ; Update player_y
;   LDA player_y
;   CMP #$e0
;   BCC not_at_bottom_edge_y
;   LDA #$00
;   STA player_dir_y    ; Start moving up
;   JMP direction_set_y
; not_at_bottom_edge_y:
;   LDA player_y
;   CMP #$10
;   BCS direction_set_y
;   LDA #$01
;   STA player_dir_y   ; Start moving down
; direction_set_y:
;   LDA player_dir_y
;   CMP #$01
;   BEQ move_down_y
;   DEC player_y
;   DEC player_y  ; Increase the decrement to move faster in Y
;   JMP exit_subroutine_xy
; move_down_y:
;   INC player_y
;   INC player_y  ; Increase the increment to move faster in Y

; exit_subroutine_xy:
  ; All done, clean up and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; write player ship tile numbers
  LDA #$00
  STA $0201
  LDA #$01
  STA $0205
  LDA #$10
  STA $0209
  LDA #$11
  STA $020d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $3c, $03, $14, $23
.byte $3c, $15, $0f, $37
.byte $3c, $15, $0f, $37
.byte $3c, $15, $0f, $37

.byte $3c, $15, $0f, $37
.byte $3c, $19, $09, $29
.byte $3c, $19, $09, $29
.byte $3c, $19, $09, $29

.segment "CHR"
.incbin "initialIdeas.chr"
