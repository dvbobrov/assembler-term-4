ifdef SystemRoot
	BINARY_FORMAT = win32
	RM = del /Q
	SOURCE = main_win.asm
else
	ifeq ($(shell uname), Linux)
		BINARY_FORMAT = elf32
		RM = rm -f
		SOURCE = main.asm
	endif
endif


all: main.o
	gcc -m32 -g -o numfmt main.o

main.o: $(SOURCE)
	yasm -a x86 -f $(BINARY_FORMAT) -g dwarf2 -o main.o $(SOURCE)

clean:
	$(RM) *.o numfmt
