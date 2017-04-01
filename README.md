# One-pass-macroprocessor-for-8086
1. Steps to execute code with implementation of nested macros and generation of unique labels

  lex macroprocessor3.l
  
  cc lex.yy.c
  
  ./a.out



2. Steps to execute code without implementation of nested macros and generation of unique labels

  lex macroprocessor.l
  
  cc lex.yy.c
  
  ./a.out
