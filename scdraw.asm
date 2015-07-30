; extremely primitive drawing program, low-res full-screen apple iie 6502
; these definitions are meant for Easy6502 because I'm both lazy and impatient
; http://skilldrick.github.io/easy6502/
; convert these to the definition format of your favorite assembler
define cur_x $06
define cur_y $07
define blink_color $08
define kbcode $09
define kbcurrent $eb

; store 0 at $30 (color byte)
SETUP:
  LDA #$00
  STA $30
; set low-res mode (GR), set to fullscreen  
SETGR:
  STA $C050
  STA $C052
; clear low-res page 1 (we're not using page 2)  
CLEAR:
  LDA $30 ; load color stored in color byte
  LDY #$78 ; 120 bytes = 6 lines 40 pixels wide yay
  JSR FILL
  RTS
  
; store color byte at: $400-$478 
;                      $480-$4F8 
;                      $500-$578
;                      $580-$5F8
; so... 6 lines per block, 48 lines total
; avoid scratchpad memory used by firmware etc which is 
; LOCATED IN THE GRAPHICS PAGE BECAUSE WTF

; if you're feeling ambitious,; look at $F847 in monitor. 
; yes, there's an entire machine language subroutine, and a rather
; weird one at that, entirely to calculate the address of a pixel.
; low-res graphics memory is NOT continuous, for reasons that escape me..
FILL:
  DEY
  STA $400,Y
  STA $480,Y
  STA $500,Y
  STA $580,Y
  STA $600,Y
  STA $680,Y
  STA $700,Y
  STA $780,Y
  BNE FILL
  RTS

; read the keyboard via $C000
; if bit 7 is set, there was a keypress, so handle it
READKB:
  LDA $C000
  AND #$80
  BNE PROCESSKB
  RTS
  
; get lower 7 bits of keyboard read byte, redirect to appropriate
; input handling routine
PROCESSKB:
  AND #$7F ; strip off bit 7
  CMP #$3C ; '<' character, ascii code 60 (decimal) = decrement color
  BEQ DECCOLOR
  CMP #$3E ; '>' character, ascii code 62 (decimal) = increment color
  BEQ INCCOLOR
  CMP #$49 ; 'I' character, ascii code 73 = move cursor up
  BEQ MOVEUP
  CMP #$4A ; 'J' character, ascii code 74 = move cursor left
  BEQ MOVELEFT
  CMP #$4B ; 'K' character, ascii code 75 = move cursor right
  BEQ MOVERIGHT
  CMP #$4D ; 'M' character, ascii code 77 = move cursor up
  BEQ MOVEDOWN
; too legit to quit (for now)  
  ;CMP #$51 
  ;BEQ QUIT 
  RTS

; decrement color in byte $30  
DECCOLOR:
  LDA $30
  BEQ NODEC ; don't let color decrement past 0 (black)
  DEC $30
NODEC:  
  RTS

; increment color in byte $30  
INCCOLOR:
  LDA $30
  CMP #$0F ; make sure color doesn't increment past white (15 decimal)
  BEQ NOINC
  INC $30
NOINC:
  RTS

; decrement Y position in byte $07  
MOVEUP:
  LDA cur_y
  BEQ NOUP ; don't let Y position decrement past 0
  DEC cur_y
NOUP:
  RTS

; decrement X position in byte $06
MOVELEFT:
  LDA cur_x
  BEQ NOLEFT ; same deal, don't let X position decrement past 0
  DEC cur_x
NOLEFT:
  RTS

; increment X position in byte $06  
MOVERIGHT:
  LDA cur_x
  CMP #$28 ; don't let X position increment past 40 (decimal)
  BEQ NORIGHT
  INC cur_x
NORIGHT:
  RTS

; increment Y position in byte $07  
MOVEDOWN:
  LDA cur_y
  CMP #$30 ; don't let Y position increment past 48
  BEQ NODOWN
  INC cur_y
NODOWN:
  RTS

; basically just calls the machine language PLOT routine
; at $F800. accumulator = Y position, Y register is X position,
; because awesome
DRAW:
  LDA cur_y
  LDY cur_x
  JSR $F800
  RTS

; call this address to start the program  
PROGSTART:
  JSR SETUP  

; main loop. surprise! reads keyboard, processes input if available,
; draws pixel at current location, repeat ad nauseum.
; 
; currently there's no way to quit the program. but of course you
; won't want to because you'll be drawing extremely low-res pictures
; in 15 glorious colors (two of the grays are exactly the same)
MAINLOOP:
  JSR READKB
  JSR DRAW
  JMP MAINLOOP