;******************************************************************************
;Archivo: Laboratorio6.s
;Dispositivo: PIC16F887
;Autor: Ana Barrientos
;Carnet: 19060
;Compilador: pic-as (v2.30), MPLABX v5.40
;******************************************************************************
PROCESSOR 16F887 // Para indicar que microprocesador es 
    
#include <xc.inc> ;Sirve para definir los registros
#include "Macros_proyecto1.s"
    
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
PSECT udata_bank0 ;PSECT = sección del programa
    unidades_v1:	    DS 1;1 byte
    decenas_v1:		    DS 1;1 byte
    unidades_v2:	    DS 1;1 byte
    decenas_v2:		    DS 1;1 byte
    unidades_v3:	    DS 1;1 byte
    decenas_v3:		    DS 1;1 byte
    unidades_v4:	    DS 1;1 byte
    decenas_v4:		    DS 1;1 byte
    var_display_1:	    DS 1;1 byte
    var_display_2:	    DS 1;1 byte
    var_display_3:	    DS 1;1 byte
    var_display_4:	    DS 1;1 byte
    var_display_5:	    DS 1;1 byte
    var_display_6:	    DS 1;1 byte
    var_display_7:	    DS 1;1 byte
    var_display_8:	    DS 1;1 byte
    var_dec1:		    DS 1;1 byte
    var_dec2:		    DS 1;1 byte
    var_dec3:		    DS 1;1 byte
    dec_ledverde:	    DS 1;1 byte
    var_A:		    DS 1;1 byte
    TV1:		    DS 1;1 byte
    TV2:		    DS 1;1 byte
    TV3:		    DS 1;1 byte
    verde_v1:		    DS 1;1 byte
    amarillo_v1:	    DS 1;1 byte
    rojo_v1:		    DS 1;1 byte
    verde_v2:		    DS 1;1 byte
    amarillo_v2:	    DS 1;1 byte
    rojo_v2:		    DS 1;1 byte
    verde_v3:		    DS 1;1 byte
    amarillo_v3:	    DS 1;1 byte
    rojo_v3:		    DS 1;1 byte
PSECT udata_shr ;memoria compartida, variables para interrupciones
    W_TEMP:	    DS 1 ;1 byte
    STATUS_TEMP:    DS 1 ;1 byte
    flag_sel:	    DS 1 
    #define	    disp  0
    #define	    time  1
    #define	    cero  2
    flag:	    DS 1 ;8 banderas
    #define	    flag_dis1 0
    #define	    flag_dis2 1
    #define	    flag_dis3 2
    #define	    flag_dis4 3
    #define	    flag_dis5 4
    #define	    flag_dis6 5
    #define	    flag_dis7 6
    #define	    flag_dis8 7
    bandera:	    DS	1 ;8 banderas
    #define	    estado_1	 0
    #define	    estado_2	 1
    #define	    estado_3	 2
    #define	    parpadeo	 3
    #define	    amarillo	 4
    #define	    led_verdet	 5
    #define	    int_verde_t  6
    
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
    btfsc   T0IF
    goto    t0_int
    btfsc   TMR2IF
    goto    t2_int
    btfsc   TMR1IF
    goto    t1_int
    
    
    
pop:
    swapf   STATUS_TEMP,W   ;Regresa registro STATUS original a W
    movwf   STATUS	    ;Mueve w al registro STATUS.
    swapf   W_TEMP,F	    ;Le da la vuelta a w_temp y lo guarda en él 
    swapf   W_TEMP,W	    ;Lo regresa al original y lo guarda en W
    retfie		    ;Regreso de la interrupcion
 ;-------------------------Subrutinas de interrupción-------------------- 
t0_int:
    bsf		flag_sel,disp   ;Se pone en 1 cuando hay interrupció
    movlw	246		;valor de 1ms
    movwf	TMR0		;Valor inicial para el tmr0
    bcf		T0IF		;Clear inicial para la bandera
    goto	isr 
    
t1_int:
    ;Valor inicial para el tmr1: TMR1H y TMR1L
    banksel	PORTA
    ;bcf		STATUS,2	;Limpia la bandera de cero
    decf	var_dec1,F
    decf	var_dec2,F
    decf	var_dec3,F
    ;Bandera status zero
    btfsc	STATUS,2
    bsf		flag_sel,cero
    movlw	0xC2	
    movwf	TMR1H	    ;Le carga 1100 0010 a los bits más significativos
    movlw	0xF7
    movwf	TMR1L	    ;Le carga 1111 0111 a los bits menos significativos
    bcf		PIR1, 0	    ;limpia la bandera del timer1
    goto	isr

