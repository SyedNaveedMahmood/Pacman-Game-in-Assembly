; =============================================================
;   W/A/S/D = move   |   Q = quit
;   Collect 'S' to increase your score!
;   You have 3 lives - when caught by a ghost, press Y to continue or N to quit
;   Get 10 points to earn an extra life!
; =============================================================

.MODEL LARGE
.STACK 100h

.DATA  
    ; welcome screen variables
    welcomeMsg1   DB '=========================================$'
    welcomeMsg2   DB '    Goriber PAC-MAN    $'
    welcomeMsg3   DB '=========================================$'
    welcomeMsg4   DB 'Chola fera korben W/A/S/D diye, S diye point uthaben$'
    welcomeMsg5   DB 'G diye ghost ashtese vagooooo!$'
    welcomeMsg6   DB 'Get 10 points to earn an extra life!$'
    welcomeMsg7   DB 'Do you want to play? (Y/N): $'
    
    ; grid and player
    W          DB 20
    H          DB 10
    posX       DB 10
    posY       DB 5
    wallChar   DB '#'
    emptyChar  DB '_'          ; underscore for empty
    playerChar DB 'P'
    promptMsg  DB 'Move (W/A/S/D, Q quit): $'
    edgeMsg    DB 'Edge! Press any key to continue...$'
    posLabel   DB 'Position: $'
    CR         DB 13
    LF         DB 10
    
    ; ghosts
    ghostX      DB 5 DUP(0)    
    ghostY      DB 5 DUP(0)    
    ghostChar   DB 'G'
    ghostCount  DB 0           
    moveCount   DB 0           ; Counts player moves
    spawnTimer  DB 0           ; Counter for ghost spawning (spawn after every 2 moves)
    gameOverMsg DB 'Game Over! Ghost caught you.$'
    
    ; scoring system variables
    scoreValue  DW 0           ; Player's score
    scoreMsg    DB 'Score: $'
    scoreChar   DB 'S'         ; Character representing points
    scoreX      DB 5 DUP(0)    
    scoreY      DB 5 DUP(0)   
    scoreCount  DB 0          
    finalScoreMsg DB 'Final Score: $'
    
    ; Continue system variables
    livesCount   DB 3          ; Number of lives player has
    livesMsg     DB 'Lives: $'
    continueMsg  DB 'Continue? (Y/N): $'
    noLivesMsg   DB 'No more lives left!$'
    addLifeMsg   DB '+1 Life!$'
    pointsForLife DW 10        
    lifeMilestone DW 10       
    highScore   DW 0       
    highScoreMsg DB 'High Score: $'
    saveMsg     DB 'Game saved.$'
    resetScoreMsg DB 'Score reset.$'  ; New message for score reset
    
    ; Variables to track cursor positions
    promptRow    DB 0          
    statusRow    DB 0       

