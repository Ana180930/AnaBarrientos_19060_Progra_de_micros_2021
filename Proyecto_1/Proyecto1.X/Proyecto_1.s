;******************************************************************************
;Archivo: Proyecto_1.s
;Dispositivo: PIC16F887
;Autor: Ana Barrientos
;Carnet: 19060
;Compilador: pic-as (v2.30), MPLABX v5.40
;******************************************************************************
PROCESSOR 16F887 // Para indicar que microprocesador es 
#include <xc.inc> 
#include "Proyecto_1.s"
    
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
    cont_1s:		    DS 1;1 byte
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
    var_disp_gris:	    DS 1;1 byte
    tiempo_temp01:	    DS 1;1 byte
    tiempo_temp02:	    DS 1;1 byte
    tiempo_temp03:	    DS 1;1 byte
PSECT udata_shr ;memoria compartida, variables para interrupciones
    W_TEMP:	    DS 1 ;1 byte
    STATUS_TEMP:    DS 1 ;1 byte
    flag_sel:	    DS 1 
    #define	    disp    0
    #define	    time    1
    #define	    cero    2
    #define	    paso01  3
    #define	    paso02  4
    #define	    gris    5    
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
    #define	    parpadeo01	 3
    #define	    parpadeo02	 4
    #define	    parpadeo03	 5
    #define	    amarillo	 6
    bandera02:	    
    #define	    int_verde_t1 0
    #define	    int_verde_t2 1
    #define	    int_verde_t3 2
    #define	    modos	 3
    #define	    decr	 4
    #define	    incr	 5
    #define	    modo4	 6
    #define	    modo5	 7
    bandera03:	    DS	1 ;8 banderas
    #define	    modo_01	0
    #define	    modo_02	1
    #define	    modo_03	2
    
    
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
    btfsc   T0IF	    ;Revisa las banderas de interrución timer 1,2 y 0
    goto    t0_int
    btfsc   RBIF	    ;Revisa bandera del puerto b
    goto    rbif_portb
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
    decf	var_dec1,F	;Decrementa la variable via 1    
    decf	var_dec2,F	;Decrementa la variable via 2
    decf	var_dec3,F	;Decrementa la variable via 3
    ;Bandera status zero
    btfsc	STATUS,2	;Revisa la bandera de cero
    bsf		flag_sel,cero	;Si esta encendida, enciende una bandera reset
    movlw	0xC2	
    movwf	TMR1H	    ;Le carga 1100 0010 a los bits más significativos
    movlw	0xF7
    movwf	TMR1L	    ;Le carga 1111 0111 a los bits menos significativos
    bcf		PIR1, 0	    ;limpia la bandera del timer1
    goto	isr
    
rbif_portb:
    bcf		INTCON,0    ;Apaga la bandera de la interrupción
    btfss	PORTB,0	    ;Revisa si el botón modo está presionado
    bsf		bandera02,modos
    btfss	PORTB,1	    ;Revisa si el botón incrementar está presionado
    bsf		bandera02,incr
    btfss	PORTB,2
    bsf		bandera02,decr
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
    clrf    TRISA
    clrf    TRISC
    clrf    TRISD
;    clrf    PORTB
    bcf	    TRISE,0
    bcf	    TRISB,3
    bcf	    TRISB,4
    bcf	    TRISB,5
    bcf	    TRISB,7
    bsf	    TRISB,0 
    bsf	    TRISB,1
    bsf	    TRISB,2
    
    banksel PORTA	;De regreso a banco 0
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC	;Para un clear inicial en los pines
    clrf    PORTD
    clrf    PORTE
    clrf    flag	;Limpiar variable banderas
    clrf    bandera
    clrf    var_disp_gris
    clrf    tiempo_temp01
    clrf    tiempo_temp02
    clrf    tiempo_temp03
    clrf    bandera02
    clrf    bandera03
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
    bsf	    bandera03,modo01		;Enciende la bandera del modo 1
    call    tiempos_vias
    config_reloj			;Configuracion del oscilador
  
    pull_ups
    call    config_tmr1_temporizador	;Configuraciones de los timers
    call    config_int_tmr1		;Configuraciones de las interrupciones
    call    config_tmr0_temporizador
    call    config_int_tmr0
    call    config_io_portb
    
    
    
