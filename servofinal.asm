;SAMUEL ALMEIDA
;197DP 4/27/22
;RUNNING SERVOS WITH CONTINUOUS INTERRUPT ROUTINES
;CAN BE ASSEMBLED FOR 6502 BY DOWNLOADING ASSEMBLER FROM http://www.kingswood-consulting.co.uk/assemblers/
;ALL VALUES ARE IN HEXADECIMAL, DENOTED BY '$' IN FRONT

;==============MEMORY ADDRESSES============

;USED FOR ADDRESSING THE PORTS AND SUBROUTINES IN THE KIM

PortA		equ	$1700
PortADDR	equ	$1701
RIOTDDR         equ     $1741
PINOUT          equ     $0F     ;Memory address to store what pin to output to
DIRECTION       equ     $10     ;Memory address to store what pulse you want for the servo (controls the direction in this program)
GETKEY		equ     $1F6A   ;Memory address for the Riot's GETKEY subroutine, which gets what key the user pressed on the KIM board
AK              equ     $1EFE   ;Memory address for the Riot's AK subroutine, which gets if a user pressed any key on the KIM board
INT1            equ     $171C   ;/1 timer int enabled
INT8            equ     $171D   ;/8 timer int enabled
INT64           equ     $171E   ;/64 timer int enabled
INT1024         equ     $171F   ;/1024 timer int enabled
FLAG            equ     $F9     ;Memory address to store the flag for the end pulse for stopping the servos


;===================CONTROLS==============

;MY SERVO FOR UP AND DOWN IS REVERSE SO I SWITCHED THE PULSES, BUT YOU CAN REMAP BUTTONS HERE

UPC             equ     $06
DOWNC           equ     $02
LEFTC           equ     $01
RIGHTC          equ     $03
OPENC           equ     $05
CLOSEC          equ     $07
TESTC           equ     $0F

;=============SERVO TIMING=======================

;USED TO CHANGE THE SPEED OF THE SERVOS AND THE PERIOD OF THE SIGNAL

PERIOD          equ     $2F
SPEEDUP         equ     $7D
SPEEDDOWN       equ     $FA
OFFPULSE        equ     $BB



;================OUTPUT PINS===================================

;USED TO CHANGE WHAT PINS TO OUTPUT TO ON THE KIM
ALLPINS        equ     $FF
PIN1           equ     $01
PIN2           equ     $02
PIN3           equ     $04
;------ALL BELOW PINS ARE NOT IMPLEMENTED IN THE CODE, BUT COULD BE ADDED USING PORTA
PIN4           equ     $08
PIN5           equ     $10
PIN6           equ     $20
PIN7           equ     $40
PIN8           equ     $80



;################## START OF PROGRAM ##########################

;==============================================================
;========================INIT==================================

;SETS THE PORT DDR FOR PORT A AND RIOT AND TURNS OFF INTERRUPTS, AS WELL AS STORES THE IRQ VECTORS

        org $0200
        code
INIT:   cld
        sei
        lda     #$00
        sta     RIOTDDR
        sta     PortA
        lda     #$FF
        sta     PortADDR
        lda     #$00
        sta     $17FE
        lda     #$04
        sta     $17FF
        jmp     MAIN

;=======================================================
;=======================MAIN LOOP=======================

;the main loop just runs and listens for a key to branch and control the servo required, and just loops

        org $0220
MAIN:   lda     #$00
        sta     RIOTDDR   ;initializes the keyboard riot chip to be in inpt mode, for GETKEY
        jsr     GETKEY    ;checks to see what key is pressed, and loads different values for the servo based on that
        cmp     #LEFTC    ;checks for if the key to the left is pressed
        beq     L
        cmp     #RIGHTC
        beq     R
        cmp     #UPC      ;checks for if the key to the left is pressed
        beq     U
        cmp     #DOWNC
        beq     D
        cmp     #OPENC
        beq     O
        cmp     #CLOSEC
        beq     C
        cmp     #TESTC
        beq     T
        jmp     MAIN      ;keeps running if no keys are pressing
