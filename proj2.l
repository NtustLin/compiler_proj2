%{
	#include <iostream>
	#include <string>
	#include <queue>
	#include <map>
	#include <list>
	#include "y.tab.h"
	using namespace std;

	#define LIST strcat(buf,yytext)
	#define MAX_LINE_LENG 256

	// queue<string> handler;
	bool flagNonsingle=false;
	bool flagSingle=false;
	int linenum = 1;
	char buf[MAX_LINE_LENG];
	string strbuf;

	class hashtable{
		public:
			hashtable(){
				count=0;
			}
			int lookup(string s){
				map<string,int>::iterator it;
				it = strTables.find(s);
				if(it != strTables.end()){
					return it->second;
				}else{
					return -1;
				}
			}
			int insert(string s){
				strTables[s]=count;
				intTables[count]=s;
				count++;
				return count-1;
			}
			void dump(){
				for (map<int,string>::iterator it=intTables.begin(); it!=intTables.end(); ++it){
    				cout << it->first << " => " << it->second << '\n';
				}
			}
		private:
			map<string,int> strTables;
			map<int,string> intTables;
			int count;
	};
	list<hashtable> symbolTables;
	hashtable create(){
		hashtable temp;
		symbolTables.push_front(temp);
		return temp;
	}

	// void handleString(){
	// 	string tmp;
	// 	if (!handler.empty()){
	// 		while(!handler.empty()){
	// 			tmp.append(handler.front());
	// 			tmp.erase(tmp.size()-1);
	// 			handler.pop();
	// 		}
	// 		tmp.append("\"");
	// 		cout<<"<string:"<<tmp<<">"<<endl;
	// 	}
	// }

	void token(){
		LIST; 
		if(flagNonsingle==false&&flagSingle==false){
			// handleString();
			printf("<%s>\n",yytext);
		}	
	}

	void tokenKeyword(){
		LIST;
		if(flagNonsingle==false&&flagSingle==false){
			// handleString();
			printf("<keyword:%s>\n",yytext);
		}
	}

	void tokenIdentifiers(){
		LIST;
		if(flagNonsingle==false&&flagSingle==false){
			// handleString();
			printf("<id:%s>\n",yytext);
			if (symbolTables.front().lookup(yytext)==-1){
				symbolTables.front().insert(yytext);
			}
		}
	} 
	
	// void tokenString(){
	// 	LIST;
	// 	if(flagNonsingle==false&&flagSingle==false){
	// 		handler.push(yytext);
	// 	}
	// }

%}
%x string
%x comment

comma ,
colon :
semicolon ;
left_parentheses \(
right_parentheses \)
left_squarebrackets \[
right_squarebrackets \]
left_brackets \{
right_brackets \}
arithmetic_addition \+
arithmetic_subtraction \-
arithmetic_multiplication \*
arithmetic_divide \/
exponentiation \^
remainder %
relational_less <
relational_lessEqual <=
relational_greaterEqual >=
relational_greater >
relational_equal ==
relational_notEqual !=
logical_and &
logical_or "|"
logical_not !
assignment =
compoundOperators_addAssign \+\=
compoundOperators_subAssign \-\=
compoundOperators_mulAssign \*\=
compoundOperators_divAssign \/\=
letters [a-zA-Z]
digits [0-9]+
identifiers {letters}({letters}|{digits})*
integerConstants {digits}*
booleanConstants_true true
booleanConstants_false false
decimal {integerConstants}\.{integerConstants}
exponent {decimal}(e|E)(\+|\-)?{integerConstants}
realConstants {decimal}|{exponent}

