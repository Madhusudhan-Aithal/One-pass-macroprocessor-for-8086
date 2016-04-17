%{
    #include <stdio.h>
    enum states {
        NORMAL,
        COMMENT_LINE
    };
    enum states STATE = NORMAL;
    int comments = 0;
%}
%%
";"    {if (STATE==NORMAL) STATE=COMMENT_LINE;
    }
\n      { 
            if (STATE == COMMENT_LINE) {
                comments++;
                STATE = NORMAL;
            }           
            if (STATE == NORMAL)
                fprintf(yyout, "\n");
        }
.       {
            if (STATE == NORMAL)
                fprintf(yyout, "%s", yytext);
        }
%%
int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Usage: ./run input.c output.c\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");
    yyout = fopen(argv[2], "w");
    yylex();

    printf("No. of comment lines: %d\n", comments);


    return 0;
}
    
int yywrap() { return 1; }
