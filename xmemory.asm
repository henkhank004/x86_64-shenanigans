; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
;   PACKAGE TO MANAGE MEMORY
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
;
; -> ABBREVIATIONS
; IN THIS LIBRARY THE FOLLOWING NON-STANDARD ABBREVIATIONS MAY OCCURE
;  +------------------------+------------------------------------------------+
;  | ABBREVIATION           | MEANING                                        |
;  +------------------------+------------------------------------------------+
;  |  xmblock               | the block pointed to by a xmptr INCLUDING the  |
;  |                        | qword before the xmptr storing the total size  |
;  +- -- -- -- -- -- -- -- -+- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
;  |    (block)             | block will thus refer to the user usable block |
;  +------------------------+------------------------------------------------+
;  |  xmptr                 | a ptr complient with this library              |
;  |                        | (i.e., allocated by xmalloc)                   |
;  |                        | this means this ptr points to the start of the |
;  |                        | user usable block, NOT the start of the xmblock|
;  +------------------------+------------------------------------------------+
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 

XM_METADATA_OFFSET equ 8

section .text
    global xmalloc
    global xmfree
    global xmsize
    global xmrealloc
    global xmcpy

; Allocates a block of memory with mmap, returns an smptr.
; Arguments:
;   rdi (size_t): desired size of memory block in bytes
; Returns smptr to the block, if error occured.
; Stores size of mem block in the qword before ret_ptr.
;   i.e. qword @ [ret_ptr - 8] = sizeof_block
xmalloc:
    mov r11, rdi                                                                ; copy size into r11
    add r11, XM_METADATA_OFFSET                                                 ; adjust for meta data storage

    mov rax, 9                                                                  ; mmap syscall id
    mov rsi, r11                                                                ; specify size
    xor rdi, rdi                                                                ; let os choose addr
    mov rdx, 0x3                                                                ; readable and writable
    mov r10, 0x22                                                               ; private and anonymous
    mov r8, -1                                                                  ; no fd
    xor r9, r9                                                                  ; no offset
    syscall                                                                     ; rax now points to start of block (addr*)

    cmp rax, -1                                                                 ; if error occured in mmap, rax = -1
    je .err                                                                     ; end procedure, return rax as -1

    mov qword [rax], r11                                                        ; store block's size in the first qword
    add rax, XM_METADATA_OFFSET                                                 ; shift addr* over by 8 bytes, to start at usable memory

.err:
    ret

; Free a block of memory allocated by smalloc.
; Arguments:
;   rdi (addr*): xmptr to start of block.
; Returns return code of munmap
xmfree:
    sub rdi, XM_METADATA_OFFSET                                                 ; subtract one qword to include the size stored by xmalloc
    mov rsi, qword [rdi]                                                        ; move the full size of the block into rsi
    mov rax, 11                                                                 ; syscall id for munmap
    syscall                                                                     
    ret


; Determine the size of a block of memory allocated by smalloc.
; Note that the size will be that of the user usable memory block, it will NOT
;   include the qword used before the smptr in rdi that stores the total size of the block.
;   to obtain this value add PTR_SIZE_SMALLOC_OFFSET into the return value.
; Arguments:
;   rdi (addr*): xmptr to start of block.
; Returns size of user usable space in memory block.
; !! TESTING IS REQUIRED, ERRONIOUS VALUES MAY BE RETURNED !!
xmsize:
    sub rdi, XM_METADATA_OFFSET                                                 ; set ptr to point to start of smblock, i.e. the size therof
    mov rax, qword [rdi]                                                        ; mov the xmblock's size into rax
    sub rax, XM_METADATA_OFFSET                                                 ; adjust for the first qword storing the xmblock's size, this qword is not useable by the user
    ret
    

; Resize the smemory compliant block of memory to desired size.
; ! Will cause segmentation fault if not called with a smptr. !
; Arguments:
;   rdi (addr*): xmptr to start of current block
;   rsi (size_t): new desired size
; Returns xmptr to resized block, -1 if an error occured.
xmrealloc:
    mov rdx, rsi                                                                ; set rdx to the desired length
    add rdx, XM_METADATA_OFFSET                                                 ; adjust for the meta data storage
    mov r11, rdx                                                                ; save the new size in r11
    sub rdi, XM_METADATA_OFFSET                                                 ; get ptr to start of xmblock
    mov rsi, qword [rdi]                                                        ; set rsi to the current length of the xmblock
    mov r10, 0x1                                                                ; MREMAP_MAYMOVE
    xor r8, r8                                                                  ; let os choose new address
    mov rax, 25                                                                 ; mremap syscall id
    syscall                                                                     ; rax now points to the start of the new xmblock
    cmp rax, -1                                                                 ; if rax = -1, an error occured
    je .err

    mov qword [rax], r11                                                        ; put the new size in the qword at the start of the xmblock
    add rax, XM_METADATA_OFFSET                                                 ; set rax to the xmptr, pointing to the user usable block

.err:
    ret                                                                         ; return rax as xmptr to the new block, -1 if an error occured.



; Copies the number of bytes specified from src to dest.
; Arguments a:
;   rdi (src*): ptr to source buffer
;   rsi (dst*): ptr to destination buffer
;   rdx (size_t): number of bytes to copy
; No return value.
xmcpy:
    mov rax, rdx                                                                ; store num in rax for division
    mov rcx, 8                                                                  ; move size of one qword into rcx
    xor rdx, rdx
    div rcx                                                                     ; rax now holds the amount of qwords to cpy, rdx the amount of bytes to cpy after the qwords

.cpyloop:
    cmp rax, 0
    jg .cpyqword                                                                ; remaining qwords to be cpy'd

.cpyloopb:                                                                      
    cmp rdx, 0
    jg .cpybyte                                                                 ; remaining bytes to be cpy'd

    jmp .done                                                                   ; if rax and rbx are 0, no more mem to cpy

.cpyqword:
    mov rcx, qword [rdi]                                                        ; cpy qword from src to rcx 
    mov qword [rsi], rcx                                                        ; cpy qword from rcx to dst
    dec rax                                                                     ; dec rax to correct amount of qwords left to cpy
    add rdi, 8                                                                  ; shift rdi one qword over for next cpy
    add rsi, 8                                                                  ; shift rsi one qword over for next cpy
    jmp .cpyloop                                                                

.cpybyte:
    mov cl, byte [rdi]                                                          ; cpy byte from src to cl
    mov byte [rsi], cl                                                          ; cpy byte from cl  to dst
    dec rdx                                                                     ; rec rdx to correct amount of bytes left to cpy
    add rdi, 1                                                                  ; shift rdi one byte over for next cpy
    add rsi, 1                                                                  ; shift rsi one byte over for next cpy
    jmp .cpyloopb                                                               ; if we are already processing bytes, no need to check if qwords remain to be copied

.done:
    ret
