;------------------------------------------
; PURPOSE : Bagrot Project(Game)  
; SYSTEM  : Turbo Assembler Ideal Mode  
; AUTHOR  : Gad Dabah
;---------------------------------------- 
	IDEAL

        MODEL huge
P386

	include "Macro.asm"
;-------------------------------------------
; ClearScreen - Clear Screen
;-------------------------------------------
; Input:
; 	none
; Output:
; 	ClearScreen
; Registers
;	 ax,ex,di,cx
;-------------------------------------------
Macro ClearScreen
	mov ax,ScreenRam      
	mov es,ax                            ;clear screen
	xor di,di                            ;clear screen
	mov cx,320*200/2                     ;clear screen
	mov al,0d                            ;clear screen
	mov ah,0d                            ;clear screen
	rep stosw                            ;clear screen
ENDM ClearScreen
;-------------------------------------------
; ShowPic - Show pcx
;-------------------------------------------
; Input:
; 	file
; Output:
; 	pcx with wait for key stroke
; Registers
;	 ax
;-------------------------------------------
Macro ShowPic file
        mov [StartPcxX], 0d
        mov [StartPcxY], 0d
        PCX StartPcxX, StartPcxY, file
		mov ah,0ch
		mov al,07h
		int 21h
		;mov ah,00
		;int 16h
ENDM ShowPic file
;-------------------------------------------
; PCX - Show pcx
;-------------------------------------------
; Input:
; 	StartX,StartY,fName
; Output:
; 	Pcx
; Registers
;	 AX, dx
;-------------------------------------------
MACRO PCX StartX, StartY, fName
        mov ax, [StartX]
        mov [Point_X], ax
        mov ax, [StartY]
        mov [Point_Y], ax
        mov dx, offset fName
        call ShowPCXFile
