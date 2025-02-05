%include "xmemory.inc"

section .text
    global strfind
    global atoi
    global itoa

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
    mov rax, 0
.loop:
    cmp byte [rdi], 0
    je .done                                                                    ; if the byte at [rdi] is 0, then at end of string
    inc rax
    inc rdi
    jmp .loop
.done:
    ret


; Converts an ASCII 0-terminated string to an intiger.
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

    movzx rcx, byte [rsi]                                                          ; move the current digit into cl
    sub rcx, 48                                                                 ; convert ASCII-char to numeric value
    imul rcx, rdx                                                               ; multiply number by power of 10 assiciated with its position in rdx
    add rax, rcx                                                                ; add the found number to result in rax
    imul rdx, rdx, 10                                                           ; set rdx to the next power of 10
    jmp .loop

.first_char:
    movzx rcx, byte [rsi]
    cmp rcx, 45                                                                  ; check if first char is a minus sign
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

