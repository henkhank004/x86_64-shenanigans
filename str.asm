%include "xmemory.inc"

section .text
    global strfind
    global atoi
    global itoa
    global atof
    global ftoa
    global atod
    global dtoa

; Finds the first instance of a character in a 0-terminated string and returns the position.
; Arguments:
;   rdi (char*): text
;   rsi (char) : char to be found
; Returns pointer to first instance of the char, -1 if the char was not found.
strfind:
    mov rax, rdi                                                                ; initialize ptr to char (rax), to start of string
    mov rcx, rsi                                                                ; move desired char into rcx; will be in cl

.loop:
    cmp byte [rax], cl
    je .done                                                                    ; if desired char, rax points to its location in memory

    cmp byte [rax], 0
    je .not_found                                                               ; if the byte at [rax] is 0, then at end of string; char not found

    inc rax
    jmp .loop

.not_found:                                                                     
    mov rax, -1                                                                 ; if not found, set rax to -1
.done:
    ret                                                                         
    

; Find the length of a 0-terminated string INCLUDING the 0-char.
; Arguments:
;   rdi (char*): 0-terminated string, text
; Returns the length of the string INCLUDING the 0-char
strlen0:
    mov rax, 1
.loop:
    cmp byte [rdi], 0
    je .done                                                                    ; if the byte at [rdi] is 0, then at end of string
    inc rax
    inc rdi
    jmp .loop
.done:
    ret


; Find the length of a 0-terminated string EXCLUDING the 0-char.
; Arguments:
;   rdi (char*): 0-terminated string, text
; Returns the length of the string EXCLUDING the 0-char
strlen:
    xor rax, rax
.loop:
    cmp byte [rdi], 0
    je .done                                                                    ; if the byte at [rdi] is 0, then at end of string
    inc rax
    inc rdi
    jmp .loop
.done:
    ret


; Converts an ASCII 0-terminated string to an ssize_t.
; Arguments:
;   rdi (char*): ASCII string containing the intiger
; Returns intiger value from the string.
atoi:
    xor rsi, rsi                                                                ; set rsi = 0 to find the end of string
    call strfind                                                                ; rax now points to the \0 char
    mov rsi, rax                                                                ; rsi now points to least significant digit + 1
    xor rax, rax                                                                ; set rax = 0, will hold return value
    xor rcx, rcx                                                                ; set rcx = 0, will be used in computation

    mov rdx, 1                                                                  ; will hold the powers of 10 assiciated with current digit
.loop:
    dec rsi                                                                     ; dec rsi to next digit
    cmp rsi, rdi                                                                ; rsi compare to the position of the first digit
    je .first_char                                                              ; if rsi points to the first char, process it appropriately

    movzx rcx, byte [rsi]                                                       ; move the current digit into cl
    sub rcx, 48                                                                 ; convert ASCII-char to numeric value
    imul rcx, rdx                                                               ; multiply number by power of 10 assiciated with its position in rdx
    add rax, rcx                                                                ; add the found number to result in rax
    imul rdx, rdx, 10                                                           ; set rdx to the next power of 10
    jmp .loop

.first_char:
    movzx rcx, byte [rsi]
    cmp rcx, 45                                                                 ; check if first char is a minus sign
    je .negate                                                                  ; if it is a minus sign, negate the result in rax
                                                                                ; if not a minus sign, add the digit like with the other digits
    sub rcx, 48
    imul rcx, rdx
    add rax, rcx
    jmp .done

.negate:
    neg rax
.done:
    ret


; Converts an integer into a 0-terminated ASCII string.
; Assumes the buffer is of an appropriate size.
; Arguments:
;   rdi (long): the integer
;   rsi (buff*): ptr to start of the buffer to write into
; Returns number of characters written to string
; including the 0-char at the end.
itoa:
    mov rax, rdi                                                                ; move integer into rax
    mov r10, 10                                                                 ; r11 will hold the powers of 10
    xor r11, r11                                                                ; used to store the order of the number

.det_order:
    xor rdx, rdx                                                                ; set rdx to zero for the division
    inc r11                                                                     ; increment the order by one
    div r10                                                                     ; devide the remaining mod number by 10
    cmp rax, 0                                                                  ; rax now holds n (mod 10^{r11})
    jne .det_order                                                              ; if rax = 0, then rdx holds the first digit, and r11 holds the order


    add rsi, r11                                                                ; set rsi to end of string
    mov byte [rsi], 0                                                           ; 0-terminate end of string
    mov rax, rdi                                                                ; set rax to the number

.write:
    xor rdx, rdx                                                                ; set rdx to zero for the division
    dec rsi                                                                     ; move rsi to next char
    div r10                                                                     ; rdx now holds the remaining number mod 10, rax holds the remaining part to be written
    add rdx, 48                                                                 ; transform numeral into ASCII representation
    mov byte [rsi], dl                                                          ; write the ASCII char to the string
    cmp rax, 0                                                                  ; if rax is zero, then rdx holds first digit: i.e. all digits will have been written
    jne .write                                                                  ; if rax not zero, then there are still digits to be written

    mov rax, r11                                                                ; number of characters excluding \0 at the end is equal to the order
    inc rax                                                                     ; increment rax to account for the \0 char at the end of the string
    ret


