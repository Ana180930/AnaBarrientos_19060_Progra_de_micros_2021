;******************************************************************************
;Archivo: Proyecto1.s
;Dispositivo: PIC16F887
;Autor: Ana Barrientos
;Carnet: 19060
;Compilador: pic-as (v2.30), MPLABX v5.40
;******************************************************************************

PROCESSOR 16F887 // Para indicar que microprocesador es 
    
#include <xc.inc> ;Sirve para definir los registros
#include "Macros.s"
    
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
    var_display_1:	    DS 1; 1 byte
    var_display_2:	    DS 1; 1 byte
    unidades:		    DS 1; 1 byte
    decenas:		    DS 1; 1 byte
    var_A:		    DS 1; 1 byte
    var_B:		    DS 1; 1 byte
    bits_low:		    DS 1; 1 byte
    bits_high:		    DS 1; 1 byte
    cont_port:		    DS 1; 1 byte 
PSECT udata_shr ;memoria compartida, variables para interrupciones
    W_TEMP:	    DS 1 ;1 byte
    STATUS_TEMP:    DS 1 ;1 byte	 
    cont_250ms:	    DS 1
    cont_1s:	    DS 1
    flag:	    DS 1 ;8 banderas
    #define	    flag_sel  0
    #define	    flag_dis1 1
    #define	    flag_dis2 2
    #define	    flag_dis3 3
    #define	    flag_dis4 4
    #define	    flag_dis5 5
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
    btfsc   T0IF	 ;Revisa bandera del tmr0
    goto
pop:
    swapf   STATUS_TEMP,W   ;Regresa registro STATUS original a W
    movwf   STATUS	    ;Mueve w al registro STATUS.
    swapf   W_TEMP,F	    ;Le da la vuelta a w_temp y lo guarda en él 
    swapf   W_TEMP,W	    ;Lo regresa al original y lo guarda en W
    retfie		    ;Regreso de la interrupcion

 ;-------------------------Subrutinas de interrupción--------------------  
t0if_timer:
    movlw	1	    
    addwf	cont_250ms,F	;Cont_250ms = 1 	
    reinicio_tmr0
    bsf		flag,flag_sel   ;Se pone en 1 cuando hay interrupción
    
    return
       
PSECT code, delta=2, abs ; delta = tamaño de cada instrucción
ORG 100h ;posición para el código 
 
tabla:
    clrf    PCLATH
    bsf	    PCLATH,0	;Posición 01 00h
    andlw   00001111B	;Para que no se pase de los 4 bits 
    addwf   PCL		;PCLATH = 01, PCL = 03h + 1h + W   
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
    retlw   0x0 
    retfie
;---------------------------configuración---------------------------------
main:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH	;pines digitales
    
    banksel TRISA	;Entradas/salidas
    clrf    PORTC
    clrf    PORTA
    clrf    PORTD
    bsf	    PORTB, 0
    bsf	    PORTB, 1
    bsf	    PORTB, 2
    bcf	    PORTB, 3
    bcf	    PORTB, 4
    bcf	    PORTB, 5
    bcf	    PORTB, 7
    bcf	    PORTE, 0
    banksel PORTA	;De regreso a banco 0
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC	;Para un clear inicial en los pines
    clrf    PORTD
    clrf    PORTE
    config_reloj
    call    config_interrup
    call    config_tmr0_temporizador
;--------------------Loop principal------------------------ 
loop:  
    call	temp_250ms
    
    goto	loop
      
;--------------------sub rutinas----------------------------
config_tmr0_temporizador:   
    banksel	TRISA
    bcf		OPTION_REG, 5	  ;Reloj interno para el temporizador
    bcf		OPTION_REG, 3	  ;Preescaler para tmr0
    bsf		PS2
    bsf		PS1
    bsf		PS0		;Prescaler de 256 (1 1 1)
    bsf		INTCON,5	;Habilitar interrupción tmr0
    reinicio_tmr0
    
    return

config_interrup:
    bsf	    INTCON, 7	;Habilitar todas las interrupciones
    ;bsf	    RBIE	;Habilitar interrupción portb
    bsf	    T0IE	;Habilitar interrupción tmr0
    bcf	    T0IF	;Limpiar bandera del tmr0
    return
    
temp_250ms:
    movlw	4  
    subwf	cont_250ms,W	;Revisa si el contador ya llego a 50
    btfsc	STATUS,2	;Si la resta es 0, ejecuta la instrucción
   	
    return 

seleccionar_displays:
    bcf	    flag,flag_sel	;apaga la bandera para selección
    clrf    PORTA		;limpia puerto de los transistores
    ;call    valores_division	;Realiza las divisiones
    call    cargar_valor	;Carga los bits ya modificados al portc	
    btfsc   flag,flag_dis1	;Revisa si el display 1 está encendido
    goto    display_2		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis2	;Revisa si el display 2 está encendido
    goto    display_3		;Si está enciendida, se enciende display 3
    btfsc   flag,flag_dis3	;Revisa si el display 3 está encendido
    goto    display_4		;Si está enciendida, se enciende display 4
    btfsc   flag,flag_dis4	;Revisa si el display 4 está encendido
    goto    display_5		;Si está enciendida, se enciende display 5
    btfsc   flag,flag_dis5	;Revisa si el display 5 está encendido
    goto    display_1		;Si está enciendida, se enciende display 1
    goto    loop


    
    
    
    END
     