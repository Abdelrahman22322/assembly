.MODEL SMALL
.STACK 100H
.DATA
welcomeMsg DB "Welcome to the Doomsday Countdown Game!", 0Dh, 0Ah, 0Dh, 0Ah, "$"
choosePartnerMsg DB "Choose your partner (1=Rude, 2=Polite): $"
rudePartnerMsg DB "You chose the Rude Partner!", 0Dh, 0Ah, 0Dh, 0Ah, "$"
politePartnerMsg DB "You chose the Polite Partner!", 0Dh, 0Ah, 0Dh, 0Ah, "$"
dateMsg    DB "Random Date: ", 0
weekdayMsg DB "Enter the weekday (1=Sun, 7=Sat): $"
correctMsg DB "Correct! +1 Point", 0Dh, 0Ah, 0Dh, 0Ah, "$"
wrongMsg   DB "Wrong! No Points", 0Dh, 0Ah, 0Dh, 0Ah, "$"
hintMsg    DB "Hint: Use the Doomsday Algorithm to find the weekday.", 0Dh, 0Ah, 0Dh, 0Ah, "$"
scoreMsg   DB "Current Score: ", 0
finalScoreMsg DB "Time is up! Your final score: ", 0Dh, 0Ah, 0Dh, 0Ah, "$"
rudeComment1 DB "Wow, you messed up again! Are you even trying?", 0Dh, 0Ah, 0Dh, 0Ah, "$"
rudeComment2 DB "This is embarrassing. Focus already!", 0Dh, 0Ah, 0Dh, 0Ah, "$"
rudeComment3 DB "Seriously? It's not that hard!", 0Dh, 0Ah, 0Dh, 0Ah, "$"
politeComment1 DB "That's okay, keep trying! You'll get it next time!", 0Dh, 0Ah, 0Dh, 0Ah, "$"
politeComment2 DB "Don't worry, mistakes are part of learning!", 0Dh, 0Ah, 0Dh, 0Ah, "$"
politeComment3 DB "Take your time, you'll figure it out!", 0Dh, 0Ah, 0Dh, 0Ah, "$"
helpMsg    DB "Steps to solve:", 0Dh, 0Ah, 0Dh, 0Ah, "$"
step1      DB "1. Remember anchor dates for centuries (e.g., 1900=Tuesday).", 0Dh, 0Ah, 0Dh, 0Ah, "$"
step2      DB "2. Compute year-related offset (year + year/4).", 0Dh, 0Ah, 0Dh, 0Ah, "$"
step3      DB "3. Add month and day offsets.", 0Dh, 0Ah, 0Dh, 0Ah, "$"
step4      DB "4. Calculate mod 7 to find the weekday.", 0Dh, 0Ah, 0Dh, 0Ah, "$"
score      DW 0                 ; Player's score
minutes    DW 10                ; Countdown timer in minutes
partner    DB 0                 ; Chosen partner (1=Rude, 2=Polite)
startTicks DW 0                 ; Store start ticks
  
year DW 2024    ; Define year as a 16-bit variable
month DW 12     ; Define month as a 16-bit variable
day DW 31       ; Define day as a 16-bit variable
              ; Random day

.CODE
START:
    ; Initialize segments
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; Display welcome message
    LEA DX, welcomeMsg
    MOV AH, 09H
    INT 21H

ChoosePartner:
    LEA DX, choosePartnerMsg
    MOV AH, 09H
    INT 21H
    CALL GetInput
    CMP AL, '1'
    JE RudePartner
    CMP AL, '2'
    JE PolitePartner
   ; LEA DX, "Please choose a valid option (1=Rude, 2=Polite): $"
    MOV AH, 09H
    INT 21H
    JMP ChoosePartner


RudePartner:
    MOV partner, 1
    LEA DX, rudePartnerMsg
    MOV AH, 09H
    INT 21H
    JMP GameStart

PolitePartner:
    MOV partner, 2
    LEA DX, politePartnerMsg
    MOV AH, 09H
    INT 21H
    JMP GameStart

GameStart:
    ; Initialize game timer
    CALL InitTimer

