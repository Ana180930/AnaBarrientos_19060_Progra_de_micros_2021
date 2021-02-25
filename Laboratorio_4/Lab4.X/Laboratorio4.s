;******************************************************************************
;Archivo: Laboratorio1.s
;Dispositivo: PIC16F887
;Autor: Ana Barrientos
;Carnet: 19060
;Compilador: pic-as (v2.30), MPLABX v5.40
;******************************************************************************

PROCESSOR 16F887 // Para indicar que microprocesador es 
    
#include <xc.inc> ;Sirve para definir los registros

;Configuration word 1
CONFIG FOSC=INTRC_NOCLKOUT // Oscilador interno sin salidas
CONFIG WDTE=OFF // WDT disabled (reinicio repetitivo del pic)
CONFIG PWRTE=ON // PWRT enabled (espera de 72ms al iniciar)
CONFIG MCLRE=OFF // El pin de MCLR se utiliza como I/O
CONFIG CP=OFF // Sin protección de código 
CONFIG CPD=OFF // Sin protección de datos
    
CONFIG BOREN=OFF // Sin reinicio cuándo el voltaje de alimentación baja a 4V
CONFIG IESO=OFF // Reinicio sin cambio de reloj de interno a externo
CONFIG FCMEN=OFF // Cambio de reloj externo a interno en caso de fallo 
CONFIG LVP=ON // Programación en bajo voltaje permitida

;Configuration word 2
CONFIG WRT=OFF // Protección de autoescritura por el programa desactivada
CONFIG BOR4V=BOR40V // Reinicio abajo de 4V, (BOR21V=2.1V)
   
PSECT udata_bank0 ;memoria común, PSECT = sección del programa
    W_TEMP:  DS 1 ;1 byte
    STATUS_TEMP:  DS 1		 ;mover las variables de interrupción
    display_push: DS 1
    cont_20ms:	  DS 1
PSECT resVect, class=CODE, abs, delta=2 ;abs = posición absoluta en donde se 
;------------------ vector resest -----------------
ORG 00h ;posición 0000h para el reset, ORG = ubicación dentro de un sector
resetVec:
    PAGESEL main ;salta a la página de main y si en caso estuviera lejos
		 ;con el goto regreso, el PAGESEL cambia de página.
    goto main

;------------------ Vector interrupción -----------------
PSECT vec_inte, class=CODE, delta=2, abs
ORG 04h		;Posición 0004h para el vector interrupción
push:
    movwf   W_TEMP	    ;Mueve el portB al registro W temporal
    swapf   STATUS,W  ;Le da la vuelta al STATUS sin alterarlo y lo guarda en W
    movwf   STATUS_TEMP	    ;Muevo el STATUS al reves a STATUS temporal

isr:			    ;Rutina de interrupción		    
    btfsc   RBIF    ;Revisa que interrupción esta realizando, con la bandera
    call    rbif_portb	 ;Si la bandera está encencida, ejecuta la instruc.
    ;movlw   1
    ;addwf   cont_20ms	    ;contador_ms + 1, contador_ms = 50
    ;btfs_   
pop:
    swapf   STATUS_TEMP,W   ;Regresa registro STATUS original a W
    movwf   STATUS	    ;Mueve w al registro STATUS.
    swapf   W_TEMP,F	    ;Le da la vuelta a w_temp y lo guarda en él 
    swapf   W_TEMP,W	    ;Lo regresa al original y lo guarda en W
    retfie		    ;Regreso de la interrupcion
;-------------------------Subrutinas de interrupción--------------------   
rbif_portb:
    banksel PORTB
    btfss   PORTB,1	    ;Revisa si se presiono el boton 1
    incf    PORTA,F	    ;Si se presiono, incrementa puerto A
    btfss   PORTB,2	    ;Si no se presiono, revisa el boton 2
    decf    PORTA,F	    ;Si se presiono, decrementa puerto A
    movf    PORTB,w	    ;lee el puerto b, si no se ha presionado
    bcf	    INTCON,0	    ;Apaga la bandera de la interrupción
    return
    
    
PSECT code, delta=2, abs ; delta = tamaño de cada instrucción
ORG 100h ;posición para el código 
 
tabla:
    clrf    PCLATH
    bsf	    PCLATH,0	;Posición 01 00h
    andlw   00001111B	;Para que no se pase de los 4 bits 
    addwf   PCL		;PCLATH = 01, PCL = 03h + 1h + W = 0   
    retlw   00111111B	;Display = 0
    retlw   00000110B	;Display = 1
    retlw   01011011B	;Display = 2
    retlw   01001111B	;Display = 3
    retlw   01100110B	;Display = 4
    retlw   01101101B	;Display = 5
    retlw   01111101B	;Display = 6
    retlw   00000111B	;Display = 7
    retlw   01111111B	;Display = 8
    retlw   01101111B	;Display = 9
    retlw   01110111B	;Display = A (10)
    retlw   01111100B	;Display = b (11)
    retlw   00111001B	;Display = c (12)
    retlw   01011110B	;Display = D (13)
    retlw   01111001B	;Display = E (14)
    retlw   01110001B	;Display = F (15)
    retlw   0x0 
;----------------------configuración----------------
main:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH	;pines digitales
    
    banksel TRISA
    bcf	    TRISA,0
    bcf	    TRISA,1
    bcf	    TRISA,2
    bcf	    TRISA,3
    clrf    TRISC
    clrf    TRISB
    clrf    TRISD	;Salidas
    bsf	    TRISB,1
    bsf	    TRISB,2	;Entradas
    
    banksel PORTA
    clrf    PORTB
    clrf    PORTC	;Para un clear inicial en los pines
    clrf    PORTD
    clrf    PORTA
    bsf	    INTCON, 7	;Habilitar todas las interrupciones
    
    call    config_reloj
    call    config_tmr0_temporizador
;--------------------Loop principal----------------
loop:
    call    pull_up  
    call    portb_int
    call    display_7
    goto    loop

;--------------------sub rutinas----------------------------
pull_up:	;HACER MACRO
    banksel	OPTION_REG	
    bcf		OPTION_REG, 7	;Habilita puerto individual para pull ups
    banksel	PORTB
    bsf		WPUB, 1		;Habilita resistencia pull up, bit 1
    bsf		WPUB, 2		;Habilita resistencia pull up, bit 2
    return 
    
portb_int:
    banksel	IOCB
    bsf		IOCB, 1		;Configuración para pin 1 como interrupción
    bsf		IOCB, 2		;Configuración para pin 2 como interrupción
    banksel	PORTB
    movf	PORTB,W		;Mueve registro a w, para comenzar a leerlo
    bcf		INTCON,0	;Por si la bandera está encendida
    bsf		INTCON,3	;Habilitar interrupción para los pines 1 y 2
    
    return

display_7:	    
    clrw
    movf    PORTA,W
    call    tabla
    movwf   PORTC
    return
    
config_reloj:	    
    banksel	OSCCON
    bcf		OSCCON,6
    bcf		OSCCON,5
    bsf		OSCCON,4	  ;Frecuencia de 
    bsf		OSCCON,0	  ;Oscilador interno
    return
    
config_tmr0_temporizador:   
    banksel	TRISA
    bcf		OPTION_REG, 5
    bcf		OPTION_REG, 3
    bsf		PS2
    bsf		PS1
    bsf		PS0
    
    ;banksel	PORTA
    ;movlw	134
    ;movf	TMR0
    ;bcf		T0IF	;Si en caso esta encendida apaga la bandera
    
    return

    
return