L:      jsr     LEFT      ;these statements are just branches to different initialisers for the servos, L=LEFT, R=RIGHT, etc.
        jmp     MAIN
        end
R:      jsr     RIGHT
        jmp     MAIN
U:      jsr     UP
        jmp     MAIN
D:      jsr     DOWN
        jmp     MAIN
O:      jsr     OPEN
        jmp     MAIN
C:      jsr     CLOSE
        jmp     MAIN
T:      jsr     TEST
        jmp     MAIN

;=============================================
;=============DIRECTIONS======================

;the directions specify the output pin and the pulse length to control each servo, 1 is the first pin in PortA, 2 is the second pin
;in PortA, 4 is the third pin in PortA, then SPEED(UP/DOWN) sends the pulse length.
; I'm using a /8 on a 1Mhz clock, which means I write a $7D for a 1 ms pulse, and a $FA for a 2 ms pulse, where $BC is a 1.504ms
                                                                                                                                ;pulse
;I flip between a /8 and a /1024 for the period, the period between uses /1024 for a  ~20ms delay since that's the delay between pulses
;that the servos need, the actual pulse is controlled with a /8
;all of these are just initialisers for the servo routine, you can change the pin value and speed up or down on each
;you can also add a servo if you use a different pin and copy paste the initialiser code and then add a branch in the main loop

        org $0300
LEFT:   lda     #PIN1         ;this is used for the output pin 1
        sta     PINOUT
        lda     #SPEEDDOWN
        sta     DIRECTION    ;this register is used for the servo routine, and the speed variable is being stored to it
        lda     #$12
        sta     PERIOD      
        sta     INT1024
        cli
        jsr     SERVO        ;jumps to servo routine to wait for interrupt
        rts


RIGHT:  lda     #PIN1         ;this is used for the output pin 1
        sta     PINOUT
        lda     #SPEEDUP
        sta     DIRECTION    ;this register is used for the servo routine, and the speed variable is being stored to it
        lda     #$13
        sta     PERIOD      
        sta     INT1024
        cli
        jsr     SERVO        ;jumps to servo routine to wait for interrupt
        rts


UP:     lda     #PIN2         ;this is used for the output pin 2
        sta     PINOUT
        lda     #SPEEDDOWN
        sta     DIRECTION    ;this register is used for the servo routine, and the speed variable is being stored to it
        lda     #$12
        sta     PERIOD    
        sta     INT1024
        cli
        jsr     SERVO        ;jumps to servo routine to wait for interrupt
        rts


DOWN:   lda     #PIN2         ;this is used for the output pin 2
        sta     PINOUT
        lda     #SPEEDUP
        sta     DIRECTION    ;this register is used for the servo routine, and the speed variable is being stored to it
        lda     #$13
        sta     PERIOD  
        sta     INT1024
        cli
        jsr     SERVO        ;jumps to servo routine to wait for interrupt
        rts


OPEN:   lda     #PIN3         ;this is used for the output pin 3
        sta     PINOUT
        lda     #SPEEDDOWN
        sta     DIRECTION    ;this register is used for the servo routine, and the speed variable is being stored to it
        lda     #$12
        sta     PERIOD    
        sta     INT1024
        cli
        jsr     SERVO        ;jumps to servo routine to wait for interrupt
        rts

CLOSE:  lda     #PIN3         ;this is used for the output pin 3
        sta     PINOUT
        lda     #SPEEDUP
        sta     DIRECTION    ;this register is used for the servo routine, and the speed variable is being stored to it
        lda     #$13
        sta     PERIOD  
        sta     INT1024
        cli
        jsr     SERVO        ;jumps to servo routine to wait for interrupt
        rts