;-----------------------------Loop principal-----------------------------
loop:
    call	Botones
    call	Revisa_modos
    call	Estados
    btfsc	flag_sel,disp
    goto	seleccionar_displays 
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
    bsf		RBIE	    ;Habilitar interrupción portb
    return
    
config_tmr1_temporizador:
    banksel	T1CON	    ;Banco 0
    bcf		T1CON,1	    ;Oscilador interno 
    bsf		T1CON,5
    bsf		T1CON,4	    ;Prescaler 8 (1 1)
    bsf		T1CON,0	    ;Bit on activado
    clrf	TMR1L
    clrf	TMR1H	    ;Limpiar los registros
    movlw	0xC2	    ;Valor inicial para el TMR1 de 49911
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
    
config_io_portb:		;Configuración para interrupción portb
    banksel	IOCB
    bsf		IOCB, 0		;Configuración para pin 1 como interrupción
    bsf		IOCB, 1		;Configuración para pin 2 como interrupción
    bsf		IOCB, 2		;Configuración para pin 3 como interrupción
    banksel	PORTB
    movf	PORTB,W		;Mueve registro a w, para comenzar a leerlo
    bcf		INTCON,0	;Por si la bandera está encendida
    return
    
Botones:
    btfss   bandera02,modos	;Revisa si la bandera modos està encendida
    goto    boton_inc		;Si está encendida, va a revisar si se soltó 
    btfss   PORTB,0		;el botón demodos, sino va a incrementar
    goto    boton_inc
;---------------------------Instrucciones modos----------------------------
    btfsc   bandera03,modo_01	    ;Revisa si bandera modo 1 está encendida
    goto    activar_modo02	    ;Si está va a activar modo 02
    btfsc   bandera03,modo_02
    goto    activar_modo03
    btfsc   bandera03,modo_03
    goto    activar_modo04
    btfsc   bandera02,modo4
    goto    activar_modo05
    btfsc   bandera02,modo5
    goto    activar_modo01
    goto    fin_botones
    
    activar_modo01:
    bcf	    PORTB,3
    bcf	    PORTB,4
    bcf	    PORTB,5
    bcf	    PORTB,7
    bcf	    bandera02,modo5
    bsf	    bandera03,modo01
    apagar_banderas
    goto    fin_botones
    
   activar_modo02:
    bsf	    PORTB,3			;Enciende la led indicador via 1
    movf    TV1,W   
    movwf   tiempo_temp01		;Carga TV1 a variable temporal
    bcf	    bandera03,modo_01		;Apaga bandera modo 1
    bsf	    bandera03,modo_02		;Enciende bandera modo2
    apagar_banderas
    goto    fin_botones			;Regresa al loop
    
    activar_modo03:
    bcf	    PORTB,3
    bsf	    PORTB,4
    movf    TV2,W
    movwf   tiempo_temp02
    bcf	    bandera03,modo_02		;Apaga bandera modo 2
    bsf	    bandera03,modo_03		;Enciende bandera modo 3
    apagar_banderas
    goto    fin_botones
    
    activar_modo04:
    bcf	    PORTB,4
    bsf	    PORTB,5
    movf    TV3,W
    movwf   tiempo_temp03
    bcf	    bandera03,modo_03
    bsf	    bandera02,modo4
    apagar_banderas
    goto    fin_botones
    
    activar_modo05:
    bcf	    PORTB,5
    bsf	    PORTB,7
    bcf	    bandera02,modo4
    bsf	    bandera02,modo5
    apagar_banderas
    goto    fin_botones
    
    boton_inc:
    btfss   bandera02,incr
    goto    boton_dec
    btfss   PORTB, 1
    goto    boton_dec
