#pragma once
#include "defs.h"
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 
//  LIBRARY FOR BASIC STRING UTILITIES
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- 


extern char* strfind(char* str, char c); 

extern usize strlen(char* str);
extern usize strlen0(char* str);

extern isize atoi(char* str);
extern char* itoa(isize n);

extern float atof(char* str);
extern char* ftoa(float f);
