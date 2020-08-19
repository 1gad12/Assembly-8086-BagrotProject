
proc ShowMenu near
Pic1:
 showpic MenuStart
		mov bl,1h	
		jmp startProc


Pic2:
 showpic MenuOptions
;check when to go on pic2				
		mov bl,2h	
		jmp startProc

; -----------------= Show Pic3 =----------------
Pic3:
 showpic MenuHelp
;check when to go on pic3		
		mov bl,3h	
		jmp startProc
	
; -----------------= Show Pic4 =----------------
Pic4:
 showpic MenuInfo
;check when to go on pic4		
		mov bl,4h	
startProc:

		
		in al,060h
		
		cmp al,1h        ;check esc
		je Exit
		
		cmp bl,4h
		je four

		cmp al, 2h ; check number 1
		je Pic1
		cmp al, 3h ; check number 2
		je Pic2
		cmp al, 4h ; check number 3
		je Pic3
		cmp al, 5h ; check number 4
		je Pic4		
		cmp al, 17h ; check i key
		je Pic4
		cmp al,13h ;R
		je Rex
		cmp al,19h ;R
		je Pong
		
		
		cmp bl,1h
		je one
		cmp bl,2h
		je two
		cmp bl,3h
		je three

		
		

jmp startProc	
one:
		cmp al,1ch        ;check enter
		je @@return
		cmp al, [UpDown]  ; check up key
		je pic4
		cmp al, [DownDown] ; check down key
		je pic2
		
		mov ah,0ch
		mov al,07h
		int 21h
jmp startProc
	
two:
		cmp al,1ch        ;check enter
		je @@OptionLbl
		cmp al, [UpDown]   ; check up key
		je pic1
		cmp al, [DownDown] ; check down key
		je pic3
	
		mov ah,0ch
		mov al,07h
		int 21h
jmp startProc
three:
		cmp al,1ch        ;check enter
		je @@HelpLbl
		cmp al, [UpDown]  ; check up key
		je pic2
		cmp al, [DownDown]; check down key
		je pic4
		
		mov ah,0ch
		mov al,07h
		int 21h
jmp startProc
four:
		cmp al,1ch ;check enter
		je @@InfoLbl
		cmp al, 2h ; check 1 number
		je CPic1
		cmp al, 3h ; check 2 number
		je CPic2
		cmp al, 4h ; check 3 number
		je Cpic3
		cmp al, [DownDown]; check down key
		je Cpic1
		cmp al, [UpDown]  ; check up key
		je Cpic3
		
		mov ah,0ch
		mov al,07h
		int 21h
jmp startProc
 
Rex:
		call TRex
		xor bl,bl
		mov ah,0ch
		mov al,07h
		int 21h
		ClearScreen
jmp pic1
Pong:
	call PongP
jmp pic1

Cpic1:
	ClearScreen
jmp pic1

Cpic2:
	ClearScreen
jmp pic2

Cpic3:
	ClearScreen
jmp pic3

@@OptionLbl:
	call OptionMp
	jmp pic1
@@HelpLbl:
	call HelpMp
	jmp @@CheckReturn
@@InfoLbl:
	call InfoMp

@@CheckReturn:
	in al,060h
	cmp al,1
	je pic1
	mov ah,0ch
	mov al,07h
	int 21h
jmp @@CheckReturn

@@return:
ret
ENDP ShowMenu
Proc DirProc near
	cmp [DirP2],1
	je @@Down
	dec [Pong2Y]
	ret
@@Down:
	inc [Pong2Y]
	ret
EndP
Proc P2Dir near
	cmp [Pong2Y],0
	jle @@DirDown
	cmp [Pong2Y],200 - 43
	jge @@DirUp
	ret
@@DirUp:
	mov [DirP2],0
	ret
@@DirDown:
	mov [DirP2],1
	ret
EndP
Proc MoveBallX near
	cmp [DirXBall],1
	je @@Right
	dec [BallX]
	ret
@@Right:
	inc [BallX]
	ret
EndP
Proc MoveBallY near
	cmp [DirYBall],1
	je @@Down
	dec [BallY]
	ret
@@Down:
	inc [BallY]
	ret
EndP
Proc CalculateDirY near
	cmp [BallY],20 + 11
	jle @@Down
	cmp [BallY],200 - 11
	jae @@Up
	ret
@@Down:
	mov [DirYBall],1
	ret
@@Up:
	mov [DirYBall],0
	ret
EndP
Proc CalculateDirX near
	;Bound Right
	ReadPixelM BallX,BallY,30,11,12,0,0
	cmp ax,1
	je @@Bound
	ret
@@Bound:
	cmp [DirXBall],1
	je @@Left
@@Right:
	mov [DirXBall],1
	ret
@@Left:
	dec [BallX]
	mov [DirXBall],0
	ret
EndP
Proc Ball near
	
	Call CalculateDirX
	Call CalculateDirY
	
	mov [Wback],11
	mov [Hback],12
	MPcxBack BallX, BallY, BallBmp ;Draw Back
	mov [Wback],14
	mov [Hback],47

	call MoveBallX
	call MoveBallY
	
	cmp [BallX],0 + 11
	jle P1Win
	cmp [BallX],320 -11
	jge P2Win
	
	ret
	
P1Win:
	inc [Score1]
	jmp @@rest
P2Win:
	inc [Score2]
	
@@rest:
	call Restart
	ret
EndP
Proc Restart near
	ClearScreen

	mov [XChar],25
	mov [YChar],0
	Int2String Score1
	DisplayChar msg2,5,15
	
	mov [XChar],10
	mov [YChar],0
	Int2String Score2
	DisplayChar msg2,5,15
	
	xor ax,ax
	in al,40h
	and ax,01b
	mov [DirP2],al

	xor ax,ax
	in al,40h
	and ax,01b
	mov [DirXBall],al
	
	xor ax,ax
	in al,40h
	and ax,01b
	mov [DirYBall],al
	
	mov [Wback],14
	mov [Hback],47
	
	mov [BallX],160-7
	mov [BallY],100-7
	
	mov [Wback],14
	mov [Hback],47
	MPcxBack Pong1X, Pong1Y, PongBmp1 ;Draw Back
	MPcxBack Pong2X, Pong2Y, PongBmp2 ;Draw Back
	call Ball
	
