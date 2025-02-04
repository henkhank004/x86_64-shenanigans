; smemory declarations
extern smalloc
    ; Allocates a block of memory with mmap, returns an smptr.
    ; Arguments:
    ;   rdi (size_t): desired size of memory block in bytes
    ; Returns smptr to the block, if error occured.
    ; Stores size of mem block in the qword before ret_ptr.
    ;   i.e. qword @ [ret_ptr - 8] = sizeof_block

extern smfree
    ; Free a block of memory allocated by smalloc.
    ; Arguments:
    ;   rdi (addr*): smptr to start of block.
    ; Returns return code of munmap

extern smsize
    ; Determine the size of a block of memory allocated by smalloc.
    ; Note that the size will be that of the user usable memory block, it will NOT
    ;   include the qword used before the smptr in rdi that stores the total size of the block.
    ;   to obtain this value add PTR_SIZE_SMALLOC_OFFSET into the return value.
    ; Arguments:
    ;   rdi (addr*): smptr to start of block.
    ; Returns size of user usable space in memory block.

extern smrealloc
    ; Resize the smemory compliant block of memory to desired size.
    ; ! Will cause segmentation fault if not called with a smptr. !
    ; Arguments:
    ;   rdi (addr*): smptr to start of current block
    ;   rsi (size_t): new desired size
    ; Returns smptr to resized block, -1 if an error occured.

extern print            ; defined in "io.asm"
extern read             ; defined in "io.asm"

section .data
    SIZE            equ     5
    SIZE2          equ     15

section .bss    
    buff             resq    1

section .text
    global _start

_start:
    mov rdi, SIZE
    call smalloc
    mov [buff], rax

    mov byte [rax], 'H'
    mov byte [rax+1], 'i'
    mov byte [rax+2], '!'
    mov byte [rax+3], 10

    mov rdi, [buff]
    call print

    mov rdi, [buff]
    mov rsi, SIZE2
    call smrealloc
    mov [buff], rax

    mov byte [rax], 'H'
    mov byte [rax+1], 'e'
    mov byte [rax+2], 'l'
    mov byte [rax+3], 'l'
    mov byte [rax+4], 'o'
    mov byte [rax+5], ','
    mov byte [rax+6], 32
    mov byte [rax+7], 'W'
    mov byte [rax+8], 'o'
    mov byte [rax+9], 'r'
    mov byte [rax+10], 'l'
    mov byte [rax+11], 'd'
    mov byte [rax+12], '!'
    mov byte [rax+13], 10

    mov rdi, [buff]
    call print

    mov rdi, [buff]
    call smfree

    mov rax, 60
    mov rdi, r11
    syscall
