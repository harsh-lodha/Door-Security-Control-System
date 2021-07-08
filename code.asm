#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#
#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#

#SI=0000h#
#DI=0000h#
#BP=0000h#
	;add your code here
	jmp     st1 ;size 3 bytes
    db     5 dup(0)
		 
    ;IVT entry for NMI (INT 02h), Physical address 00008h- ip and 0000A-CS
    dw     Nmi_24hrtimer
    dw     0000		 
    db     500 dup(0)
		 
	;IVT entry for 80H
	dw     Switch_intR
    dw     0000
	db     508 dup(0)
	st1:   cli 
	
	;Intialize ds,es,ss to start of RAM
    mov    ax,0200h    
    mov    ds,ax
    mov    es,ax
    mov    ss,ax
    mov    sp,0FFFEH
	
	;8255-1 , interfaced with LCD and keypad  
	A1 equ 00h
	B1 equ 02h
	C1 equ 04h
	CR1 equ 06h

	;8255-2 , interfaced with Darlington pair, Motor, LEDs, alarm and relay
	A2 equ 08H
	B2 equ 0Ah
	C2 equ 0Ch
	CR2 equ 0Eh
	
	;8253-1	, generates output frequencies of 50Hz and 0.5Hz
	clk_01 equ 10h
	clk_11 equ 12h
	clk_21 equ 14h
	CR3 equ 16h
		
	;8253-2	, 24hr timer rate generator and 1 min timer h/w retriggerable 1 shot timer
	clk_02 equ 18h
	clk_12 equ 1Ah
	clk_22 equ 1Ch
	CR4 equ 1Eh
	
; INITIALIZATION OF 8255
	sti	  	   
	mov al,88h	; control word for 8255-1 
	out CR1,al
	
	mov al,89h  	; control word for 8255-2 
	out CR2,al
	
; INITIALIZATION OF TIMERS
	mov al,36h	;control word for 8253-1 counter 0,mode 3	
	out CR3,al
	
	mov al,56h  ;control word for 8253-1 counter 1, mode 3
	out CR3,al
	
	mov al,92h  ;control word for 8253-1 counter 2, Mode 1
	out CR3,al 

	mov al,34h  ;control word for 8253-2 counter 0, Mode 2
	out CR4,al    

	mov al,5ah  ;control word for 8253-2 counter 1 , Mode 5
	out CR4,al    

	mov al,94h  ;control word for 8253-2 counter 2 ,Mode 2
	out CR4,al
	
; Loading counts in counters
	mov al,50h	;load count lsb for 8253-1 counter 0 | Count value = 50000(dec)
	out clk_01, al
	
	mov al,0C3h 	;load count msb for 8253-1 counter 0 
	out clk_01, al
	
	mov al,64h	;load count for 8253-1 counter 1 | Count value = 100(dec)
	out clk_11, al
	
	mov al,5h	;load count lsb for 8253-1 counter 2 (1 minute Timer) | Count value = 30(dec)
	out clk_21, al
	
	mov al,0C0h	;load count for 8253-2  LSB counter 0 (24 hour counter) | Count value =43200(dec)
	out clk_02, al
	
	mov al,0A8h	;load count for 8253-2  MSB counter 0      (24 hour counter)
	out clk_02,al
	
	mov al,3	;load count for 8253-2 counter 1 (Switch trigger counter) | Count value = 3(dec)
	out clk_12, al
	
	mov al,2	;load count for 8253-2 counter 2 | Count value = 2(dec)
	out clk_22, al
	
	mov al,00h 	;default low output from 8255-2 upper port C
	out C2, al
;INITIALIZATION OF 8255,8253 ENDS HERE
		
; LCD INITIALIZATION BEGINS
	call DELAY_20ms 
	mov al,04h
	out B1,al
	call DELAY_20ms
	mov al,00h
	out B1,al			
	
	mov al,38h;2 lines and 5×7 matrix
	out A1,al
	
	mov al,04h
	out B1,al
	call DELAY_20ms
	mov al,00h
	out B1,al
	call DELAY_20ms
	mov al,0Fh
	out A1,al
	mov al,04h
	out B1,al
	call DELAY_20ms
	mov al,00h
	out B1,al
	
	mov al,06h; shift cursor right
	out A1,al
	call DELAY_20ms
	mov al,04h
	out B1,al
	call DELAY_20ms
	mov al,00h
	out B1,al
	mov al,01h ;clear display screen
	out A1,al
	call DELAY_20ms 
