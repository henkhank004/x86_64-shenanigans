extern strfind      ; defined in "str.asm"
    ; Finds the first instance of a character in a 0-terminated string and returns the position.
    ; Arguments:
    ;   rdi (string): text
    ;   rsi (char)  : char to be found
    ; Returns pointer to first instance of the char, -1 if the char was not found.

extern memalloc     ; defined in "smemory.asm"
    ; Allocates a block of memory with mmap.
    ; Arguments:
    ;   rdi (size_t): desired size of memory in bytes
    ; Returns pointer to beginning of mem buff, -1 if error occured.

extern memfree      ; defined in "smemory.asm"
    ; Free a block of memory allocated by memalloc.
    ; ! Will cause segmentation fault if called with a pointer to a block not allocated by memalloc !
    ; Arguments:
    ;   rdi (addr*): ptr to start of block, must have been allocated by memalloc.
    ; Returns return code of munmap


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
