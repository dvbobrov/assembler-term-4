extern puts
extern printf
global main


%macro readHelper 2
rol %1, 4
mov ebp, %1
and ebp, 0x0000000F
and %1, 0xFFFFFFF0
or %2, ebp
%endmacro

section .rodata
usage db "Usage: numfmt format number",0
numError db "Error parsing number",0

fmt db "0x%x 0x%x 0x%x 0x%x",10,0

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
isNegative: db 0

section .text

main:
	cmp [esp + 4], dword 3
	jnz .printUsageMsg
	
	; Read flags
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
	
	; Read number into edi:edx:ecx:ebx
	xor edi, edi
	xor edx, edx
	xor ecx, ecx
	xor ebx, ebx
	
	mov esi, [esp + 8]
	mov esi, [esi + 8]
	
	push ebp
	
	xor eax, eax
	.loop2:
		mov al, [esi]
		inc esi
		cmp al, '-'
		jz .negNumber
		test al, al
		jz .endLoop2
		
		sub al, '0'
		jl .errorParsingNumber
		cmp al, 9
		jle .digitParsed
		; A-F
		sub al, 17
		jl .errorParsingNumber
		cmp al, 5
		jle .digitAbove9Parsed
		sub al, 32
		jl .errorParsingNumber
		cmp al, 5
		jg .errorParsingNumber
		
		.digitAbove9Parsed:
			add al, 10
		.digitParsed:
			
			xor ebp, ebp
			shl edi, 4
			readHelper edx, edi
			readHelper ecx, edx
			readHelper ebx, ecx
			or ebx, eax
			
			jmp .loop2
		
		
	.endLoop2:
	
	; Write number to array
	mov [number], edi
	mov [number + 4], edx
	mov [number + 8], ecx
	mov [number + 12], ebx
	
	; Make the number in array positive
	mov ebp, edi
	shr ebp, 31
	test ebp, ebp
	pop ebp
	jnz .negateNumber
	
	.getDigits:
	
	
	; Testing 
	push dword [number + 12]
	push dword [number + 8]
	push dword [number + 4]
	push dword [number]
	push fmt
	call printf
	add esp, 20
	
	xor eax, eax
	ret
	
	
.negateNumber:
	mov ecx, 4
	mov esi, number
	
	; Set CF
	stc
	
	.loop3:
		mov edx, [esi + ecx * 4 - 4]
		not edx
		adc edx, 0
		mov [esi + ecx * 4 - 4], edx
		loop .loop3
	jmp .getDigits

.negNumber:
	mov [isNegative], byte 1
	jmp .loop2

.printUsageMsg:
	push usage
	call puts
	add esp, 4
	xor eax, eax
	ret
	
.errorParsingNumber:
	pop ebp
	push numError
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
	