; LCD INITIALIZATION ENDS	

	mov ax,0200h ;initialize DS
	mov ds,ax
	
;Hard coding master password : 0123456789012345	
	mov si,0000h
	mov al,0eeh	
	mov [si],al
	
	mov al,0edh
	mov [si+1],al
	
	mov al,0ebh
	mov [si+2],al
	
	mov al,0e7h
	mov [si+3],al
	
	mov al,0deh
	mov [si+4],al
	
	mov al,0ddh
	mov [si+5],al
	
	mov al,0dbh
	mov [si+6],al
	
	mov al,0d7h
	mov [si+7],al
	
	mov al,0beh
	mov [si+8],al
	
	mov al,0bdh
	mov [si+9],al
	
	mov al,0eeh
	mov [si+0ah],al
	
	mov al,0edh
	mov [si+0bh],al
	
	mov al,0ebh
	mov [si+0ch],al
	
	mov al,0e7h
	mov [si+0dh],al
	
	mov al,0deh
	mov [si+0eh],al
	
	mov al,0ddh
	mov [si+0fh],al
	
	add si,000fh
	inc si
	
	;hard coding alarm password : 77777777777777	
	mov cx,14
x_alarm_pass:		
    mov al,0d7h
    mov [si],al
    inc si
	dec cx
	jnz x_alarm_pass
	
	mov al,0ffh 
	out A2,al
	
start:	
	call clear_LCD	
	call welcome_msg
	mov bp,00h
	call keypad_inp
	cmp al,0bbh
	jz master_mode
	jmp start
		
x6: call clear_LCD
	call welcome_msg
	call keypad_inp
	cmp al,0b7h
	jz user_mode
	jmp x6 		
	
master_mode:	
   call intmaster
   mov bp,0abcdh
   cmp ax,0abcdh
   jnz x6
x8:   call keypad_inp
	cmp al,7Dh;A key
	jz alarm_mode
	jnz x8	
	
alarm_mode:
   call intmaster
   cmp dh,6h ;Alarm caused by wrong Master pwd
   jz start
   cmp dh,1h ;Alarm caused by wrong User pwd
   jz x6
   jmp x70	
   
user_mode:	
   call intuser
   cmp ax,02345h
   jz x8
   jnz x6

x70:	
stop: jmp stop   


;-------procedures------

DELAY_20ms proc
	MOV	CH,5
	X4:	NOP
		NOP
		DEC 	CH
		JNZ 	X4
	RET
DELAY_20ms endp

DELAY_0.04s proc
	
	MOV		cx,4fffh
	X17:	NOP
		NOP
		DEC 	cx
		JNZ 	X17
	RET
DELAY_0.04s endp

DELAY_max proc
	MOV	cx,0ffffh
	X16:NOP
		NOP
		DEC 	cx
		JNZ 	X16
	RET
DELAY_max endp

clear_LCD proc
	mov al,00h
	out B1,al
	call DELAY_20ms
	mov al,01h		;Clear Display
	out A1,al
	call DELAY_20ms
	mov al,04h
	out B1,al
	call DELAY_20ms
	mov al,00h
	out B1,al  
RET
clear_LCD endp

pressenter_LCD proc
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h; E=1 RW=0 RS=1-> Data write
	out B1,al
	call DELAY_20ms
	mov al,01h;E=1 RW=0 RS=1 -> data write H-L transition
	out B1,al  ;prints Space
	
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints Space
	
	mov al,050h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints P
	
	mov al,052h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints R
	
	mov al,45h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints E
	
	mov al,053h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints S
	
	mov al,053h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints S
	
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints Space
	
	mov al,045h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints E
	
	mov al,4Eh
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints N
	
	mov al,54h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints T
	
	mov al,045h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints E
	
	mov al,052h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints R
RET
pressenter_LCD endp	

keypad_inp proc ;SubR for keypad entry,al has unique key input value.
x0:		mov al,00h
		out 04h,al
x1:		in al,04h
		and al,0f0h
		cmp al,0f0h
		jnz x1
		CALL DELAY_20ms
		
		mov al,00h				; Check for key press
		out 04,al