; Converts an ASCII 0-terminated string to a float (32-bits).
; Arguments:
;    rdi (char*): ASCII string containing the float
; Returns (xmm0) float value from the string.
atof:
    call _acftoir                                                               ; get the integer reduction
    mov rdx, rax                                                                ; store integer reduction in rdx
    cvtsi2ss xmm0, rdx                                                          ; cast ir to float in xmm0

    mov rsi, 46                                                                 ; load ASCII code for '.'
    call strfind                                                                ; rax now holds the position of the decimal delimiter

    cmp rax, -1                                                                 ; check if '.' was found
    je .int                                                                     ; if not found, the number is an integer

    mov rdi, rax
    call strlen                                                                 ; rax now holds (1 + the number of divisions) by 10 to get the float from integer reduction, i.e. ord_10(f) + 1
    mov rcx, rax                                                                ; rcx now holds ord_10(f) + 1

    mov rax, 1
    mov r10, 10                                                                 
.exploop:                                                                       ; compute correct power of 10
    mul r10
    dec rcx
    cmp rcx, 1
    jne .exploop

    cvtsi2ss xmm1, rax                                                          ; cast power of 10 to float in xmm1
    divss xmm0, xmm1                                                            ; adjust ir by appropriate power of 10
    
    jmp .done

.int:
    call atoi                                                                   ; convert the number, which we now know is an int to a str; rdi strill contains the ptr to the str
    cvtsi2ss xmm0, rax                                                          ; convert the int to a float

.done:
    ret


; Converts an ASCII 0-terminated containing a float to an intiger
; obtained by simply removing the decimal delimiter.
;   i.e. input (str) "123.4567",0 returns (int) 1234567
; Arguments:
;   rdi (char*): ASCII string containing the float
; Returns intiger value from the string.
_acftoir:
    xor rsi, rsi                                                                ; set rsi = 0 to find the end of string
    call strfind                                                                ; rax now points to the \0 char
    mov rsi, rax                                                                ; rsi now points to least significant digit + 1
    xor rax, rax                                                                ; set rax = 0, will hold return value
    xor rcx, rcx                                                                ; set rcx = 0, will be used in computation

    mov rdx, 1                                                                  ; will hold the powers of 10 assiciated with current digit
.loop:
    dec rsi                                                                     ; dec rsi to next digit
    cmp rsi, rdi                                                                ; rsi compare to the position of the first digit
    je .first_char                                                              ; if rsi points to the first char, process it appropriately

    movzx rcx, byte [rsi]                                                       ; move the current digit into cl
    cmp rcx, 46                                                                 ; if current char is '.', ignore
    je .loop

    sub rcx, 48                                                                 ; convert ASCII-char to numeric value
    imul rcx, rdx                                                               ; multiply number by power of 10 assiciated with its position in rdx
    add rax, rcx                                                                ; add the found number to result in rax
    imul rdx, rdx, 10                                                           ; set rdx to the next power of 10
    jmp .loop

.first_char:
    movzx rcx, byte [rsi]
    cmp rcx, 45                                                                 ; check if first char is a minus sign
    je .negate                                                                  ; if it is a minus sign, negate the result in rax
                                                                                ; if not a minus sign, add the digit like with the other digits
    sub rcx, 48
    imul rcx, rdx
    add rax, rcx
    jmp .done

.negate:
    neg rax
.done:
    ret

    


; Converts a float into a 0-terminated ASCII string.
; Assumes the buffer is of an appropriate size.
; Arguments:
;   rdi (float): the integer
;   rsi (buff*): ptr to start of the buffer to write into
; Returns number of characters written to string
; including the 0-char at the end.
ftoa:
    ret


; Converts an ASCII 0-terminated string to a double (64-bits).
; Arguments:
;    rdi (char*): ASCII string containing the double
; Returns (xmm0) float value from the string.
atod:
    call _acftoir                                                               ; get the integer reduction
    mov rdx, rax                                                                ; store integer reduction in rdx
    cvtsi2sd xmm0, rdx                                                          ; cast ir to float in xmm0

    mov rsi, 46                                                                 ; load ASCII code for '.'
    call strfind                                                                ; rax now holds the position of the decimal delimiter

    cmp rax, -1                                                                 ; check if '.' was found
    je .int                                                                     ; if not found, the number is an integer

    mov rdi, rax
    call strlen                                                                 ; rax now holds (1 + the number of divisions) by 10 to get the float from integer reduction, i.e. ord_10(f) + 1
    mov rcx, rax                                                                ; rcx now holds ord_10(f) + 1

    mov rax, 1
    mov r10, 10                                                                 
.exploop:                                                                       ; compute correct power of 10
    mul r10
    dec rcx
    cmp rcx, 1
    jne .exploop

    cvtsi2sd xmm1, rax                                                          ; cast power of 10 to float in xmm1
    divsd xmm0, xmm1                                                            ; adjust ir by appropriate power of 10
    
    jmp .done

.int:
    call atoi                                                                   ; convert the number, which we now know is an int to a str; rdi strill contains the ptr to the str
    cvtsi2sd xmm0, rax                                                          ; convert the int to a float

.done:
    ret


    
; Converts a double into a 0-terminated ASCII string.
; Assumes the buffer is of an appropriate size.
; Arguments:
;   rdi (float): the integer
;   rsi (buff*): ptr to start of the buffer to write into
; Returns number of characters written to string
; including the 0-char at the end.
dtoa:
    ret
