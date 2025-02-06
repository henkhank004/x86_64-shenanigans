#pragma once
#include "defs.h"
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
//   LIBRARY TO MANAGE MEMORY
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
//
// -> ABBREVIATIONS
// IN THIS LIBRARY THE FOLLOWING NON-STANDARD ABBREVIATIONS MAY OCCUR
//+------------------------+------------------------------------------------+
//| ABBREVIATION           | MEANING                                        |
//+------------------------+------------------------------------------------+
//|  xmblock               | the block pointed to by a xmptr INCLUDING the  |
//|                        | qword before the xmptr storing the total size  |
//+- -- -- -- -- -- -- -- -+- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
//|    (block)             | block will thus refer to the user usable block |
//+------------------------+------------------------------------------------+
//|  xmptr                 | a ptr compliant with this library              |
//|                        | (i.e., allocated by xmalloc)                   |
//|                        | this means this ptr points to the start of the |
//|                        | user usable block, NOT the start of the xmblock|
//+------------------------+------------------------------------------------+
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 

#define XM_METADATA_OFFSET 8

extern void* xmalloc(usize size);
extern void xmfree(void* xmptr);
extern usize xmsize(void* xmptr);
extern void* xmrealloc(void* xmptr, usize new_size);
extern void* xmncpy(void* src, void* dst, usize n);