@@Again:
	mov ah,00h
	int 16h
	cmp ah,[SpaceDown]
	jne @@Again
	ret
EndP
Proc PongP near
	mov [Score1],0
	mov [Score2],0
	call Restart
@@Draw:
	MPcxBack Pong1X, Pong1Y, PongBmp1 ;Draw Back
@@KeyPress:
	mov eax,150000
@@cyc:
	dec eax
	cmp eax,0
	jne @@cyc

	call P2Dir
	call DirProc
	MPcxBack Pong2X, Pong2Y, PongBmp2 ;Draw Back
	
	call Ball
	
	in al,060h
	cmp al,[DownDown]
	je @@Down
	cmp al,[UpDown]
	je @@up
	cmp al,1
	jne @@KeyPress
ret
	
@@Down:
	cmp [Pong1Y],200 - 47
	jae @@Draw
	add [Pong1Y],2
	jmp @@Draw
@@up:
	cmp [Pong1Y],2
	jle @@Draw
	sub [Pong1Y],2
	jmp @@Draw
ret
EndP
proc StartP near
	mov	[PlayerX],65  ;X of Player 
	mov	[PlayerY],60  ;Y of Player 
	mov	[XScreen],0  ;X of Player 
	mov	[YScreen],0  ;Y of Player 
	mov [Y],400
	mov [X],0
	mov [WidthPic],1920
	mov	[EnemyX],450  ;X of Player 
	mov	[EnemyY],180  ;Y of Player 
	mov	[RocketX],450  ;X of Player 
	mov	[RocketY],180  ;Y of Player 
	mov [EnemyDead],0d

	mov ah,10h
	mov al,10h
	mov bx,254  ; color
	mov dh,8	; R
	mov ch,8	; G
	mov cl,8	; B
	int 10h
	
	mov ah,10h
	mov al,10h
	mov bx,253  ; color
	mov dh,8	; R
	mov ch,8	; G
	mov cl,8	; B
	int 10h
	
	mov ah,10h
	mov al,10h
	mov bx,252  ; color
	mov dh,8	; R
	mov ch,8	; G
	mov cl,8	; B
	int 10h
	
	mov ah,10h
	mov al,10h
	mov bx,251  ; color
	mov dh,63	; R
	mov ch,39	; G
	mov cl,31	; B
	int 10h
	
	mov ah,10h
	mov al,10h
	mov bx,250  ; color
	mov dh,19	; R
	mov ch,19	; G
	mov cl,19	; B
	int 10h
	mov [Wback],Player1W
	mov [Hback],Player1H
		ReadBmp File       

StartLoop:
lblShoot:
	call ShootP
	;inc [AnimateEnemy]
	;cmp [AnimateEnemy],10
	;jne lblJump
	;mov [AnimateEnemy],0
lblJump:
	call JumpP
GravityLbl:
	call Gravity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Enemy
	call Enemy
	ReadPixelM PlayerX,PlayerY,250,Player1W,Player1H,0,0
	cmp ax,1
	je @@Lose
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CheckEndGame:
	cmp [PlayerY],180
	jl @@Next
	cmp [PlayerX],150
	jl @@Lose
	mov ax,1
	ret
@@Lose:
	dec [Lives]
	mov ax,2
	ret
@@Next:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;glitch
	cmp [Glitch],1
	je NoKey
	ReadBmp File       
	call Animate
	call ShowUser
	;Check Winning
NoKey:
	call Enemy
	mov [Glitch],1
	in al,060h
MoveMentloop:
	cmp al,0
	jz NoKey
	

    cmp al, [RightDown]
    je Right
    cmp al, [LeftDown]
    je Left
	cmp al,[SpaceDown]
	je jump
	cmp al,[ZDown]
	je Shoot1

	
	cmp al, [RightUp]
    je KeyUp	
	cmp al, [LeftUp]
    je KeyUp
	;cmp al,[ZUp]
	;je KeyUp
	
	cmp al, 1
    je @@return
	
NoAbility:
	mov al,[Key]
jmp MoveMentloop

	
Left:
	
	mov [Glitch],0
	mov [Key], al
	;MPcxBack PlayerX, PlayerY, PlayerArray ;Draw Back
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov [Dir],1
	call incAnimate
	
	ReadPixelM PlayerX,PlayerY,252,21,24,0,0
	cmp ax,1
	je @@EndL
	
	cmp [X],0
	jle @@ConL
	dec [X]	
	inc [EnemyX]
	inc [RocketX]
	jmp StartLoop
@@ConL:
	cmp [PlayerX],0
	jle StartLoop
	dec [PlayerX]
@@EndL:
jmp StartLoop
		
Right:	
	
	mov [Glitch],0
	mov [Key], al
	;MPcxBack PlayerX, PlayerY, PlayerArray ;Draw Back
	mov [Dir],0
	call incAnimate
	ReadPixelM PlayerX,PlayerY,253,21,24,0,0
	cmp ax,1
	je @@EndR
	cmp [PlayerX],140
	jb  @@conR
	cmp [X],1600
	jae @@conR
	inc [X]
	dec [EnemyX]
jmp StartLoop
@@conR:
	inc [PlayerX]	
@@EndR:
jmp StartLoop

KeyUp:
	mov [Key], al
		
	cmp [IsShoot],1
	je lblShoot

	cmp [IsJump],0
	je lblJump
	


jmp StartLoop

jump:	
	cmp [CanJump],1
	jne NoAbility
	mov [IsJump],1
jmp lblJump

Shoot1:
	cmp [IsShoot],1
	je NoAbility
	
	mov bh,[Dir]
	mov [DirS],bh
	
	cmp [dir],1
	je XRight
	
	mov bx,[PlayerX]
	add bx,Player1W
	mov [XShoot],bx

jmp NextS

XRight:
	mov bx,[PlayerX]
	sub bx,Player1W
	mov [XShoot],bx

