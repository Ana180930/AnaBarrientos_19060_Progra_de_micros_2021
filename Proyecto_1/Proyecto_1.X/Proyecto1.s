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
    unidades:		    DS 1; 1 byte
    decenas:		    DS 1; 1 byte
    var_A:		    DS 1; 1 byte
    var_B:		    DS 1; 1 byte
    cont_time:		    DS 1; 1 byte 
PSECT udata_shr ;memoria compartida, variables para interrupciones
    W_TEMP:	    DS 1 ;1 byte
    STATUS_TEMP:    DS 1 ;1 byte	 
    cont_250ms:	    DS 1
    cont_1s:	    DS 1
    flag_sel:	    DS 1 
    #define	    flag_sel_disp 0
    flag:	    DS 1 ;8 banderas
    #define	    flag_dis1 0
    #define	    flag_dis2 1
    #define	    flag_dis3 2
    #define	    flag_dis4 3
    #define	    flag_dis5 4
    #define	    flag_dis6 5
    #define	    flag_dis7 6
    #define	    flag_dis8 7
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
    btfsc   TMR1IF
    goto    t1_int	 ;Revisa bandera del tmr0
    btfsc   T0IF
    goto    t0_int
    
pop:
    swapf   STATUS_TEMP,W   ;Regresa registro STATUS original a W
    movwf   STATUS	    ;Mueve w al registro STATUS.
    swapf   W_TEMP,F	    ;Le da la vuelta a w_temp y lo guarda en él 
    swapf   W_TEMP,W	    ;Lo regresa al original y lo guarda en W
    retfie		    ;Regreso de la interrupcion

 ;-------------------------Subrutinas de interrupción--------------------  
t1_int:
    banksel	PORTA
    decf	cont_time,F	;decrementar variable cada 1s 
    movlw	0xC2
    movwf	TMR1H
    movlw	0xF7
    movwf	TMR1L
    bcf		PIR1, 0  
    goto	isr

t0_int:
    movlw	225		;valor de 1ms
    movf	TMR0		;Valor inicial para el tmr0
    bcf		T0IF		;Clear inicial para la bandera
    bsf		flag_sel,flag_sel_disp  ;Se pone en 1 cuando hay interrupción
    goto	isr 
       
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
    clrf    flag_sel		;Limpiar variable de seleccion
    clrf    flag		;Limpiar variable banderas
    bsf	    flag,flag_dis1	;encender bandera para display 1
    clrf    cont_time
    config_reloj
    call    config_tmr1_temporizador
    call    config_int_tmr1
    call    config_tmr0_temporizador
    call    config_int_tmr0
;--------------------Loop principal------------------------ 
loop:  
    btfsc	flag_sel,flag_sel_disp
    goto	seleccionar_displays
    goto	loop
      
;--------------------sub rutinas----------------------------  
config_tmr0_temporizador:
    banksel	TRISA
    bcf		OPTION_REG, 5	  ;Reloj interno para el temporizador
    bcf		OPTION_REG, 3	  ;Preescaler para tmr0
    bcf		PS2
    bcf		PS1
    bsf		PS0		  ;Prescaler de 4 (0 0 1)
    reinicio_tmr0
    return

config_tmr1_temporizador:
    banksel	T1CON	    ;Banco 0
    bcf		T1CON,1	    ;Oscilador interno 
    bsf		T1CON,5
    bsf		T1CON,4	    ;Prescaler 8 (1 1)
    bsf		T1CON,0	    ;Bit on activado
    clrf	TMR1L
    clrf	TMR1H	    ;Limpiar los registros
    movlw	0xC2	    ;Valor inicial para el TMR1
    movwf	TMR1H
    movlw	0xF7
    movwf	TMR1L	
    bcf		PIR1,0	    ;Limpiar bandera del timer 1
    return	

config_int_tmr1:
    banksel	PIE1	    ;Banco 1
    bsf		PIE1,0	    ;Habilitar la interrupción del tmr1
    bsf		INTCON,6    ;Habilita las interrupciones perifericas
    bsf		INTCON,7    ;Habilita las interrupciones globales
    return
    
config_int_tmr0:
    bsf	    T0IE	;Habilitar interrupción tmr0
    bcf	    T0IF	;Limpiar bandera del tmr0
    return   

