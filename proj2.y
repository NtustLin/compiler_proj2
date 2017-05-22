%{
    #include "lex.yy.c"
    #include <stdio.h>
    #define Trace(t) printf(t)
    void yyerror(char *msg);
%}

/* tokens */
%token BOOL BREAK CASE CONST CONTINUE DEFAULT ELSE FALSE FOR FUNC GO IF IMPORT INT NIL PRINT PRINTLN REAL RETURN STRING STRUCT SWITCH TRUE TYPE VAR VOID WHILE
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
start:              program
                {
                    Trace("Reducing to start\n");
                }
                ;
 
program:            //function
                    declarations
                {
                    Trace("Reducing to program\n");
                }
                ;

/*function:         FUNC type IDENTIFIERS LEFT_PARENTHESES formal_arguments RIGHT_PARENTHESES LEFT_BRACKETS 
                    declarations|statements 
                    RIGHT_BRACKETS
                |

                {
                    Trace("Reducing to function\n");
                }
                ;*/

type:               BOOL
                |   INT
                |   REAL
                |   STRING
                {
                    Trace("Reducing to type\n");
                }
                ;

/*formal_arguments:   
                {
                    Trace("Reducing to formal_arguments\n");
                }
                ;*/

declarations:       declaration declarations
                {
                    Trace("Reducing to declarations\n");
                }
                |   declaration
                {
                    Trace("Reducing to declarations\n");
                }
                ; 
declaration:        constant
                {
                    Trace("Reducing to declaration\n");
                }
                |   variable
                {
                    Trace("Reducing to declaration\n");
                }
                |   arrays
                {
                    Trace("Reducing to declaration\n");
                }
                ;
constant:           CONST IDENTIFIERS ASSIGNMENT constant_exp
                {
                    Trace("Reducing to constant\n");
                }
                ;
variable:           VAR IDENTIFIERS type ASSIGNMENT constant_exp
                {
                    Trace("Reducing to variable\n");
                }
                |   VAR IDENTIFIERS type
                {
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
                |   BOOLEANCONSTANTS_TRUE
                {
                    Trace("Reducing to bool_exp\n");
                }
                |   BOOLEANCONSTANTS_FALSE
                {
                    Trace("Reducing to bool_exp\n");
                }
                ;
num_exp:            int_exp
                {
                    Trace("Reducing to num_exp\n");
                }
                |   real_exp
                {
                    Trace("Reducing to num_exp\n");
                }
                ;
int_exp:            LEFT_PARENTHESES int_exp RIGHT_PARENTHESES
                |   int_exp ARITHMETIC_ADDITION int_exp
                |   int_exp ARITHMETIC_SUBTRACTION int_exp
                |   int_exp ARITHMETIC_MULTIPLICATION int_exp
                |   int_exp ARITHMETIC_DIVIDE int_exp
                |   ARITHMETIC_ADDITION int_exp %prec POSITIVE
                {
                    Trace("Reducing to int_exp\n");
                }
                |   ARITHMETIC_SUBTRACTION int_exp %prec NEGATIVE
                {
                    Trace("Reducing to int_exp\n");
                }
                |   INTEGERCONSTANTS
                {
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
                |   ARITHMETIC_ADDITION real_exp %prec POSITIVE
                {
                    Trace("Reducing to real_exp\n");
                }
                |   ARITHMETIC_SUBTRACTION real_exp %prec NEGATIVE
                {
                    Trace("Reducing to real_exp\n");
                }
                |   REALCONSTANTS
                {
                    Trace("Reducing to real_exp\n");
                }
                |   IDENTIFIERS{
                    Trace("Reducing to constant_exp\n");
                }
                ;
/*statements:       simple
                |   compound
                |   conditional
                |   loop
                |   procedure_invocation
                {
                    Trace("Reducing to statements\n");
                }
                ;*/

arrays:             VAR IDENTIFIERS LEFT_SQUAREBRACKETS constant_exp RIGHT_SQUAREBRACKETS type
                {
                    Trace("Reducing to arrays\n");
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

