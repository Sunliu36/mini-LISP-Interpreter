%option noyywrap
%{
#include "final.tab.h"

%}

%%
\n                  { /* printf("lex \\n \n");*/ /* do nothing */ }
[ \t]+              { /* printf("lex t\n"); *//* do nothing */ }
"("                 { return LB; }         
")"                 { return RB; }        
"print-num"         {
                        /* printf("lex: print num \n") ; */
                        return PRINT_NUM; }
"print-bool"        { 
                        /* printf("lex: print bool \n") ; */
                        return PRINT_BOOL; }

"+"                 { return PLUS; }
"-"                 { return SUB; }
"*"                 { return MUL; }
"/"                 { return DIV; }
">"                 { return GR; }
"<"                 { return SM; }
"="                 { return EQ; }
"mod"               { return MOD; }

"and"               { return AND; }
"or"                { return OR; }
"not"               { return NOT; }
"if"                { return IF; }

"define"            { /* printf("lex: define \n");*/ return DEFINE; }
"fun"               { return FUN;}


"#t"                {

                        yylval.Bool = 1;
                        return BOOL;
                    }
"#f"                {

                        yylval.Bool = 0;
                        return BOOL;
                    }
(0|[-]?[1-9][0-9]*) {
                        yylval.Integer = atoi(yytext);
                        /* printf("lex number:%s\n",yytext) ;*/
                        return NUMBER;
                    }
[a-z][-|0-9|a-z]*        {
                        // strncpy(yylval.tokenVar.cval, yytext, (sizeof(yytext) / sizeof(char)));
                        strncpy( yylval.tokenID.arr,yytext,(yyleng/sizeof(char))) ;
                        yylval.tokenID.len=yyleng; 
                        /* printf("lex id:%s\n",yytext) ; */
                        return ID;
                    }
.                   { printf("what the fuck is the input?\n");/* do nothing */ }
%%