seleccionar_displays:
    bcf	    flag,flag_sel	;apaga la bandera para selección
    clrf    PORTA		;limpia puerto d
    call    valores_division	;Realiza las divisiones
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
    goto    display_6		;Si está enciendida, se enciende display 1
    btfsc   flag,flag_dis6	;Revisa si el display 5 está encendido
    goto    display_7		;Si está enciendida, se enciende display 1
    btfsc   flag,flag_dis7	;Revisa si el display 5 está encendido
    goto    display_8		;Si está enciendida, se enciende display 1
    btfsc   flag,flag_dis8	;Revisa si el display 5 está encendido
    goto    display_1		;Si está enciendida, se enciende display 1
    
    goto    loop
    
display_2:
    movf    decenas,W	;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,0		;encedemos el display 2
    bcf	    flag,flag_dis1	;Apaga la bandera del display 1
    bsf	    flag,flag_dis2	;Enciende la bandera display 2
    goto    loop
    
display_1:
    movf    unidades,W	;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,1		;encedemos el display 1
    bcf	    flag,flag_dis5	;Apaga la bandera del display 5
    bsf	    flag,flag_dis1	;Enciende la bandera del display 1
    goto    loop

display_3:
    movf    decenas,W		;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,2		;encedemos el display 3
    bcf	    flag,flag_dis2	;Apaga la bandera del display 2
    bsf	    flag,flag_dis3	;Enciende la bandera del display 3
    goto    loop
    
display_4:
    movf    unidades,W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,3		;encedemos el display 4
    bcf	    flag,flag_dis3	;Apaga la bandera del display 3
    bsf	    flag,flag_dis4	;Enciende la bandera del display 4
    goto    loop

display_5:
    movf    decenas,W		;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,4		;encedemos el display 5
    bcf	    flag,flag_dis4	;Apaga la bandera del display 4
    bsf	    flag,flag_dis5	;Enciende la bandera del display 5
    goto    loop
    
display_6:
    movf    unidades,W		;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,5		;encedemos el display 5
    bcf	    flag,flag_dis5	;Apaga la bandera del display 4
    bsf	    flag,flag_dis6	;Enciende la bandera del display 5
    goto    loop    
    
display_7:
    movf    decenas,W		;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,6		;encedemos el display 5
    bcf	    flag,flag_dis6	;Apaga la bandera del display 4
    bsf	    flag,flag_dis7	;Enciende la bandera del display 5
    goto    loop    

display_8:
    movf    unidades,W		;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,7		;encedemos el display 5
    bcf	    flag,flag_dis7	;Apaga la bandera del display 4
    bsf	    flag,flag_dis8	;Enciende la bandera del display 5
    goto    loop
   
cargar_valor: 
   ;Convertir para display 2
    movf    decenas, W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   decenas		;Regresa los bits modificados
    ;Convertir para display 1
    movf    unidades, W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   unidades		;Regresa los bits modificados
    
    return    
    
valores_division:
    movlw   10100000B		    ;w = 10 decimal
    movwf   cont_time,F
    movf    cont_time,w		    ;Mover variable a W
    movwf   var_A		    ;Mover W a la variable, A = 255
    movlw   10			    
    movwf   var_B		    ;Variable B = 100
    movlw   0		
    movwf   decenas		    ;Variable decenas = 0    
    movlw   0
    movwf   unidades		    ;Variable unidades = 0
    
division_decenas:
    movlw   10
    movwf   var_B		 ;B = 10
    movf    var_B,W		 ;mover var_A a w 
    subwf   var_A,F		 ;var_A - var_B, el resultado lo guarda en A		    
    incf    decenas,F		 ;incrementar decenas 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a decenas
    goto    division_decenas	 ;Si no está encendida STATUS = 0, ir a decenas
    movlw   1
    subwf   decenas,F		 ;Decenas = decenas - 1, 25
    movlw   10
    addwf   var_A,F		 ;A = 10 + A, A = 255

division_unidades:
    movlw   1
    movwf   var_B		 ;B = 1
    movf    var_B,W		 ;mover var_A a w 
    subwf   var_A,F		 ;var_A - var_B, el resultado lo guarda en A	    
    incf    unidades,F		 ;incrementar variable unidades	 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a unidades
    goto    division_unidades	 ;Si no está encendida STATUS = 0, ir a unidades
    movlw   1
    subwf   unidades,F		 ;Unidades = Unidades - 1
    return    
    
    END
     