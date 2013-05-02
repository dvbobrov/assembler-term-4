#!/bin/sh
sed -e "s/printf/_printf/g;s/puts/_puts/g;s/putchar/_putchar/g;s/main/_main/g" < main.asm > main_win.asm

