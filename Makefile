all: 
	flex --header-file=lexer.yy.h lexer.l
	bison -d -v parser.y

clean:
	rm lexer.yy.h
	rm lex.yy.c
	rm parser.output
	rm parser.tab.c
	rm parser.tab.h
