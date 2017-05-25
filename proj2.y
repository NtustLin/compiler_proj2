%{
    #include "lex.yy.c"
    #include <stdio.h>
    #define Trace(t) printf(t)
    void yyerror(char *msg);
    using namespace std;

    std::string nowscope;
    list<std::string> scope;
    
    void insert(std::string s, idtuple id){
        symbolTables.begin()->insert(s,id);
    }
    // 執行的時候 提取值用的 要看全部的人有宣告過的東西
    int lookup(std::string s){
        for (std::list<hashtable>::iterator it=symbolTables.begin(); it!=symbolTables.end(); ++it){
            if(it->lookup(s)==1)
                return 1;
        }
        return -1;
    }   
    // 宣告用只看自己的scope
    int current_lookup(std::string s){
        if(symbolTables.front().lookup(s)==1)
            return 1;
        else
            return -1;
    }
    void init_scope(){
        create();
        nowscope = "golbal";
        scope.push_front("golbal");
    }
    void start_scope(std::string s){
        create();
        nowscope = s;
        scope.push_front(s);
    }
    void end_scope(){
        symbolTables.pop_front();
        scope.pop_front();
        nowscope = scope.front();
    }
    // 從hashtable裡面拿資料出來
    infor::info getdata(std::string s){
        infor::info in;
        idtuple id;
        for (std::list<hashtable>::iterator it=symbolTables.begin(); it!=symbolTables.end(); ++it){
            if(it->lookup(s)==1){
                id = it->getdata(s);
                in.name = new std::string(id.getname());
                in.value = new std::string(id.getvalue());
                in.type = id.gettype();
                in.style = id.getstyle();
                in.size = id.getsize();
            }
        }
        return in;    
    }
    void dump(){
        for (std::list<hashtable>::iterator it=symbolTables.begin(); it!=symbolTables.end(); ++it){
            it->dump();
            // std::cout << it->first << " => " << it->second.getname() << '\n';
        }
    }

%}
%union {
    int val;
    // id的資訊 名字 數值 類型 型態 空間大小
    struct info
    {
        std::string* name;
        std::string* value;
        int style;
        int type;
        int size;
    }myinfo;
}
/* tokens */
%token BOOL BREAK CASE CONST CONTINUE DEFAULT ELSE FALSE FOR FUNC GO IF IMPORT INT NIL PRINT PRINTLN REAL RETURN STRING STRUCT SWITCH TRUE TYPE VAR VOID WHILE READ
%token COMMA COLON SEMICOLON LEFT_PARENTHESES RIGHT_PARENTHESES LEFT_SQUAREBRACKETS RIGHT_SQUAREBRACKETS LEFT_BRACKETS RIGHT_BRACKETS
%token ARITHMETIC_ADDITION ARITHMETIC_SUBTRACTION ARITHMETIC_MULTIPLICATION ARITHMETIC_DIVIDE
%token EXPONENTIATION REMAINDER
%token RELATIONAL_LESS RELATIONAL_LESSEQUAL RELATIONAL_GREATEREQUAL RELATIONAL_GREATER RELATIONAL_EQUAL RELATIONAL_NOTEQUAL
%token LOGICAL_AND LOGICAL_OR LOGICAL_NOT ASSIGNMENT
%token COMPOUNDOPERATORS_ADDASSIGN COMPOUNDOPERATORS_SUBASSIGN COMPOUNDOPERATORS_MULASSIGN COMPOUNDOPERATORS_DIVASSIGN

%token<myinfo> IDENTIFIERS BOOLEANCONSTANTS_TRUE BOOLEANCONSTANTS_FALSE REALCONSTANTS INTEGERCONSTANTS STRINGCONSTANTS

%left ARITHMETIC_ADDITION ARITHMETIC_SUBTRACTION
%left ARITHMETIC_MULTIPLICATION ARITHMETIC_DIVIDE REMAINDER
%left EXPONENTIATION
%nonassoc POSITIVE
%nonassoc NEGATIVE

%type<val> type 
%type<myinfo> exp number int_exp bool_exp num_exp func_exp array_exp constant variable constant_exp declaration simple

%%
start:              programs{
                    Trace("Reducing to start\n");
                }
                ;
programs:           program programs
                |   
                {
                    Trace("Reducing to programs\n");
                }
                ;
program:            functions
                |   contents{
                    Trace("Reducing to program\n");
                }
                ;
functions:          function functions
                |   
                {
                    Trace("Reducing to functions\n");
                }
                ;