NextS:
	mov bx,[PlayerY]
	add bx,3
	mov [YShoot],bx

	mov [IsShoot],1
	;inc [HowMany]
	
	;mov [Wback],19
	;mov [Hback],13
	;MSaveBG XShoot, YShoot, ShootArray
	;mov [Wback],Player1W
	;mov [Hback],Player1H

jmp lblShoot
@@return:
mov ax,0
ret
ENDP

Proc ShootOn near
	ReadPixelM XShoot,YShoot,251,19,13,0,0
	cmp ax,1
	jne @@return
	mov [EnemyDead],1
	mov [IsShoot],0
@@return:
ret
EndP
Proc Enemy near
	call ShootOn
	cmp [EnemyDead],1
	je @@return
	cmp [X],220
	jl @@return
	cmp [X],515
	jg @@return
	cmp [Y],400
	jg @@return
	cmp [Y],200
	jl @@return
	mov [Glitch],0
	mov [Wback],29
	mov [Hback],21
	cmp [EnemyAni],4
	jle @@AniT
	MPcxBack EnemyX, EnemyY, E2
	jmp @@con
@@AniT:
	cmp [EnemyAni],8
	jle @@AniF
	MPcxBack EnemyX, EnemyY, E3
	jmp @@con
@@AniF:
	MPcxBack EnemyX, EnemyY, E1
@@con:
	mov [Wback],Player1W
	mov [Hback],Player1H
	
	cmp [RocketX],240
	jae @@Reset
	mov [Wback],23
	mov [Hback],8
	MPcxBack RocketX, RocketY, Rocket
	mov [Wback],Player1W
	mov [Hback],Player1H
	inc [RocketX]
	inc [EnemyAni]
	jmp @@return
@@Reset:
	mov [EnemyAni],1
	push [EnemyX]
	pop [RocketX]
	add [RocketX],20
	push [EnemyY]
	pop [RocketY]
@@return:
call ShootOn
ret
ENDP
Proc Won near
	ClearScreen
	ShowPic YouWin
ret
EndP

Proc LoseP near
	ShowPic Lose
ret
EndP

Proc ShowLive near
    mov [XChar],5
    mov [YChar],24

    Int2String Lives

    mov si,4
    mov cx,1
@@lop1:
    mov  dl, [XChar]   ;Column
    mov  dh, [YChar]   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h

    mov  al, [Msg2+si]
    mov  bl, 15   ;Color is red
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h 
    inc si
    inc [XChar]
loop @@lop1
ret
EndP
Proc PressKey near
    mov [XChar],9
    mov [YChar],12

    mov si,0
    mov cx,20
@@lop1:
    mov  dl, [XChar]   ;Column
    mov  dh, [YChar]   ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h

    mov  al, [Press+si]
    mov  bl, 15   ;Color is red
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h 
    inc si
    inc [XChar]
loop @@lop1
ret
EndP
Proc ShowUser near
	
	mov [Wback],69
	mov [Hback],37
	MPcxBack Xuser, Yuser, User
	mov [Wback],Player1W
	mov [Hback],Player1H

	mov [Wback],28
	mov [Hback],5
	add [Yuser],30
	add [Xuser],5
	MPcxBack Xuser, Yuser, Live
	sub [Xuser],5
	sub [Yuser],30
	mov [Wback],Player1W
	mov [Hback],Player1H
	
	call ShowLive

	mov [Wback],33
	mov [Hback],51
	sub [Yuser],25
	MPcxBack Xuser, Yuser, Liam
	add [Yuser],25
	mov [Wback],Player1W
	mov [Hback],Player1H
	
@@return:
ret	
EndP
proc ShootP near
	cmp [IsShoot],1
	jne @@return
	mov [Glitch],0

	;MReadPixel [XShoot],[YShoot],23,6
	;cmp al,254
	;je con
	;
	ReadPixelM XShoot,YShoot,254,19,13,0,0
	cmp ax,1
	je do
	
	cmp [XShoot],295
	jbe con
	
do:	
	;mov [Wback],19
	;mov [Hback],13
	;	MPcxBack XShoot, YShoot, ShootArray ;Draw Back
	;mov [Wback],Player1W
	;mov [Hback],Player1H
	mov [IsShoot],0
jmp @@return

con:	
	mov [Wback],19
	mov [Hback],13

	;MPcxBack XShoot, YShoot, ShootArray ;Draw Back
	
	cmp [dirS],0
	jne subX
	
	add [XShoot],3
jmp next
subX:	
 	sub [XShoot],3
next:

	;MSaveBG XShoot, YShoot, ShootArray ;Save Back
    MPcxBack XShoot, YShoot, Shoot
	
	mov [Wback],Player1W
	mov [Hback],Player1H
@@return:
ret
endp

proc JumpP near	
	cmp [IsJump],0
	je @@return
	cmp [JumpV],0
	je @@return
	mov [Glitch],0

	;MPcxBack PlayerX, PlayerY, PlayerArray ;Draw Back

	mov ax,[JumpV]
	cmp [PlayerY],100
	jae Player
	sub	[Y],ax              ;If Not End Scrool Down
	add [EnemyY],ax
	add [Yshoot],ax
	add [RocketY],ax
	jmp @@con
Player:
	sub	[PlayerY],ax              ;If Not End Scrool Down
@@con:
	dec [JumpCyc]
	cmp [JumpCyc],0
	jne @@return
	dec [JumpV]
	mov [JumpCyc],6
	;MSaveBG PlayerX, PlayerY, PlayerArray ;Save Back
	;call Animate
@@return:
ret
endp

Proc Gravity near
	mov [XChecker],0
	mov [YChecker],0
@@OnFloor:
	ReadPixelM PlayerX,PlayerY,254,21,24,0,0
	cmp ax,1
	je @@return


	;MPcxBack PlayerX, PlayerY, PlayerArray ;Draw Image
	mov ax,[GravityV]
	cmp [Y],399
	jae NoDown
	add	[Y],ax              ;If Not End Scrool Down
	sub	[EnemyY],ax              ;If Not End Scrool Down
	sub [Yshoot],ax
	sub [RocketY],ax
	jmp @@con
NoDown:
	add	[PlayerY],ax              ;If Not End Scrool Down
@@con:
	dec [JumpCyc]
	cmp [JumpCyc],0
	jne @@Next
	inc [GravityV]
	mov [JumpCyc],6
