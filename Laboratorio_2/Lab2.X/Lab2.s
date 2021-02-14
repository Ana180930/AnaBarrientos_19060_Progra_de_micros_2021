;******************************************************************************
;Archivo: Lab_2.s
;Dispositivo: PIC16F887
;Autor: Ana Barrientos
;Carnet: 19060
;Compilador: pic-as (v2.30), MPLABX v5.40
;******************************************************************************

PROCESSOR 16F887    ;Indica que procesador se está utilizando
    
#include <xc.inc>   ;Incluye los registros 

;Configuration word 1
CONFIG FOSC=XT // Oscilador externo de cristal
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
    cont_small: DS 1 ;1 byte, DS = reserva de almacenamiento 
    cont_big:   DS 1
  
PSECT resVect, class=CODE, abs, delta=2
;------------------ vector resest-----------------
ORG 00h ;posición 0000h para el reset, ORG = ubicación dentro de un sector
resetVec:
    PAGESEL main ;salta a la página de main y si en caso estuviera lejos
		 ;con el goto regreso, el PAGESEL cambia de página.
    goto main

PSECT code, delta=2, abs 
ORG 100h ;posición para el còdigo en la memoria
;-----------------configuración de pines----------------
main:
    bsf	    STATUS, 5
    bsf	    STATUS, 6	;banco 3
    clrf    ANSEL	;pines digitales
    clrf    ANSELH
       
    
    bsf	    STATUS, 5 
    bcf	    STATUS, 6	;Banco 1
    clrf    TRISA	;Clear inicial para colocar los I/O
    clrf    TRISB
    bsf	    TRISB, 0	;Pin 0,portb como entrada
    bsf	    TRISB, 1	;Pin 1 portb como entrada
    bsf	    TRISB, 2	;Pin 2 portb como entrada
    bsf	    TRISB, 3	;Pin 3 portb como entrada
    bsf	    TRISB, 4	;Pin 4 portb como entrada
    bsf	    TRISA, 6	;Pin 6 porta como entrada
    bsf	    TRISA, 7	;Pin 7 porta como entrada
    
    bcf	    TRISA, 0	;Pin 0 porta como salida
    bcf	    TRISA, 1	;Pin 1 porta como salida
    bcf	    TRISA, 2	;Pin 2 porta como salida
    bcf	    TRISA, 3	;Pin 3 porta como salida
    bcf	    TRISC, 0	;Pin 0 portc como salida
    bcf	    TRISC, 1	;Pin 1 portc como salida
    bcf	    TRISC, 2	;Pin 2 portc como salida
    bcf	    TRISC, 3	;Pin 3 portc como salida
    bcf	    TRISD, 0	;Pin 0 portd como salida
    bcf	    TRISD, 1	;Pin 1 portd como salida
    bcf	    TRISD, 2	;Pin 2 portd como salida
    bcf	    TRISD, 3	;Pin 3 portd como salida    
    bcf	    TRISE, 0	;Pin 0 porte como salida
   
    bcf	    STATUS, 5	;regreso al banco 00
    bcf	    STATUS, 6
    clrf    PORTB
    clrf    PORTA
    clrf    PORTC	;Para un clear inicial en los pines
    clrf    PORTD
    clrf    PORTE
;--------------------Loop principal----------------
loop:
    clrw    ;Limpia el registro W
    btfsc   PORTB,0 ;Revisa si hay un 1 o un 0 en el pin 0 
    call    inc_cont1 ;Si hay un (1), llama a incrementar contador 1
    btfsc   PORTB,1 ;De lo contrario (0) revisa si hay un 1 o 0	en el pin 1
    call    dec_cont1 ;Si hay un (1), llama a decrementar contador 1
    btfsc   PORTB,2 ;De lo contrario (0) revisa si hay un 1 o 0 en el pin 2
    call    inc_cont2 ;Si hay un (1), llama a incrementar contador 2
    btfsc   PORTB,3 ;De lo contrario (0) revisa si hay un 1 o 0 en el pin 3
    call    dec_cont2 ;Si hay un (1), llama a decrementar contador 2
    btfsc   PORTB,4 ;De lo contrario (0) revisa si hay un 1 o 0 en el pin 4
    call    resultado ;Si hay un (1), llama a resultado
    goto    loop    ;De lo contrario (0) regresa al loop
      
;--------------------sub rutinas-------------------    
inc_cont1:  ;Operaciòn incrementar C1
    call    delay_big	;Para evitar el ruido al cambiar de voltaje 
    btfsc   PORTB, 0	;Revisa si hay un 1 o un 0 en el pin 0
    goto    inc_cont1	;Si hay un (1), regresa a inc_cont1
    incf    PORTC, 1	;Si hay un (0), incrementa el puerto C y lo guarda en F
 
    return  

dec_cont1:  ;Operaciòn incrementar C1
    call    delay_big	;Para evitar el ruido al cambiar de voltaje 
    btfsc   PORTB, 1	;Revisa si hay un 1 o un 0 en el pin 1
    goto    dec_cont1	;Si hay un (1), regresa a dec_cont1
    decf    PORTC, 1	;Si hay un (0), decrementa el puerto C y lo guarda en F
   
    return
    
inc_cont2:  ;Operaciòn incrementar C2
    call    delay_big	;Para evitar el ruido al cambiar de voltaje
    btfsc   PORTB, 2	;Revisa si hay un 1 o un 0 en el pin 2
    goto    inc_cont2	;Si hay un (1), regresa a inc_cont2
    incf    PORTA,1	;Si hay un (0), incrementa el puerto A y lo guarda en F
    return  

dec_cont2:  ;Operaciòn decrementar C2
    call    delay_big	;Para evitar el ruido al cambiar de voltaje
    btfsc   PORTB, 3	;Revisa si hay un 1 o un 0 en el pin 3
    goto    dec_cont2	;Si hay un (1), regresa a dec_cont2
    decf    PORTA, 1	;Si hay un (0), decrementa el puerto A y lo guarda en F
    return

resultado:  ;Operaciòn Resultado
    call    delay_big	;Para evitar el ruido al cambiar de voltaje
    btfsc   PORTB, 4	;Revisa si hay un 1 o un 0 en el pin 4
    goto    resultado	;Si hay un (0), regresa a resultado
    ;Carry
    btfsc   STATUS,0	;Revisa si hay un 1 o un 0 en el pin 0 del STATUS
    bsf	    PORTE, 0	;Si hay un (1), enciende el pin 0 del puerto E
    btfss   STATUS, 0	;Si hay un (0), revisa si está en 0
    bcf	    PORTE, 0	;Apaga el pin 0 del puerto E
    ;Suma
    movf    PORTC, 0	;Si hay un (1), mueve el puerto C a W
    addwf   PORTA, 0	;Suma el puerto C + el puerto A y lo guarda en W
    movwf   PORTD	;Mueve la suma a W y lo muestra en el puerto D
    
    return

delay_big:
    movlw   200		    ;valor inicial del contador 
    movwf   cont_big 
    call    delay_small	    ;rutina de delay 
    decfsz  cont_big, 1	    ;decrementar el contador 
    goto    $-2		    ;ejecutar dos líneas atras
    return 
    
delay_small:
    movlw   249		    ;valor inicial del contador 
    movwf   cont_small 
    decfsz  cont_small, 1   ;decrementar el contador 
    goto    $-1		    ;ejecutar línea anterior 
    return
    
return  