;---------------------------------Instrucciones-------------------------------    
    btfsc   bandera03,modo_02
    goto    incModo2
    btfsc   bandera03,modo_03
    goto    incModo3
    btfsc   bandera02,modo4
    goto    incModo4
    btfsc   bandera02,modo5
    goto    guardar_valores
    goto    fin_botones
    
    incModo2:
    incf    tiempo_temp01,F
    Overflow01
    apagar_banderas
    goto    fin_botones
    
    incModo3:
    incf    tiempo_temp02,F
    Overflow02
    bcf		    bandera02,modos
    bcf		    bandera02,incr
    bcf		    bandera02,decr
    goto    fin_botones
    
    incModo4:
    incf    tiempo_temp03,F
    Overflow03
    bcf		    bandera02,modos
    bcf		    bandera02,incr
    bcf		    bandera02,decr
    goto    fin_botones
    
    guardar_valores:
    ;Reseteo
    movlw   01001001B
    movwf   PORTD
    btfsc   bandera02,modo5
    goto    reset_disp
    goto    continuar
    reset_disp:
    clrf    var_dec1
    clrf    var_dec2
    clrf    var_dec3
    continuar:
    clrf    TV1
    movf    tiempo_temp01,w
    movwf   TV1
    movf    tiempo_temp02,w
    movwf   TV2
    movf    tiempo_temp03,w
    movwf   TV3
    bcf	    bandera02,modo5
    bsf	    bandera03,modo_01
    bcf	    bandera,estado_2
    bcf	    bandera,estado_3
    bsf	    bandera,estado_1
    goto    fin_botones
    
   boton_dec:
    btfss   bandera02,decr
    goto    fin_botones
    btfss   PORTB, 1
    goto    fin_botones
;---------------------------------Instrucciones-------------------------------    
    btfsc   bandera03,modo_02
    goto    decModo2
    btfsc   bandera03,modo_03
    goto    decModo3
    btfsc   bandera02,modo4
    goto    decModo4
    btfsc   bandera02,modo5
    goto    cancelar
    goto    fin_botones
    
    decModo2:
    decf    tiempo_temp01,F
    Underflow01
    apagar_banderas
    goto    fin_botones
    
    decModo3:
    decf    tiempo_temp02,F
    Underflow02
    apagar_banderas
    goto    fin_botones
    
    decModo4:
    decf    tiempo_temp03,F
    Underflow03
    apagar_banderas
    goto    fin_botones
    
    cancelar:
    bcf	    PORTB,7
    bcf	    bandera02,modo5
    bsf	    bandera03,modo_01
    
    fin_botones:
    return
    
   
Revisa_modos:
    btfsc   bandera03,modo_01
    goto    Modo_1
    btfsc   bandera03,modo_02
    goto    Modo_2
    btfsc   bandera03,modo_03
    goto    Modo_3
    btfsc   bandera02,modo4
    goto    Modo_4
    btfsc   bandera02,modo5
    goto    Modo_5
    goto    fin_revisa_modos
    
    Modo_1:
  
    goto    fin_revisa_modos
    
    Modo_2:
    bcf	    PORTB,5
    movf    tiempo_temp01,W
    movwf   var_disp_gris
    goto    fin_revisa_modos
    
    Modo_3:
    movf    tiempo_temp02,W
    movwf   var_disp_gris
    goto    fin_revisa_modos
    
    Modo_4:
    movf    tiempo_temp03,W
    movwf   var_disp_gris
    goto    fin_revisa_modos
    
    Modo_5:
    
    
    fin_revisa_modos:
    return
    
tiempos_vias:
    ;Carga valores iniciales
    movlw   10
    movwf   TV1
    movwf   TV2
    movwf   TV3
    ;Realiza la operacion del tiempo para los displays
    ;-------------------------------vía -------------------------------------
    movf    TV1,W		;W = TV1 = 10
    movwf   var_dec1		;Var_dec1 = 10 (via 1)
    movwf   var_dec2		;Var_dec2 = 10 (via 2)
    addwf   TV2,W		;W = TV1 + TV2 = 20		
    movwf   var_dec3		;Var_dec3 = 20
    ;Verde
    movlw   01001100B		;Verde v1, rojo v2, rojo v3
    movwf   PORTD 
    bcf     flag_sel,cero
    movwf   PORTD		;Lo muestra en el puerto D
    bcf     flag_sel,cero	;Clear en las banderas 
    bcf	    bandera,parpadeo01
    bcf	    bandera,amarillo
    return
    