@@Next:
	;MSaveBG PlayerX, PlayerY, PlayerArray ;Save Back
	mov [CanJump],0
	mov [Glitch],0
ret

@@return:
	mov [GravityV],0
	mov [JumpV],5
	mov [CanJump],1
	mov [IsJump],0
	mov [JumpCyc],6
ret
endp
proc ReadPixelP near
	push [BoundX]
	pop  [StartXRead]
	push [BoundY]
	pop  [StartYRead]
@@Horizontal:
	mov bh,0h      
	mov cx,[BoundX]
	mov dx,[BoundY]
	mov ah,0Dh     
	int 10h 
	cmp al,[ColorRead]
	je @@return
	inc [BoundX]
	
	mov ax,[EndX]
	add ax,[StartXRead]
	cmp [BoundX],ax
	jne @@Horizontal
	
	inc [BoundY]
	mov ax,[StartXRead]
	mov [BoundX],ax
	
	mov ax,[EndY]
	add ax,[StartYRead]
	cmp [BoundY],ax	
	jne @@Horizontal
	mov ax,0
	ret
@@return:
	mov ax,1
	ret
endp



Proc InfoMp near
	ClearScreen
	showpic Info
ret
endp
Proc CurrentKey near
	mov  dl, 24   ;Column;x
    mov  dh, 42   ;Row;y
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h

    mov  al, [msg2+3]
    mov  bl, 15   ;Color is red
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h 
	
	mov  dl, 25   ;Column;x
    mov  dh, 42   ;Row;y
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h

    mov  al, [msg2+4]
    mov  bl, 15   ;Color is red
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h 
ret
EndP
Proc OptionMp near
@@OPUp:
	ClearScreen
	mov [StartPcxX], 0d
    mov [StartPcxY], 0d
    PCX StartPcxX, StartPcxY, OptionUp
	xor ax,ax
	mov al,[UpDown]
	mov [KeyC],ax
	Int2String KeyC
	call CurrentKey
@@LopUP:
	mov ah,0ch
	mov al,07h
	int 21h
	
	in al,060h
	cmp al,1Ch ;enter
	je ChangeKeyU
	cmp al,[DownDown]
	je @@OPDown
	cmp al,[UpDown]
	je @@OpJump
	cmp al,46;C
	je Code
	cmp al,1
	je @@return
jmp @@LopUP
Code:
	ClearScreen
	ShowPic ScanC
	jmp @@OPUp
ChangeKeyU:
	call PressKey
	mov ah,0ch
	mov al,07h
	int 21h
	in al,060h
	mov [UpDown],al
jmp @@OPUp


@@OPDown:
	ClearScreen
	mov [StartPcxX], 0d
    mov [StartPcxY], 0d
    PCX StartPcxX, StartPcxY, OptionDown
	xor ax,ax
	mov al,[DownDown]
	mov [KeyC],ax
	Int2String KeyC
	call CurrentKey
@@LopDown:
	mov ah,0ch
	mov al,07h
	int 21h
	
	in al,060h
	cmp al,[DownDown]
	je @@OPLeft
	cmp al,[UpDown]
	je @@OpUp
	cmp al,46;C
	je Code
	cmp al,1
	je @@return
	cmp al,1Ch ;enter
	je ChangeKeyD

jmp @@LopDown	

ChangeKeyD:
	call PressKey
	mov ah,0ch
	mov al,07h
	int 21h
@@AgainDown:
	in al,060h
	cmp al,0
	jl DownUpKey
	mov [DownDown],al
	jmp @@AgainDown
DownUpKey:
	cmp al,0E0h
	je Downlbl
	mov [DownUp],al
jmp @@OPDown
Downlbl:
	mov [DownUp],0D0h
jmp @@OPDown
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@@OPLeft:
	ClearScreen
	mov [StartPcxX], 0d
    mov [StartPcxY], 0d
    PCX StartPcxX, StartPcxY, OptionLeft
	xor ax,ax
	mov al,[LeftDown]
	mov [KeyC],ax
	Int2String KeyC
	call CurrentKey
@@LopLeft:
	mov ah,0ch
	mov al,07h
	int 21h
	
	in al,060h
	cmp al,[DownDown]
	je @@OPRight
	cmp al,[UpDown]
	je @@OpDown
	cmp al,46;C
	je Code
	cmp al,1
	je @@return
	cmp al,1Ch ;enter
	je ChangeKeyL

jmp @@LopLeft	

ChangeKeyL:
	call PressKey
	mov ah,0ch
	mov al,07h
	int 21h
@@AgainLeft:
	in al,060h
	cmp al,0
	jl LeftUpKey
	mov [LeftDown],al
	jmp @@AgainLeft
LeftUpKey:
	cmp al,0E0h
	je Leftlbl
	mov [LeftUp],al
jmp @@OPLeft
Leftlbl:
	mov [LeftUp],0CBh
jmp @@OPLeft

@@OPRight:
	ClearScreen
	mov [StartPcxX], 0d
    mov [StartPcxY], 0d
    PCX StartPcxX, StartPcxY, OptionRight
	xor ax,ax
	mov al,[RightDown]
	mov [KeyC],ax
	Int2String KeyC
	call CurrentKey
@@LopRight:
	mov ah,0ch
	mov al,07h
	int 21h
	
	in al,060h
	cmp al,[DownDown]
	je @@OPZ
	cmp al,[UpDown]
	je @@OpLeft
	cmp al,46;C
	je Code
	cmp al,1
	je @@return
	cmp al,1Ch ;enter
	je ChangeKeyR

jmp @@LopRight	

ChangeKeyR:
	call PressKey
	mov ah,0ch
	mov al,07h
	int 21h
@@AgainRight:
	in al,060h
	cmp al,0
	jl RightUpKey
	mov [RightDown],al
jmp @@AgainRight
RightUpKey:
	cmp al,0E0h
	je Rightlbl	
jmp @@OPRight
Rightlbl:
	mov [RightUp],0CDh
jmp @@OPRight