.CODE
    
    NEWLINE MACRO
        PUSH AX
        PUSH DX
        
        MOV DL, CR
        MOV AH, 02h
        INT 21h
        MOV DL, LF
        INT 21h
        
        POP DX
        POP AX
    ENDM
    

    print2 PROC
        PUSH AX
        PUSH BX
        PUSH DX
    
        XOR  AH, AH
        MOV  BL, 10
        DIV  BL                 ; AL=tens AH=ones
    
        CMP  AL, 0
        JE   p2_one
        ADD  AL, '0'
        MOV  DL, AL
        MOV  AH, 02h
        INT  21h
    p2_one:
        MOV  AL, AH
        ADD  AL, '0'
        MOV  DL, AL
        MOV  AH, 02h
        INT  21h
    
        POP  DX
        POP  BX
        POP  AX
        RET
    print2 ENDP


    printWord PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        MOV BX, 10
        MOV CX, 0
        
    pw_div:
        XOR DX, DX
        DIV BX          
        PUSH DX         
        INC CX         
        CMP AX, 0      
        JNZ pw_div      
        
    pw_print:
        POP DX          
        ADD DL, '0'     
        MOV AH, 02h    
        INT 21h
        LOOP pw_print   
        
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    printWord ENDP
    

    clearScreen PROC
        PUSH AX
        PUSH CX
        PUSH DX
    
        MOV  AX, 0600h          
        MOV  BH, 07h           
        MOV  CX, 0000h         
        MOV  DX, 184Fh         
        INT  10h
    
        MOV  AH, 02h            
        XOR  BH, BH             
        XOR  DH, DH            
        XOR  DL, DL          
        INT  10h
    
        POP  DX
        POP  CX
        POP  AX
        RET
    clearScreen ENDP
    

    getRandom PROC
        PUSH BX
        PUSH CX
        PUSH DX
        
        ; We used a mix of time and previous value for randomness
        MOV AH, 0
        INT 1Ah         
        

        MOV AH, 2Ch
        INT 21h        
        ADD DL, AL     
        XOR AL, DL    
        XOR AL, CL     
        
        XOR AH, AH
        DIV BL          
        MOV AL, AH      
        INC AL         
        
        POP DX
        POP CX
        POP BX
        RET
    getRandom ENDP
    
 
    showWelcomeScreen PROC
        PUSH AX
        PUSH DX
        
        CALL clearScreen
        
         
        MOV AH, 09h
        LEA DX, welcomeMsg1
        INT 21h
        NEWLINE
        
        MOV AH, 09h
        LEA DX, welcomeMsg2
        INT 21h
        NEWLINE
        
        MOV AH, 09h
        LEA DX, welcomeMsg3
        INT 21h
        NEWLINE
        NEWLINE
        
        MOV AH, 09h
        LEA DX, welcomeMsg4
        INT 21h
        NEWLINE
        
        MOV AH, 09h
        LEA DX, welcomeMsg5
        INT 21h
        NEWLINE
        
        MOV AH, 09h
        LEA DX, welcomeMsg6
        INT 21h
        NEWLINE
        NEWLINE
        
        MOV AH, 09h
        LEA DX, welcomeMsg7
        INT 21h
        
       
    get_welcome_input:
        MOV AH, 08h             
        INT 21h
        
       
        CMP AL, 'Y'
        JE welcome_done
        CMP AL, 'y'
        JE welcome_done
     
        CMP AL, 'N'
        JE exit_game
        CMP AL, 'n'
        JE exit_game
        
     
        JMP get_welcome_input
        
    exit_game:
        MOV AH, 4Ch           
        INT 21h
        
    welcome_done:
        POP DX
        POP AX
        RET
    showWelcomeScreen ENDP
    
     
    spawnScoreItem PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
      
        CMP scoreCount, 5
        JAE spawn_done          
        
        MOV SI, 0         
        MOV BL, scoreCount   
        XOR BH, BH           
        MOV SI, BX         
        
    try_spawn:
    
        MOV BL, [W]
        DEC BL             
        CALL getRandom
        MOV scoreX[SI], AL     
        
        
        MOV BL, [H]
        DEC BL            
        CALL getRandom
        MOV scoreY[SI], AL     
        
    
        MOV AL, scoreX[SI]
        CMP AL, [posX]
        JNE valid_pos
        MOV AL, scoreY[SI]
        CMP AL, [posY]
        JE try_spawn            
        
    valid_pos:
        
        
        INC scoreCount          
    
    spawn_done:
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    spawnScoreItem ENDP
    
    
    checkScoreCollision PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH SI
        PUSH DI
        
        XOR CX, CX              
        
    check_loop:
        CMP CX, 5             
        JAE check_done
        MOV SI, CX              
        
        MOV BL, scoreCount
        CMP CL, BL             
        JAE check_next         
        
        MOV AL, scoreX[SI]
        CMP AL, [posX]
        JNE check_next
        MOV AL, scoreY[SI]
        CMP AL, [posY]
        JNE check_next
        
       
        ADD scoreValue, 1     
        
        
        MOV AX, scoreValue
        CMP AX, lifeMilestone
        JB no_extra_life
        
         
        INC livesCount
        ADD lifeMilestone, 10   
        
        
        MOV AH, 09h
        LEA DX, addLifeMsg
        INT 21h
        NEWLINE
        
    no_extra_life:
        
        MOV DI, SI
        INC DI
        
    shift_loop:
        CMP DI, 5
        JAE shift_done
        
         
        MOV AL, scoreX[DI]
        MOV scoreX[SI], AL
        MOV AL, scoreY[DI]
        MOV scoreY[SI], AL
        
        INC SI
        INC DI
        JMP shift_loop
        
    shift_done:
        DEC scoreCount          
        CALL spawnScoreItem     
        JMP check_done        
        
    check_next:
        INC CX
        JMP check_loop
        
    check_done:
        POP DI
        POP SI
        POP CX
        POP BX
        POP AX
        RET
    checkScoreCollision ENDP
    
    
    drawGrid PROC
        CALL clearScreen
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        
 
       
        MOV CX, 0           
    top_border:
        
        MOV AL, [W]
        ADD AL, 1              
        CMP CL, AL
        JA top_border_done
        
    
        MOV DL, wallChar
        MOV AH, 02h
        INT 21h
        
        INC CX
        JMP top_border
        
    top_border_done:
        NEWLINE
        
        
        MOV CH, 1               
    main_grid_row:
         
        MOV AL, [H]
        CMP CH, AL
        JA main_grid_done
        
      
        MOV DL, wallChar
        MOV AH, 02h
        INT 21h
        
         
        MOV CL, 1               
    main_grid_col:
         
        MOV AL, [W]
        CMP CL, AL
        JA main_grid_col_done
        
         
        MOV AL, CL
        CMP AL, [posX]
        JNE check_score_items
        MOV AL, CH
        CMP AL, [posY]
        JNE check_score_items
        
         
        MOV DL, playerChar
        JMP print_grid_cell
        
    check_score_items:
        
        MOV SI, 0              
        MOV DI, 0               
        
    score_item_loop:
        CMP SI, 5              
        JAE check_ghosts
        
        MOV BL, scoreCount
        CMP SI, BX             
        JAE next_score_item
        
        MOV AL, scoreX[SI]    
        CMP AL, CL
        JNE next_score_item
        MOV AL, scoreY[SI]      
        CMP AL, CH
        JNE next_score_item
        
        
        MOV DL, scoreChar
        MOV DI, 1               
        JMP print_grid_cell
        
    next_score_item:
        INC SI
        JMP score_item_loop
        
    check_ghosts:
         
        CMP DI, 1
        JE print_grid_cell
        
         
        MOV SI, 0               
        
    ghost_loop:
        CMP SI, 5              
        JAE empty_cell
        
        MOV BL, ghostCount
        CMP SI, BX             
        JAE next_ghost
        
        MOV AL, ghostX[SI]    
        CMP AL, CL
        JNE next_ghost
        MOV AL, ghostY[SI]   
        CMP AL, CH
        JNE next_ghost
        
       
        MOV DL, ghostChar
        JMP print_grid_cell
        
    next_ghost:
        INC SI
        JMP ghost_loop
        
    empty_cell:
        
        MOV DL, emptyChar
        
    print_grid_cell:
        
        MOV AH, 02h
        INT 21h
        
        INC CL
        JMP main_grid_col
        
    main_grid_col_done:
        
        MOV DL, wallChar
        MOV AH, 02h
        INT 21h
        
        
        NEWLINE
        INC CH
        JMP main_grid_row
        
    main_grid_done:
        
        MOV CX, 0               
    bottom_border:
        
        MOV AL, [W]
        ADD AL, 1               
        CMP CL, AL
        JA bottom_border_done
        
         
        MOV DL, wallChar
        MOV AH, 02h
        INT 21h
        
        INC CX
        JMP bottom_border
        
    bottom_border_done:
        NEWLINE
        NEWLINE
        
        
        MOV AH, 09h
        LEA DX, posLabel
        INT 21h
        
        MOV AL, [posX]
        CALL print2
        MOV AH, 02h
        MOV DL, ','
        INT 21h
        MOV DL, ' '
        INT 21h
        MOV AL, [posY]
        CALL print2
        
        NEWLINE
        NEWLINE
        
        
        MOV AH, 03h             
        XOR BH, BH             
        INT 10h                
        
        
        MOV AH, 09h
        LEA DX, scoreMsg
        INT 21h
        
        MOV AX, scoreValue
        CALL printWord
        
        NEWLINE
        
       
        MOV AH, 09h
        LEA DX, livesMsg
        INT 21h
        
        XOR AH, AH
        MOV AL, livesCount
        CALL print2
        
        NEWLINE
        
        
        MOV AH, 09h
        LEA DX, highScoreMsg
        INT 21h
        
        MOV AX, highScore
        CALL printWord
        
        NEWLINE
        NEWLINE  
        
      
        MOV AH, 03h          
        XOR BH, BH            
        INT 10h               
        MOV promptRow, DH    
        
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    drawGrid ENDP
    
   
    showEdge PROC
        PUSH AX
        PUSH BX
        PUSH DX
        
         
        MOV AH, 03h            
        XOR BH, BH             
        INT 10h              
        MOV statusRow, DH      
        
         
        MOV AH, 02h           
        XOR BH, BH        
        MOV DH, promptRow   
        XOR DL, DL            
        INT 10h
        
        MOV AH, 09h        
        LEA DX, edgeMsg     
        INT 21h
        
        
        MOV AH, 08h            
        INT 21h
        
       
        MOV AH, 02h            
        XOR BH, BH            
        MOV DH, promptRow      
        XOR DL, DL             
        INT 10h
        
         
        MOV CX, 30            
    clear_edge_line:
        MOV AH, 02h           
        MOV DL, ' '          
        INT 21h
        LOOP clear_edge_line
        
         
        MOV AH, 02h
        XOR BH, BH
        MOV DH, promptRow
        XOR DL, DL
        INT 10h
        
        POP DX
        POP BX
        POP AX
        RET
    showEdge ENDP      
    
    
    spawnGhost PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        
         
        CMP ghostCount, 5
        JAE spawn_ghost_done
        
        MOV SI, 0
        MOV BL, ghostCount
        XOR BH, BH
        MOV SI, BX             
        
    retry_ghost:
         
        MOV BL, [W]
        DEC BL                
        CALL getRandom
        MOV ghostX[SI], AL
        
       
        MOV BL, [H]
        DEC BL                  
        CALL getRandom
        MOV ghostY[SI], AL
        
         
        MOV AL, ghostX[SI]
        SUB AL, [posX]
        JNS calc_dist_x       
        NEG AL
    calc_dist_x:
        CMP AL, 3               
        JB retry_ghost         
        
        
        MOV AL, ghostY[SI]
        SUB AL, [posY]
        JNS calc_dist_y         
        NEG AL
    calc_dist_y:
        CMP AL, 3               
        JB retry_ghost          
        
    ghost_valid_pos:
        INC ghostCount          
        
    spawn_ghost_done:
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    spawnGhost ENDP
    
     
    moveGhosts PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH SI
        
        XOR CX, CX             
        
    moveGhostsLoop:
        MOV BL, ghostCount
        CMP CL, BL              
        JAE moveGhostsDone
        
        MOV SI, CX             
        
        
        MOV AL, moveCount
        AND AL, 1             
        JZ skipThisGhost       
        
       
        MOV AL, ghostX[SI]
        CMP AL, [posX]
        JG moveGhostLeft
        JL moveGhostRight
        JMP moveGhostY
        
    moveGhostLeft:
        DEC ghostX[SI]
        JMP moveGhostY
        
    moveGhostRight:
        INC ghostX[SI]
        
    moveGhostY:
        
        MOV AL, ghostY[SI]
        CMP AL, [posY]
        JG moveGhostUp
        JL moveGhostDown
        JMP moveGhostNext
        
    moveGhostUp:
        DEC ghostY[SI]
        JMP moveGhostNext
        
    moveGhostDown:
        INC ghostY[SI]
        JMP moveGhostNext
        
    skipThisGhost:
         
        
    moveGhostNext:
        INC CX
        JMP moveGhostsLoop
        
    moveGhostsDone:
        POP SI
        POP CX
        POP BX
        POP AX
        RET
    moveGhosts ENDP
    
   
    saveHighScore PROC
        PUSH AX
        
     
        MOV AX, scoreValue
        CMP AX, highScore
        JBE no_high_score     
        
      
        MOV highScore, AX
        
   
        MOV AH, 09h
        LEA DX, saveMsg
        INT 21h
        NEWLINE
        
    no_high_score:
        POP AX
        RET
    saveHighScore ENDP
    
 
    resetPlayerPosition PROC
        PUSH AX
      
        MOV posX, 10
        MOV posY, 5
        
        
        MOV ghostCount, 0
        
     
        CALL spawnGhost
        
        POP AX
        RET
    resetPlayerPosition ENDP
    
    ; -------------------------------------------------
    ; resetScoreAndLifeMilestone - Reset score to 0 and recalculate life milestone
    ; -------------------------------------------------
    resetScoreAndLifeMilestone PROC
        PUSH AX
        
        ; Reset score to 0
        MOV scoreValue, 0
        
        ; Reset life milestone to next 10 points
        MOV AX, 10
        MOV lifeMilestone, AX
        
        ; Display reset message
        MOV AH, 09h
        LEA DX, resetScoreMsg
        INT 21h
        NEWLINE
        
        POP AX
        RET
    resetScoreAndLifeMilestone ENDP
    
   
    checkGameOver PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH SI
        PUSH DX
        
        XOR CX, CX            
        
    checkGhostLoop:
        MOV BL, ghostCount
        CMP CL, BL              
        JAE checkGameOverDone
        
        MOV SI, CX             
        
    
        MOV AL, ghostX[SI]
        CMP AL, [posX]
        JNE nextGhostCheck
        MOV AL, ghostY[SI]
        CMP AL, [posY]
        JE playerCaught
        
    nextGhostCheck:
        INC CX
        JMP checkGhostLoop
        
    checkGameOverDone:
        POP DX
        POP SI
        POP CX
        POP BX
        POP AX
        RET
        
    playerCaught:
 
        CALL clearScreen
        
   
        MOV AH, 09h
        LEA DX, gameOverMsg
        INT 21h
        NEWLINE
        
      
        CMP livesCount, 0
        JE finalGameOver       
        
       
        MOV AH, 09h
        LEA DX, continueMsg
        INT 21h
        
 
        MOV AH, 08h        
        INT 21h
        
        
        CMP AL, 'Y'
        JE useContinue
        CMP AL, 'y'
        JE useContinue
        
  
        JMP finalGameOver
        
    useContinue:
       
        DEC livesCount
        
       
        CALL saveHighScore
        
        ; FIXED: Reset score to 0 when continuing after losing a life
        CALL resetScoreAndLifeMilestone
        
        
        CALL resetPlayerPosition
        
        
        CALL drawGrid
        POP DX              
        POP SI
        POP CX
        POP BX
        POP AX
        RET
        
    finalGameOver:
   
        NEWLINE
        
        
        CALL saveHighScore
        
      
        MOV AH, 09h
        LEA DX, finalScoreMsg
        INT 21h
        
        MOV AX, scoreValue
        CALL printWord
        
        NEWLINE
        
  
        MOV AH, 09h
        LEA DX, highScoreMsg
        INT 21h
        
        MOV AX, highScore
        CALL printWord
        
        MOV AH, 4Ch             
        INT 21h
    checkGameOver ENDP
    
 
    initScoreItems PROC
        PUSH CX
        
      
        MOV CX, 5
    initLoop:
        CALL spawnScoreItem
        LOOP initLoop
        
        POP CX
        RET
    initScoreItems ENDP
    
    
    MAIN PROC
        MOV  AX, @DATA
        MOV  DS, AX
        
        
        CALL showWelcomeScreen
        
        
        CALL initScoreItems     
        CALL drawGrid           
    
        inputLoop:
         
            MOV  BH, 0
            MOV  AH, 02h
            MOV  DL, 0
            MOV  DH, promptRow  
            INT  10h
        
            MOV  AH, 09h
            LEA  DX, promptMsg
            INT  21h
        
         
            MOV  AH, 08h
            INT  21h              ; AL = key
        
            ; quit?
            CMP  AL, 'Q'
            JE   quit
            CMP  AL, 'q'
            JE   quit
        
  
            CMP  AL, 'W'
            JE   tryUp
            CMP  AL, 'w'
            JE   tryUp
   
            CMP  AL, 'S'
            JE   tryDown
            CMP  AL, 's'
            JE   tryDown
          
            CMP  AL, 'A'
            JE   tryLeft
            CMP  AL, 'a'
            JE   tryLeft
      
            CMP  AL, 'D'
            JE   tryRight
            CMP  AL, 'd'
            JE   tryRight
        
            JMP  inputLoop     
        
 
        tryUp:
            CMP  [posY], 1
            JG   doUp
            CALL showEdge
            JMP  inputLoop
        doUp:
            DEC  [posY]            
            
    
            CALL processPlayerMove
            JMP  inputLoop
        
 
        tryDown:
            MOV  AL, [H]
            CMP  [posY], AL
            JL   doDown
            CALL showEdge
            JMP  inputLoop
        doDown:
            INC  [posY]            
            
            
            CALL processPlayerMove
            JMP  inputLoop
        
   
        tryLeft:
            CMP  [posX], 1
            JG   doLeft
            CALL showEdge
            JMP  inputLoop
        doLeft:
            DEC  [posX]           
            
          
            CALL processPlayerMove
            JMP  inputLoop
 
        tryRight:
            MOV  AL, [W]
            CMP  [posX], AL
            JL   doRight
            CALL showEdge
            JMP  inputLoop
        doRight:
            INC  [posX]           
            
         
            CALL processPlayerMove
            JMP  inputLoop
        
        quit:
        
            CALL saveHighScore
            
            MOV  AH, 4Ch
            INT  21h   
            
    MAIN ENDP

 
    processPlayerMove PROC
        PUSH AX
     
        CALL checkScoreCollision
        
       
        INC moveCount
        
        
        INC spawnTimer
        CMP spawnTimer, 2
        JB no_ghost_spawn
        
        MOV spawnTimer, 0     
        CALL spawnGhost        
        
    no_ghost_spawn:
     
        CALL moveGhosts
        
        
        CALL checkGameOver
        
   
        CALL drawGrid
        
        POP AX
        RET
    processPlayerMove ENDP

END MAIN