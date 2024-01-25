Mini Lisp Interpreter
===

LEX
-


:::warning
注意事項：
>標投記得加%option noyywrap：好像是因為沒加會output出一些奇怪的東西
>lex是可以回傳struct型態的變數給yacc的
```=
strncpy( yylval.tokenID.arr,yytext,(yyleng/sizeof(char))) ;
// tokenID就是我宣告的struct名稱，arr則是裡面的元素，注意都直接用定義的變數名就好
```
:::

YACC
-

1. typedef

```=
struct VAL {
    int b         //紀錄boolean型別，沒用bool的原因c不讓我用
    int num       //紀錄數值
    char* str ;   //紀錄字串、主要是紀錄ID
    int pos ;     //紀錄變數在var,也就是儲存變數代表數值的陣列中的位置
    int isVar ;   //如果數值是36代表這是一個變數，要用pos去var找值，而不是直接用num
    int fpos ;    //紀錄函數內變數在fvar,也就是儲存函數變數代表數值的陣列中的位置
    int isFvar ;  //如果數值是3代表這是一個函數內變數，要用fpos去vfar找值，而不是直接用num
```
```=
struct forID {
        int len ;      //由lex的yyleng直接回傳ID長度
        char arr[20] ; //儲存id（遇到問題：不確定只用了array的一點點，在傳遞資料的時候的正確性。
    };
```
:::danger

注意事項
>註解文法： /* 註解 */
>note: 記得前後要空格
:::

遇到問題
-
1. 只能處理單行輸入
>原本
```yacc=
Program : stmt
stmt : expr
```
>應該要是：
```yacc=
Program : stmts
stmts : stmt stmts 
    | {}
    ;
stmt : expr
```

未來展望
-
1. 用ast完成整個interpreter
2. 更熟悉左優先、右優先、nonassoc的確切使用原因
3. 要再更熟悉什麼是在c＋＋裡面才能用的