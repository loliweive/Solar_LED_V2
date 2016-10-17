;********************************************
;̫���ܵƹ��ĸ�ģʽ����ں�MCU��ʼ��������ʱ��ȫ��4Сʱ��Ϊģʽһ��4Сʱ��ʱ����������ģʽ��
;ģʽ�����ư���2Сʱ��2Сʱ��ʱ����������ģʽ��
;ģʽ������Ϩ��4Сʱ��4Сʱ��ʱ����������ģʽ��
;ģʽ�ģ���ȫ��2Сʱ��Ϩ�𣬵ȴ�̫���ܰ��ж�MCU��Դ
;********************************************

          #include "HC18P013.inc"
          #include "reg.inc"
          list p = 18P013, R=DEC
;********************************************
;               RAM  START                  
;******************************************** 
;;;;;;;;;;;;;;;4M 2T


          DATA	
;;CONST          
#Define PORTA_INI	b'00000000'	; PORTA�˿ڳ�ֵ 
#Define PORTB_INI	b'00100000'	; PORTB�˿ڳ�ֵ  

#Define TRISA_INI	b'00000000'	; PORTA�����ֵ  0 ��� 1����
#Define TRISB_INI	b'11011111'	; PORTB�����ֵ

#Define PHCON_INI	b'11111111'	; ���� 0 ʹ�� 1��ֹ
#Define PDCON_INI	b'11111111'	; ���� 0 ʹ�� 1��ֹ 
#Define ODCON_INI	b'00000000'	; ��©���      1 ʹ�� 0��ֹ

#Define	OPTION_INI	b'10001000'	; X �������½��� T0ʱ��Դ T0������ѡ�� ��Ƶ������ T0Ԥ��Ƶ1:2
#DEFINE T0_INI	        109		; 8m2t��40us,160 instructions

#DEFINE	PCON_INI	B'10111000'     ;WDTʹ��   �ⲿint��ֹ	        
#DEFINE	IOCB_INI	B'00000000'     ;PB �жϺͻ��� 0 ��ֹ

#DEFINE	INTECON_INI	B'10000001'     ;WDTʹ��   �ⲿint��ֹ	 

;;;;;IO�ڶ���
#DEFINE PIN_PWM		PORTB,5

;---------------------------------------------------

#Define C_RAM_START		0x10
#Define C_RAM_END		0xC0

;RAM define here  ����ʹ��20~3f�ռ� 
MODE		EQU	0X20
CNT_10MS	EQU	0X21
CNT_2S		EQU	0X22
CNT_2MIN	EQU	0X23
FLAG_BYTE	EQU	0X24
#DEFINE		F_KEYLOCK_BIT	FLAG_BYTE,0
#DEFINE		F_2MS_BIT	FLAG_BYTE,1
#DEFINE		F_SLEEP_BIT	FLAG_BYTE,2
#define		F_10MS		FLAG_BYTE,3
#DEFINE		F_STATUS_ON	FLAG_BYTE,4
CNT_1H		EQU	0X25
CNT_40US	EQU	0X26
SET_TIME	EQU	0X27

PCLATH_TEMP	EQU       0X3D 
STATUS_TEMP     EQU       0X3E
W_TEMP          EQU       0X3F            
	

;********************************************
;               CODE START                  
;********************************************
        CODE

		ORG     0000H	
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP        
		GOTO    RESET        
                
		ORG     0008H  							
INTPROGRAM:		

	MOVWF	W_TEMP
	SWAPF	W_TEMP,F	; SAVE W
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	; SAVE STATUS
	;MOVF    PCLATH,W
	;MOVWF   PCLATH_TEMP	  
		
	BTFSS	T0IF		;40us
	GOTO	INT_EXIT
	BCF	T0IF
	
	MOVLW	T0_INI
	MOVWF	T0
	
PWM_OUTPUT:

	BTFSS	F_STATUS_ON
	GOTO	TIMEFLAG

	MOVLW	D'1'
	XORWF	MODE,W
	BTFSS	Z
	GOTO	TIMEFLAG
	
MODE1:

	;һ��ʱ��������ʾ2Сʱ
	MOVLW	B'00100000'
	XORWF	PORTB,F
;	GOTO	TIMEFLAG
	
TIMEFLAG:
	
	INCF	CNT_40US,F
	MOVLW	D'250'
	SUBWF	CNT_40US,W
	BTFSS	C
	GOTO	TIMEFLAG_END
	CLRF	CNT_40US		;10MS IS DUE,4h�İ汾��250-200-60-30,1min�İ汾��250-10-10-15
	BSF	F_10MS

TIMEFLAG_END:	
INT_EXIT:
        ;MOVF    PCLATH_TEMP,W
        ;MOVWF   PCLATH										
	SWAPF	STATUS_TEMP, W
	MOVWF	STATUS				;�ָ�STATUS
        SWAPF	W_TEMP, W			;�ָ�W		
	RETFIE			
;***************************************  	   
RESET:   
	CLRF    INTECON
	CLRF    INTFLAG
	CLRF	PCON    
	CLRWDT
 
;***************************************   
	
;***************************************      
;IO

	MOVLW	PORTA_INI
	MOVWF	PORTA
		
	MOVLW	TRISA_INI
	MOVWF	TRISA
		
	MOVLW	PORTB_INI
	MOVWF	PORTB

	MOVLW	TRISB_INI
	MOVWF	TRISB
	
	MOVLW	ODCON_INI
	MOVWF	ODCON	
	
	MOVLW	PHCON_INI
	MOVWF	PHCON	

	MOVLW	PDCON_INI
	MOVWF	PDCON
	
	MOVLW	IOCB_INI
	MOVWF	IOCB	
	
