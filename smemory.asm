; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
;  | IMPORTANT INFORMATION                                                   |
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
;
; -> ABBREVIATIONS
; IN THIS LIBRARY THE FOLLOWING NON-STANDARD ABBREVIATIONS MAY OCCURE
;  +------------------------+------------------------------------------------+
;  | ABBREVIATION           | MEANING                                        |
;  +------------------------+------------------------------------------------+
;  |  smblock               | the block pointed to by a smptr INCLUDING the  |
;  |                        | qword before the smptr storing the total size  |
;  +- -- -- -- -- -- -- -- -+- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
;  |    (block)             | block will thus refer to the user usable block |
;  +------------------------+------------------------------------------------+
;  |  smptr                 | a ptr complient with this library              |
;  |                        | (i.e., allocated by smalloc)                   |
;  |                        | this means this ptr points to the start of the |
;  |                        | user usable block, NOT the start of the smblock|
;  +------------------------+------------------------------------------------+
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 

PTR_METADATA_OFFSET equ 8                                                       ; one qword to store the smblock's size

section .text
    global smalloc
    global smfree
    global smsize
    global smrealloc


; Allocates a block of memory with mmap, returns an smptr.
; Arguments:
;   rdi (size_t): desired size of memory block in bytes
; Returns smptr to the block, if error occured.
; Stores size of mem block in the qword before ret_ptr.
;   i.e. qword @ [ret_ptr - 8] = sizeof_block
smalloc:
    mov r11, rdi                                                                ; copy size into r11
    add r11, PTR_METADATA_OFFSET                                                ; adjust for meta data storage

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
    add rax, PTR_METADATA_OFFSET                                                ; shift addr* over by 8 bytes, to start at usable memory

.err:
    ret

; Free a block of memory allocated by smalloc.
; Arguments:
;   rdi (addr*): smptr to start of block.
; Returns return code of munmap
smfree:
    sub rdi, PTR_METADATA_OFFSET                                                ; subtract one qword to include the size stored by smalloc
    mov rsi, qword [rdi]                                                        ; move the full size of the block into rsi
    mov rax, 11                                                                 ; syscall id for munmap
    syscall                                                                     
    ret


; Determine the size of a block of memory allocated by smalloc.
; Note that the size will be that of the user usable memory block, it will NOT
;   include the qword used before the smptr in rdi that stores the total size of the block.
;   to obtain this value add PTR_SIZE_SMALLOC_OFFSET into the return value.
; Arguments:
;   rdi (addr*): smptr to start of block.
; Returns size of user usable space in memory block.
; !! TESTING IS REQUIRED, ERRONIOUS VALUES MAY BE RETURNED !!
smsize:
    sub rdi, PTR_METADATA_OFFSET                                                ; set ptr to point to start of smblock, i.e. the size therof
    mov rax, qword [rdi]                                                        ; mov the smblock's size into rax
    sub rax, PTR_METADATA_OFFSET                                                ; adjust for the first qword storing the smblock's size, this qword is not useable by the user
    ret
    

; Resize the smemory compliant block of memory to desired size.
; ! Will cause segmentation fault if not called with a smptr. !
; Arguments:
;   rdi (addr*): smptr to start of current block
;   rsi (size_t): new desired size
; Returns smptr to resized block, -1 if an error occured.
smrealloc:
    mov rdx, rsi                                                                ; set rdx to the desired length
    add rdx, PTR_METADATA_OFFSET                                                ; adjust for the meta data storage
    mov r11, rdx                                                                ; save the new size in r11
    sub rdi, PTR_METADATA_OFFSET                                                ; get ptr to start of smblock
    mov rsi, qword [rdi]                                                        ; set rsi to the current length of the smblock
    mov r10, 0x1                                                                ; MREMAP_MAYMOVE
    xor r8, r8                                                                  ; let os choose new address
    mov rax, 25                                                                 ; mremap syscall id
    syscall                                                                     ; rax now points to the start of the new smblock
    cmp rax, -1                                                                 ; if rax = -1, an error occured
    je .err

    mov qword [rax], r11                                                        ; put the new size in the qword at the start of the smblock
    add rax, PTR_METADATA_OFFSET                                                ; set rax to the smptr, pointing to the user usable block

.err:
    ret                                                                         ; return rax as smptr to the new block, -1 if an error occured.