GAME_LOOP:
    ; Check if time is up
    CALL CheckTimer
    CMP AX, 1
    JE GAME_END

    ; Generate a random date
    CALL GenerateRandomDate

    ; Display the date
    LEA DX, dateMsg
    MOV AH, 09H
    INT 21H
    CALL DisplayDate

    ; Prompt for weekday input
    LEA DX, weekdayMsg
    MOV AH, 09H
    INT 21H
    CALL GetInput

    ; Validate answer
    CALL ValidateAnswer

    ; Display current score
    LEA DX, scoreMsg
    MOV AH, 09H
    INT 21H
    CALL DisplayScore

    JMP GAME_LOOP

GAME_END:
    ; Display final score
    LEA DX, finalScoreMsg
    MOV AH, 09H
    INT 21H
    CALL DisplayScore

    ; Exit program
    MOV AH, 4CH
    INT 21H

; ---------------------------------------------------------
; Helper Functions
; ---------------------------------------------------------

; Initialize timer by storing the start clock ticks
InitTimer PROC
    MOV AH, 00H       ; BIOS service to get system time
    INT 1AH
    MOV startTicks, DX ; Store the initial clock ticks in startTicks
    RET
InitTimer ENDP

; Check if 10 minutes have passed (182 ticks per second)
CheckTimer PROC
    MOV AH, 00H       ; Get current time
    INT 1AH
    SUB DX, startTicks ; Subtract initial clock ticks
    MOV BX, 182       ; Ticks per second
    MOV AX, minutes
    MUL BX            ; Convert minutes to ticks
    CMP DX, AX        ; Compare elapsed ticks
    MOV AX, 0         ; Not done
    JB TimerEnd
    MOV AX, 1         ; Time's up
TimerEnd:
    RET
CheckTimer ENDP

; Generate a simple random date
GenerateRandomDate PROC
    MOV AX, 2023      ; Fixed year
    MOV year, AX
    MOV BX, 12        ; Random month (1-12)
    XOR DX, DX        ; Clear remainder
    MOV CX, 30        ; Max days
    DIV CX            ; Generate random day
    MOV month, AX
    MOV day, DX       ; Store day in DX
    RET
GenerateRandomDate ENDP

; Display the generated date in YYYY-MM-DD format
DisplayDate PROC
    MOV AX, year
    CALL PrintNumber
    MOV AL, '-'
    CALL PrintChar
    MOV AX, month
    CALL PrintNumber
    MOV AL, '-'
    CALL PrintChar
    MOV AX, day
    CALL PrintNumber
    RET
DisplayDate ENDP

; Get a single character input
GetInput PROC
    MOV AH, 01H
    INT 21H
    RET
GetInput ENDP

; Validate if user input matches correct answer using Doomsday Algorithm

     ValidateAnswer PROC
    CALL CalculateDoomsday
    ADD AL, '0'
    CMP AL, '0'
    JE Correct
    CMP partner, 1
    JE RudeFeedback
    CMP partner, 2
    JE PoliteFeedback
    RET

Correct:
    INC score          ; Increment score
    LEA DX, correctMsg
    MOV AH, 09H
    INT 21H
    RET

RudeFeedback:
    LEA DX, rudeComment1
    MOV AH, 09H
    INT 21H
    RET

PoliteFeedback:
    LEA DX, politeComment1
    MOV AH, 09H
    INT 21H
    RET

; Display the current score
DisplayScore PROC
    MOV AX, score
    CALL PrintNumber
    RET
DisplayScore ENDP

; Calculate the Doomsday for the given date
CalculateDoomsday PROC
    ; Step 1: Determine the anchor day for the century
    MOV AX, year         ; Load the year into AX
    MOV BX, 100          ; BX = 100
    MOV DX, 0            ; Clear DX before division
    DIV BX               ; AX = century, DX = year % 100
    CMP AX, 19           ; Check if century is 1900s
    JE Anchor1900
    CMP AX, 20           ; Check if century is 2000s
    JE Anchor2000
    JMP InvalidDate      ; Invalid century for this logic

Anchor1900:
    MOV BL, 2            ; Anchor day for 1900s is Tuesday
    JMP AnchorDone

