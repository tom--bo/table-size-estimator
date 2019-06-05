all: 
	@$(MAKE) -C src all

test:
	@make clean
	@make all
	bash ./tests/test.sh
	@make clean

clean:
	@$(MAKE) -C src clean

