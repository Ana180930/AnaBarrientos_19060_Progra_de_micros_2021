;******************************************************************************
;Archivo: Laboratorio6.s
;Dispositivo: PIC16F887
;Autor: Ana Barrientos
;Carnet: 19060
;Compilador: pic-as (v2.30), MPLABX v5.40
;******************************************************************************

PROCESSOR 16F887 // Para indicar que microprocesador es 
    
#include <xc.inc> ;Sirve para definir los registros
#include "Macros1.s"
    
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
    variable_inc:	    DS 1;1 byte
    unidades:		    DS 1;1 byte
    decenas:		    DS 1; 1 byte
    var_A:		    DS 1; 1 byte
    var_B:		    DS 1; 1 byte
    cont_porta:		    DS 1; 1 byte
PSECT udata_shr ;memoria compartida, variables para interrupciones
    W_TEMP:	    DS 1 ;1 byte
    STATUS_TEMP:    DS 1 ;1 byte
    flag:	    DS 1 ;8 banderas
    #define	    flag_sel  0
    #define	    flag_dis1 1
    #define	    flag_dis2 2
    #define	    flag_timer2 3
    
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
    goto    t1_int
    btfsc   TMR2IF
    goto    t2_int
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
    ;Valor inicial para el tmr1: TMR1H y TMR1L
    banksel	PORTA
    incf	PORTA,F	    ;incrementar puerto A
    movlw	0xC2	
    movwf	TMR1H	    ;Le carga 1100 0010 a los bits más significativos
    movlw	0xF7
    movwf	TMR1L	    ;Le carga 1111 0111 a los bits menos significativos
    bcf		PIR1, 0	    ;limpia la bandera del timer1
    goto	isr

t2_int:
    clrf	TMR2	    ;limpia el tmr2
    banksel	PORTE
    incf	PORTE,F	    ;incrementa el puerto E
    bcf		TMR2IF	    ;apaga la bandera del timer 2
    bsf		flag,flag_timer2    ;enciende una bandera del timer2
    goto	isr

t0_int:
    movlw	225		;valor de 1ms
    movf	TMR0		;Valor inicial para el tmr0
    bcf		T0IF		;Clear inicial para la bandera
    bsf		flag,flag_sel   ;Se pone en 1 cuando hay interrupción
    goto	isr
    
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
    clrf    PORTB
    bcf	    PORTD, 0
    bcf	    PORTD, 1
    bcf	    PORTE, 0
    
    banksel PORTA	;De regreso a banco 0
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC	;Para un clear inicial en los pines
    clrf    PORTD
    clrf    PORTE
    clrf    flag		;Limpiar variable banderas
    bsf	    flag,flag_dis1	;encender bandera para display 1
    config_reloj
    call    config_tmr1_temporizador
    call    config_int_tmr1
    call    config_tmr2_temporizador
    call    config_int_tmr2
    call    config_tmr0_temporizador
    call    config_int_tmr0
;--------------------Loop principal----------------
loop:  
    btfsc	flag,flag_timer2
    call	apagar_displays
    btfsc	flag,flag_sel
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

config_tmr2_temporizador:
    banksel	T2CON	    ;Banco 0
    bsf		T2CON, 2    ;Timer2 bit on
    bsf		T2CON, 1    
    bcf		T2CON, 0    ;Prescaler de 16 (1 0)
    bsf		T2CON, 6
    bsf		T2CON, 5
    bsf		T2CON, 4
    bsf		T2CON, 3    ;Postcaler de 16 (1 1 1 1)
    bcf		PIR1, 1	    ;limpiar bandera timer 2
    banksel	PR2
    movlw	122	    ;w = 122
    movwf	PR2	    ;PR2 = 122
    return

config_int_tmr1:
    banksel	PIE1	    ;Banco 1
    bsf		PIE1,0	    ;Habilitar la interrupción del tmr1
    bsf		INTCON,6    ;Habilita las interrupciones perifericas
    bsf		INTCON,7    ;Habilita las interrupciones globales
    return
    
config_int_tmr2:
    banksel	PIE1	    ;Banco 1
    bsf		PIE1,1	    ;Habilita la interrupción tmr2	
    return

config_int_tmr0:
    bsf	    T0IE	;Habilitar interrupción tmr0
    bcf	    T0IF	;Limpiar bandera del tmr0
    return
      
seleccionar_displays:
    bcf	    flag,flag_sel	;apaga la bandera para selección
    clrf    PORTD		;limpia puerto d
    call    valores_division	;Realiza las divisiones
    call    cargar_valor	;Carga los bits ya modificados al portc	
    btfsc   flag,flag_dis1	;Revisa si el display 1 está encendido
    goto    display_2		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis2	;Revisa si el display 2 está encendido
    goto    display_1		;Si está enciendida, se enciende display 1
    goto    loop
    
display_2:
    movf    decenas,W		;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTD,0		;encedemos el display 2
    bcf	    flag,flag_dis1	;Apaga la bandera del display 1
    bsf	    flag,flag_dis2	;Enciende la bandera display 2
    goto    loop
    
display_1:
    movf    unidades,W		;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTD,1		;encedemos el display 1
    bcf	    flag,flag_dis2	;Apaga la bandera del display 2
    bsf	    flag,flag_dis1	;Enciende la bandera del display 1
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
    movf    PORTA, w		    ;Mover puerto A a W
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

apagar_displays:
    clrf    PORTE
    return
END   