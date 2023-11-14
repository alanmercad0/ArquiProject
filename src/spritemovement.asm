.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir_x: .res 1
player_dir_y: .res 1
velocity_y: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
tmp: .res 1
player_state: .res 1
player_animation: .res 1  ; Added player_animation variable
player_health: .res 1
counter: .res 1
jumping: .res 1
.exportzp player_x, player_y, player_dir_x, player_dir_y, pad1, velocity_y, tmp, player_animation, player_health

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
  LDA #$64
  STA player_health

  LDA #%11111111
  STA player_state


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

  DEC player_y
  ; DEY
  ; STY player_y

collides:
  INC player_y
  ; LDA player_y
  CMP #$F0
  BCS check_left


check_left:
  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed

  LDA player_x
  CMP #$05
  BCC done_checking

  LDA #$01
  STA player_state

  DEC player_x    ; If the branch is not taken, move player left


check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up

  LDA #$00
  STA player_state

  LDA player_x
  CMP #$F5
  BCS done_checking

  INC player_x

check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down

  DEC player_y
  DEC player_y

check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ check_jumping

  INC player_y

check_jumping:
  LDA jumping
  CMP #$00
  BEQ check_a

  LDA #$01
  CMP #jumping
  BCC check_a

  DEC player_y
  DEC player_y
  DEC player_y
  DEC jumping
  JMP check_b

check_a:
  LDA pad1
  AND #BTN_A
  BEQ check_b

  LDA #$10
  STA jumping

check_b: ; K key
  LDA pad1
  AND #BTN_B
  BEQ done_checking
  
  JSR dead

done_checking:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc CheckCollide
  TXA

  LSR
  LSR
  LSR
  LSR
  LSR
  LSR

  STA tmp

  TYA 

  LSR
  LSR
  LSR

  ASL
  ASL

  CLC
  ADC tmp

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

.proc dead
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$23
  STA $0201
  LDA #$24
  STA $0205
  LDA #$33
  STA $0209
  LDA #$34
  STA $020d

  LDA #$41
  STA $0202

  ; LDA #$01
  STA $0206

  ; LDA #$02
  STA $020a

  ; LDA #$03
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

  
  ; LDA player_health
  ; CMP #$00
  ; BNE continue
  ; JSR dead
  ; JMP done

  LDA player_state
  CMP #$01
  BCS go_left


continue:

;  ; Determine which frame to use based on player_animation counter
;   LDX player_animation

;   CPX #$00 
;   BEQ use_frame_1

;   CPX #$0A
;   BEQ use_frame_2

;   CPX #$14
;   BEQ use_frame_3

;   CPX #$1E
;   BEQ use_frame_4


;   ; STA $0202
;   ; STA $0206
;   ; STA $020a
;   ; STA $020e

; use_frame_1:
  ; entity stand
  LDA #$02
  STA $0201
  LDA #$03
  STA $0205
  LDA #$12
  STA $0209
  LDA #$13
  STA $020d
  LDA #$00
  JMP go_here

go_left:
  LDA #$03
  STA $0201
  LDA #$02
  STA $0205
  LDA #$13
  STA $0209
  LDA #$12
  STA $020d
  LDA #$40


  
;   INC counter
;   INC counter
;   INC counter
;   LDA counter
;   AND #$10
;   BEQ even
;   LDA #$00
;   JMP go_here

; even:
;   LDA #$03

;   INC player_animation
;   JMP done_drawing_player

; use_frame_2:
;   ; entity run 
;   LDA #$04
;   STA $0201
;   LDA #$05
;   STA $0205
;   LDA #$14
;   STA $0209
;   LDA #$15
;   STA $020d

;   INC player_animation
;   JMP done_drawing_player

; use_frame_3:
;   ; Add code for frame 3 (if different from frame 1)
;   ; entity run 
;   LDA #$06
;   STA $0201
;   LDA #$07
;   STA $0205
;   LDA #$16
;   STA $0209
;   LDA #$17
;   STA $020d

;   INC player_animation
;   JMP done_drawing_player

; use_frame_4:
;   ; Add code for frame 4 (if different from frame 1)
;   ; write player ship tile numbers
;   LDA #$08
;   STA $0201
;   LDA #$09
;   STA $0205
;   LDA #$18
;   STA $0209
;   LDA #$19
;   STA $020d

;   LDX #$00 
;   STX player_animation

;   JMP done_drawing_player

; done_drawing_player:
;   ; write player ship tile attributes
;   ; use palette 0
  ; LDA #$00
go_here:
  STA $0202

  ; LDA #$01
  STA $0206

  ; LDA #$02
  STA $020a

  ; LDA #$03
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
done:
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
.byte $3c, $03, $14, $23 ; Blocks
.byte $3c, $27, $37, $0f ; Sun
.byte $3c, $31, $30, $0f ; Clouds
.byte $3c, $37, $37, $37

.byte $3c, $0f, $04, $37 ; Character
.byte $3c, $01, $01, $01
.byte $3c, $2D, $00, $3D ; Tombstone
.byte $3c, $06, $06, $06 ; All red

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
  .byte %10000000, %00000000, %00000000, %00000001

BitMask:
  .byte %10000000
  .byte %01000000
  .byte %00100000
  .byte %00010000
  .byte %00001000
  .byte %00000100
  .byte %00000010
  .byte %00000001


.segment "CHR"
.incbin "addedTombstone.chr"