function:           FUNC type IDENTIFIERS LEFT_PARENTHESES formal_arguments RIGHT_PARENTHESES compound{
                    // function 要被宣告時利用current_lookup function 去看這個id在當前scope裡是否已經被宣告過了
                    if (current_lookup($3.name->c_str())==-1){
                        idtuple temp($3.name->c_str(), nowscope, "0", $2, FUNC_STYLE, 1);
                        insert($3.name->c_str(),temp);
                    }else{
                        printf("func redefine\n");
                        return 1;
                    }
                    Trace("Reducing to function\n");
                }
                ;

type:               BOOL{
                    $$=BOOL_TYPE;
                    Trace("Reducing to type\n");
                }
                |   INT{
                    $$=INT_TYPE;
                    Trace("Reducing to type\n");
                }
                |   REAL{
                    $$=REAL_TYPE;
                    Trace("Reducing to type\n");
                }
                |   STRING{
                    $$=STRING_TYPE;
                    Trace("Reducing to type\n");
                }
                |   VOID{
                    $$=VOID_TYPE;
                    Trace("Reducing to type\n");
                }
                ;

formal_arguments:   formal_argument COMMA formal_arguments
                |   formal_argument
                |
                {
                    Trace("Reducing to formal_arguments\n");
                }
                ;

formal_argument:    IDENTIFIERS type{
                    Trace("Reducing to formal_argument\n");
                }
                ;

exp:                num_exp{
                    $$=$1;
                    Trace("Reducing to exp\n");
                }
                |   bool_exp{
                    $$=$1;
                    Trace("Reducing to exp\n");
                }
                |   array_exp{
                    $$=$1;
                    Trace("Reducing to exp\n");   
                }
                |   func_exp{
                    $$=$1;
                    Trace("Reducing to exp\n");   
                }
                |   STRINGCONSTANTS{
                    $$=$1;
                    Trace("Reducing to exp\n");
                }
                ;

contents:           content contents
                |   
                {
                    Trace("Reducing to contents\n");
                }
                ;
content:            declaration
                |   statement
                |   function{
                    Trace("Reducing to content\n");
                }
                ;

/*statements:         statement statements
                |
                {
                    Trace("Reducing to statements\n");
                }
                ;*/
statement:          simple
                |   compound
                |   conditional
                |   loop
                |   procedure_invocation
                {
                    Trace("Reducing to statement\n");
                }
                ;
simple:             IDENTIFIERS ASSIGNMENT exp{
                    // 判斷id是否存在 再判斷id是不是const 再判斷type是否相同
                    if(lookup($1.name->c_str())==1){
                        $1 = getdata($1.name->c_str());
                        if($1.style==CONST_STYLE){
                            printf("const can not be assign\n");
                            return 1;
                        }
                        if ($1.type!=$3.type){
                            printf("type is not equal\n");
                            return 1;
                        }
                        $$ = getdata($3.name->c_str());
                    }else{
                        printf("id doesn't exist\n");
                        return 1;
                    }
                    Trace("Reducing to simple\n");
                }
                |   IDENTIFIERS LEFT_SQUAREBRACKETS int_exp RIGHT_SQUAREBRACKETS ASSIGNMENT exp{
                    // 判斷array id是否存在 再判斷type是否相同
                    if(lookup($1.name->c_str())==1){
                        $1 = getdata($1.name->c_str());
                        if ($1.type!=$6.type){
                            printf("type is not equal\n");
                            return 1;
                        }
                        $$ = getdata($6.name->c_str()); 
                    }else{
                        printf("id doesn't exist\n");
                        return 1;
                    }
                    Trace("Reducing to simple\n");
                }
                |   PRINT exp{
                    Trace("Reducing to simple\n");
                }
                |   PRINTLN exp{
                    Trace("Reducing to simple\n");
                }
                |   READ IDENTIFIERS{
                    Trace("Reducing to simple\n");
                }
                |   RETURN{
                    Trace("Reducing to simple\n");
                }
                |   RETURN exp{
                    Trace("Reducing to simple\n");
                }
                ;
                // 遇到大括號 就開新的scope
compound:           LEFT_BRACKETS{start_scope("compound");} contents RIGHT_BRACKETS
                {
                    // 大括號結束 關閉
                    end_scope();
                    Trace("Reducing to compound\n");
                }
                ;

conditional:        IF LEFT_PARENTHESES bool_exp RIGHT_PARENTHESES compound ELSE compound{
                    Trace("Reducing to conditional\n");
                }
                |   IF LEFT_PARENTHESES bool_exp RIGHT_PARENTHESES compound
                {
                    Trace("Reducing to conditional\n");
                }
                ;
                    // 這邊值注意一下 再我的設定之上 分號一定要