@@OPZ:
	ClearScreen
	mov [StartPcxX], 0d
    mov [StartPcxY], 0d
    PCX StartPcxX, StartPcxY, OptionZ
	xor ax,ax
	mov al,[ZDown]
	mov [KeyC],ax
	Int2String KeyC
	call CurrentKey
@@LopZ:
	mov ah,0ch
	mov al,07h
	int 21h
	
	in al,060h
	cmp al,[DownDown]
	je @@OpJump
	cmp al,[UpDown]
	je @@OpRight
	cmp al,46;C
	je Code
	cmp al,1
	je @@return
	cmp al,1Ch ;enter
	je ChangeKeyZ

jmp @@LopZ	

ChangeKeyZ:
	call PressKey
	mov ah,0ch
	mov al,07h
	int 21h
@@AgainZ:
	in al,060h
	cmp al,0
	jl ZUpKey
	mov [ZDown],al
	jmp @@AgainZ
ZUpKey:
	mov [ZUp],al
jmp @@OPZ

@@OPJump:
	ClearScreen
	mov [StartPcxX], 0d
    mov [StartPcxY], 0d
    PCX StartPcxX, StartPcxY, OptionJump
	xor ax,ax
	mov al,[SpaceDown]
	mov [KeyC],ax
	Int2String KeyC
	call CurrentKey
@@LopJ:
	mov ah,0ch
	mov al,07h
	int 21h
	
	in al,060h
	cmp al,[DownDown]
	je @@OpUp
	cmp al,[UpDown]
	je @@OpZ
	cmp al,46;C
	je Code
	cmp al,1
	je @@return
	cmp al,1Ch ;enter
	je ChangeKeyJ

jmp @@LopJ	

ChangeKeyJ:
	call PressKey
	mov ah,0ch
	mov al,07h
	int 21h
	in al,060h
	mov [SpaceDown],al
jmp @@OPJump
@@return:
	ClearScreen
ret
endp

Proc HelpMp near
	ClearScreen
	showpic Help
ret
endp

Proc Animate near
cmp [dir],1
je LeftAnimate

RightAnimate:
	cmp [Animated],1
	jbe PicOneR
	
	cmp [Animated],2
	jbe PicTwoR
		MPcxBack PlayerX, PlayerY, PlayerPic3R
	
	ret
	
	PicOneR:
		MPcxBack PlayerX, PlayerY, PlayerPic1R
	ret
	
	PicTwoR:
		MPcxBack PlayerX, PlayerY, PlayerPic2R
	ret

LeftAnimate:
	cmp [Animated],1
	jbe PicOneL
	
	cmp [Animated],2
	jbe PicTwoL
		MPcxBack PlayerX, PlayerY, PlayerPic3L
	
	ret
	
	PicOneL:
		MPcxBack PlayerX, PlayerY, PlayerPic1L
	ret
	
	PicTwoL:
		MPcxBack PlayerX, PlayerY, PlayerPic2L
	ret
endp

proc incAnimate near
inc [Animated]
cmp [Animated],4
jne @@return
mov [Animated],0
@@return:
ret
endp




proc JumpRex near
	cmp [IsJump],1
	jne @@return
	
	mov ax,[JumpV]
	sub [RexY],ax
	Call WScreen
	call Zoom

	dec [JumpV]
	
	cmp [RexY],145
	jb @@return
	
	mov [RexY],145
	Call WScreen
	call Zoom
	mov [JumpV],14
	mov [IsJump],0
	
@@return:
	ret
endp
proc WScreen near
	mov ax,ScreenRam      
	mov es,ax                            ;clear screen
	xor di,di                            ;clear screen
	mov cx,320*192/2                     ;clear screen
	mov al,15d                           ;clear screen
	mov ah,15d                           ;clear screen
	rep stosw                            ;clear screen
	ret
endp

proc Zoom near

	cmp [Char],0
	je @@return
	cmp [Char],2
	je Char2
	cmp [Char],3
	je Char2
cmp [Animated],1
je @@Two
	MPcxBack RexX, RexY, RexBmp
jmp @@return
@@Two:
	MPcxBack RexX, RexY, RexBmpDown
@@return:
ret

Char2:
	push [XScreen]
	push [YScreen]	
	
	xor bx,bx              
	push [RexX] 
	pop  [XScreen]
	push [RexY]
	pop  [YScreen]
	
	cmp [Animated],1
	je @@Next
	mov di,offset  PlayerPic1R
	jmp @@Next1
@@Next:
	mov di,offset  PlayerDownR
@@Next1:
	call ZoomPlayer
	

	
	cmp [Char],3
	je Char3
	
	pop [YScreen]
	pop [XScreen]
ret

Char3:
	push [RexX]
	pop  [XScreen]
	push [RexY]
	pop  [YScreen]
	
	xor bx,bx
	mov si,offset RexBmp

	cmp [Animated],0
	je @@One
	sub  [XScreen],9
	add  [YScreen],10
	jmp @@H
@@One:
	sub  [XScreen],12
@@H:	
	mov ah,0Ch
	mov al,[si]
	mov cx,[XScreen]
	mov dx,[YScreen]
	int 10h
	inc si
	inc [XScreen]
	mov ax,[Wback]
	cmp [XScreen],ax
	jne @@H
	inc [YScreen]
	mov [XScreen],0
	mov ax,16d
	add ax,[RexY]
	cmp [YScreen],ax
	jne @@H
	;mov ax,[Hback]
	;cmp [YScreen],ax	
	;jne @@H
	
	pop [YScreen]
	pop [XScreen]
ret
endp

Proc ChooseP near
	ClearScreen
    mov [StartPcxX], 0d
    mov [StartPcxY], 0d
    PCX StartPcxX, StartPcxY, Choose
	mov ax,00h
	int 33h
	mov ax,01h
	int 33h
@@Check:
	mov ax,05h	
	int 33h
	
    shr cx,1

Card1:
	cmp bx,0
	je @@Next
	;cmp ax,0
	;jne @@Next
	cmp dx,75
	jb @@Next
	cmp dx,178
	ja @@Next
	
	cmp cx,8
	jb Card2
	cmp cx,82
	ja Card2
	mov [Char],2
	mov ax,02h
	int 33h
