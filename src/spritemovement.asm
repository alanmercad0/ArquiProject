.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir_x: .res 1
player_dir_y: .res 1

player_animation: .res 1  ; Added player_animation variable

sprite1_x: .res 1   ; Allocate memory for sprite 1 position
sprite1_y: .res 1
sprite1_dir_x: .res 1  ; Define direction for sprite 1
sprite1_dir_y: .res 1

sprite2_x: .res 1   ; Allocate memory for sprite 2 position
sprite2_y: .res 1
sprite2_dir_x: .res 1  ; Define direction for sprite 2
sprite2_dir_y: .res 1
.exportzp player_x, player_y, player_dir_x, player_dir_y, player_animation, sprite1_x, sprite1_y, sprite1_dir_x, sprite1_dir_y, sprite2_x, sprite2_y, sprite2_dir_x, sprite2_dir_y


.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00

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
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

;   ; Increment player_animation counter to switch frames
;   LDA player_animation
;   CLC
;   ADC #$01
;   STA player_animation

;   ; Check if player_animation exceeds the maximum frame value
;   LDA player_animation
;   CMP #$04  ; Adjust the value based on your maximum frame value (here, $04 is one more than the highest frame value)
;   BCC not_at_max_value  ; Branch if not at max value

;   ; Reset player_animation to the starting frame
;   LDA #$00  ; Set it to the value of the first frame
;   STA player_animation

; not_at_max_value:
; ; Continue with the rest of your code

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
	LDX #$30
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
	LDX #$30
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
	LDX #$30
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
	LDX #$30
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
	LDX #$30
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
  PHP        ; Push processor status register onto the stack
  PHA        ; Push accumulator onto the stack
  TXA        ; Transfer X register to accumulator
  PHA        ; Push accumulator onto the stack
  TYA        ; Transfer Y register to accumulator
  PHA        ; Push accumulator onto the stack

  ; Update player_x
  LDA player_x
  CMP #$e0
  BCC not_at_right_edge_x
  LDA #$00
  STA player_dir_x    ; Start moving left
  JMP direction_set_x
not_at_right_edge_x:
  LDA player_x
  CMP #$10
  BCS direction_set_x
  LDA #$01
  STA player_dir_x   ; Start moving right
direction_set_x:
  LDA player_dir_x
  CMP #$01
  BEQ move_right_x
  DEC player_x
  DEC player_x  ; Increase the decrement to move faster in X
  JMP exit_subroutine_xy
move_right_x:
  INC player_x
  INC player_x  ; Increase the increment to move faster in X


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

exit_subroutine_xy:
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

 ; Determine which frame to use based on player_animation counter
  ; LDA player_animation
  LDA #$03

  CMP #$00 
  BEQ use_frame_1
  CMP #$01
  BEQ use_frame_2
  CMP #$02
  BEQ use_frame_3
  CMP #$03
  BEQ use_frame_4

  JMP use_frame_1  ; Default to frame 1

use_frame_1:
  ; entity stand
  LDA #$02
  STA $0201
  LDA #$03
  STA $0205
  LDA #$12
  STA $0209
  LDA #$13
  STA $020d
  JMP done_drawing_player

use_frame_2:
  ; entity run 
  LDA #$04
  STA $0201
  LDA #$05
  STA $0205
  LDA #$14
  STA $0209
  LDA #$15
  STA $020d
  JMP done_drawing_player

use_frame_3:
  ; Add code for frame 3 (if different from frame 1)
  ; entity run 
  LDA #$06
  STA $0201
  LDA #$07
  STA $0205
  LDA #$16
  STA $0209
  LDA #$17
  STA $020d
  JMP done_drawing_player

use_frame_4:
  ; Add code for frame 4 (if different from frame 1)
  ; write player ship tile numbers
  LDA #$08
  STA $0201
  LDA #$09
  STA $0205
  LDA #$18
  STA $0209
  LDA #$19
  STA $020d
  JMP done_drawing_player

done_drawing_player:
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
