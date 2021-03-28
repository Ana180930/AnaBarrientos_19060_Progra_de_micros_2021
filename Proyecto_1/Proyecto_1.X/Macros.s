;-------------------Resistencias pull_up puerto B------------------------------
pull_ups macro 
    banksel	OPTION_REG	
    bcf		OPTION_REG, 7	;Habilita puerto individual para pull ups
    banksel	PORTB
    bsf		WPUB, 1		;Habilita resistencia pull up, bit 1
    bsf		WPUB, 2		;Habilita resistencia pull up, bit 2
endm

    
;--------------------Configuración del oscilador para 250ms --------------------
config_reloj macro
banksel	OSCCON
    bcf		OSCCON,6
    bsf		OSCCON,5    
    bsf		OSCCON,4	  ;Frecuencia de 500kHz
  
endm
 
    
;-------------------Configuracion del reinicio del tmr0------------------------
reinicio_tmr0 macro
banksel   PORTA	    ;Va al banco 0 en donde se encuentra PORTA    
    movlw   225	    ;Valor inicial para el tmr0, tiempo de 250ms
    movwf   TMR0
    bcf	    INTCON, 2 ;Limpia la bandera 
    
endm
 
    
;----------------Configuración para la interrupcion del puerto B --------------   
portb_int macro
    banksel	IOCB
    bsf		IOCB, 1		;Configuración para pin 1 como interrupción
    bsf		IOCB, 2		;Configuración para pin 2 como interrupción
    banksel	PORTB
    movf	PORTB,W		;Mueve registro a w, para comenzar a leerlo
    bcf		INTCON,0	;Por si la bandera está encendida
   
endm
;----------------------------Tiempo en vías----------------------------------
tiempo_vias macro
    movlw   10
    movwf   Tv1			    ;Tv1 = 10
    movlw   6			    ;w = 6
    subwf   Tv1,W		    ;Tv1 - w = 10 - 6 = 4s, guardo en W
    movwf   TIME_ACT
    movf    TIME_ACT,W
    movwf   var_A		    ;A = 4
    
    endm
    