ret
Card2:
	cmp cx,122
	jb Card3
	cmp cx,200
	ja Card3
	mov [Char],1
	mov ax,02h
	int 33h
ret
Card3:
	cmp cx,235
	jb @@Next
	cmp cx,310
	ja @@Next
	mov [Char],3
	mov ax,02h
	int 33h
ret
@@Next:
	in al,060h
	
	cmp al,1
	je @@Exit1

jmp @@Check
@@Exit1:
	ret
endp 
Proc Cactus near
	push [Wback]
	push [Hback]
	;push dx
	xor dx,dx
	inc [Value]
	mov ax,1500
	div [Value]
	cmp dx,1500
	jne @@NoValue
	inc [Speed] 
	mov [Value],1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@@NoValue:
	;pop dx
	cmp [CactusX],280
	jne @@next
	xor ax,ax
	in al,40h
	and ax,01b
	mov [rnd],al
@@next:
	cmp [rnd],1
	je Big
Little:
	mov  [Wback],15
	mov  [Hback],21
	mov [CactusY],168
	MPcxBack CactusX, CactusY, CacBmp
	mov ax,[Speed]
	sub [CactusX],ax
	cmp [CactusX],ax
	jae @@con
	mov [CactusX],280
	inc [ScoreRex]
@@con:
	pop [Hback]
	pop [Wback]
ret
Big:
	mov [CactusY],145
	mov  [Wback],30
	mov  [Hback],42
	MPcxBack CactusX, CactusY, CacBmpBig
	mov ax,[Speed]
	sub [CactusX],ax
	cmp [CactusX],ax
	jae @@con1
	mov [CactusX],280
	inc [ScoreRex]
@@con1:
	pop [Hback]
	pop [Wback]
ret
endp
proc ZoomPlayer near
	mov si,0                  
@@Horizontal:	
	xor bx,bx              
	mov ah,0Ch	
	mov al, [di]	
	cmp al,TransporentColor
	je @@not_draw	
	mov cx,[XScreen]          
	mov dx,[YScreen]          
	int 10h     
@@not_draw:
	inc [XScreen]             
	mov ax, [XScreen]          
	mov dx, 0             
	mov bx, 2
	div bx       
	cmp dx,1
	je @@Horizontal
	
	inc di                         
	mov ax,[Wback]
	cmp [XScreen],ax               
	jne @@Horizontal
	inc [YScreen]                  
	mov [XScreen],0		
	
	mov ax, [YScreen]          
	mov dx, 0             
	mov bx, 2
	div bx       
	cmp dx,1
	jne @@Con
	
	sub di,21
	jmp @@Horizontal
@@Con:
	mov ax,[Hback]
	add ax,[RexY]
	cmp [YScreen],ax               
	jbe @@Horizontal
ret
endp


Proc TRex near
	mov	[RexY],145
	mov	[RexX],0
	
	mov	[CactusY],168
	mov	[CactusX],280

	push [Wback]
	push [Hback]
	
	call ChooseP
	cmp al,1
	je ReturnT
	call clear
	call WScreen
	mov  [WidthPic],1280
	mov  [Y],0
	mov  [JumpV],14
	mov  [Zero],0

	mov  [Wback],42;53
	mov  [Hback],48;54
	call Zoom
@@lop:


	call Cactus
	call JumpRex
	Call WScreen
	call Zoom
	call Cactus
	
	mov [YScreen],188
	
	mov [XChar], 0
	mov [YChar], 0
	Int2String ScoreRex
	DisplayChar msg2,5,15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ReadPixelM RexX,RexY,23,42,48,0,0
	cmp ax,1
	je ScoreBoard

	;call cyc
	;MPcxBack RexX, RexY, RexBmp
	ReadBmp TrexMap
	mov [Animated],0
	mov eax,300000
	@@lop2:
	dec eax
	cmp eax,0
	jne @@lop2
	
	mov ax,[Speed]
	add ax,3
	add [X],ax
	sub [RocketX],ax
	sub [EnemyX],ax
	cmp [X],1000
	jb @@Next1
	mov [X],0
@@Next1:
	in al,060h
	
	cmp al, [SpaceDown]
	je @@Jump
	cmp al,[UpDown]
	je @@Jump
	cmp al,[DownDown]
	je @@Down
	cmp al,[DownUp]
	je ReleaseDown
	
	cmp al,1
	je ReturnT
	
	jmp @@lop

@@Jump:
	mov [IsJump],1
jmp @@lop
ReleaseDown:
	call WScreen
	mov [CanDown],1
	mov [Animated],0
	call Zoom
	;mov [JumpV],14
jmp @@lop
@@Down:
;	cmp [JumpV],14
;	je Can
;	cmp [JumpV],0
;	jl Can
;	add [JumpV],5
;	jmp Can2
;Can:
	sub [JumpV],5
;Can2:
	mov [Animated],1
	cmp [CanDown],1
	jne @@Lop
	call WScreen
	call Zoom
	mov [CanDown],0
jmp @@Lop
ScoreBoard:
	mov ah,0ch
	mov al,07h
	int 21h
	;Messege all
	mov [XChar], 0
	mov [YChar], 40
	mov [ScoreCount],0
	mov cx,5
	mov bx,0
	mov ax,0
	mov si,0
	@@Msg1:
	mov al,[Any+bx]
	mov [msg2+si],al
	inc bx
	inc si
	loop @@Msg1
	mov si,0
	pusha
	DisplayChar msg2,5,15
	popa
	inc [ScoreCount]
	mov cx,5
	cmp [ScoreCount],5
	jne @@Msg1
	
	mov ah,0ch
	mov al,07h
	int 21h	
	ClearScreen
	ShowPic MYName
	mov  dl, 5  ;Column
	mov  dh, 45  ;Row
	mov  bh, 0    ;Display page
	mov  ah, 02h  ;SetCursorPosition
	int  10h

	mov dx, offset FullName + 19
	mov ah, 0Ah
	int 21h
	mov [FullName+20],' '
	ClearScreen

	 
	mov [XChar],5
	mov [YChar],10
	DisplayChar FullName,25,15
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	add [YChar],2
	mov [XChar],5
	DisplayChar Smsg,14,15
	Int2String ScoreRex
	DisplayChar msg2,5,15
	
	mov ah,0ch
	mov al,07h
	int 21h	
	mov [ScoreRex],0
	mov [Value],1
	mov [Speed],2
	mov [ScoreCount],0