x2:		;in al,0ch
		;cmp al,0fbh
		;jz sta

		in al,04h
		and al,0F0h
		cmp al,0F0h
		jz x2
		CALL DELAY_20ms
		
		mov al,00h				; Check for key press
		out 04,al
		in al,04h
		and al,0F0h
		cmp al,0F0h
		jz x2
		
		mov al,0Eh				;Check for key press column 1
		mov bl,al
		out 04h,al
		in al,04h
		and al,0f0h
		cmp al,0f0h
		jnz x3
		
		mov al,0Dh				;Check for key press column 2
		mov bl,al
		out 04h,al
		in al,04h
		and al,0f0h
		cmp al,0f0h
		jnz x3
		
		mov al,0Bh				;Check for key press column 3
		mov bl,al
		out 04h,al
		in al,04h
		and al,0f0h
		cmp al,0f0h
		jnz x3
		
		mov al,07h				;Check for key press column 4
		mov bl,al
		out 04h,al
		in al,04h
		and al,0f0h
		cmp al,0f0h
		jz x2
		
x3:		or al,bl		
ret
keypad_inp endp

Print_* proc
		mov al,2Ah
		out A1,al
		call DELAY_20ms
		mov al,05h
		out B1,al
		call DELAY_20ms
		mov al,01h
		out B1,al  ;prints *
ret
Print_* endp

intmaster proc
			
		call clear_LCD	
		mov al,0feh
		out A2,al	  	;glow enter pass LED	  
						;byte by byte pass enter
		mov cx,16
						;store the 16-bit entered pass after the hard coded pass word	

enter_16bit:		
		call keypad_inp
		cmp al,7eh
		jz pressc
		cmp al,7bh
		jz pressac
		cmp al,77h
		jz press_enter
		cmp al,0bbh
		jz nop_master
		cmp al,0b7h
		jz nop_master
		cmp al,7dh
		jz nop_master
		mov [si],al		
		CALL Print_*
		inc si	
		dec cx
		jnz enter_16bit
disp_entermaster:
		call keypad_inp
		cmp al,7eh
		jz pressc
		cmp al,7bh
		jz pressac
		cmp al,77h
		jz press_enter	
asd:	CALL clear_LCD; for other keys
		CALL pressenter_LCD	;add code here to display 'PRESS ENTER' on lcd
		call keypad_inp
		cmp al,77h
		jz press_enter
		jnz asd		
nop_master: nop
		jmp enter_16bit			
pressc:  
		call clear_1digit_LCD
		dec si
		inc cx
		jmp enter_16bit		
pressac: 
		CALL clear_LCD
		mov cx,16
		mov si,1eh;start of pass segment
		jmp enter_16bit		
press_enter:
		CALL clear_LCD
		mov al,0ffh
		out A2,al
		cmp cx,0
		jz cmp_pass
		jmp raise_alarm
		;glow retry/update led
		;byte by byte
day_pass:
		mov si,002Eh
		mov al,0fdh
		out A2,al ;Turn On Retry/Update LED
		call DELAY_max
		call DELAY_max
		call DELAY_max
		call clear_LCD
		mov cx,12
enter_12bit:		
		call keypad_inp
		cmp al,7eh
		jz presscday
		cmp al,0bbh
		jz nop_day
		cmp al,0b7h
		jz nop_day
		cmp al,7dh
		jz nop_day
		cmp al,7bh
		jz pressacday
		cmp al,77h
		jz press_enterday
		mov [si],al		
		CALL Print_*
		inc si	
		dec cx
		jnz enter_12bit	
disp_enter:
			call keypad_inp
			cmp al,7eh
			jz presscday
			cmp al,7bh
			jz pressacday
			cmp al,77h
			jz press_enterday		
asd1:		CALL clear_LCD
			CALL pressenter_LCD				;add code here to display 'PRESS ENTER' on lcd
			call keypad_inp
			cmp al,77h
			jz press_enterday
			jnz asd1
nop_day:nop
		jmp enter_12bit	
		
presscday: 
		call clear_1digit_LCD
		dec si
		inc cx
		jmp enter_12bit
pressacday:
		CALL clear_LCD
		jmp day_pass