loop:               FOR LEFT_PARENTHESES statement SEMICOLON bool_exp SEMICOLON statement RIGHT_PARENTHESES compound{
                    Trace("Reducing to loop\n");
                }
                ;
procedure_invocation:
                    GO func_exp
                {
                    Trace("Reducing to procedure_invocation\n");
                }
                ;

/*declarations:       declaration declarations
                |
                {
                    Trace("Reducing to declarations\n");
                }
                ;*/
declaration:        constant{
                    Trace("Reducing to declaration\n");
                }
                |   variable{
                    Trace("Reducing to declaration\n");
                }
                |   array{
                    Trace("Reducing to declaration\n");
                }
                ;
//have to be change when you are doing type verify
constant_exp:       
                    exp
                {   
                    //查exp 是不是const
                    if($1.style==CONST_STYLE)
                        $$=$1;
                    else{
                        printf("error! not a const value\n");
                        return 1;
                    }
                    Trace("Reducing to exp\n");
                }
                ;

constant:           CONST IDENTIFIERS ASSIGNMENT constant_exp{
                    // const 要被宣告時利用current_lookup function 去看這個id在當前scope裡是否已經被宣告過了
                    
                    if (current_lookup($2.name->c_str())==-1){
                        // 沒有就存值
                        idtuple temp($2.name->c_str(), nowscope, $4.value->c_str(), $4.type, CONST_STYLE, 1);
                        insert($2.name->c_str(),temp);
                    }else{
                        printf("id redefine\n");
                        return 1;
                    }

                    Trace("Reducing to constant\n");
                }
                ;
                    // var 要被宣告時利用current_lookup function 去看這個id在當前scope裡是否已經被宣告過了

variable:           VAR IDENTIFIERS type ASSIGNMENT constant_exp{
                        // 沒有就存值
                    if (current_lookup($2.name->c_str())==-1 && $3==$5.type){
                        idtuple temp($2.name->c_str(), nowscope, $5.value->c_str(), $3, VAR_STYLE, 1);
                        insert($2.name->c_str(),temp);
                    }else{
                        printf("id redefine or wrong type assign\n");
                        return 1;
                    }
                    Trace("Reducing to variable\n");
                }
                |   VAR IDENTIFIERS type{
                    if (current_lookup($2.name->c_str())==-1){
                        idtuple temp($2.name->c_str(), nowscope, "0", $3, VAR_STYLE, 1);
                        insert($2.name->c_str(),temp);
                    }else{
                        printf("id redefine\n");
                        return 1;
                    }
                    Trace("Reducing to variable\n");
                }
                ;

                    // array 要被宣告時利用current_lookup function 去看這個id在當前scope裡是否已經被宣告過了
array:              VAR IDENTIFIERS LEFT_SQUAREBRACKETS int_exp RIGHT_SQUAREBRACKETS type
                {
                    // 沒有就存值
                    if (current_lookup($2.name->c_str())==-1){
                        idtuple temp($2.name->c_str(), nowscope, "0", $6, ARRAY_STYLE, atoi($4.value->c_str()));
                        insert($2.name->c_str(),temp);
                    }else{
                        printf("array redefine\n");
                        return 1;
                    }
                    Trace("Reducing to array\n");
                }
                ;
