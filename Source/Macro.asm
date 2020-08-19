;-------------------------------------------
; DisplayChar - Display Char on screen
;-------------------------------------------
; Input:
; 	Messege,count,color
; Output:
; 	Char on screen
; Registers
;	 AX, BX, CX, DX, SI, ES
;-------------------------------------------
Macro DisplayChar Messege,count,color
local @@lop
	mov si,0
	mov cx,count
@@lop:
	mov  dl, [XChar]   ;Column
	mov  dh, [YChar]   ;Row
	mov  bh, 0    ;Display page
	mov  ah, 02h  ;SetCursorPosition
	int  10h
	
	mov  al, [Messege+si]
	mov  bl, color 
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h 
	inc si
	inc [XChar]
loop @@lop
endm
;-------------------------------------------
; Int2String - Make int string
;-------------------------------------------
; Input:
; 	Integer
; Output:
; 	int to string
; Registers
;	 AX, BX, CX, DX, SI, ES
;-------------------------------------------
Macro Int2String Integer
local @@lop
	mov si,4
	mov cx,5
	mov bx,10
	xor ax,ax
	push [Integer]
@@lop:
	xor dx,dx
	mov ax,[Integer]
	div bx
	add dx,'0'
	mov [msg2+si],dl
	mov [Integer],ax
	dec si
	loop @@lop
	pop [Integer]
EndM
;-------------------------------------------
; ReadPixelM - Check 
;-------------------------------------------
; Input:
; 	PaletteOffset
; Output:
; 	New palette
; Registers
;	 AX, BX, CX, DX, SI, ES
;-------------------------------------------
Macro ReadPixelM Xm,Ym,Color,EndXr,EndYr,AddX,AddY
	mov [EndX],EndXr
	mov [EndY],EndYr
	
	push [Xm]
	pop  [BoundX]
	push [Ym]
	pop  [BoundY]
	mov [ColorRead],Color
	add [BoundX], AddX
	add [BoundX], AddY
	call ReadPixelP
Endm
;-------------------------------------------
; MPcxBack - Show bmp
;-------------------------------------------
; Input:
; 	StartX,StartY,ImgName
; Output:
; 	Bmp
; Registers
;	 AX,si
;-------------------------------------------
MACRO MPcxBack StartX, StartY, ImgName 
    mov ax, [StartX]
    mov [Point_X], ax
    mov ax, [StartY]
    mov [Point_Y], ax

    mov si, offset ImgName
    call PPcxBack
ENDM MPcxBack
;-------------------------------------------
; ReadBmp - Scrooling
;-------------------------------------------
; Input:
; 	FileName
; Output:
; 	Scrooling
; Registers
;	 ex,ax,dx
;-------------------------------------------
Macro ReadBmp FileName
local @@next
	mov ax, BufferBmp
	mov es, ax

	mov [Lines],0
	mov [Weight],0
	
	mov ax,[Y]
	mov [CurrentY],ax
	
	cmp [Zero],0
	je @@Next
	
	mov [XScreen],0
	mov [YScreen],0
@@Next:
	
	mov dx, offset FileName  ;Mov Dx Offset Of File To Read It
	;call Clear
	call ReadToBuffer		;Call Proc That Move Values To Buffer
	call ShowBMP
	
	mov ax,[CurrentY]
	mov [Y],ax
EndM

