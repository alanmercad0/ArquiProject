.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir_x: .res 1
player_dir_y: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
.exportzp player_x, player_y, player_dir_x, player_dir_y, pad1

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
  DEC player_y

check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking
  INC player_y

done_checking:

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

  ; LDA pad1
  ; AND #BTN_LEFT
  ; BEQ go_right

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
