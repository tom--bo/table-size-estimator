all: 
	flex --header-file=lexer.yy.h lexer.l
	bison -d -v parser.y

clean:
	rm *.h
	rm *.c
	rm *.output
