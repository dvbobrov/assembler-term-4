all: main.o
	gcc -m32 -g -o numfmt main.o

main.o: main.asm
	yasm -a x86 -f elf32 -g dwarf2 main.asm

clean:
	rm -rf *.o numfmt
