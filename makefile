a.out: proj2.y proj2.l
	yacc proj2.y -d
	lex proj2.l
	g++ y.tab.c -ll -std=c++11