ReturnT:
	pop  [Hback]
	pop  [Wback]
	mov	[PlayerX],65  ;X of Player 
	mov	[PlayerY],80  ;Y of Player 
	mov	[XScreen], 0
	mov	[YScreen], 0
	mov	[X]      , 0
	mov	[Y]      , 0
	mov [Zero],1
ret
endp

Proc PPcxBack near
    mov cx, [Hback]
vertical_loop:
    push cx
    mov cx, [Wback]
horizontal_loop:
    push cx
    mov bh, 0
    mov cx, [Point_X]
    mov dx, [Point_Y]
    mov al, [si]
    cmp al, TransporentColor
    je @@not_draw
    mov ah, 0ch
    int 10h
@@not_draw:
    inc [Point_X]
    inc si
    pop cx
    loop horizontal_loop
    inc [Point_Y]
	cmp [Point_Y],200
	je @@return
	cmp [Point_Y],0
	je @@return
    mov ax, [Point_X]
    sub ax, [Wback]
    mov [Point_X], ax

    pop cx
    loop vertical_loop
	ret
@@return:
	pop cx
	ret
ENDP PPcxBack



Proc ReadPCXFile Near
        pusha
;-----  Initialize variables
        mov     [FileHandle],0
        mov     [FileSize],0

;-----  Open file for reading
        mov     ah, 3Dh
        mov     al, 0
        ; mov DX,offset FileName  
        int     21h
        jc      @@Err
        mov     [FileHandle],AX   ; save Handle

;-----  Get the length of a file by setting a pointer to its end
        mov     ah, 42h
        mov     al ,2
        mov     bx, [FileHandle]
        xor     cx, cx
        xor     dx, dx
        int     21h
        jc 		@@Err
        cmp     dx,0
        jne     @@Err  ;file size exceeds 64K

;-----  Save size of file
        mov     [FileSize], ax

;----- Return a pointer to the beginning of the file
        mov     ah, 42h
        mov     al, 0
        mov     bx, [FileHandle]
        xor     cx, cx
        xor dx, dx
        int 21h
        jc  @@Err

;-----  Read file into FILEBUF
        mov     bx, [FileHandle]
        pusha     
        push    ds
        mov     ax,BufferBmp
        mov     ds, ax
        xor     dx, dx
        mov     cx, 28000
        mov     ah, 3Fh
        int     21H
        pop     ds
        popa
        jc      @@Err

;-----  Close the file
        mov     ah, 3Eh
        mov     bx,[FileHandle]
        int     21H
        jc      @@Err
        popa
        ret
		
;-----  Exit - error reading file
@@Err:  ; Set text mode
        mov     ax, 3
        int     10h
        
        mov     dx, offset ErrorReadingFile
        mov     ah, 09h
        int     21h
        jmp     Exit
ENDP ReadPCXFile

;-------------------------------------------
; ShowPCXFile - show PCX file 
;-------------------------------------------
; Input:
; 	File name
; Output:
; 	The file
; Registers
;	 AX, BX, CX, DX, DS
;-------------------------------------------
Proc ShowPCXFile Near	
        pusha

        call    ReadPCXFile

		mov	    ax, BufferBmp
        mov     es, ax

;-----  Set ES:SI on the image
        mov     si, 128

;-----  Calculate the width and height of the image
        mov     ax, [es:42h]
        mov     [ImageWidth], ax
        dec     [ImageWidth]
		
        mov     ax, [es:0Ah]
        sub     ax, [es:6]
        inc     ax
        mov     [ImageHeigth], ax

;-----  Calculate the offset from the beginning of the palette file
        mov     ax, [FileSize]
        sub     ax, 768
        mov     [PaletteOffset], ax
       call    SetPalette
        mov     ax, [FileSize]
        sub     ax, 128+768
        mov     [ImageSizeInFile], ax
		
        xor  ch, ch            ; Clear high part of CX for string copies
        push [PcxX]      ; Set start position
        pop  [Point_x]
        push [PcxY]
        pop  [Point_y]
NextByte:
        mov     cl, [es:si]     ; Get next byte
        cmp     cl, 0C0h        ; Is it a length byte?
        jb      normal          ;  No, just copy it
        and     cl, 3Fh         ; Strip upper two bits from length byte
        inc     si              ; Advance to next byte - color byte

       	mov     al, [es:si]
	mov 	[Color], al
NextPixel:
		call 	PutPixel1
		cmp     cx, 1
		je 	CheckEndOfLine
	
        inc     [Point_X]

		loop 	NextPixel		
        jmp     CheckEndOfLine
Normal:
      	mov [Color], cl
		call 	PutPixel1
CheckEndOfLine:
        mov     ax, [Point_X]
        sub     ax, [PcxX]
        cmp     ax, [ImageWidth]
        jae     LineFeed
        inc     [Point_x]
        jmp     cont1
LineFeed:
        push    [PcxX]
        pop     [Point_x]
        inc     [Point_y]
cont1:
        inc     si
        cmp     si, [ImageSizeInFile]     ; End of file? (written 320x200 bytes)
        jb      nextbyte
        popa
		
        ret
ENDP ShowPCXFile

Proc PutPixel1 near
        pusha
        mov 	bh, 0h
        mov 	cx, [Point_x]
        mov 	dx, [Point_Y]
        mov 	al, [color]
        mov 	ah, 0ch
        int 	10h
        popa
        ret
ENDP PutPixel1
		
;-------------------------------------------
; Clear - Clear Array And Screen(Not In Use)
;-------------------------------------------
; Input:
; Output:
; 	Clear
; Registers
;       si,ax,es,di,cx
;-------------------------------------------
Proc Clear near
;-----------------------------Clear Buffer-----------------------------;
	mov ax,BufferBmp
	mov es,ax
	mov si,0
	mov al,15
NoFinish:
	mov [es:si],al
	inc si
	cmp si,65535
	jne NoFinish
;-----------------------------Clear Buffer-----------------------------;