%%
{comma} {token();return COMMA;}
{colon} {token();return COLON;}
{semicolon} {token();return SEMICOLON;}
{left_parentheses} {token();return LEFT_PARENTHESES;}
{right_parentheses} {token();return RIGHT_PARENTHESES;}
{left_squarebrackets} {token();return LEFT_SQUAREBRACKETS;}
{right_squarebrackets} {token();return RIGHT_SQUAREBRACKETS;}
{left_brackets} {token();return LEFT_BRACKETS;}
{right_brackets} {token();return RIGHT_BRACKETS;}
{arithmetic_addition} {token();return ARITHMETIC_ADDITION;}
{arithmetic_subtraction} {token();return ARITHMETIC_SUBTRACTION;}
{arithmetic_multiplication} {token();return ARITHMETIC_MULTIPLICATION;}
{arithmetic_divide} {token();return ARITHMETIC_DIVIDE;}
{exponentiation} {token();return EXPONENTIATION;}
{remainder} {token();return REMAINDER;}
{relational_less} {token();return RELATIONAL_LESS;}
{relational_lessEqual} {token();return RELATIONAL_LESSEQUAL;}
{relational_greaterEqual} {token();return RELATIONAL_GREATEREQUAL;}
{relational_greater} {token();return RELATIONAL_GREATER;}
{relational_equal} {token();return RELATIONAL_EQUAL;}
{relational_notEqual} {token();return RELATIONAL_NOTEQUAL;}
{logical_and} {token();return LOGICAL_AND;}
{logical_or} {token();return LOGICAL_OR;}
{logical_not} {token();return LOGICAL_NOT;}
{assignment} {token();return ASSIGNMENT;}
{compoundOperators_addAssign} {token();return COMPOUNDOPERATORS_ADDASSIGN;}
{compoundOperators_subAssign} {token();return COMPOUNDOPERATORS_SUBASSIGN;}
{compoundOperators_mulAssign} {token();return COMPOUNDOPERATORS_MULASSIGN;}
{compoundOperators_divAssign} {token();return COMPOUNDOPERATORS_DIVASSIGN;}
{booleanConstants_true} {token();return BOOLEANCONSTANTS_TRUE;}
{booleanConstants_false} {token();return BOOLEANCONSTANTS_FALSE;}
"bool" {tokenKeyword(); return BOOL;}
"break" {tokenKeyword(); return BREAK;}
"case" {tokenKeyword(); return CASE;}
"const" {tokenKeyword(); return CONST;}
"continue" {tokenKeyword(); return CONTINUE;}
"default" {tokenKeyword(); return DEFAULT;}
"else" {tokenKeyword(); return ELSE;}
"false" {tokenKeyword(); return FALSE;}
"for" {tokenKeyword(); return FOR;}
"func" {tokenKeyword(); return FUNC;}
"go" {tokenKeyword(); return GO;}
"if" {tokenKeyword(); return IF;}
"import" {tokenKeyword(); return IMPORT;}
"int" {tokenKeyword(); return INT;}
"nil" {tokenKeyword(); return NIL;}
"print" {tokenKeyword(); return PRINT;}
"println" {tokenKeyword(); return PRINTLN;}
"real" {tokenKeyword(); return REAL;}
"return" {tokenKeyword(); return RETURN;}
"string" {tokenKeyword(); return STRING;}
"struct" {tokenKeyword(); return STRUCT;}
"switch" {tokenKeyword(); return SWITCH;}
"true" {tokenKeyword(); return TRUE;}
"type" {tokenKeyword(); return TYPE;}
"var" {tokenKeyword(); return VAR;}
"void" {tokenKeyword(); return VOID;}
"while" {tokenKeyword(); return WHILE;}
{identifiers} {tokenIdentifiers();return IDENTIFIERS;}
{integerConstants} {token();return INTEGERCONSTANTS;}
{realConstants} {token();return REALCONSTANTS;}

\"			{
				BEGIN string;
				strbuf[0] = '\0';
				LIST;
			}
<string>\" 	{
				BEGIN 0;
				printf("<string:%s>\n", strbuf.c_str());
				return STRINGCONSTANTS;
			}
<string>\"\" {
				strbuf+="\"";
				LIST;
			}

<string>\n 	{
				printf("missing terminal symbol \"\n");
				exit(-1);
			}
<string>.	{
				strbuf+=yytext;
				LIST;
			}
\/\*		{
				BEGIN comment;
			}
<comment>\*\/ {
				BEGIN 0;
			}
<comment>.	{}
\/\/.*\n {}

[ \t]* {LIST;}
\n {
	flagSingle = false;
	LIST;
	printf("%d: %s", linenum++, buf);
	buf[0] = '\0';
}
. {
	LIST;
	if(flagNonsingle==false&&flagSingle==false){
		printf("%d:%s\n", linenum++, buf);
		printf("bad character:'%s'\n",yytext);
		exit(-1);
	}

}
%%
// int main(){
// 	hashtable one;
// 	one = create();
// 	yylex();
// 	one = symbolTables.front();
// 	one.dump();
// }