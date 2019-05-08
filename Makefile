all: 
	bison -d parser.y
	flex --header-file=lexer.yy.h lexer.l
	gcc *.c

parse: 
	bison -d parser.y
	flex --header-file=lexer.yy.h lexer.l

clean:
	rm -f lexer.yy.h parser.tab.h
	rm -f *yy.c
	rm -f *tab.c
	rm -f *.output
	rm -f p parser
	rm -f a.out