Estados:
    btfsc   bandera,estado_1	;Revisa si la bandera estado 1 está encendida
    goto    Estado_01		;Si está, va a estado 1 
    btfsc   bandera,estado_2	;Si no, revisa si la bandera estado 2 está enc.
    goto    Estado_02		;Si está, va a estado 2
    btfsc   bandera,estado_3	;Si no, revisa si la bandera estado 3 está ence.
    goto    Estado_03		;Si está, va a estado 3
    goto    fin_estados		;Si no, regresa al loop

;-----------------------------------Estados-----------------------------------
Estado_01:
;Displays y leds v1 = verde (10 s), via 2 = rojo (10s), via 3 = rojo (20s)   
    btfss   flag_sel,cero	;Bandera reseteo
    goto    verde_t01
    ;Carga valor a los displays
    movf    TV1,W		;W = TV1 = 10
    movwf   var_dec1		;Var_dec1 = 10 (via 1)
    movwf   var_dec2		;Var_dec2 = 10 (via 2)
    addwf   TV2,W		;W = TV1 + TV2 = 20		
    movwf   var_dec3		;Var_dec3 = 20
    ;LEDS vía 1
    movlw   01001100B		;Verde v1, rojo v2, rojo v3
    movwf   PORTD 
    bcf     flag_sel,cero	;apaga la bandera de reset 
    bcf	    bandera,parpadeo01	;Clear banderas
    bcf	    bandera,amarillo
    
    verde_t01:			;Verde titilante
    movlw   6			    
    subwf   var_dec1,w
    btfsc   STATUS,2		;Revisa si el display llegó a 6
    bsf	    bandera,parpadeo01	;Si llegó, enciende la bandera parpadeo
    btfsc   bandera,parpadeo01	;Si no, revisa la bandera 
    goto    verde_parpadeo_1	;Si la bandera está encendida va a la subrutina
    
    revisar_amarillo01:		;Amarillo
    movlw   3			
    subwf   var_dec1,W		;Revisa si el display llegó a 3
    btfsc   STATUS,2		;Si llegó, enciende la bandera amarillo
    bsf	    bandera,amarillo	
    btfsc   bandera,amarillo	;Si la bandera amarillo está encendida
    goto    amarillo_1		;Va a amarillo, si no va a revisar cero 01
    
    revisar_cero01:
    movlw   0
    subwf   var_dec1,W		;Revisa si el display llegó a 0
    btfsc   STATUS,2		;Si llegó, enciende la bandera de reset
    bsf	    flag_sel,cero	;Si no, revisa si la bandera reset esta encen.
    btfsc   flag_sel,cero	;Si está encendida, va a resetear el display
    goto    reset_1
    
Estado_02:
    ;Displays y leds v1 = verde (10 s), via 2 = rojo (10s), via 3 = rojo (20s)   
    btfss   flag_sel,cero	;Bandera reseteo
    goto    verde_t02
     ;Actuliza los valores y limpia banderas,registros
    movf    TV2,W	    ;poner valores de tv2, tv1 etc
    movwf   var_dec2	    ;Var_dec2 = TV2 = 10
    movwf   var_dec3	    ;Var_dec3 = TV2 = 10
    addwf   TV3,W	    ;Var_dec1 = TV2 + TV3 = 20
    movwf   var_dec1
    clrf    PORTD	    ;Limpia el puerto de las leds
    ;LEDS via 2: rojo v1 - verde v2 - rojo v3
    movlw   01100001B	    
    movwf   PORTD
    bcf	    flag_sel,cero	;Apaga la bandera de reset 
    bsf	    flag_sel,paso01	;Enciende una bandera de paso
    clrf    dec_ledverde
    
    verde_t02:
    btfsc   flag_sel,paso01	;Revisa si está encendida la bandera de paso
    goto    cargar_valor	;Si está, va a revisar si llegó a 6 el disp.
    goto    fin_estados		;Si no, regresa al loop
    cargar_valor:
    movlw   6			    
    subwf   var_dec2,w
    btfsc   STATUS,2		;Revisa si el display llegó a 6
    bsf	    bandera,parpadeo02	;Si llegó, enciende la bandera parpadeo
    btfsc   bandera,parpadeo02	;Si no, revisa la bandera 
    goto    verde_parpadeo_2	;Si la bandera está encendida va a la subrutina
    
    revisar_amarillo02:		;Amarillo
    movlw   3			
    subwf   var_dec2,W		;Revisa si el display llegó a 3
    btfsc   STATUS,2		;Si llegó, enciende la bandera amarillo
    bsf	    bandera,amarillo	
    btfsc   bandera,amarillo	;Si la bandera amarillo está encendida
    goto    amarillo_2		;Va a amarillo, si no va a cero 02
    
    revisar_cero02:
    movlw   0
    subwf   var_dec2,W		;Revisa si el display llegó a 0
    btfsc   STATUS,2		;Si llegó, enciende la bandera de reset
    bsf	    flag_sel,cero	;Si no, revisa si la bandera reset está encendi.
    btfsc   flag_sel,cero	;Si está encendida, va resetear
    goto    reset_2
 
