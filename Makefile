all: 
	@bison -d parser.y
	@flex -i --header-file=lexer.yy.h lexer.l
	@gcc -w *.c -o tsm

parse: 
	@bison -d parser.y
	@flex -i --header-file=lexer.yy.h lexer.l

test:
	@make clean
	@make all
	bash ./tests/test.sh
	@make clean

clean:
	@rm -f lexer.yy.h parser.tab.h
	@rm -f *yy.c
	@rm -f *tab.c
	@rm -f *.output
	@rm -f p parser
	@rm -f tsm
