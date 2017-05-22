%{
    #include "lex.yy.c"
    #include <stdio.h>
    #define Trace(t) printf(t)
    void yyerror(char *msg);
%}

/* tokens */
%token BOOL BREAK CASE CONST CONTINUE DEFAULT ELSE FALSE FOR FUNC GO IF IMPORT INT NIL PRINT PRINTLN REAL RETURN STRING STRUCT SWITCH TRUE TYPE VAR VOID WHILE READ
%token COMMA COLON SEMICOLON LEFT_PARENTHESES RIGHT_PARENTHESES LEFT_SQUAREBRACKETS RIGHT_SQUAREBRACKETS LEFT_BRACKETS RIGHT_BRACKETS
%token ARITHMETIC_ADDITION ARITHMETIC_SUBTRACTION ARITHMETIC_MULTIPLICATION ARITHMETIC_DIVIDE
%token EXPONENTIATION REMAINDER
%token RELATIONAL_LESS RELATIONAL_LESSEQUAL RELATIONAL_GREATEREQUAL RELATIONAL_GREATER RELATIONAL_EQUAL RELATIONAL_NOTEQUAL
%token LOGICAL_AND LOGICAL_OR LOGICAL_NOT ASSIGNMENT
%token COMPOUNDOPERATORS_ADDASSIGN COMPOUNDOPERATORS_SUBASSIGN COMPOUNDOPERATORS_MULASSIGN COMPOUNDOPERATORS_DIVASSIGN
%token BOOLEANCONSTANTS_TRUE BOOLEANCONSTANTS_FALSE
%token IDENTIFIERS INTEGERCONSTANTS REALCONSTANTS STRINGCONSTANTS

%left ARITHMETIC_ADDITION ARITHMETIC_SUBTRACTION
%left ARITHMETIC_MULTIPLICATION ARITHMETIC_DIVIDE REMAINDER
%left EXPONENTIATION
%nonassoc POSITIVE
%nonassoc NEGATIVE

%%
start:              program{
                    Trace("Reducing to start\n");
                }
                ;

program:            //function
                    contents{
                    Trace("Reducing to program\n");
                }
                ;

function:           FUNC type IDENTIFIERS LEFT_PARENTHESES formal_arguments RIGHT_PARENTHESES LEFT_BRACKETS 
                    contents
                    RIGHT_BRACKETS{
                    Trace("Reducing to function\n");
                }
                ;

type:               BOOL
                |   INT
                |   REAL
                |   STRING
                |   VOID{
                    Trace("Reducing to type\n");
                }
                ;

formal_arguments:   formal_argument COMMA formal_arguments
                |   formal_argument{
                    Trace("Reducing to formal_arguments\n");
                }
                ;

formal_argument:    IDENTIFIERS type{
                    Trace("Reducing to formal_argument\n");
                }
                ;

exp:                constant_exp{
                    Trace("Reducing to exp\n");
                }
                |   function{
                    Trace("Reducing to exp\n");
                }
                |   array_exp{
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
                // |   function_invocation
                // |   compound
                // |   conditional
                // |   loop
                // |   procedure_invocation
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
constant_exp:       bool_exp{
                    Trace("Reducing to constant_exp\n");
                }
                |   int_exp{
                    Trace("Reducing to constant_exp\n");
                }
                |   real_exp{
                    Trace("Reducing to constant_exp\n");
                }
                |   STRINGCONSTANTS{
                    Trace("Reducing to constant_exp\n");
                }
                ;

bool_exp:           LEFT_PARENTHESES bool_exp RIGHT_PARENTHESES
                |   num_exp RELATIONAL_LESS num_exp
                |   num_exp RELATIONAL_LESSEQUAL num_exp
                |   num_exp RELATIONAL_GREATEREQUAL num_exp
                |   num_exp RELATIONAL_GREATER num_exp
                |   num_exp RELATIONAL_EQUAL num_exp
                |   num_exp RELATIONAL_NOTEQUAL num_exp
                |   bool_exp LOGICAL_AND bool_exp
                |   bool_exp LOGICAL_OR bool_exp
                |   LOGICAL_NOT bool_exp
                |   BOOLEANCONSTANTS_TRUE{
                    Trace("Reducing to bool_exp\n");
                }
                |   BOOLEANCONSTANTS_FALSE{
                    Trace("Reducing to bool_exp\n");
                }
                |   IDENTIFIERS{
                    Trace("Reducing to bool_exp\n");
                }
                ;

num_exp:            int_exp{
                    Trace("Reducing to num_exp\n");
                }
                |   real_exp{
                    Trace("Reducing to num_exp\n");
                }
                ;
int_exp:            LEFT_PARENTHESES int_exp RIGHT_PARENTHESES
                |   int_exp ARITHMETIC_ADDITION int_exp
                |   int_exp ARITHMETIC_SUBTRACTION int_exp
                |   int_exp ARITHMETIC_MULTIPLICATION int_exp
                |   int_exp ARITHMETIC_DIVIDE int_exp
                |   ARITHMETIC_ADDITION int_exp %prec POSITIVE{
                    Trace("Reducing to int_exp\n");
                }
                |   ARITHMETIC_SUBTRACTION int_exp %prec NEGATIVE{
                    Trace("Reducing to int_exp\n");
                }
                |   INTEGERCONSTANTS{
                    Trace("Reducing to int_exp\n");
                }
                |   IDENTIFIERS{
                    Trace("Reducing to constant_exp\n");
                }   
                ;

real_exp:           LEFT_PARENTHESES real_exp RIGHT_PARENTHESES
                |   real_exp ARITHMETIC_ADDITION real_exp
                |   real_exp ARITHMETIC_SUBTRACTION real_exp
                |   real_exp ARITHMETIC_MULTIPLICATION real_exp
                |   real_exp ARITHMETIC_DIVIDE real_exp
                |   ARITHMETIC_ADDITION real_exp %prec POSITIVE{
                    Trace("Reducing to real_exp\n");
                }
                |   ARITHMETIC_SUBTRACTION real_exp %prec NEGATIVE{
                    Trace("Reducing to real_exp\n");
                }
                |   REALCONSTANTS{
                    Trace("Reducing to real_exp\n");
                }
                |   IDENTIFIERS{
                    Trace("Reducing to constant_exp\n");
                }
                ;

array:              VAR IDENTIFIERS LEFT_SQUAREBRACKETS int_exp RIGHT_SQUAREBRACKETS type{
                    Trace("Reducing to array\n");
                }
                ;

array_exp:          LEFT_PARENTHESES array_exp RIGHT_PARENTHESES
                |   array_exp ARITHMETIC_ADDITION array_exp
                |   array_exp ARITHMETIC_SUBTRACTION array_exp
                |   array_exp ARITHMETIC_MULTIPLICATION array_exp
                |   array_exp ARITHMETIC_DIVIDE array_exp
                |   ARITHMETIC_ADDITION array_exp %prec POSITIVE{
                    Trace("Reducing to array_exp\n");
                }
                |   ARITHMETIC_SUBTRACTION array_exp %prec NEGATIVE{
                    Trace("Reducing to array_exp\n");
                }
                |   IDENTIFIERS LEFT_SQUAREBRACKETS int_exp RIGHT_SQUAREBRACKETS{
                    Trace("Reducing to array_exp\n");
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

