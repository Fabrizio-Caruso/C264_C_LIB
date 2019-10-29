
    .DEFINE IRQ_ACK $FF09
    .DEFINE TED_LINE $FF0B
    .DEFINE TED_IRQ_MASK $FF0A
    
    .IF .DEFINED(BASIC)
        USE_KERNAL=1
        STANDARD_IRQ=1
        .BYTE $00, $C0    
        .ORG $C000         
    .ENDIF
;--------------------------------------

    .INCLUDE "zeropage.inc"
    .INCLUDE "c16.inc"             ; Include file for C16 specific compilation

;-------------------
    .EXPORT _INITRASTER

    FULL_STANDARD_KERNAL=$CE0E
    LIGHT_STANDARD_KERNAL=$FCBE

    TOP_KERNAL_IRQ=LIGHT_STANDARD_KERNAL
    .IFDEF STANDARD_IRQ
        BOTTOM_KERNAL_IRQ=FULL_STANDARD_KERNAL        
    .ELSE
        BOTTOM_KERNAL_IRQ=LIGHT_STANDARD_KERNAL        
    .ENDIF

   
;-------------------
;DEBUG = $00                             ; Set to != $00 to show rastertime usage.
;USE_KERNAL = $01                        ; Set to != $00 to enable normal kernal usage
;MULTICOLOR = $01                        ; Set to != $00 to enable multicolor sprites flag
;EXPANDX= $01                            ; Set to != $00 to enable expand_x sprites flag
;EXPANDY= $01                            ; Set to != $00 to enable expand_y sprites flag
;-------------------
;-------------------
IRQTOPLINE = $02                       ; Sprites display IRQ at rasterline $023.
IRQBOTTOMLINE = 203                     ; Sorting code IRQ at rasterline $0FC

;-------------------
;MUSIC_CODE = $01                       ; Set to $01 to enable music routines


;-------------------
TEMPVARIABLE = $FE                      ; Just a temp variable used by the raster interrupt

;---------------------------------------
; Routine to init the
; raster interrupt system
;-------------------
_INITRASTER:

    SEI

;-------------------
    LDA #<IRQBOTTOM                          ; Load low byte of Setup IRQ vector
    .IFDEF USE_KERNAL
        STA IRQVec                      ; Store it into vector used if Kernal is ON,
    .ELSE
        STA $FFFE                       ; otherwise store it into vector used if Kernal is OFF
    .ENDIF
    LDA #>IRQBOTTOM                          ; Load hi byte of Setup IRQ vector
    .IFDEF USE_KERNAL
        STA IRQVec+$0001                ; Store it into vector used if Kernal is ON,
    .ELSE
        STA $FFFF                       ; otherwise store it into vector used if Kernal is OFF
    .ENDIF
    LDA #<IRQ_RTI                       ; Load low byte of unarmed RTI (disable RESTORE key)
    .IFDEF USE_KERNAL
        STA NMIVec                      ; Store it into vector used if Kernal is ON,
    .ELSE
        STA $FFFA                       ; otherwise store it into vector used if Kernal is OFF
    .ENDIF
    LDA #>IRQ_RTI                       ; Load hi byte of unarmed RTI (disable RESTORE key)
    .IFDEF USE_KERNAL
        STA NMIVec+$0001                ; Store it into vector used if Kernal is ON,
    .ELSE
        STA $FFFB                       ; otherwise store it into vector used if Kernal is OFF
    .ENDIF
    ; Enable raster IRQs and set high bit of interrupt position = $0xx
    LDA TED_IRQ_MASK
    ORA #$02+0
    STA TED_IRQ_MASK
    LDA #IRQBOTTOMLINE
    STA TED_LINE                        ; Set position where first IRQ happens.
    LDA IRQ_ACK                         ; Acknowledge IRQ (to be sure)

    CLI                                 ; Let IRQs happen.
    RTS                                 ; Back to where he came from.