t2_int:
    clrf	TMR2		    ;limpia el tmr2
    decf	dec_ledverde,F	    ;incrementa la variable para la led verde
    btfsc	STATUS,2
    goto	apagar
    goto	encender
    apagar:
    bcf		bandera,int_verde_t
    goto	fin_t2_int
    encender:	
    bsf		bandera,int_verde_t
    bsf		PORTD,7
    fin_t2_int:
    bcf		TMR2IF	    ;apaga la bandera del timer 2
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
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    bcf	    PORTE,0
    bcf	    PORTB,3
    bcf	    PORTB,4
    bcf	    PORTB,5
    bcf	    PORTB,7
    bsf	    PORTB,0 
    bsf	    PORTB,1
    bsf	    PORTB,2
    
    banksel PORTA	;De regreso a banco 0
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC	;Para un clear inicial en los pines
    clrf    PORTD
    clrf    PORTE
    clrf    flag		;Limpiar variable banderas
    clrf    TV1
    clrf    TV2
    clrf    TV3
    clrf    var_dec1
    clrf    var_dec2
    clrf    var_dec3
    clrf    flag_sel
    clrf    dec_ledverde
    clrf    var_A
    bsf	    flag,flag_dis1
    bsf	    bandera,estado_1
    call    tiempos_vias
    config_reloj
    call    config_tmr1_temporizador
    call    config_int_tmr1
    call    config_tmr2_temporizador
    call    config_int_tmr2
    call    config_tmr0_temporizador
    call    config_int_tmr0
    
;-----------------------------Loop principal-----------------------------
loop:  
    
    call	Estados
    btfsc	flag_sel,disp
    goto	seleccionar_displays ;ponerlo en una subrutina aparte
    goto	loop
      
;----------------------------sub rutinas-----------------------------------
config_tmr0_temporizador:
    banksel	TRISA
    bcf		OPTION_REG, 5	  ;Reloj interno para el temporizador
    bcf		OPTION_REG, 3	  ;Preescaler para tmr0
    bsf		PS2
    bcf		PS1
    bsf		PS0		  ;Prescaler de 64 (1 0 1)
    reinicio_tmr0
    return
    
config_int_tmr0:
    ;bsf	    INTCON, 7	;Habilitar todas las interrupciones
    bsf		T0IE	    ;Habilitar interrupción tmr0
    bcf		T0IF	    ;Limpiar bandera del tmr0
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
    movwf	PR2	    ;PR2 = 122, tiempo de 250 ms
    return
    
config_int_tmr2:
    banksel	PIE1	    ;Banco 1
    bsf		PIE1,1	    ;Habilita la interrupción tmr2	
    return
    
tiempos_vias:
    ;Cargar valores 
    movlw   10
    movwf   TV1
    movwf   TV2
    movwf   TV3
    ;Realiza la operacion del tiempo para los displays
    movf    TV1,W		;W = TV1 = 10
    movwf   var_dec1		;Var_dec1 = 10 (via 1)
    movwf   var_dec2		;Var_dec2 = 10 (via 2)
    addwf   TV2,W		;W = TV1 + TV2 = 20		
    movwf   var_dec3		;Var_dec3 = 20
    ;Verde
    movlw   01001100B		;Verde v1, rojo v2, rojo v3
    movwf   PORTD 
    bcf     flag_sel,cero
    bcf	    bandera,parpadeo
    bcf	    bandera,amarillo
    return
    
Estados:
    bcf	    PORTA,6
    bcf	    PORTA,7		;Display gris en gris
    btfsc   bandera,estado_1
    goto    Estado_01
    goto    fin_estados
    ;goto    Estado_02
    
;-----------------------------------Estados-----------------------------------
Estado_01:
;Displays y leds v1 = verde (10 s), via 2 = rojo (10s), via 3 = rojo (20s)   
    btfss   flag_sel,cero	;Bandera reseteo
    goto    verde_t
    ;Carga valor a los displays
    bcf     flag_sel,cero
    bcf	    bandera,parpadeo
    bcf	    bandera,amarillo
    ;movlw   01001100B		;Verde v1, rojo v2, rojo v3
    ;movwf   PORTD  
    ;Var_dec = 6
    
    verde_t:
    movlw   6
    subwf   var_dec1,w
    btfsc   STATUS,2
    bsf	    bandera,parpadeo
    btfsc   bandera,parpadeo
    goto    verde_parpadeo_1
    
    revisar_amarillo:
    movlw   3
    subwf   var_dec1,W
    btfsc   STATUS,2
    bsf	    bandera,amarillo
    btfsc   bandera,amarillo
    goto    amarillo_1

