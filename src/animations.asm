; File: animations.asm
; Description: This file contains NES assembly code for various animation subroutines
;              used in a game. The animations include player actions such as standing,
;              walking, punching, leaping, dancing, and facing left or right. Each
;              subroutine is responsible for setting up the appropriate animation frames
;              based on the current state or animation frame of the player.
;              The code makes use of constants defined in "constants.inc" and ZEROPAGE
;              variables for efficient memory management on the NES platform.


.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, last_state, player_animation, counter

; Animation Subroutines
.segment "CODE"
.export player_standing, player_walking_left, player_walking_right, player_left, player_right, punching, player_leaping, player_dance, player_death

; Subroutine: punching
; Description: Initiates the punching animation frames.
.proc punching
    LDA last_state
    CMP #$02
    BEQ punch_right

    LDA #$09
    STA $0201
    LDA #$08
    STA $0205
    LDA #$19
    STA $0209
    LDA #$18
    STA $020d
    LDA #$40
    JMP done

punch_right:
    LDA #$08
    STA $0201
    LDA #$09
    STA $0205
    LDA #$18
    STA $0209
    LDA #$19
    STA $020d
    LDA #$00

done:
    RTS
.endproc

; Subroutine: player_leaping
; Description: Initiates the leaping animation frames.
.proc player_leaping
  LDA #$25
  STA $0201
  LDA #$26
  STA $0205
  LDA #$35
  STA $0209
  LDA #$36
  STA $020d
  LDA #$00
  RTS
.endproc

; Subroutine: player_standing
; Description: Initiates the standing animation frames based on the player's last state.
.proc player_standing
  LDA last_state
  CMP #$02
  BEQ standing_right

  LDA #$03
  STA $0201
  LDA #$02
  STA $0205
  LDA #$13
  STA $0209
  LDA #$12
  STA $020d
  LDA #$40
  JMP return

; Subroutine: dance
; Description: Initiates the dance animation frames based on the player's animation frame.
standing_right:
  LDA #$02
  STA $0201
  LDA #$03
  STA $0205
  LDA #$12
  STA $0209
  LDA #$13
  STA $020d
  LDA #$00

return:
  RTS
.endproc

.proc player_dance
  LDX player_animation

  CPX #$01 
  BEQ use_frame_1

  CPX #$02 
  BEQ use_frame_2

  CPX #$03 
  BEQ use_frame_1

  CPX #$04 
  BEQ use_frame_2

  CPX #$05 
  BEQ use_frame_1

  CPX #$06 
  BEQ use_frame_2

use_frame_1:
  LDA #$25
  STA $0201
  LDA #$26
  STA $0205
  LDA #$35
  STA $0209
  LDA #$36
  STA $020d
  LDA #$00

  JMP done_drawing_player

use_frame_2:
  LDA #$26
  STA $0201
  LDA #$25
  STA $0205
  LDA #$36
  STA $0209
  LDA #$35
  STA $020d
  LDA #$40

done_drawing_player:
  RTS
.endproc

; Subroutine: player_walking_left
; Description: Initiates the walking left animation frames based on the player's animation frame.
.proc player_walking_left
  LDX player_animation

  CPX #$01 
  BEQ use_frame_1

  CPX #$02 
  BEQ use_frame_2

  CPX #$03 
  BEQ use_frame_1

  CPX #$04 
  BEQ use_frame_2

  CPX #$05 
  BEQ use_frame_1

  CPX #$06 
  BEQ use_frame_2

use_frame_1:
  LDA #$05
  STA $0201
  LDA #$04
  STA $0205
  LDA #$15
  STA $0209
  LDA #$14
  STA $020d

  JMP done_drawing_player

use_frame_2:
  LDA #$07
  STA $0201
  LDA #$06
  STA $0205
  LDA #$17
  STA $0209
  LDA #$16
  STA $020d

done_drawing_player:
  LDA #$40

  RTS
.endproc

; Subroutine: player_walking_right
; Description: Initiates the walking right animation frames based on the player's animation frame.
.proc player_walking_right
  LDX player_animation

  CPX #$01 
  BEQ use_frame_1

  CPX #$02 
  BEQ use_frame_2

  CPX #$03 
  BEQ use_frame_1

  CPX #$04 
  BEQ use_frame_2

  CPX #$05 
  BEQ use_frame_1

  CPX #$06 
  BEQ use_frame_2

use_frame_1:
  LDA #$04
  STA $0201
  LDA #$05
  STA $0205
  LDA #$14
  STA $0209
  LDA #$15
  STA $020d

  JMP done_drawing_player

