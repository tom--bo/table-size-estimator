calc: calc.l calc.y
	bison -d calc.y
	flex calc.l
	gcc calc.tab.c lex.yy.c -lfl

clean:
	rm *.c *.h
