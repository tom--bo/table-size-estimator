all: 
	bison -d parser.y
	flex -i --header-file=lexer.yy.h lexer.l
	gcc *.c -o tsm

parse: 
	bison -d parser.y
	flex -i --header-file=lexer.yy.h lexer.l

test:
	# clean
	rm -f lexer.yy.h parser.tab.h
	rm -f *yy.c
	rm -f *tab.c
	rm -f *.output
	rm -f p parser
	rm -f tsm
	# all
	bison -d parser.y
	flex -i --header-file=lexer.yy.h lexer.l
	gcc *.c -o tsm
	# run test script
	bash ./tests/test.sh

clean:
	rm -f lexer.yy.h parser.tab.h
	rm -f *yy.c
	rm -f *tab.c
	rm -f *.output
	rm -f p parser
	rm -f tsm
