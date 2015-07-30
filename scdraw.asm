;extremely primitive drawing program, low-res full-screen apple iie 6502
define cur_x $06
define cur_y $07
define blink_color $08
define kbcode $09
define kbcurrent $eb

SETUP:
  LDA #$00
  STA $30
SETGR:
  STA $C050
  STA $C052
CLEAR:
  LDA $30
  LDY #$78
  JSR FILL1
  LDY #$78
  JSR FILL2
  RTS
FILL1:
  DEY
  STA $400,Y
  STA $480,Y
  STA $500,Y
  STA $580,Y
  BNE FILL1
  RTS
FILL2:
  DEY
  STA $600,Y
  STA $680,Y
  STA $700,Y
  STA $780,Y
  BNE FILL2
  RTS

READKB:
  LDA #$00
  LDA $C000
  STA kbcode
  AND #$80
  BNE PROCESSKB
  RTS
PROCESSKB:
  STA $C010
  LDA $C000
  AND #$7F
  CMP #$3C
  BEQ DECCOLOR
  CMP #$3E
  BEQ INCCOLOR
  CMP #$49
  BEQ MOVEUP
  CMP #$4A
  BEQ MOVELEFT
  CMP #$4B
  BEQ MOVERIGHT
  CMP #$4D
  BEQ MOVEDOWN
  ;CMP #$51
  ;BEQ QUIT
  RTS
  
DECCOLOR:
  LDA $30
  BEQ NODEC
  DEC $30
NODEC:  
  RTS
  
INCCOLOR:
  LDA $30
  CMP #$0F
  BEQ NOINC
  INC $30
NOINC:
  RTS
  
MOVEUP:
  LDA cur_y
  BEQ NOUP
  DEC cur_y
NOUP:
  RTS
  
MOVELEFT:
  LDA cur_x
  BEQ NOLEFT
  DEC cur_x
NOLEFT:
  RTS
  
MOVERIGHT:
  LDA cur_x
  CMP #$28
  BEQ NORIGHT
  INC cur_x
NORIGHT:
  RTS
  
MOVEDOWN:
  LDA cur_y
  CMP #$30
  BEQ NODOWN
  INC cur_y
NODOWN:
  RTS
  
DRAW:
  LDA cur_y
  LDY cur_x
  JSR $F800
  RTS
  
PROGSTART:
  JSR SETUP  
  
MAINLOOP:
  JSR READKB
  JSR DRAW
  JMP MAINLOOP

    