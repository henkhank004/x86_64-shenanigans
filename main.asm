; xmemory declarations
extern xmalloc
extern xmfree
extern xmsize
extern xmrealloc
extern xmcpy

; io declarations
extern print            
extern read             

section .bss    
    buff            resq    1
    buff2           resq    1

section .text
    global _start

_start:
    mov rdi, 15
    call xmalloc
    mov [buff], rax

    mov rdi, 17
    call xmalloc
    mov [buff2], rax

    mov rax, [buff]
    mov byte [rax], 'H'
    mov byte [rax+1], 'e'
    mov byte [rax+2], 'l'
    mov byte [rax+3], 'l'
    mov byte [rax+4], 'o'
    mov byte [rax+5], ','
    mov byte [rax+6], ' '
    mov byte [rax+7], 'W'
    mov byte [rax+8], 'o'
    mov byte [rax+9], 'r'
    mov byte [rax+10], 'l'
    mov byte [rax+11], 'd'
    mov byte [rax+12], '!'
    mov byte [rax+13], 10

    mov rdi, [buff]
    mov rsi, [buff2]
    mov rdx, 15
    call xmcpy

    mov rdi, [buff]
    call xmfree

    mov rax, [buff2]
    mov byte [rax+13], ' '
    mov byte [rax+14], ':'
    mov byte [rax+15], 51
    mov byte [rax+16], 10

    mov rdi, [buff2]
    call print

    mov rdi, [buff2]
    call xmfree

    mov rax, 60
    xor rdi, rdi
    syscall
