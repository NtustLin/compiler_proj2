%{
    #include "lex.yy.c"
    #include <stdio.h>
    #define Trace(t) printf(t)
    void yyerror(char *msg);

%}

%union {
    int val;
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
%type<myinfo> exp number int_exp bool_exp num_exp func_exp array_exp

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
                    Trace("Reducing to exp\n");
                }
                |   bool_exp{
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
                |   statement{
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
                    Trace("Reducing to simple\n");
                }
                |   IDENTIFIERS LEFT_SQUAREBRACKETS int_exp RIGHT_SQUAREBRACKETS ASSIGNMENT exp{
                    Trace("Reducing to simple\n");
                }
                |   PRINT exp{
                    Trace("Reducing to simple\n");
                }
                |   PRINTLN exp{
                    Trace("Reducing to simple\n");
                }
                |   READ exp{
                    Trace("Reducing to simple\n");
                }
                |   RETURN{
                    Trace("Reducing to simple\n");
                }
                |   RETURN exp{
                    Trace("Reducing to simple\n");
                }
                ;
compound:           LEFT_BRACKETS contents RIGHT_BRACKETS
                {
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

loop:               FOR LEFT_PARENTHESES statement SEMICOLON exp SEMICOLON statement RIGHT_PARENTHESES{
                    Trace("Reducing to loop\n");
                }
                |   FOR LEFT_PARENTHESES SEMICOLON exp SEMICOLON statement RIGHT_PARENTHESES{
                    Trace("Reducing to loop\n");
                }
                |   FOR LEFT_PARENTHESES SEMICOLON statement SEMICOLON exp RIGHT_PARENTHESES{
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
constant_exp:       exp
                {
                    Trace("Reducing to exp\n");
                }
                ;

constant:           CONST IDENTIFIERS ASSIGNMENT constant_exp{
                    Trace("Reducing to constant\n");
                }
                ;
variable:           VAR IDENTIFIERS type ASSIGNMENT constant_exp{
                    Trace("Reducing to variable\n");
                }
                |   VAR IDENTIFIERS type{
                    Trace("Reducing to variable\n");
                }
                ;
array:              VAR IDENTIFIERS LEFT_SQUAREBRACKETS int_exp RIGHT_SQUAREBRACKETS type
                {
                    Trace("Reducing to array\n");
                }
                ;

bool_exp:           LEFT_PARENTHESES bool_exp RIGHT_PARENTHESES{$$=$2;}
                |   num_exp RELATIONAL_LESS num_exp {
                        if(($1.type==INT_TYPE || $3.type==INT_TYPE || $1.type==REAL_TYPE || $3.type==REAL_TYPE) && $1.type==$3.type){
                            $$=$1;
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
                            if(atof($1.value->c_str())>atof($3.value->c_str())){
                                $$.value=new string("1");
                            }else{
                                $$.value=new string("0");
                            }
                        }else{
                            printf("Error not a same type\n");
                            return 1;
                        }
                    }
                |   num_exp RELATIONAL_EQUAL num_exp{
                        if(($1.type==INT_TYPE || $3.type==INT_TYPE || $1.type==REAL_TYPE || $3.type==REAL_TYPE) && $1.type==$3.type){
                            $$=$1;
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
                    $$=$1;
                    Trace("Reducing to bool_exp\n");
                }
                ;

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
                    $$=$1;
                    Trace("Reducing to number\n");
                }
                ;

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

array_exp:          IDENTIFIERS LEFT_SQUAREBRACKETS int_exp RIGHT_SQUAREBRACKETS{
                    Trace("Reducing to array_exp\n");
                }
                ;

func_exp:           IDENTIFIERS LEFT_PARENTHESES parameters RIGHT_PARENTHESES{
                    Trace("Reducing to func_exp\n");
                }
                ;
parameters:         exp COMMA exp
                |   exp
                |   
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
    hashtable one;
    one = create();
    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */
}