use_frame_2:
  LDA #$06
  STA $0201
  LDA #$07
  STA $0205
  LDA #$16
  STA $0209
  LDA #$17
  STA $020d

done_drawing_player:
  LDA #$00

  RTS
.endproc

; Subroutine: player_right
; Description: Initiates the animation frames for the player facing right based on the player's animation frame.
.proc player_right
  LDX player_animation

  CPX #$01 
  BEQ use_frame_2 ; standing

  CPX #$02 
  BEQ use_frame_3 ; leaning

  CPX #$03 
  BEQ use_frame_4 ; walking 

  CPX #$04 
  BEQ use_frame_4 ; attack

  CPX #$05 
  BEQ use_frame_5 ; attack with damage

  CPX #$06
  BEQ use_frame_6 ; rip

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
  LDA #$04
  STA $0201
  LDA #$05
  STA $0205
  LDA #$14
  STA $0209
  LDA #$15
  STA $020d

   ; use palette 0
  ; LDA #$40

  JMP done_drawing_player

use_frame_3:
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
  LDA #$08
  STA $0201
  LDA #$09
  STA $0205
  LDA #$18
  STA $0209
  LDA #$19
  STA $020d

  JMP done_drawing_player

use_frame_5:
  LDA #$08
  STA $0201
  LDA #$09
  STA $0205
  LDA #$18
  STA $0209
  LDA #$19
  STA $020d
  
  JMP done_drawing_with_damage

use_frame_6:
  ; entity rip
  LDA #$23
  STA $0201
  LDA #$24
  STA $0205
  LDA #$33
  STA $0209
  LDA #$34
  STA $020d

  JMP done_drawing_tombstone

done_drawing_with_damage:
  LDA #$03
  JMP finish

done_drawing_player:
  ; use palette 0
  LDA #$00
  JMP finish

done_drawing_tombstone:
  LDA #$02

finish:
  RTS
.endproc

; Subroutine: player_left
; Description: Initiates the animation frames for the player facing left based on the player's animation frame.
.proc player_left
  LDX player_animation

  CPX #$01 
  BEQ use_frame_2

  CPX #$02 
  BEQ use_frame_3

  CPX #$04 
  BEQ use_frame_4

  CPX #$05 
  BEQ use_frame_5

  CPX #$06
  BEQ use_frame_6

use_frame_1:
  ; entity stand
  LDA #$03
  STA $0201
  LDA #$02
  STA $0205
  LDA #$13
  STA $0209
  LDA #$12
  STA $020d

  JMP done_drawing_player

use_frame_2:
  LDA #$05
  STA $0201
  LDA #$04
  STA $0205
  LDA #$15
  STA $0209
  LDA #$14
  STA $020d

  JMP done_drawing_player

use_frame_3:
  LDA #$07
  STA $0201
  LDA #$06
  STA $0205
  LDA #$17
  STA $0209
  LDA #$16
  STA $020d

  JMP done_drawing_player

use_frame_4:
  ; entity stand
  LDA #$09
  STA $0201
  LDA #$08
  STA $0205
  LDA #$19
  STA $0209
  LDA #$18
  STA $020d

  JMP done_drawing_player

use_frame_5:
  LDA #$09
  STA $0201
  LDA #$08
  STA $0205
  LDA #$19
  STA $0209
  LDA #$18
  STA $020d

  JMP done_drawing_with_damage

use_frame_6:
  ; entity rip
  LDA #$24
  STA $0201
  LDA #$23
  STA $0205
  LDA #$34
  STA $0209
  LDA #$33
  STA $020d

  JMP done_drawing_tombstone

done_drawing_with_damage:
  LDA #$43
  JMP finish

done_drawing_player:
  ; use palette 0
  LDA #$40
  JMP finish

done_drawing_tombstone:
  LDA #$42
  
finish:
  RTS
.endproc

.proc player_death
  LDX player_animation

  CPX #$01 
  BEQ use_frame_1 

  CPX #$02 
  BEQ use_frame_2 

  CPX #$03 
  BEQ use_frame_1 

  CPX #$04 
  BEQ use_frame_2 

  CPX #$05 
  BEQ use_frame_1  

  CPX #$06
  BEQ use_frame_3 ; rip

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
  LDA #$00

  JMP finish

use_frame_2:
  LDA #$02
  STA $0201
  LDA #$03
  STA $0205
  LDA #$12
  STA $0209
  LDA #$13
  STA $020d
  LDA #$03

  JMP finish

use_frame_3:
  ; entity rip
  LDA #$23
  STA $0201
  LDA #$24
  STA $0205
  LDA #$33
  STA $0209
  LDA #$34
  STA $020d
  LDA #$02 

finish:
  RTS
.endproc