ENDM PCX

	STACK 256
	
	    ScreenRam    	 equ 0A000h
	    Player1W  	     equ 21
	    Player1H   	     equ 24
	    TransporentColor equ 15
		
		
	
		PongW			 equ 10 
		PongH            equ 40
	DATASEG
		
		KeyC             DW ?
		RightDown        DB 77
	    LeftDown  	     DB 75
        UpDown           DB 72
        DownDown  	     DB 80
        DownUp  	     DB ‬11010000b
	    SpaceDown        DB 39h
	    ZDown            DB 2Ch
	    ZUp              DB 0ACh
		RightUP  		 DB 11001101b
        LeftUP   		 DB 11001011b
		
		ErrorMsg         DB 'There Is A Problem To Show The File$'
		Handle           DW ?
		File             DB 'Map.bmp',0
		TrexMap          DB 'TrexMap.bmp',0
		Index            DD ?
		X                DW 0
		Y                DW 0
		CurrentY         DW 0
		XScreen          DW 0
		YScreen          DW 0
		Weight           DW 0
		Lines            DB 0
		WidthPic         DD 1920
						 
		RexY             DW 145
		RexX             DW 0
		
		CactusY          DW 168
		CactusX          DW 280
		XChar			 DB ?
		YChar            DB ?

		
		Speed            DW 2
		Cyc              DD 100000
		Rnd              DB 0
		ScoreRex         DW 0
		Value            DW 1
			
		ScoreCount       DB 0
	
		Zero             DB 1
		Any              DB "Press Any Key To Continue"
		Tnx              DB "Thank You :)$"

        MenuStart        DB 'Start.pcx',0
		MenuOptions      DB 'Options.pcx',0
		MenuHelp         DB 'MHelp.pcx',0
		MenuInfo         DB 'MInfo.pcx',0
		Help     	     DB 'Help.pcx',0
		Info    	     DB 'Info.pcx',0	
		Choose    	     DB 'Choose.pcx',0	
	    MYName           DB 'Name.pcx',0
		Lose             DB 'End.pcx',0
		YouWin           DB 'YouWin.pcx',0
		OptionUp         DB 'OpU.pcx',0
		OptionDown       DB 'OpD.pcx',0
		OptionLeft       DB 'OpL.pcx',0
		OptionRight      DB 'OpR.pcx',0
		OptionZ          DB 'OpZ.pcx',0
		OptionJump       DB 'Jump.pcx',0
		ScanC            DB 'ScanCode.pcx',0

		;Win   DB 'Win.pcx',0

		;Cactusc    	     DB 'Cactus.pcx',0	

		;Map     	     DB 'Map.pcx',0
		Char             DB 0
		ErrorReadingFile DB 'Can not open file$'
        FileName         DW ?   ;Offset file name for current file     ;PCX
        FileHandle       DW ?   ;FileHandle                            ;PCX
        FileSize         DW ?   ;Size Image                            ;PCX
        ImageSizeInFile  DW ?	;Size Image	                           ;PCX
        ImageWidth       DW ?	;Width image                           ;PCX
        ImageHeigth      DW ?	;Height image                          ;PCX
        PaletteOffset    DW ?	;Palette color offset                  ;PCX
        Point_X          DW ?   ;PcxX of BackGround Game               ;PCX
        Point_Y          DW ?	;PcxY of BackGround Game               ;PCX
		StartPcxX        DW ?   ;PcxX of BackGround Game               ;PCX
        StartPcxY        DW ?	;PcxY of BackGround Game               ;PCX
						 
        Color            DB ?	;Color Pixel Pcx
						 
		Wback            DW ?
		Hback            DW ?    
						 
		PcxX      		 DW 0	;PcxX of BackGround Game
        PcxY     	     DW 0   ;PcxY of BackGround Game 
						 
		PlayerX	         DW 65  ;X of Player 
		PlayerY	         DW 60  ;Y of Player
						 
		JumpV            DW 5 	;Value of jump
		IsJump           DB 0  	;1 if jump 0 if not
		CanJump          DB 0  	;If player in ground he CanJump(1) else CanJump(2)
		GravityV         DW 0
		Key              DB 0   ;Keep Key Preesd For the Moving
		JumpCyc          DB 5
						 
	    PlayerArray      DB Player1W*Player1H dup(0)
		ShootArray       DB 19*13 dup(0)
						 
		
		;Cycle            DD 100000		;Delay
						 
		XChecker         DW 0
		YChecker         DW 0
						 
		Animated  		 DB 0  
		
		CanDown          DB 1
		AnimateEnemy     DB 0 
		DirS             DB 0
		Dir              DB 0
		NoMove           DB 0
		Xshoot           DW 0
		Yshoot           DW 0
		IsShoot          DB 0
		HowMany          DB 0
		ShootPlayer      DB 0
		
		Glitch           DB 0
		include "data.asm"
		BoundX           DW ?
		BoundY           DW ?
		ColorRead        DB ?
		EndX             DW ?
		EndY             DW ?
		StartXRead       DW ?
		StartYRead       DW ?
		Smsg    		 DB "Your Score Is "
		Msg2             DB "     "
		
		EnemyDead        DB 0
		
		EnemyX			 DW 450
		EnemyY           DW 180
		RocketX          DW 470
		RocketY          DW 180
		Lives            DW 3
		Press    		 DB "Press Key To Change"
		EnemyAni         DB 0
		
		Xuser            DW 0
		Yuser            DW 200 - 37
		
		Pong1X           DW 305
		Pong1Y           DW 75

		Pong2X           DW 5
		Pong2Y           DW 75
		
		BallX            DW 160-7
		BallY            DW 100-7
		DirP2            DB ?
		
		DirXBall         DB ?
		DirYBall         DB ?
		
		Score1			 DW 0
		Score2           DW 0
		

SEGMENT BufferBmp para public  ;'DATA'  
        DB 65535 DUP(0)
ENDS		
		FullName  		 DB "Thanks For Playing       "

        CODESEG   
		
		
;-----------------------------------------Program code Main-----------------------------------------
Exit1:
Start:
	mov ax, @data
	mov ds, ax
		
    mov ax, 0013h       ;Graphics Mode
    int 10h             ;Graphics Mode
;--------------------------------------------------------------------------
Start1:
	mov [Lives],3

	xor bl,bl
	call ShowMenu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AfterLose:
	call StartP
	cmp ax,1
	je @@Won
	cmp ax,2
	jne start
	cmp [Lives],0
	jne AfterLose
	call LoseP 
	;mov [Lives],3
	jmp AfterLose
@@Won:
	call Won
jmp Start1



	

		
	
Exit:
		mov ah, 0           ;text mode
		mov al, 2           ;text mode
		int 10h             ;text mode
		
		mov dx, offset Tnx
		mov ah,09h
		int 21h
		
        mov ax,04c00h
        int 21h

include "Procs.asm"






;-----------------------------------------Picture Method-----------------------------------------









