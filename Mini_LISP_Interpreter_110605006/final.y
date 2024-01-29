%{
    #include <stdio.h>
    #include <string.h>
    #include <stdbool.h>

    int yylex() ;
    void yyerror(const char *message);
    void semantic_error() ;
    void print_n(int);
    void print_b(int);

    struct VAR {
        int value ;
        char name[20] ;
    } ;

    struct VAR var[10] ;
    struct VAR fvar[10] ;
    int vtop = 0 ;
    int ftop = 0 ;
%}

%code requires
{
    struct VAL {
        int b ;
        int num ;
        char* str ;
        int pos ;
        int isVar ; /* 36 represent var  */

        int fpos ;
        int isFvar ; /* 3 represent fvar */
    } ;
    struct forID {
        int len ;
        char arr[20] ;
    };
}



%union {

    int Integer ;
    char* Str ;
    int Bool ;
    
    struct forID tokenID ;
    struct VAL tokenVAL ;
}


%token<Integer> NUMBER 
%token<tokenID> ID
%token<Bool> BOOL

%token LB RB
%token PRINT_NUM PRINT_BOOL
%token PLUS SUB MUL DIV GR SM EQ MOD 
%token AND OR NOT IF
%token DEFINE FUN

%left PLUS SUB 
%left MUL DIV MOD
%nonassoc GR SM EQ 
/*type*/
%type <tokenVAL> exp num_op eq_exp plus_exp mul_exp 
%type <tokenVAL> and_exp or_exp if_exp def_stmt
%type <Bool> log_op 

%%
Program : stmts {} ;

stmts : stmt stmts
    | {} 
    ;

stmt : exp {}
    | def_stmt {}
    | print_stmt {}
    ;

print_stmt : LB PRINT_NUM exp RB { 
        if ( $3.isVar == 36 ) {
            print_n($3.num) ;
        }
        else print_n($3.num) ;

    }
    | LB PRINT_BOOL exp RB { 
        if ( $3.isVar == 36 ) {
            printf("Print bool:%d\n",var[$3.pos].value) ;
        }
        else print_b($3.b) ;
    
    }
    ;

def_stmt : LB DEFINE ID exp RB{
        /* printf("go def_stmt \n") ; 
        printf("$3: %s\n",$3.arr) ;
        /* printf("sizeof_$3:%d\n", $3.len) ; 
        */
        strncpy( var[vtop].name ,$3.arr, $3.len); 
        var[vtop].value = $4.num ;
        vtop++ ;

    } ; /* variabel = ID */

/* -----------------------EXP down------------------------------- */
exp : BOOL {$$.b=$1;}
    | NUMBER {$$.num=$1;}
    | ID {
        $$.str=$1.arr;
        /* printf("go id \n") ; */
        for (int i = 0 ; i < vtop ; i++ ) {
            /*
            printf("$1: %s\n",$1.arr) ;
            printf("name: %s\n",var[i].name) ;
            */
            if (strcmp($1.arr,var[i].name) == 0 ) {
                
                $$.isVar = 36 ;
                $$.pos = i ;
                $$.num = var[i].value ;
                /*
                printf("go if\n") ;
                printf("match:%s\n",$1.arr) ;
                */
            }
        }  
        /* printf("loop result:\nvtop:%d\nisVar:%d\nid_num:%d\n",vtop, $$.isVar,$$.num) ; */
    }
    | num_op {$$.num=$1.num;}
    | log_op {$$.b=$1;}
    | fun_exp {}
    | fun_call {}
    | if_exp {$$=$1} 
    ;
/* -----------------------EXP up--------------------------------- */