;---------------------------------------
; Top Raster interrupt 
;-------------------
IRQTOP:
    
    .IFNDEF USE_KERNAL
        STA BOTTOM_STORE_A                     ; Fast way to store/restore
        STX BOTTOM_STORE_X                     ; CPU regs after an IRQ
        STY BOTTOM_STORE_Y                     ; for kernal OFF only
    .ENDIF

    .IFDEF DEBUG
        LDA #$FF
        STA TED_BORDERCOLOR             ; Show rastertime usage for debug.
    .ENDIF

    LDA #<IRQBOTTOM                         ; If we just displayed last sprite, load low byte of sort IRQ vector
    .IFDEF USE_KERNAL
        STA IRQVec                      ; Store it into vector used if Kernal is ON,
    .ELSE
        STA $FFFE                       ; otherwise store it into vector used if Kernal is OFF
    .ENDIF
    LDA #>IRQBOTTOM                          ; Load hi byte of sort IRQ vector
    .IFDEF USE_KERNAL
        STA IRQVec+$0001                ; Store it into vector used if Kernal is ON
    .ELSE
        STA $FFFF                       ; otherwise store it into vector used if Kernal is OFF
    .ENDIF
    LDA #IRQBOTTOMLINE                       ; Load position where sort IRQ happens,
    STA TED_LINE                        ; Set position where first IRQ happens.
    LDA IRQ_ACK                         ; Acknowledge IRQ (to be sure)

    .IFDEF DEBUG
        LDA #$82
        STA TED_BORDERCOLOR             ; Show rastertime usage for debug.
    .ENDIF  
    
    LSR IRQ_ACK 
    
    .IF .NOT .DEFINED(USE_KERNAL)
        TOP_STORE_A = *+$0001           ; Restore original registers value
        LDA #$00
        TOP_STORE_X = *+$0001           ; at the original values they have before
        LDX #$00
        TOP_STORE_Y = *+$0001           ; IRQ call
        LDY #$00         
    .ELSE ; 
        JMP TOP_KERNAL_IRQ              ; Use normal Kernal C64 IRQ exit code if Kernal is ON 
    .ENDIF
    
    RTI
;----------------------------------------------

IRQBOTTOM:

    
    .IFNDEF USE_KERNAL
        STA BOTTOM_STORE_A                     ; Fast way to store/restore
        STX BOTTOM_STORE_X                     ; CPU regs after an IRQ
        STY BOTTOM_STORE_Y                     ; for kernal OFF only
    .ENDIF

    .IFDEF DEBUG
        LDA #$47
        STA TED_BORDERCOLOR             ; Show rastertime usage for debug.
    .ENDIF

    LDA #<IRQTOP                         ; If we just displayed last sprite, load low byte of sort IRQ vector
    .IFDEF USE_KERNAL
        STA IRQVec                      ; Store it into vector used if Kernal is ON,
    .ELSE
        STA $FFFE                       ; otherwise store it into vector used if Kernal is OFF
    .ENDIF
    LDA #>IRQTOP                          ; Load hi byte of sort IRQ vector
    .IFDEF USE_KERNAL
        STA IRQVec+$0001                ; Store it into vector used if Kernal is ON
    .ELSE
        STA $FFFF                       ; otherwise store it into vector used if Kernal is OFF
    .ENDIF
    LDA #IRQTOPLINE                       ; Load position where sort IRQ happens,
    STA TED_LINE                       ; and set it.    

    .IFDEF DEBUG
        LDA #$A0
        STA TED_BORDERCOLOR             ; Show rastertime usage for debug.
    .ENDIF  
   
    LSR IRQ_ACK                         ; Acknowledge raster IRQ

    .IF .NOT .DEFINED(USE_KERNAL)
        BOTTOM_STORE_A = *+$0001           ; Restore original registers value
        LDA #$00
        BOTTOM_STORE_X = *+$0001           ; at the original values they have before
        LDX #$00
        BOTTOM_STORE_Y = *+$0001           ; IRQ call
        LDY #$00         
    .ELSE ; JMP $EA31/$EA81
        JMP BOTTOM_KERNAL_IRQ              ; Use normal Kernal C64 IRQ exit code if Kernal is ON 
    .ENDIF

IRQ_RTI:
    RTI                                 ; ReTurn from Interrupt 

