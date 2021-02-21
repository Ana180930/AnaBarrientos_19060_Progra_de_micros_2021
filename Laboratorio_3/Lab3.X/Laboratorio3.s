;******************************************************************************
;Archivo: Lab3.s
;Dispositivo: PIC16F887
;Autor: Ana Barrientos
;Carnet: 19060
;Compilador: pic-as (v2.30), MPLABX v5.40
;******************************************************************************

PROCESSOR 16F887    ;Indica que procesador se está utilizando    
#include <xc.inc>   ;Incluye los registros 
    
;Configuration word 1
CONFIG FOSC=INTRC_NOCLKOUT //Oscilador interno
CONFIG WDTE=OFF // WDT disabled ("Perro guardian", reloj o contador)
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

PSECT udata_bank0 ;memoria común
    
PSECT resVect, class=CODE, abs, delta=2
;------------------ vector resest-----------------
ORG 00h ;posición 0000h para el reset, ORG = ubicación dentro de un sector
resetVec:
    PAGESEL main ;salta a la página de main y si en caso estuviera lejos
		 ;con el goto regreso, el PAGESEL cambia de página.
    goto main

PSECT code, delta=2, abs 
ORG 100h ;posición para el código en la memoria
tabla:
    clrf    PCLATH	;Clear inicial
    bsf	    PCLATH,0	;Posición 01 00h
    andlw   0x0F	;Para que no se pase de los 4 bits 
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
     
;-----------------configuración de pines----------------
main:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH	;pines digitales
    
    banksel TRISB
    bsf	    TRISB, 0	;Entradas
    bsf	    TRISB, 1
    bcf	    TRISC, 0
    bcf	    TRISC, 1
    bcf	    TRISC, 2	
    bcf	    TRISC, 3
    bcf	    TRISC, 4
    bcf	    TRISC, 5
    bcf	    TRISC, 6
    bcf	    TRISC, 7
    bcf	    TRISD, 0	;Salidas
    bcf	    TRISD, 1
    bcf	    TRISD, 2
    bcf	    TRISD, 3
    bcf	    TRISE, 0
    bcf	    TRISA, 0
    bcf	    TRISA, 1
    bcf	    TRISA, 2
    bcf	    TRISA, 3
    
    bcf	    STATUS, 5	;regreso al banco 00
    bcf	    STATUS, 6
    clrf    PORTB
    clrf    PORTC	;Para un clear inicial en los pines
    clrf    PORTD
    clrf    PORTE
    clrf    PORTA
    
    call    config_reloj 
    call    config_tmr0_temporizador
    
    banksel PORTB
  
 ;--------------------Loop principal----------------
loop:
   call    antirebote		;Pulsadores
   goto	   temp			;Contador tmr0
   goto	   loop	
         
;--------------------sub rutinas------------------------------------   
;-------------------------TMR0 temp---------------------------------
config_reloj:		    ;Configuración del oscilador
    banksel OSCCON
    bcf	  OSCCON,6	
    bsf	  OSCCON,5
    bsf	  OSCCON,4	    ;Frecuencia de 500KHz
    bsf	  SCS		    ;Oscilador interno
    
    return
    
    
config_tmr0_temporizador:   ;Configuración del TMR0 como temporizador
    banksel OPTION_REG
    bcf	    T0CS	;Reloj interno para el temporizador
    bcf	    PSA		;Prescaler para el tmr0
    bsf	    PS2		;Prescaler de 256 (1 1 1)
    bsf	    PS1
    bsf	    PS0
    banksel   PORTA
    movlw   12		;Mueve el valor de TMR0 encontrado a dicho registro
    movwf   TMR0
    bcf	    INTCON, 2	;Apaga la bandera 
  
    return

temp:				;Subrutina temporizador
    btfss   INTCON,2		;Revisa la bandera del tmr0
    goto    loop		;Si es (0) ejecuta la instrucción goto 		
    bcf	    PORTE, 0		;Si es (1) apaga la led de alarma
    call    alarma		;Llama la subrutina de llamada
    call    reinicio_tmr0_temp  ;Llama el reinicio del tmr0
    incf    PORTD, F		;Incrementa el puerto D
    
    goto    loop
  
reinicio_tmr0_temp:		;Subrutina reinicio tmr0
    banksel   PORTA		;Va al banco 0 en donde se encuentra PORTA    
    movlw   12	    ;Vuelve a mover la literal inicial para empezar de nuevo
    movwf   TMR0
    bcf	    INTCON, 2 
    
    return
;--------------------------------Display 7 seg------------------------------
antirebote:
    btfsc   PORTB,0		;Revisa si hay un 1 o un 0 en el pin 0 
    call    display_7_incr	;Si hay un (1) incrementar display
    btfsc   PORTB,1		;Si hay un (0) va a revisar el otro push
    call    display_7_decr	;Si hay un (1) decrementa display
  
    return			;Si hay un (0) regresa al loop
   
display_7_incr:			;Subrutina para incrementar display
    btfsc   PORTB,0		;Revisa si hay un 1 o un 0 en el pin 0
    goto    display_7_incr	;Si hay un (1) regresa al loop 
    incf    PORTA,1		;Si hay un (0) incrementa el puerto A
    movf    PORTA,W		;Mueve el puerto A a W
    call    tabla 		;Llama a tabla
    movwf   PORTC   ;Mueve la modificación de los bits a puerto C para display
 
    return
   
display_7_decr:			;Subrutina para decrementar display
    btfsc   PORTB,1		;Revisa si hay un 1 o un 0 en el pin 1
    goto    display_7_decr	;Si hay un (1) regresa al loop 
    decf    PORTA,1		;Si hay un (0) decrementa el puerto A
    movf    PORTA,W		;Mueve el puerto A a W
    call    tabla		;Llama a tabla
    movwf   PORTC   ;Mueve la modificación de los bits a puerto C para display
    
    return

alarma:				;Subrutina para la alarma
    movf    PORTA,W		;Mueve puerto D a W
    subwf   PORTD,W		;Resta puerto D con el puerto A
    btfsc   STATUS,2		;Revisa si el resultado de la resta es 0
    bsf	    PORTE, 0		;Enciende la led de la alarma
    btfsc   STATUS,2		;Vuelve a revisar el status 
    clrf    PORTD		;Reinicia el puerto D
    return
    

    
Return