;-----------------------------Clear Screen-----------------------------;
 	mov ax,ScreenRam      
 	xor di,di                           
 	mov cx,320*200/2                    
 	mov al,0d                           
 	mov ah,0d                           
 	rep stosw                           
;-----------------------------Clear Screen-----------------------------;
	ret
endp

;-------------------------------------------
; ReadToBuffer - Read BMP file into BufferBmp 
;-------------------------------------------
; Input:
; Output:
; 	File into BufferBmp
; Registers
;       EAX, EBX, ECX, EDX, DS
;-------------------------------------------
Proc ReadToBuffer near
;--------------------OpenFile Use Handle--------------------;
	mov ah, 3Dh 		    ;INT 21 Know If Ah == 3dh He Need To Open/Create File
	mov al, 0   		    ;Read Only
	;mov dx,offset FileName
	int 21h
	jc  @@Err
	mov [Handle], ax	    ;Handle On ax Go To Var
;--------------------Copy Lines To Buffer------------------;
;--------------------Move Pointer To Check End Of File--------------------;
;	mov 	ah,  42h			     ;int 21h Know That If AH == 42h He Move Pointer On File
;	mov 	al,  02			         ;End Of File To Know Size Of A File
;	mov     bx, [Handle]			 ;BX = file handle
;	xor     ecx,ecx				     ;CX:DX = offset from origin of new file position.
;	xor     edx,edx				     ;CX:DX = offset from origin of new file position. 	
;	int 	21h                 
;	jc      @@Err
;	;Enter The Image Size Into A Variable
;	mov     [SizeFile],eax 
;	mov     eax,65536
;	mul     edx
;	add     [SizeFile],eax
;	cmp     [SizeFile],0
;	je     @@Err
;--------------------Move Pointer To Check End Of File--------------------;
@@Lop:         
;--------------------Calculate index By WY+X-------------;
	movzx   eax, [word Y]       ; Y position within bitmap
	imul    eax, [WidthPic]           ; Width of bitmap
	movzx   ebx, [word X]       ; X position within bitmap
	lea     eax, [eax+ebx+1078] ;<<<< Plus offset to start of pixel data,add eax, 14+40+1024.
	push    eax
	pop     dx
	pop     cx
;--------------------Calculate index By WY+X-------------;



;I fliped this manual
;--------------------Flip Image--------------------;
	;mov 	[index],eax			     ;index == eax
	;mov     eax,[SizeFile]			 ;eax == All Byte Image	
	;sub     eax,[index]				 ;Eax - Index
	;mov 	[index],eax			     ;index == eax
	;xor     edx, edx				 ;edx = 0
	;mov     ebx, 65536				 ;ebx = 65536
	;div 	ebx						 ;Dx = Remains,ax = dose
	;mov 	ecx,  eax                ;CX = high order word of number of bytes to move
	;xor     ebx, ebx				 ;edx = 0
									 ;CX:DX distance to move file pointer: offset is (CX * 65536) + DX
;--------------------Flip Image--------------------;





;--------------------Move Pointer To Read Data--------------------;
	mov 	ah,  42h			     ;int 21h Know That If AH == 42h He Move Pointer On File
	mov 	al,  00			         ;Current Location Plus Offset
	mov     bx, [Handle]			 ;BX = file handle
									 ;CX:DX = offset from origin of new file position. 
	int 	21h                 
	jc      @@Err
;--------------------Move Pointer To Read Data--------------------;


;--------------------Read Data--------------------;

    mov     bx, [Handle]             ;BX = file handle
	mov     dx, [Weight]             ;DS:DX = pointer to read buffer
    pusha     
    push    ds
    mov     ax, BufferBmp
    mov     ds, ax
    mov     cx, 320                 ;CX = number of bytes to read---;320 = Line;
    mov     ah, 3Fh
    int     21H
    pop     ds
    popa
    jc      @@Err           
;--------------------Read Data--------------------;

	inc     [Lines]
	inc     [Y]                      ;Add Y To Calculate Position
	add 	[Weight], 320	         ;Add Weight X
	cmp 	[Lines],  200            ;Check End
	jne  	@@Lop
	
	mov     ah, 3Eh                  ;Close File
    mov     bx,[Handle]              ;BX = file handle
    int     21H
    jc      @@Err	
	ret
	
@@Err:  
        mov     ax, 3 				 ; Set text mode
        int     10h
        mov     dx, offset ErrorMsg
        mov     ah, 09h
        int     21h                  ;Print Error
        jmp     Exit
endp

;-------------------------------------------
; ShowBMP - Show BMP On Screen From Buffer
;-------------------------------------------
; Input:
; Output:
; 	Bmp On Screen
; Registers
;       Si,es,ax,cx,dx,bx
;-------------------------------------------
Proc ShowBMP near
	mov si,0                     ;Start From The Begining Of Buffer
	mov bx,0                         ;page 0
@@Horizontal:	                     
	mov ah,0Ch					     ;int 10h Know That If AH == 0Ch He Write Graphics Pixel at Coordinate
	mov al, [es:si]				     ;Color
	mov cx,[XScreen]                 ;X
	mov dx,[YScreen]                 ;Y
	int 10h                          ;Put Pixel On Screen
	inc si                           ;mov to next pixel
	inc [XScreen]                    ;Add X
	cmp [XScreen],320                ;Check End Line
	jne @@Horizontal
	inc [YScreen]                    ;Add Y
	mov [XScreen],0					 ;Start New Line
	cmp [YScreen],200                ;Check End Of Image
	jne @@Horizontal
ret
endp	
;-------------------------------------------
; SetPalette - change palette from 0-255 to from 0-63 
;-------------------------------------------
; Input:
; 	PaletteOffset
; Output:
; 	New palette
; Registers
;	 AX, BX, CX, DX, SI, ES
;-------------------------------------------
SetPalette:
		pusha
		mov cx, 256*3
		mov si, [PaletteOffset] 	
NextColor:
		shr [byte es:si], 2
		inc si
		loop NextColor

		mov dx,	[PaletteOffset]
		mov ax, 1012h
		mov bx, 00h
		mov cx, 256d  
		int 10h
		popa
ret

End Start