// 布林型態的運算
bool_exp:           LEFT_PARENTHESES bool_exp RIGHT_PARENTHESES{$$=$2;}
                |   num_exp RELATIONAL_LESS num_exp {
                        if(($1.type==INT_TYPE || $3.type==INT_TYPE || $1.type==REAL_TYPE || $3.type==REAL_TYPE) && $1.type==$3.type){
                            $$=$1;
                            $$.type = BOOL_TYPE;
                            if(atof($1.value->c_str())<atof($3.value->c_str())){
                                $$.value=new string("1");
                            }else{
                                $$.value=new string("0");
                            }
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   num_exp RELATIONAL_LESSEQUAL num_exp {
                        if(($1.type==INT_TYPE || $3.type==INT_TYPE || $1.type==REAL_TYPE || $3.type==REAL_TYPE) && $1.type==$3.type){
                            $$=$1;
                            $$.type = BOOL_TYPE;
                            if(atof($1.value->c_str())<=atof($3.value->c_str())){
                                $$.value=new string("1");
                            }else{
                                $$.value=new string("0");
                            }
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   num_exp RELATIONAL_GREATEREQUAL num_exp {
                        if(($1.type==INT_TYPE || $3.type==INT_TYPE || $1.type==REAL_TYPE || $3.type==REAL_TYPE) && $1.type==$3.type){
                            $$=$1;
                            $$.type = BOOL_TYPE;
                            if(atof($1.value->c_str())>=atof($3.value->c_str())){
                                $$.value=new string("1");
                            }else{
                                $$.value=new string("0");
                            }
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   num_exp RELATIONAL_GREATER num_exp{
                        if(($1.type==INT_TYPE || $3.type==INT_TYPE || $1.type==REAL_TYPE || $3.type==REAL_TYPE) && $1.type==$3.type){
                            $$=$1;
                            $$.type = BOOL_TYPE;
                            if(atof($1.value->c_str())>atof($3.value->c_str())){
                                $$.value=new string("1");
                            }else{
                                $$.value=new string("0");
                            }
                        }else{
                            // symbolTables.front().dump();
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   num_exp RELATIONAL_EQUAL num_exp{
                        if(($1.type==INT_TYPE || $3.type==INT_TYPE || $1.type==REAL_TYPE || $3.type==REAL_TYPE) && $1.type==$3.type){
                            $$=$1;
                            $$.type = BOOL_TYPE;
                            if(atof($1.value->c_str())==atof($3.value->c_str())){
                                $$.value=new string("1");
                            }else{
                                $$.value=new string("0");
                            }
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   num_exp RELATIONAL_NOTEQUAL num_exp{
                        if(($1.type==INT_TYPE || $3.type==INT_TYPE || $1.type==REAL_TYPE || $3.type==REAL_TYPE) && $1.type==$3.type){
                            $$=$1;
                            $$.type = BOOL_TYPE;
                            if(atof($1.value->c_str())!=atof($3.value->c_str())){
                                $$.value=new string("1");
                            }else{
                                $$.value=new string("0");
                            }
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   bool_exp LOGICAL_AND bool_exp{
                        if($1.type==BOOL_TYPE && $3.type==BOOL_TYPE){
                            $$=$1;
                            if((atoi($1.value->c_str())==0) || (atoi($3.value->c_str()))==0){
                                $$.value=new string("0");
                            }else{
                                $$.value=new string("1");
                            }
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   bool_exp LOGICAL_OR bool_exp{
                        if($1.type==BOOL_TYPE && $3.type==BOOL_TYPE){
                            $$=$1;
                            if((atoi($1.value->c_str())==1)||(atoi($3.value->c_str()))==1){
                                $$.value=new string("1");
                            }else{
                                $$.value=new string("0");
                            }
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   LOGICAL_NOT bool_exp{
                        if($2.type==BOOL_TYPE){
                            $$=$2;
                            if(atoi($2.value->c_str())==0){
                                $$.value=new string("1");
                            }else{
                                $$.value=new string("0");
                            }
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   BOOLEANCONSTANTS_TRUE{
                    $$=$1;
                    Trace("Reducing to bool_exp\n");
                }
                |   BOOLEANCONSTANTS_FALSE{
                    $$=$1;
                    Trace("Reducing to bool_exp\n");
                }
                |   IDENTIFIERS{
                    $1 = getdata($1.name->c_str());
                    $$=$1;
                    Trace("Reducing to bool_exp\n");
                }
                ;
// 所有可以用來表示數字的nonterminal
number:             INTEGERCONSTANTS{
                    $$=$1;
                    Trace("Reducing to number\n");
                }
                |   REALCONSTANTS{
                    $$=$1;
                    Trace("Reducing to number\n");
                }
                |   func_exp{
                    $$=$1;
                    Trace("Reducing to number\n");
                }
                |   array_exp{
                    $$=$1;
                    Trace("Reducing to number\n");
                }
                |   IDENTIFIERS{
                    $1 = getdata($1.name->c_str());
                    $$=$1;
                    Trace("Reducing to number\n");
                }
                ;
// 數字型態的運算
num_exp:            LEFT_PARENTHESES num_exp RIGHT_PARENTHESES{$$=$2;}
                |   num_exp ARITHMETIC_ADDITION num_exp{
                        if($1.type==$3.type && (($1.type==INT_TYPE)||($1.type==REAL_TYPE))){
                            $$ = $1;
                            $$.value = new string(to_string(atof($1.value->c_str())+atof($3.value->c_str())));
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   num_exp ARITHMETIC_SUBTRACTION num_exp{
                        if($1.type==$3.type && (($1.type==INT_TYPE)||($1.type==REAL_TYPE))){
                            $$ = $1;
                            $$.value = new string(to_string(atof($1.value->c_str())-atof($3.value->c_str())));
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   num_exp ARITHMETIC_MULTIPLICATION num_exp{
                        if($1.type==$3.type && (($1.type==INT_TYPE)||($1.type==REAL_TYPE))){
                            $$ = $1;
                            $$.value = new string(to_string(atof($1.value->c_str())*atof($3.value->c_str())));
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   num_exp ARITHMETIC_DIVIDE num_exp{
                        if($1.type==$3.type && (($1.type==INT_TYPE)||($1.type==REAL_TYPE))){
                            $$ = $1;
                            $$.value = new string(to_string(atof($1.value->c_str())/atof($3.value->c_str())));
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   ARITHMETIC_ADDITION num_exp %prec POSITIVE{
                        $$ = $2;
                        Trace("Reducing to num_exp\n");
                }
                |   ARITHMETIC_SUBTRACTION num_exp %prec NEGATIVE{
                        $$ = $2;
                        $$.value = new string(to_string(-1.0*atof($2.value->c_str())));
                        Trace("Reducing to num_exp\n");
                }
                |   number{
                        $$=$1;
                        Trace("Reducing to num_exp\n");
                }
                ;
// int型態的運算
int_exp:            LEFT_PARENTHESES int_exp RIGHT_PARENTHESES{$$=$2;}
                |   int_exp ARITHMETIC_ADDITION int_exp{
                        if($1.type==$3.type && $1.type==INT_TYPE){
                            $$ = $1;
                            $$.value = new string(to_string(atoi($1.value->c_str())+atoi($3.value->c_str())));
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   int_exp ARITHMETIC_SUBTRACTION int_exp{
                        if($1.type==$3.type && $1.type==INT_TYPE){
                            $$ = $1;
                            $$.value = new string(to_string(atoi($1.value->c_str())-atoi($3.value->c_str())));
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   int_exp ARITHMETIC_MULTIPLICATION int_exp{
                        if($1.type==$3.type && $1.type==INT_TYPE){
                            $$ = $1;
                            $$.value = new string(to_string(atoi($1.value->c_str())*atoi($3.value->c_str())));
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   int_exp ARITHMETIC_DIVIDE int_exp{
                        if($1.type==$3.type && $1.type==INT_TYPE){
                            $$ = $1;
                            $$.value = new string(to_string(atoi($1.value->c_str())/atoi($3.value->c_str())));
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   /*ARITHMETIC_ADDITION int_exp %prec POSITIVE{
                        $$=$2;
                        Trace("Reducing to int_exp\n");
                    }
                |   ARITHMETIC_SUBTRACTION int_exp %prec NEGATIVE{
                        $$=$2;
                        $$.value = new string(to_string(-atoi($2.value->c_str())));
                        Trace("Reducing to int_exp\n");
                }
                |*/   INTEGERCONSTANTS{
                        $$=$1;
                        Trace("Reducing to int_exp\n");
                }
                ;

//array的exp
array_exp:          IDENTIFIERS LEFT_SQUAREBRACKETS exp RIGHT_SQUAREBRACKETS{
                        // 檢查這個array的id是否已經存在
                        if(lookup($1.name->c_str())==1){
                            $$ = getdata($1.name->c_str());
                            $$.style = VAR_STYLE;           //a[0] is a var
                            if ($3.type!=INT_TYPE){
                                printf("index must be int\n");
                                return 1;
                            }
                        }else{
                            printf("array id doesn't exist\n");
                            return 1;
                        }
                    Trace("Reducing to array_exp\n");
                }
                ;
// func的exp
func_exp:           IDENTIFIERS LEFT_PARENTHESES parameters RIGHT_PARENTHESES{
                        // 檢查這個func的id是否已經存在
                        if(lookup($1.name->c_str())==1){
                            $$ = getdata($1.name->c_str());
                            $$.style = VAR_STYLE;           //func() is a var
                        }else{
                            printf("func id doesn't exist\n");
                            return 1;
                        }
                    Trace("Reducing to func_exp\n");
                }
                ;
parameters:         parameter
                | 
                ;
parameter:          exp COMMA parameter
                |   exp
                {
                    Trace("Reducing to parameters\n");
                }
                ;
%%

void yyerror(char *msg)
{
    fprintf(stderr, "%s\n", msg);
}

int main(int argc, char **argv)
{

    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */
    init_scope();
    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */
    // dump();
}

