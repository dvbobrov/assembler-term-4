extern puts
global main

section .rodata
usage db "Usage: numfmt format number",10,0

section .text

main:
	cmp [esp + 4], dword 3
	jnz printUsageMsg
	
	xor eax, eax
	ret
	
printUsageMsg:
	push usage
	call puts
	add esp, 4
	xor eax, eax
	ret