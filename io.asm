; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
;   PACKAGE FOR BASIC IO UTILITES
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 


%include "xmemory.inc"
%include "str.inc"


section .text
    global print
    global read


; Prints 0-terminated ASCII string.
; Arguments:
;   rdi (char*): text
; Returns return value from SYS_WRITE syscall.
print:
    mov rsi, rdi                                                                
    xor rdx, rdx                                                               
    
.loop:
    cmp byte [rdi], 0
    je .done
    inc rdx
    inc rdi
    jmp .loop

.done:
    mov rax, 1
    mov rdi, 1
    syscall

    ret


; Retrieves 0-terminated ASCII string: will set last byte to 0.
; Arguments:
;   rdi (char*): buffer to read into
;   rsi (size_t): buffer size
; Returns return value from SYS_READ syscall.
read:
    mov r10, rdi
    mov r9, rsi

    ; Obtain input from console
    xor rax, rax
    mov rdi, 0
    mov rsi, r10
    mov rdx, r9
    syscall

    ; 0-terminate the string
    dec r9
    add r10, r9
    mov byte [r10], 0

    ret


; Retrieves 0-terminated ASCII string.
; Returns pointer to smemory compliant buffer containing the string string.
scan:
    ret