TEST:   lda     #ALLPINS      ;this is used for all output pins THIS IS USED TO TEST IF THE OFF PULSE IS CALIBRATED FOR SERVOS
        sta     PINOUT
        lda     #OFFPULSE
        sta     DIRECTION    ;this register is used for the servo routine, and the speed variable is being stored to it
        lda     #$13
        sta     PERIOD  
        sta     INT1024
        cli
        jsr     SERVO        ;jumps to servo routine to wait for interrupt
        rts

;========================================================
;===================SERVO CONTROL========================

;the servo control uses two interupts to flip a pulse, to get around using a delay loop and allow
;it first starts a timer for ~20ms and then on interupt jumps to a loop that sets
;whatever specified pin to high, then sets a new timer for the speed direction specified and when that interrupts
;the new interrupt toggles the port low then jumps back to the servo routine
;this continues as long as the user is pressing down a key, when the user releases, the routine runs one more time to 
;send a 1.5 ms pulse to tell the servo to stop, then jumps back to main to wait for another key inpur

        org $0390
SERVO:  jsr     AK           ;KIM subroutine to check to see if A key is pressed (AK - A KEY)
        cmp     #$00         ;if no key is pressed the A register will have a 00 in it, so we compare with 00 to see key released
        beq     EXIT         ;if AK finds no key pressed, run exit routine
        jmp     SERVO        ;else keep running servo and pulse on interrupt
EXIT:   lda     #$00         ;this sets the interrupt vector to $400 for the first stage of the pulse
        sta     $17FE
        lda     #$04
        sta     $17FF
        lda     #FLAG
END:    cmp     #$EC         ;waits for a to have EC to break the loop so that way it doesn't overlap with a key press
                                ;EC is only set to A from the END PULSE section of toggle off interrupt (TOFF)
        beq     LEAVE
        jmp     END
LEAVE:  lda     #$00
        sta     PortA
        lda     $A
        sei
        rts

;=======================================================
;====================INTERRUPTS=========================

;these interrupts toggle between two states to output a periodic signal thats specified by the user
;you can change the duty cycle by changing the SPEED(UP/DOWN) variable and the PERIOD variable at the top

        org $0400            ;used for the pulse to send a signal to servo
ONPULSE:cmp     #FLAG        ;this is a flag to see if the routine needs to run the 1.5ms pulse, otherwise it's ignored
        beq     EPULSE       ;short for END PULSE
        sta     $A           ;stores A in case we need the value in A
        lda     #$40         ;setting the IRQ to $440 to jump to the routine to toggle the pin off
        sta     $17FE        ;^
        lda     #$04         ;^^
        sta     $17FF        ;^^^
        lda     DIRECTION    ;this is used for the length of the pulse for the servo
        sta     INT8         ;stores it in the /64 interrupt enabled
        lda     OUT          ;loads a with the pin we need to output to for the pulse
        sta     PortA        ;stores that value to set that pin to high
        lda     $A
        rti     
EPULSE: sta     $A           ;this is taken after AK returns 0, to send a 1.5 ms pulse to stop the servo
        lda     OUT
        sta     PortA
        lda     #$40         ;the rest is the same as the previous loop, it just runs with OFFPULSE instead of DIRECTION
        sta     $17FE
        lda     #$04
        sta     $17FF
        lda     #OFFPULSE
        sta     INT8
        lda     $A
        rti
        end

        org $0440             ;this is the second interrupt to toggle the pulse off after the specified period
TOFF:   sta     $A           ;this code is the same as the regular period, so ill just comment the differences
        lda     #$00         ;sets the IRQ back to $400 to repeat the periodic interrupt
        sta     PortA
        sta     $17FE
        lda     #$04
        sta     $17FF
        lda     PERIOD
        sta     INT1024      ;this loads the period time back to the /1064 interrupt enabled time to repeat the period
        lda     $A
        cmp     #FLAG
        beq     EPULSE2      ;this just checks to see if the flag was set in A, to finish the end pulse
        rti
EPULSE2:lda     #$EC         ;this sets A to $EC for the END loop in SERVO CONTROL
        rti
        end