num_op : LB PLUS exp plus_exp RB {
            $$.num = $3.num + $4.num ;
            /* printf("go plus\n"); */
    }   
    |    LB SUB exp exp RB {
            $$.num = $3.num - $4.num ;
    }
    |    LB MUL exp mul_exp RB {
            $$.num = $3.num * $4.num ;
            /* printf("go mul\n"); */
    }
    |    LB DIV exp exp RB {
            $$.num = $3.num / $4.num ;
    }
    |    LB MOD exp exp RB {
            $$.num = $3.num % $4.num ;
    }
    |    LB GR exp exp RB {
            if($3.num > $4.num) $$.b = 1 ;
            else $$.b = 0 ;
    }
    |    LB SM exp exp RB {
            if($3.num < $4.num) $$.b = 1 ;
            else $$.b = 0 ;
    }
    |    LB EQ exp eq_exp RB {
            if($3.num == $4.num) $$.b = 1 ;
            else $$.b = 0 ;
    }
    ;

plus_exp : exp {$$.num = $1.num ;} 
    |    plus_exp exp {$$.num = $1.num + $2.num;}
    ;
mul_exp : exp {$$.num = $1.num; } 
    |    mul_exp exp {$$.num = $1.num * $2.num;}
    ;
eq_exp : exp {$$.num = $1.num } 
    |    eq_exp exp {
            if($1.num == $2.num) $$.b = 1 ;
            else $$.b = 0 ;
        }
    ;

log_op : LB AND exp and_exp RB {
            if($3.b ==1 && $4.b==1) $$ = 1 ;
            else $$ = 0 ;

            /* printf("%d and %d = %d\n",$3.b,$4.b, $$) ; */
    }
    |    LB OR exp or_exp RB {
            if($3.b==1 || $4.b==1) $$ = 1 ;
            else $$ = 0 ;
            /* printf("%d or %d = %d\n",$3.b,$4.b, $$) ; */
    }
    |    LB NOT exp RB {
            if($3.b==1) $$ = 0 ;
            else $$ = 1 ;
            /* printf("not %d = %d\n",$3.b, $$) ; */
    }
    ;
    
and_exp : exp {$$.b = $1.b } 
    |    exp and_exp {
            if($1.b ==1&& $2.b==1) $$.b = 1 ;
            else $$.b = 0 ;
            /* printf("%d and_list %d = %d\n",$1.b,$2.b, $$) ; */
        }
    ;
or_exp : exp {$$.b = $1.b } 
    |    exp or_exp {
            if($1.b == 1|| $2.b==1) $$.b = 1 ;
            else $$.b = 0 ;
            /* printf("%d or_list %d = %d\n",$1.b,$2.b, $$) ; */
        }
    ;

/* if */
if_exp : LB IF exp exp exp RB {
            if($3.b==1) $$=$4 ;
            else if ($3.b==0) $$=$5 ;
            else printf("In IF, Bool has error: %d\n",$3.b);
        } ; /* LB IF test_exp(3) then_exp(4) else_exp(5) RB */

/* fun*/
fun_exp : LB FUN fun_ids fun_body RB {} ;

fun_ids: LB ID_exp RB {} ;
ID_exp : ID {
        strncpy( fvar[ftop].name ,$1.arr, $1.len); 
        /* fvar[ftop].value = $1.num ; */
        ftop++ ;
    }
    | ID ID_exp {
        strncpy( fvar[ftop].name ,$1.arr, $1.len); 
        /* fvar[ftop].value = $1.num ; */
        ftop++ ;
    };   

    | {}
    ; /* ID* */

fun_body : exp ;

fun_call : LB fun_exp param RB {} /* param* */
    |      LB fun_name param RB {} /* param* */
    ;

param : exp ;
/* last_exp : exp ; */
fun_name : ID ;



%%

void semantic_error(){
    printf("Semantic error\n");
}
void print_n(int num) {
    printf("%d\n",num);
}
void print_b(int num) {
    
    if(num==1) printf("#t\n");
    else if(num==0) printf("#f\n");
    else printf("Bool has error: %d\n",num);
}

void yyerror ( const char *message )
{
	//correct = 0;
    printf("There're a fucking syntax error\n");
    /* fprintf (stderr, "%s\n",message); */
	
}
int main(int argc, char *argv[]) {
    yyparse();
    return(0);
}