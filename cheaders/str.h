#pragma once
#include "stddefs.h"
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
//  LIBRARY FOR BASIC STRING UTILITES
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 


extern char* strfind(char* str, char c); 
extern usize strlen(char* str);
extern usize strlen0(char* str);
extern isize atoi(char* str);
extern char* itoa(isize n);