press_enterday:
		CALL clear_LCD
		mov al,0ffh
		out A2,al;shut down all LEDs
		cmp cx,0
		jnz err_msg
		mov al,0fbh
		out A2,al; Turn on password updated LED
			
		call DELAY_max
		call DELAY_max
		
		
		mov al,0ffh
		out A2,al
		jz endseq
err_msg:
		call error_msg
		jmp day_pass
cmp_pass:
		cld
		mov si,0000h
		mov di,001Eh
		mov cx,17
x5:		mov al,[si]
		mov bl,[di]
		dec cx
		jz day_pass
		cmp al,bl
		jnz raise_alarm
		inc si
		inc di
		jmp x5
		
		
raise_alarm:
		mov dh,5h
		mov al,0fh
		out 08h,al	
		mov ax,0abcdh
endseq:
ret				
intmaster endp		

intalarm proc
	mov al,00eh
	out A2,al
	
	
	
	mov cx,14
	mov si,3ah	;store the 16-bit entered pass after the hard coded pass word	
enter_14bit:		
		call keypad_inp
		cmp al,7eh
		jz pressc_alarm
		cmp al,0bbh
		jz nop_alarm
		cmp al,0b7h
		jz nop_alarm
		cmp al,7dh
		jz nop_alarm
		cmp al,7bh
		jz pressac_alarm
		cmp al,77h
		jz press_enter_alarm
		mov [si],al		
		CALL Print_*
		inc si	
		dec cx
		jnz enter_14bit		
disp_enteralarm:
		call keypad_inp
		cmp al,7eh
		jz pressc_alarm
		cmp al,7bh
		jz pressac_alarm
		cmp al,77h
		jz press_enter_alarm
asd2:	CALL clear_LCD
		CALL pressenter_LCD	;add code here to display 'PRESS ENTER' on lcd
		call keypad_inp
		cmp al,77h
		jz press_enter_alarm
		jnz asd2	
nop_alarm: nop
	  jmp enter_14bit		
pressc_alarm:  
		call clear_1digit_LCD
		dec si
		inc cx
		jmp enter_14bit
pressac_alarm: 
		call clear_LCD
		mov cx,14
		mov si,3ah;start of pass segment
		jmp enter_14bit
press_enter_alarm:
		CALL clear_LCD
		mov al,0fh
		out A2,al
		cmp cx,0
		jz cmp_pass_alarm
		jnz x56
cmp_pass_alarm:
		cld
		mov si,10h
		mov di,3ah
		mov cx,14
		repe cmpsb
		cmp cx,00h
		jnz x56
		mov al,0ffh
		out A2,al
		add dh,1h
x56:
ret		
intalarm endp

;User procedure
intuser proc
		call clear_LCD
		mov dl,1 ;flag for checking two inputs		
		mov al,0feh
	    out 08h,al
	   	mov cx,12
	    mov si,48h	;store the 16-bit entered pass after the hard coded pass word	
enter_12bitu:		
		call keypad_inp
		cmp al,7eh
		jz pressc_user
		cmp al,7bh
		jz pressac_user
		cmp al,0bbh
		jz nop_user
		cmp al,0b7h
		jz nop_user
		cmp al,7dh
		jz nop_user
		cmp al,77h
		jz press_enter_user
		mov [si],al		
		CALL Print_*
		inc si	
		dec cx
		jnz enter_12bitu	
disp_enter_user:
		call keypad_inp
		cmp al,7eh
		jz pressc_user
		cmp al,7bh
		jz pressac_user
		cmp al,77h
		jz press_enter_user
asd3:	CALL clear_LCD
		CALL pressenter_LCD	;add code here to display 'PRESS ENTER' on lcd
		call keypad_inp
		cmp al,77h
		jz press_enter_user
		jnz asd3		
nop_user:
			nop
			jmp enter_12bitu		
pressc_user:  
		call clear_1digit_LCD
		dec si
		inc cx
		jmp enter_12bitu
pressac_user: 
		call clear_LCD
		mov cx,12
		mov si,48h;start of pass segment
		jmp enter_12bitu
press_enter_user:
		mov al,0ffh
		out 08h,al
		cmp cx,0
		jz cmp_pass_user
		jnz wrong_pass
		
cmp_pass_user:
		cld
		mov si,2eh
		mov di,48h
		mov cx,12
		repe cmpsb
		cmp cx,00h
		jnz wrong_pass
		jz open_door_user
		
