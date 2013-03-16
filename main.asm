extern puts
extern printf
global main

section .rodata
usage db "Usage: numfmt format number",10,0

fmt db "%d %d",10,0

flgSpace equ 0x1
flgPlus equ 0x2
flgMinus equ 0x4
flgZero equ 0x8

disableSpace equ 0xFF ^ flgSpace
disableMinus equ 0xFF ^ flgMinus

section .data
number: resd 4
flags: resb 1
length: resd 1

section .text

main:
	cmp [esp + 4], dword 3
	jnz .printUsageMsg
	;reading flags
	mov esi, [esp + 8]
	mov esi, [esi + 4]
	xor ecx, ecx
	xor edx, edx
	.loop1:
		mov dl, [esi]
		test edx, edx
		jz .endLoop1
		call .parseFlag
		test eax, eax
		jz .parseLength
		inc esi
		jmp .loop1
	
	.endLoop1:
	mov [flags], ecx
	mov [length], edx
	push edx
	push ecx
	push fmt
	call printf
	add esp, 12
	
	xor eax, eax
	ret
	
.printUsageMsg:
	push usage
	call puts
	add esp, 4
	xor eax, eax
	ret

.parseFlag:
	cmp dl, ' '
	jz .spaceCase
	cmp dl, '+'
	jz .plusCase
	cmp dl, '-'
	jz .minusCase
	cmp dl, '0'
	jz .zeroCase
	xor eax, eax
	ret
	
	.end:
		mov eax, 1
		ret
	
	.spaceCase:
		test ecx, flgPlus
		jnz .end
		or ecx, flgSpace
		mov eax, 1
		ret
	
	.plusCase:
		or ecx, flgPlus
		and ecx, disableSpace
		mov eax, 1
		ret
		
	.minusCase:
		test ecx, flgZero
		jnz .end
		or ecx, flgMinus
		mov eax, 1
		ret
	
	.zeroCase:
		or ecx, flgZero
		and ecx, disableMinus
		mov eax, 1
		ret

.parseLength:
	sub dl, '0'

	inc esi
	mov al, [esi]
	test al, al
	jz .endLoop1
	
	sub al, '0'
	
	; edx *= 10
	lea edx, [edx * 5] 
	lea edx, [edx * 2]
	
	add edx, eax
	jmp .endLoop1
	
