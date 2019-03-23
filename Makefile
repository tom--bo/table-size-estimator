all: 
	flex --header-file=lexer.yy.h lexer.l
	yacc -d -v parser.y

clean:
	rm *.h
	rm *.c
	rm *.output
	rm p parser