Estado_03:
    ;Displays y leds v1 = verde (10 s), via 2 = rojo (10s), via 3 = rojo (20s)   
    btfss   flag_sel,cero	;Bandera reseteo
    goto    verde_t03
    ;Actuliza los valores y limpia banderas,registros
    movf    TV3,w		
    movwf   var_dec1		;Var_dec1 = TV3 = 10
    movwf   var_dec3		;Var_dec3 = TV3 = 10
    addwf   TV1,W		;Var_dec2 = TV3 + TV1 = 20
    movwf   var_dec2
    clrf    PORTD		;Limpia el puerto de las leds
    ;LEDS via 2: rojo v1 - verde v2 - rojo v3
    movlw   00001001B	    
    movwf   PORTD
    bsf	    PORTE,0
    bcf	    flag_sel,cero	;Apaga la bandera de reset 
    bsf	    flag_sel,paso02	;Enciende una bandera de paso
    clrf    dec_ledverde
 
    verde_t03:
    btfsc   flag_sel,paso02	;Revisa si está encendida la bandera de paso
    goto    cargar_valor01	;Si está, va a revisar si llegó a 6 el disp.
    goto    fin_estados		;Si no, regresa al loop
    cargar_valor01:
    movlw   6			    
    subwf   var_dec3,w
    btfsc   STATUS,2		;Revisa si el display llegó a 6
    bsf	    bandera,parpadeo03	;Si llegó, enciende la bandera parpadeo
    btfsc   bandera,parpadeo03	;Si no, revisa la bandera 
    goto    verde_parpadeo_3	;Si la bandera está encendida va a la subrutina
    
    revisar_amarillo03:		;Amarillo
    movlw   3			
    subwf   var_dec3,W		;Revisa si el display llegó a 3
    btfsc   STATUS,2		;Si llegó, enciende la bandera amarillo
    bsf	    bandera,amarillo	
    btfsc   bandera,amarillo	;Si la bandera amarillo está encendida
    goto    amarillo_3		;Va a amarillo, si no regresa
    
    revisar_cero03:
    movlw   0
    subwf   var_dec3,W		;Revisa si el display llegó a 0
    btfsc   STATUS,2		;Si llegó, enciende la bandera de reset
    bsf	    flag_sel,cero	;Si no, revisa si la bandera reset está encendi.
    btfsc   flag_sel,cero	;Si está encendida, va a reset 3
    goto    reset_3
    
    
fin_estados:    
return  
    
verde_parpadeo_1:
    btfsc   bandera02,int_verde_t1  ;Revisa la bandera parpadeo de la interrup.
    goto    encender_led01	  ;Si está encendida, enciende la led
    goto    apagar_led01	  ;Si no, apaga la led
    encender_led01:
    bsf	    PORTD,2
    goto    fin_subrutina01
    apagar_led01:
    bcf	    PORTD,2
    fin_subrutina01:
    goto    revisar_amarillo01	    ;Regresa a amarillo 01
     
amarillo_1:
    bcf	    bandera,parpadeo01	    ;Apaga la bandera de verde titilante	   
    bcf	    PORTD,5		    ;Apaga la led verde via 1
    movlw   01001010B		    ;Enciende la led amarilla, vía 1
    movwf   PORTD
    bcf	    bandera,amarillo	    ;Apaga la bandera de amarillo, via 1
    goto    revisar_cero01	    ;Regresa a cero 01

