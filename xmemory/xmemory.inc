; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
;   LIBRARY TO MANAGE MEMORY
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
;
; -> ABBREVIATIONS
; IN THIS LIBRARY THE FOLLOWING NON-STANDARD ABBREVIATIONS MAY OCCUR
;  +------------------------+------------------------------------------------+
;  | ABBREVIATION           | MEANING                                        |
;  +------------------------+------------------------------------------------+
;  |  xmblock               | the block pointed to by a xmptr INCLUDING the  |
;  |                        | qword before the xmptr storing the total size  |
;  +- -- -- -- -- -- -- -- -+- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
;  |    (block)             | block will thus refer to the user usable block |
;  +------------------------+------------------------------------------------+
;  |  xmptr                 | a ptr compliant with this library              |
;  |                        | (i.e., allocated by xmalloc)                   |
;  |                        | this means this ptr points to the start of the |
;  |                        | user usable block, NOT the start of the xmblock|
;  +------------------------+------------------------------------------------+
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 


XM_METADATA_OFFSET equ 8
    ; one qword to store the xmblock's size


extern xmalloc
extern xmfree
extern xmsize
extern xmrealloc
extern xmncpy