fin_estados:    
return  
    
verde_parpadeo_1:
    bcf	    PORTE,2
;    btfsc   bandera,int_verde_t
;    goto    encender_1
;    goto    apagar_1
;    encender_1:
;    bsf	    PORTE,4
;    goto    fin_verde_parpadeo_1
;    apagar_1:
;    bcf	    PORTE,4
;    fin_verde_parpadeo_1:
     goto    revisar_amarillo
;       
amarillo_1:
    bcf	    bandera,parpadeo
    bcf	    PORTD,5
    movlw   01001010B
    movwf   PORTD
    bcf	    bandera,amarillo
    goto    fin_estados
    
seleccionar_displays:
    bcf	    flag_sel,disp	;apaga la bandera para selección
    clrf    PORTA		;limpia puerto d
    clrf    decenas_v1
    clrf    unidades_v1
    clrf    decenas_v2
    clrf    unidades_v2
    clrf    decenas_v3
    clrf    unidades_v3
    clrf    decenas_v4
    clrf    unidades_v4
    call    valores_division	;Realiza las divisiones para unidades/decenas	
    btfsc   flag,flag_dis1	;Revisa si el display 1 está encendido
    goto    display_2		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis2	;Revisa si el display 2 está encendido
    goto    display_3		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis3	;Revisa si el display 2 está encendido
    goto    display_4		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis4	;Revisa si el display 2 está encendido
    goto    display_5		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis5	;Revisa si el display 2 está encendido
    goto    display_6		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis6	;Revisa si el display 2 está encendido
    goto    display_7		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis7	;Revisa si el display 2 está encendido
    goto    display_8		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis8	;Revisa si el display 2 está encendido
    goto    display_1		;si está encendido,se enciende display 2
    goto    loop
    
display_2:
    movf    var_display_2,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,0		;encedemos el display 2
    bcf	    flag,flag_dis1	;Apaga la bandera del display 1
    bsf	    flag,flag_dis2	;Enciende la bandera display 2
    goto    loop
    
display_1:
    movf    var_display_1,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,1		;encedemos el display 1
    bcf	    flag,flag_dis8	;Apaga la bandera del display 2
    bsf	    flag,flag_dis1	;Enciende la bandera del display 1
    goto    loop    
display_3:
    movf    var_display_3,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,2		;encedemos el display 2
    bcf	    flag,flag_dis2	;Apaga la bandera del display 1
    bsf	    flag,flag_dis3	;Enciende la bandera display 2
    goto    loop
display_4:
    movf    var_display_4,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,3		;encedemos el display 2
    bcf	    flag,flag_dis3	;Apaga la bandera del display 1
    bsf	    flag,flag_dis4	;Enciende la bandera display 2
    goto    loop
display_5:
    movf    var_display_5,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,4		;encedemos el display 2
    bcf	    flag,flag_dis4	;Apaga la bandera del display 1
    bsf	    flag,flag_dis5	;Enciende la bandera display 2
    goto    loop
display_6:
    movf    var_display_6,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,5		;encedemos el display 2
    bcf	    flag,flag_dis5	;Apaga la bandera del display 1
    bsf	    flag,flag_dis6	;Enciende la bandera display 2
    goto    loop
       
display_7:
    movf    var_display_7,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,6		;encedemos el display 2
    bcf	    flag,flag_dis6	;Apaga la bandera del display 1
    bsf	    flag,flag_dis7	;Enciende la bandera display 2
    goto    loop
display_8:
    movf    var_display_8,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,7		;encedemos el display 2
    bcf	    flag,flag_dis7	;Apaga la bandera del display 1
    bsf	    flag,flag_dis8	;Enciende la bandera display 2
    goto    loop
    
valores_division:
    movf    var_dec1,W
    movwf   var_A
;--------------------------------- vía 1 -----------------------------------    
division_decenas_v1:
    movlw   10			 ;mover 10 a w 
    subwf   var_A,F		 ;var_A - 10, 4 - 10		    
    incf    decenas_v1,F	 ;incrementar decenas 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a decenas
    goto    division_decenas_v1	 ;Si no está encendida STATUS = 0, ir a decenas
    movlw   1
    subwf   decenas_v1,F	 ;Decenas = decenas - 1, 25
    movlw   10
    addwf   var_A,F		 ;A = 10 + A, A = 255, lo guarda en W = 10
    ;Convertir para display 2
    movf    decenas_v1,W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   var_display_2	;Regresa los bits modificados
    
