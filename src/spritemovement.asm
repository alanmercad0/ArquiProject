.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir_x: .res 1
player_dir_y: .res 1
<<<<<<< HEAD

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

=======
velocity_y: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
tmp: .res 1
.exportzp player_x, player_y, player_dir_x, player_dir_y, pad1, velocity_y, tmp
>>>>>>> 9f3ad2976fdd0c1447b56e234aa0d3bb632692a8

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


  ; update tiles *after* DMA transfer
  JSR read_controller1
	JSR update_player
  JSR draw_player

	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler
.import draw_platform

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
	LDA #$a2
	STA PPUADDR
	LDA #%11000000
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


.proc update_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDX player_x
  LDY player_y
  JSR CheckCollide
  BEQ collides
  LDY player_y
  DEY
  STY player_y

<<<<<<< HEAD
first_row:
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	STY PPUADDR
	LDX #$30
	STX PPUDATA
=======


collides:
  LDY player_y
>>>>>>> 9f3ad2976fdd0c1447b56e234aa0d3bb632692a8
  INY
  STY player_y

  ; INC player_y
  ; INC player_y

<<<<<<< HEAD
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
=======
  ; DEC player_y ; Does collide
  ; DEC player_y


; continue:
  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  DEC player_x    ; If the branch is not taken, move player left

  LDA #$01
  STA FACING

check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  INC player_x

  LDA #$00
  STA FACING

check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down

  LDX player_x
  LDY player_y
  JSR CheckCollide
  BEQ check_down

  LDX #$10
jump:
  LDY player_y
  DEY
  DEY
  STY player_y

  DEX
  CPX #$00
  BEQ check_down

  JMP jump


check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking

  LDY player_y
  INY
>>>>>>> 9f3ad2976fdd0c1447b56e234aa0d3bb632692a8
  INY
  STY player_y

<<<<<<< HEAD
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
=======
done_checking:
>>>>>>> 9f3ad2976fdd0c1447b56e234aa0d3bb632692a8

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

<<<<<<< HEAD
.proc update_player
  PHP        ; Push processor status register onto the stack
  PHA        ; Push accumulator onto the stack
  TXA        ; Transfer X register to accumulator
  PHA        ; Push accumulator onto the stack
  TYA        ; Transfer Y register to accumulator
  PHA        ; Push accumulator onto the stack
=======
.proc CheckCollide
  TXA
>>>>>>> 9f3ad2976fdd0c1447b56e234aa0d3bb632692a8

  LSR
  LSR
  LSR
  LSR
  LSR
  LSR

<<<<<<< HEAD

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
=======
  STA tmp

  TYA 

  LSR
  LSR
  LSR

  ASL
  ASL

  CLC
  ADC tmp
>>>>>>> 9f3ad2976fdd0c1447b56e234aa0d3bb632692a8

  TAY
  TXA

  LSR 
  LSR 
  LSR

  AND #%0111
  TAX

  LDA CollisionMap, Y
  AND BitMask, X

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

<<<<<<< HEAD
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
=======
  ; Check which direction player is facing
  LDA FACING
  CMP #%00000001
  BEQ go_left
  JMP go_right


go_left:
  LDA #$01
  STA $0201
  LDA #$00
  STA $0205
  LDA #$11
  STA $0209
  LDA #$10
  STA $020d
  LDA #$40
  JMP continue

go_right:
  LDA pad1
  AND #BTN_RIGHT
  LDA #$00
  STA $0201
  LDA #$01
  STA $0205
  LDA #$10
  STA $0209
  LDA #$11
  STA $020d
  LDA #$00

  ; write player ship tile numbers

continue:
>>>>>>> 9f3ad2976fdd0c1447b56e234aa0d3bb632692a8
  ; write player ship tile attributes
  ; use palette 0
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
.byte $3c, $03, $14, $23 ; Background
.byte $3c, $15, $15, $15
.byte $3c, $0f, $0f, $0f
.byte $3c, $37, $37, $37

.byte $3c, $15, $0f, $37 ; Sprite
.byte $3c, $19, $09, $29
.byte $3c, $19, $09, $29
.byte $3c, $19, $09, $29

<<<<<<< HEAD
=======
CollisionMap:
  .byte %11111111, %11111111, %11111111, %11111111
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000001, %10000000, %00000110, %00000001

  .byte %10011110, %00000000, %00000001, %11100001
  .byte %10000110, %00001111, %11000001, %10000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000001, %11111111, %11111110, %00000001
  .byte %10000000, %11111111, %11111100, %00000001
  .byte %10000000, %01111111, %11111000, %00000001
  .byte %10000000, %00011111, %11100000, %00000001
  .byte %10000000, %00001111, %11000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001

  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %10000000, %00000000, %00000000, %00000001
  .byte %11111111, %11111111, %11111111, %11111111

BitMask:
  .byte %10000000
  .byte %01000000
  .byte %00100000
  .byte %00010000
  .byte %00001000
  .byte %00000100
  .byte %00000010
  .byte %00000001

>>>>>>> 9f3ad2976fdd0c1447b56e234aa0d3bb632692a8

.segment "CHR"
.incbin "initialIdeas.chr"
