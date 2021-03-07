;******************************************************************************
;Archivo: Laboratorio5.s
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
    centenas:		    DS 1; 1 byte
    var_A:		    DS 1; 1 byte
    var_B:		    DS 1; 1 byte
    bits_low:		    DS 1; 1 byte
    bits_high:		    DS 1; 1 byte
    cont_porta:		    DS 1; 1 byte
PSECT udata_shr ;memoria compartida, variables para interrupciones
    W_TEMP:	  DS 1 ;1 byte
    STATUS_TEMP:  DS 1 ;1 byte	 
    flag:	  DS 1 ;8 bites
    #define	  flag_sel  0
    #define	  flag_dis1 1
    #define	  flag_dis2 2
    #define	  flag_dis3 3
    #define	  flag_dis4 4
    #define	  flag_dis5 5
    
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
    btfsc   RBIF	    ;revisa la bandera del puerto B
    call    rbif_portb	    ;Si la bandera está encencida, ejecuta la instruc.
    btfsc   T0IF	    ;Revisa bandera del tmr0 
    call    t0if_timer
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
    
t0if_timer:
    reinicio_tmr0
    bsf	    flag,flag_sel   ;Se pone en 1 cuando hay interrupción
    
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
    retfie
;----------------------configuración----------------
main:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH	;pines digitales
    
    banksel TRISA	;Entradas/salidas
    clrf    TRISA
    clrf    TRISC
    bcf	    TRISD, 0
    bcf	    TRISD, 1
    bcf	    TRISD, 2
    bcf	    TRISD, 3
    bcf	    TRISD, 4
    bsf	    TRISB, 1
    bsf	    TRISB, 2
    call    config_interrup
    
    banksel PORTA	;De regreso a banco 0
    clrf    PORTB
    clrf    PORTC	;Para un clear inicial en los pines
    clrf    PORTD
    clrf    PORTA
    clrf    flag	;Limpiar variable banderas
    bsf	    flag,flag_dis1	;encender bandera para display 1
    
    
    pull_ups		;Macros
    config_reloj
    call    config_tmr0_temporizador
    call    config_interrup
    portb_int
;--------------------Loop principal----------------
loop:  
    btfsc	flag,flag_sel
    goto	seleccionar_displays
    goto	loop
      
;--------------------sub rutinas----------------------------   
config_tmr0_temporizador:  
    banksel	TRISA
    bcf		OPTION_REG, 5	  ;Reloj interno para el temporizador
    bcf		OPTION_REG, 3	  ;Preescaler para tmr0
    bsf		PS2
    bcf		PS1
    bsf		PS0		  ;Prescaler de 64 (1 0 1)
    reinicio_tmr0
    return

config_interrup:
    bsf	    INTCON, 7	;Habilitar todas las interrupciones
    bsf	    RBIE	;Habilitar interrupción portb
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
    goto    display_3		;Si está enciendida, se enciende display 3
    btfsc   flag,flag_dis3	;Revisa si el display 3 está encendido
    goto    display_4		;Si está enciendida, se enciende display 4
    btfsc   flag,flag_dis4	;Revisa si el display 4 está encendido
    goto    display_5		;Si está enciendida, se enciende display 5
    btfsc   flag,flag_dis5	;Revisa si el display 5 está encendido
    goto    display_1		;Si está enciendida, se enciende display 1
    goto    loop
    
display_2:
    movf    var_display_2,W	;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTD,1		;encedemos el display 2
    bcf	    flag,flag_dis1	;Apaga la bandera del display 1
    bsf	    flag,flag_dis2	;Enciende la bandera display 2
    goto    loop
    
display_1:
    movf    var_display_1,W	;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTD,0		;encedemos el display 1
    bcf	    flag,flag_dis5	;Apaga la bandera del display 5
    bsf	    flag,flag_dis1	;Enciende la bandera del display 1
    goto    loop

display_3:
    movf    unidades,W		;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTD,2		;encedemos el display 3
    bcf	    flag,flag_dis2	;Apaga la bandera del display 2
    bsf	    flag,flag_dis3	;Enciende la bandera del display 3
    goto    loop
    
display_4:
    movf    decenas,W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTD,3		;encedemos el display 4
    bcf	    flag,flag_dis3	;Apaga la bandera del display 3
    bsf	    flag,flag_dis4	;Enciende la bandera del display 4
    goto    loop

display_5:
    movf    centenas,W		;Mover variable a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTD,4		;encedemos el display 5
    bcf	    flag,flag_dis4	;Apaga la bandera del display 4
    bsf	    flag,flag_dis5	;Enciende la bandera del display 5
    goto    loop
       
cargar_valor:
    movf    PORTA,W		;Mueve el puerto A a W
    movwf   cont_porta		;Luego lo mueve a mi variable cont porta
    movwf   bits_low		;Mueve w a la variable bits_low
    swapf   bits_low,W		;Intercambio los nibbles y los guardo.
    movwf   bits_high
    
    ;Convertir los bits
    movf    bits_low,W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla		
    movwf   var_display_1	;Regresa los bits modificados
    movf    bits_high,W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   var_display_2	;Regresa los bits modificados
    ;Convertir para display 3
    movf    unidades, W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   unidades		;Regresa los bits modificados
    ;Convertir para display 4
    movf    decenas, W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   decenas		;Regresa los bits modificados
    ;Convertir para display 5
    movf    centenas, W		;Mueve la variable a W
    andlw   00001111B		;Agrega los bits menos significativos a w
    call    tabla
    movwf   centenas		;Regresa los bits modificados
    
    return
   
valores_division:
    movf    PORTA, w		    ;Mover puerto A a W
    movwf   var_A		    ;Mover W a la variable 
    movlw   100		    
    movwf   var_B		    ;Variable B = 100
    movlw   0
    movwf   centenas		    ;Variable centenas = 0
    movlw   0		
    movwf   decenas		    ;Variable decenas = 0    
    movlw   0
    movwf   unidades		    ;Variable unidades = 0
    
division_centenas:
    movf    var_B,W		 ;mover var_A a w 
    subwf   var_A,F		 ;var_A - var_B, el resultado lo guarda en A    
    incf   centenas,F		 ;incrementar centenas	 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a centenas
    goto    division_centenas	 ;Si no está encendida STATUS = 0, ir a decenas
    movlw   1
    subwf   centenas,F		 ;Centenas = centenas - 1
    movlw   100
    addwf   var_A,F		 ;A = 100 + A
    
division_decenas:
    movlw   10
    movwf   var_B		 ;B = 10
    movf    var_B,W		 ;mover var_A a w 
    subwf   var_A,F		 ;var_A - var_B, el resultado lo guarda en A		    
    incf    decenas,F		 ;incrementar decenas 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a centenas
    goto    division_decenas	 ;Si no está encendida STATUS = 0, ir a decenas
    movlw   1
    subwf   decenas,F		 ;Centenas = centenas - 1
    movlw   10
    addwf   var_A,F		 ;A = 10 + A

division_unidades:
    movlw   1
    movwf   var_B		 ;B = 1
    movf    var_B,W		 ;mover var_A a w 
    subwf   var_A,F		 ;var_A - var_B, el resultado lo guarda en A	    
    incf    unidades,F		 ;incrementar variable unidades	 
    btfsc   STATUS,0		 ;Si está encendida STATUS = 1, ir a unidades
    goto    division_unidades	 ;Si no está encendida STATUS = 0, ir a decenas
    movlw   1
    subwf   unidades,F		 ;Unidades = Unidades - 1
    return
END