Anchor2000:
    MOV BL, 2            ; Anchor day for 2000s is Tuesday
    JMP AnchorDone

AnchorDone:
    MOV AL, BL           ; Store anchor day in AL

    ; Step 2: Calculate year offset
            MOV AX, year
        MOV BX, 100
        MOV DX, 0            ; Clear DX before division
        DIV BX               ; AX = year / 100, DX = year % 100
        MOV CX, DX           ; CX = year % 100
        MOV AX, CX
        MOV DX, 0            ; Clear DX before division
        MOV BX, 4
        DIV BX               ; AX = (year % 100) / 4
        ADD AX, CX           ; Add (year % 100) + (year % 100) / 4
        ADD AL, BL           ; Add anchor day to the result

    ; Step 3: Add month offset
    MOV AX, month        ; Load the month
    CMP AX, 1            ; Check if January
    JE JanOrFeb
    CMP AX, 2            ; Check if February
    JE JanOrFeb

    ; Non-leap year offsets for other months
    MOV BL, 0            ; Default offset for March
    CMP AX, 3
    JE AddMonthOffset
    MOV BL, 3            ; April offset
    CMP AX, 4
    JE AddMonthOffset
    MOV BL, 5            ; May offset
    CMP AX, 5
    JE AddMonthOffset
    MOV BL, 1            ; June offset
    CMP AX, 6
    JE AddMonthOffset
    MOV BL, 3            ; July offset
    CMP AX, 7
    JE AddMonthOffset
    MOV BL, 6            ; August offset
    CMP AX, 8
    JE AddMonthOffset
    MOV BL, 2            ; September offset
    CMP AX, 9
    JE AddMonthOffset
    MOV BL, 4            ; October offset
    CMP AX, 10
    JE AddMonthOffset
    MOV BL, 0            ; November offset
    CMP AX, 11
    JE AddMonthOffset
    MOV BL, 2            ; December offset
    JMP AddMonthOffset

JanOrFeb:
    ; Check for leap year for January and February
    MOV AX, year
    MOV BX, 4
    MOV DX, 0            ; Clear DX before division
    DIV BX               ; AX = year / 4, DX = year % 4
    CMP DX, 0            ; Check if leap year
    JE LeapYear
    MOV BL, 3            ; January offset (non-leap year)
    CMP month, 1
    JE AddMonthOffset
    MOV BL, 0            ; February offset (non-leap year)
    JMP AddMonthOffset

LeapYear:
    MOV BL, 4            ; January offset (leap year)
    CMP month, 1
    JE AddMonthOffset
    MOV BL, 1            ; February offset (leap year)

AddMonthOffset:
    ADD AL, BL           ; Add month offset to AL

    ; Step 4: Add the day of the month
    MOV AX, day          ; Load the 16-bit 'day' variable into AX
    ADD AL, BL           ; Add day to AL

    ; Step 5: Calculate result modulo 7
    XOR DX, DX           ; Clear DX
    MOV BX, 7            ; Divisor = 7
    DIV BX               ; AX = result / 7, DX = result % 7
    MOV AL, DL           ; Remainder (weekday) is stored in DL

    RET

InvalidDate:
    MOV AL, 254          ; Return error code for invalid date
    RET
CalculateDoomsday ENDP






; Print a number stored in AX
PrintNumber PROC
    PUSH AX
    XOR CX, CX         ; Clear counter
    MOV BX, 10         ; Base 10 for division
Repeat:
    XOR DX, DX         ; Clear remainder
    DIV BX             ; Divide AX by 10
    PUSH DX            ; Push remainder (digit)
    INC CX             ; Increment count
    TEST AX, AX        ; Check if AX is zero
    JNZ Repeat
PrintLoop:
    POP DX             ; Pop a digit
    ADD DL, '0'        ; Convert to ASCII
    MOV AH, 02H        ; Print character
    INT 21H
    LOOP PrintLoop
    POP AX             ; Restore AX
    RET
PrintNumber ENDP

; Print a single character stored in AL
PrintChar PROC
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    RET
PrintChar ENDP
                      