reset_1:
    bcf	    bandera,estado_1	    ;Apaga la bandera estado 1	
    bsf	    bandera,estado_2	    ;Enciende la bandera estado 2
    clrf    var_dec1
    clrf    var_dec2
    clrf    var_dec3		    ;Quita el valor anterior
    clrf    PORTD
    bcf	    bandera,parpadeo02
    bcf	    bandera,amarillo	    ;Apago la bandera de led amarillo
    goto    fin_estados		    ;Regresa al loop

verde_parpadeo_2:
    btfsc   bandera02,int_verde_t2  ;Revisa la bandera parpadeo de la interrup.
    goto    encender_led02	  ;Si está encendida, enciende la led
    goto    apagar_led02	  ;Si no, apago la led
    encender_led02:
    bsf	    PORTD,5
    goto    fin_subrutina02
    apagar_led02:
    bcf	    PORTD,5
    fin_subrutina02:
    goto    revisar_amarillo02	    ;Regresa a amarillo 02

amarillo_2:
    bcf	    bandera,parpadeo02	    ;Apaga la bandera de verde titilante	   
    bcf	    PORTD,5		    ;Apaga la led verde via 2
    movlw   01010001B		    ;Enciende la led amarilla, vía 2
    movwf   PORTD
    bcf	    bandera,amarillo	    ;Apaga la bandera de amarillo, via 1
    goto    revisar_cero02	    ;Regresa a cero 02
    
reset_2:
    bcf	    bandera,estado_2	    ;Apaga la bandera estado 2	
    bsf	    bandera,estado_3	    ;Enciende la bandera estado 3
    clrf    var_dec1
    clrf    var_dec2
    clrf    var_dec3		    ;Quita el valor anterior
    clrf    PORTD
    bcf	    bandera,parpadeo03
    bcf	    bandera,amarillo	    ;Apago la bandera de led amarillo
    goto    fin_estados		    ;Regresa al loop

verde_parpadeo_3:
    btfsc   bandera02,int_verde_t3 ;Revisa la bandera parpadeo de la interrup.
    goto    encender_led03	   ;Si está encendida, enciende la led
    goto    apagar_led03	   ;Si no, apago la led
    encender_led03:
    bsf	    PORTE,0
    goto    fin_subrutina02
    apagar_led03:
    bcf	    PORTE,0
    fin_subrutina03:
    goto    revisar_amarillo03	    ;Regresa a amarillo 02
    
amarillo_3:
    bcf	    bandera,parpadeo03	    ;Apaga la bandera de verde titilante	   
    bcf	    PORTE,0		    ;Apaga la led verde titilante de la via 3
    movlw   10001001B		    ;Enciende la led amarilla, vía 3
    movwf   PORTD
    bcf	    bandera,amarillo	    ;Apaga la bandera de amarillo
    goto    revisar_cero03	    ;Regresa a cero 03
    
reset_3:
    bcf	    bandera,estado_3	    ;Apaga la bandera estado 3	
    bsf	    bandera,estado_1	    ;Enciende la bandera estado 1
    clrf    var_dec1
    clrf    var_dec2
    clrf    var_dec3		    ;Quita el valor anterior
    clrf    PORTD
    bcf	    bandera,parpadeo01
    bcf	    bandera,amarillo	    ;Apago la bandera de led amarillo
    goto    fin_estados		    ;Regreso al loop
   
    