;***************************************	
;;;;;;CLRF RAM �Լ�
;;;;;
;;;;;#Define C_RAM_START	0x3f
;;;;;#Define C_RAM_END		0xd0
;;;;;        CLRF    TEMP_BUF
;;;;;	
;;;;;	MOVLW	C_RAM_START
;;;;;	MOVWF	FSR
;;;;;	
;;;;;_INI_RAM_Loop
;;;;;	CLRF	INDF
;;;;;	decf	FSR, F
;;;;;
;;;;;        MOVF    FSR,W
;;;;; ;       IORLW   C_RAM_END       ;�Ƚ�ʱ,��Ҫ��fsr�ĸ���λ��1,������������Թ�,�ճ���оƬû��!�����Լҵ�ʱ��!
;;;;;	XORLW	C_RAM_END        ;�Լ���ram��ʱ��,��ֵ��3f,����D0H,ֹͣ�Լ�,Ȼ���ٰ�D0H��һ��!D0H�൱����10h!��Ϊ����λ��1.
;;;;;	BTFSS	Z                ;�Լ���ram��ʱ��,��ֵ��10h,�жϵ�c0hֹͣ�Լ�,��������c0h,3f����,��һ�ͱ��c0h��,�൱��00h.
;;;;;	GOTO	_INI_RAM_Loop 
;;;;;	CLRF	INDF 
;;;;;	
;***************************************	
;CLRF RAM �Լ�
;#Define C_RAM_START		0x10
;#Define C_RAM_END		0xC0
        CLRF    0X07
	
	MOVLW	C_RAM_START
	MOVWF	FSR
	
_INI_RAM_Loop:
	CLRF	INDF
	INCF	FSR, F

        MOVF    FSR,W
	XORLW	C_RAM_END 
	BTFSS	Z         
	GOTO	_INI_RAM_Loop 
	
;***************************************	

;***************************************
;T0

	MOVLW	OPTION_INI		 
	MOVWF	OPTION

	MOVLW	T0_INI
	MOVWF   T0

	BCF	T0IF
	
	MOVLW	PCON_INI
	MOVWF	PCON
	
	MOVLW   INTECON_INI
	MOVWF   INTECON
	
	MOVLW	CONST_1_CONTINUE_TIME
	MOVWF	SET_TIME
	
	BSF	F_STATUS_ON
	
;������������������������������������������������������������������
;����ѭ��							 ��
;������������������������������������������������������������������
MAINLOOP:

	CLRWDT
	BTFSS	F_10MS
	GOTO	MAINLOOP
	BCF	F_10MS
	CALL	TIME_PROC
	GOTO	MAINLOOP
;*************************************************
;1MIN
;4HOURS
;*************************************************	
TIME_PROC:

	BTFSS	F_STATUS_ON
	GOTO	TIME_PROC_END
	
	INCF	CNT_10MS,F
	MOVLW	D'200'
	SUBWF	CNT_10MS,W
	BTFSS	C
	GOTO	TIME_PROC_END
	CLRF	CNT_10MS		;2S IS DUE
	INCF	CNT_2S,F
	MOVLW	D'60'
	SUBWF	CNT_2S,W
	BTFSS	C
	GOTO	TIME_PROC_END
	CLRF	CNT_2S			;2MIN IS DUE
	INCF	CNT_2MIN,F
	MOVLW	D'30'
	SUBWF	CNT_2MIN,W
	BTFSS	C
	GOTO	TIME_PROC_END
	CLRF	CNT_2MIN		;1H IS DUE
	INCF	CNT_1H,F
	MOVF	SET_TIME,W
	SUBWF	CNT_1H,W
	BTFSS	C
	GOTO	TIME_PROC_END
MODE_CHANGE:

	CLRF	CNT_1H
	MOVLW	D'3'
	XORWF	MODE,W
	BTFSC	Z
	GOTO	$+2
	GOTO	$+4
	BCF	F_STATUS_ON
	BCF	PIN_PWM
	GOTO	MAINLOOP
	
	INCF	MODE,F
	MOVLW	HIGH	MODE_TAB
	MOVWF	PCLATH
	MOVF	MODE,W	
MODE_TAB:

	ADDWF	PCL,F
	GOTO	TAB_MODE0	;ȫ��4С�r
	GOTO	TAB_MODE1	;����2С�r
	GOTO	TAB_MODE2	;Ϩ��4С�r
	GOTO	TAB_MODE3	;ȫ��2С�r���P��
	
TAB_MODE0:

	MOVLW	CONST_1_CONTINUE_TIME
	MOVWF	SET_TIME
	BSF	PIN_PWM
	GOTO	MAINLOOP
	
TAB_MODE1:

	MOVLW	CONST_2_CONTINUE_TIME
	MOVWF	SET_TIME
	GOTO MAINLOOP
	
TAB_MODE2:

	MOVLW	CONST_3_CONTINUE_TIME
	MOVWF	SET_TIME
	BSF	PIN_PWM
	GOTO MAINLOOP
	
TAB_MODE3:

	MOVLW	CONST_4_CONTINUE_TIME
	MOVWF	SET_TIME
	BSF	PIN_PWM
	GOTO MAINLOOP
	
TIME_PROC_END:

	return
		
;********************************************  
;********************************************
        ORG     03FFH                   ; ����Ĳ�����!        
        GOTO    RESET                           
        END


;********************************************
;               CODE END                    
;********************************************