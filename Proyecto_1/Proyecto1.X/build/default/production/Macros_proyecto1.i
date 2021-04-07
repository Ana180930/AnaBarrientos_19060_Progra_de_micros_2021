# 1 "Macros_proyecto1.s"
# 1 "<built-in>" 1
# 1 "Macros_proyecto1.s" 2
;-------------------Resistencias pull_up puerto B------------------------------
pull_ups macro
    banksel OPTION_REG
    bcf OPTION_REG, 7 ;Habilita puerto individual para pull ups
    banksel PORTB
    bsf WPUB, 0 ;Habilita resistencia pull up, bit 1
    bsf WPUB, 1 ;Habilita resistencia pull up, bit 2
    bsf WPUB, 2 ;Habilita resistencia pull up, bit 3
endm

;--------------------Configuración del oscilador para 10 ms--------------------
config_reloj macro
banksel OSCCON
    bcf OSCCON,6
    bsf OSCCON,5
    bsf OSCCON,4 ;Frecuencia de 500kHz

endm

;-------------------Configuracion del reinicio del tmr0------------------------
reinicio_tmr0 macro
banksel PORTA ;Va al banco 0 en donde se encuentra PORTA
    movlw 246 ;Valor inicial para el tmr0, 5 ms
    movwf TMR0
    bcf INTCON, 2 ;Limpia la bandera

endm

;-------------------------------Underflow y overflow-------------------------
Underflow01 macro
    movlw 9
    subwf tiempo_temp01,W
    btfsc STATUS,2
    movlw 20
    btfsc STATUS,2
    movwf tiempo_temp01

endm

Underflow02 macro
    movlw 9
    subwf tiempo_temp02,W
    btfsc STATUS,2
    movlw 20
    btfsc STATUS,2
    movwf tiempo_temp02

endm

Underflow03 macro
    movlw 9
    subwf tiempo_temp03,W
    btfsc STATUS,2
    movlw 20
    btfsc STATUS,2
    movwf tiempo_temp03

endm

Overflow01 macro
    movlw 21
    subwf tiempo_temp01,W
    btfsc STATUS,2
    movlw 10
    btfsc STATUS,2
    movwf tiempo_temp01

 endm

 Overflow02 macro
    movlw 21
    subwf tiempo_temp02,W
    btfsc STATUS,2
    movlw 10
    btfsc STATUS,2
    movwf tiempo_temp02

 endm

  Overflow03 macro
    movlw 21
    subwf tiempo_temp03,W
    btfsc STATUS,2
    movlw 10
    btfsc STATUS,2
    movwf tiempo_temp03

 endm

;----------------------------------Apagar banderas----------------------------
apagar_banderas macro



    bcf bandera02,3
    bcf bandera02,5
    bcf bandera02,4
endm
