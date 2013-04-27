all: main.o test.o
	g++ -m32 -g -Wall main.o test.o -o test

main.o: main.asm
	yasm -g dwarf2 -f elf32 -a x86 main.asm

test.o: test.cpp
	g++ -c -m32 -std=c++11 -m32 -Wall -g -c -o test.o test.cpp

clean:
	rm -f main.o test.o test