seleccionar_displays:
    bcf	    flag_sel,disp	   ;Apaga la bandera para selección
    clrf    PORTA		   ;Limpia puerto d
    clrf    decenas_v1		   ;Limpia las variables de division
    clrf    unidades_v1
    clrf    decenas_v2
    clrf    unidades_v2
    clrf    decenas_v3
    clrf    unidades_v3
    clrf    decenas_v4
    clrf    unidades_v4
    call    valores_division	;Realiza las divisiones para unidades/decenas	
    btfsc   flag,flag_dis8	;Revisa si el display 8 está encendido
    goto    display_1		;si está encendido,se enciende display 1
    btfsc   flag,flag_dis1	;Revisa si el display 1 está encendido
    goto    display_2		;si está encendido,se enciende display 2
    btfsc   flag,flag_dis2	;Revisa si el display 2 está encendido
    goto    display_3		;si está encendido,se enciende display 3
    btfsc   flag,flag_dis3	;Revisa si el display 3 está encendido
    goto    display_4		;si está encendido,se enciende display 4
    btfsc   flag,flag_dis4	;Revisa si el display 4 está encendido
    goto    display_5		;si está encendido,se enciende display 5
    btfsc   flag,flag_dis5	;Revisa si el display 5 está encendido
    goto    display_6		;si está encendido,se enciende display 6
    btfsc   flag,flag_dis6	;Revisa si el display 6 está encendido
    goto    display_7		;si está encendido,se enciende display 7
    btfsc   flag,flag_dis7	;Revisa si el display 7 está encendido
    goto    display_8		;si está encendido,se enciende display 8
    btfsc   flag,flag_dis8
    goto    display_1
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
    bcf	    flag,flag_dis8	;Apaga la bandera del display 8
    bsf	    flag,flag_dis1	;Enciende la bandera del display 1
    goto    loop    
    
display_3:
    movf    var_display_3,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,2		;encedemos el display 3
    bcf	    flag,flag_dis2	;Apaga la bandera del display 2
    bsf	    flag,flag_dis3	;Enciende la bandera display 3
    goto    loop
    
display_4:
    movf    var_display_4,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,3		;encedemos el display 4
    bcf	    flag,flag_dis3	;Apaga la bandera del display 3
    bsf	    flag,flag_dis4	;Enciende la bandera display 4
    goto    loop
    
display_5:
    movf    var_display_5,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,4		;encedemos el display 5
    bcf	    flag,flag_dis4	;Apaga la bandera del display 4
    bsf	    flag,flag_dis5	;Enciende la bandera display 5
    goto    loop
    
display_6:
    movf    var_display_6,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    bsf	    PORTA,5		;encedemos el display 6
    bcf	    flag,flag_dis5	;Apaga la bandera del display 5
    bsf	    flag,flag_dis6	;Enciende la bandera display 6
    goto    loop
       
display_7:
    movf    var_display_7,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    btfsc   bandera03,modo01
    goto    apagar_gris01
    goto    encender_gris01
    apagar_gris01:
    bcf	    PORTA,6
    goto    paso_banderas01
    encender_gris01:
    bsf	    PORTA,6		;encedemos el display 7
    paso_banderas01:
    bcf	    flag,flag_dis6	;Apaga la bandera del display 6
    bsf	    flag,flag_dis7	;Enciende la bandera display 7
    goto    loop
    
display_8:
    movf    var_display_8,W	;Mover variable cargada a W
    movwf   PORTC		;Cargamos el valor al puerto c
    btfsc   bandera03,modo01
    goto    apagar_gris02
    goto    encender_gris02
    apagar_gris02:
    bcf	    PORTA,7
    goto    paso_banderas02
    encender_gris02:
    bsf	    PORTA,7		;encedemos el display 8
    paso_banderas02:
    bcf	    flag,flag_dis7	;Apaga la bandera del display 7
    bsf	    flag,flag_dis8	;Enciende la bandera display 8
    goto    loop
    
valores_division:
    movf    var_dec1,W		;Carga el valor a los displays
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
    movwf   var_display_1	;Regresa los bits modificados
;----------------------------------- vía 2 -----------------------------------
    movf    var_dec2,W
    movwf   var_A		 ;Carga el valor a los displays
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
    movwf   var_display_3	;Regresa los bits modificados
    
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
    movwf   var_display_4	;Regresa los bits modificados    
       
;--------------------------------via 3----------------------------------------
    movf    var_dec3,W
    movwf   var_A		 ;Carga el valor a los displays
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
    movwf   var_display_5	;Regresa los bits modificados

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
    movwf   var_display_6	;Regresa los bits modificados   
;-------------------------------via 4-----------------------------------------
    movf    var_disp_gris,W	 
    movwf   var_A		 ;Carga el valor a los displays 7 y 8
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
    movwf   var_display_7	;Regresa los bits modificados

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
    movwf   var_display_8	;Regresa los bits modificados      
    return
    
 
   
    END