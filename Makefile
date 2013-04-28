all: dct.o test.o
	g++ -m32 -g -Wall dct.o test.o -o test

dct.o: dct.asm
	yasm -g dwarf2 -f elf32 -a x86 dct.asm

test.o: test.cpp
	g++ -c -m32 -Wall -g -o test.o test.cpp

clean:
	rm -f dct.o test.o test