division_unidades_v1:
    movlw   1
    subwf   var_A,F		 ;var_A - 1, el resultado lo guarda en A	    
    incf    unidades_v1,F	 ;incrementar variable unidades	 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a unidades
    goto    division_unidades_v1 ;Si no está encendida STATUS = 0, ir a unidades
    movlw   1
    subwf   unidades_v1,W	;Unidades = Unidades - 1
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   var_display_1		;Regresa los bits modificados

;----------------------------------- vía 2 -----------------------------------
    movf    var_dec2,W
    movwf   var_A		 ;Mover W a la variable, A = 4
division_decenas_v2:
    movlw   10			 ;mover 10 a w 
    subwf   var_A,F		 ;var_A - 10, 4 - 10		    
    incf    decenas_v2,F	 ;incrementar decenas 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a decenas
    goto    division_decenas_v2	 ;Si no está encendida STATUS = 0, ir a decenas
    movlw   1
    subwf   decenas_v2,F	 ;Decenas = decenas - 1, 25
    movlw   10
    addwf   var_A,F		 ;A = 10 + A, A = 255, lo guarda en W = 10
    ;Convertir para display 2
    movf    decenas_v2, W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   var_display_3		;Regresa los bits modificados
    
division_unidades_v2:
    movlw   1
    subwf   var_A,F		 ;var_A - 1, el resultado lo guarda en A	    
    incf    unidades_v2,F	 ;incrementar variable unidades	 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a unidades
    goto    division_unidades_v2 ;Si no está encendida STATUS = 0, ir a unidades
    movlw   1
    subwf   unidades_v2,W	;Unidades = Unidades - 1
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   var_display_4		;Regresa los bits modificados    
       
;--------------------------------via 3----------------------------------------
;movf    var_dec1,W
    movf    var_dec3,W
    movwf   var_A		    ;Mover W a la variable, A = 4

division_decenas_v3:
    movlw   10			 ;mover 10 a w 
    subwf   var_A,F		 ;var_A - 10, 4 - 10		    
    incf    decenas_v3,F	 ;incrementar decenas 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a decenas
    goto    division_decenas_v3	 ;Si no está encendida STATUS = 0, ir a decenas
    movlw   1
    subwf   decenas_v3,F	 ;Decenas = decenas - 1, 25
    movlw   10
    addwf   var_A,F		 ;A = 10 + A, A = 255, lo guarda en W = 10
    ;Convertir para display 2
    movf    decenas_v3, W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   var_display_5		;Regresa los bits modificados


division_unidades_v3:
    movlw   1
    subwf   var_A,F		 ;var_A - 1, el resultado lo guarda en A	    
    incf    unidades_v3,F	 ;incrementar variable unidades	 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a unidades
    goto    division_unidades_v3 ;Si no está encendida STATUS = 0, ir a unidades
    movlw   1
    subwf   unidades_v3,W	;Unidades = Unidades - 1
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   var_display_6		;Regresa los bits modificados   

;-------------------------------via 4-----------------------------------------
    movlw   10
    movwf   var_A		 ;Mover W a la variable, A = 4
division_decenas_v4:
    movlw   10			 ;mover 10 a w 
    subwf   var_A,F		 ;var_A - 10, 4 - 10		    
    incf    decenas_v4,F	 ;incrementar decenas 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a decenas
    goto    division_decenas_v4	 ;Si no está encendida STATUS = 0, ir a decenas
    movlw   1
    subwf   decenas_v4,F	 ;Decenas = decenas - 1, 25
    movlw   10
    addwf   var_A,F		 ;A = 10 + A, A = 255, lo guarda en W = 10
    ;Convertir para display 2
    movf    decenas_v4, W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   var_display_7		;Regresa los bits modificados

division_unidades_v4:
    movlw   1
    subwf   var_A,F		 ;var_A - 1, el resultado lo guarda en A	    
    incf    unidades_v4,F	 ;incrementar variable unidades	 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a unidades
    goto    division_unidades_v4 ;Si no está encendida STATUS = 0, ir a unidades
    movlw   1
    subwf   unidades_v4,W	;Unidades = Unidades - 1
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   var_display_8		;Regresa los bits modificados      
    return
    
 
   
    END  