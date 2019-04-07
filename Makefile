all: 
	bison -d parser.y
	flex --header-file=lexer.yy.h lexer.l

clean:
	rm *.h
	rm *.c
	rm *.output
	rm p parser