wrong_pass : 
		call clear_LCD
		mov si,48h
		mov cx,12
		cmp dl,0
		jz raise_alarm_user
		mov al,0fdh
		out 08h,al
		call retry_msg
		call DELAY_max
		call DELAY_max
		call clear_LCD
		mov cx,12
		dec dl
		jmp enter_12bitu
raise_alarm_user:
		mov dh,0
		mov al,0fh
		out 08h,al
		mov ax,02345h
		jmp end_70h	
open_door_user:
		call open_door	
end_70h:
ret		
intuser endp

open_door proc
	call clear_LCD
	mov al,8ah
	out 0Ah,al
	
	call DELAY_20ms
	
	mov al,0ah
	out 0Ah,al
	
x31:	in al,0ch
		cmp al,0ffh
		jnz x31
		call DELAY_20ms
		call close_door		
ret
open_door endp

close_door proc
	mov al,03h
	out 0Ah,al
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max
	call DELAY_max

	
ret
close_door endp	

welcome_msg proc ;      G55 MUP
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints Space
	
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints Space
	
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints Space
	
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints Space
	
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints Space
	
	mov al,047h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints G
	
	mov al,035h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints 5
	
	mov al,035h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints 5
	
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints Space
	
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints Space
	
	mov al,04Dh
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints M
	
	mov al,055h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints U
	
	mov al,050h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al  ;prints P
	
	ret
welcome_msg endp


clear_1digit_LCD proc
	mov al,00h
	out B1,al
	call DELAY_20ms
	mov al,10h			;shift left by 1 
	out A1,al
	call DELAY_20ms
	mov al,04h
	out B1,al
	call DELAY_20ms
	mov al,00h
	out B1,al  
	
	mov al,0A0h
	out A1,al
	call DELAY_20ms
	mov al,05h
	out B1,al
	call DELAY_20ms
	mov al,01h
	out B1,al 			;prints Space
	
	call DELAY_20ms
	mov al,10h			;shift left by 1 
	out A1,al
	call DELAY_20ms
	mov al,04h
	out B1,al
	call DELAY_20ms
	mov al,00h
	out B1,al  
	
RET
clear_1digit_LCD endp	

error_msg proc
	mov al,0A0h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Space
	
	mov al,45h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints E
	
	mov al,4Eh
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints N
	
	mov al,54h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints T
	
	mov al,45h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints E
	
	mov al,52h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints R
	
	mov al,0A0h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Space
	
	mov al,31h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints 1
	
	mov al,32h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints 2
	
	mov al,0A0h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Space
	
	mov al,44h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints D
	
	mov al,49h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints I
	
	mov al,47h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints G
	
	mov al,49h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints I
	
	mov al,54h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints T
	
	mov al,53h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints S
RET
error_msg endp

retry_msg proc
	mov al,0A0h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Space
	
	mov al,0A0h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Space
	
	mov al,0A0h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Space
	
	mov al,0A0h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Space
	
	mov al,52h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints R
	
	mov al,45h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints E
	
	mov al,54h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints T
	
	mov al,52h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints R
	
	mov al,59h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Y

ret
retry_msg endp

updateday_msg proc
	mov al,55h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints U
	
	mov al,50h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints P
	
	mov al,44h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints D
	
	mov al,41h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints A
	
	mov al,54h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints T
	
	mov al,45h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints E
	
	mov al,0a0h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Space
	
	mov al,44h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints D
	
	mov al,41h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints A
	
	mov al,59h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Y
	
	mov al,0a0h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints Space
	
	mov al,50h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al ;prints P
	
	mov al,41h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints A
	
	mov al,53h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints S 
	
	mov al,53h
	out 00h,al
	call DELAY_20ms
	mov al,05h
	out 02h,al
	call DELAY_20ms
	mov al,01h
	out 02h,al  ;prints S 
ret
updateday_msg endp

	
Nmi_24hrtimer:    
				call clear_LCD
				call clear_1digit_LCD
		  		call updateday_msg
startnmi:	

		call keypad_inp
		cmp al,0bbh
		jz master_mode
		jmp startnmi
		
 iret
 Switch_intR:
	call open_door
	sti
	cmp bp,0abcdh
	jz x6
	jnz start