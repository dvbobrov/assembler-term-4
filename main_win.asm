extern _puts
extern _printf
extern _putchar

global main


%macro readHelper 2
	rol %1, 4
	mov ebp, %1
	and ebp, 0x0000000F
	and %1, 0xFFFFFFF0
	or %2, ebp
%endmacro

; %1: char to write, %2: register to save
%macro printChar 2
	push %2
	push dword %1
	call _putchar
	add esp, 4
	pop %2
%endmacro

%macro printNum 0
	push digits
	call _printf
	add esp, 4
%endmacro

section .rodata
usage db "Usage: numfmt [format_string] number",0
numError db "Error parsing number",0

fmt db "0x%x 0x%x 0x%x 0x%x",10,0
fmt1 db "%d",10,0

flgSpace equ 0x1
flgPlus equ 0x2
flgMinus equ 0x4
flgZero equ 0x8

disableSpace equ 0xFF ^ flgSpace
disableMinus equ 0xFF ^ flgMinus
flagsAffectingLength equ flgPlus | flgSpace

section .data
number: resd 4
flags: db 0
length: db 0
isNegative: db 0
digits: resb 40
curDigit: db 0, 0, 0, 1
numberLength: dd 0
spacer: db 32

section .text

main:
	; Check args number
	mov eax, [esp + 4]
	cmp eax, dword 1
	je .printUsageMsg
	
	; Read flags
	mov esi, [esp + 8]
	mov esi, [esi + 4]
	
	cmp eax, dword 2
	je .oneArg
	
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
	
	mov esi, [esp + 8]
	mov esi, [esi + 8]
	.oneArg:
	
	; Read number into edi:edx:ecx:ebx
	xor edi, edi
	xor edx, edx
	xor ecx, ecx
	xor ebx, ebx
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
	lea edi, [digits]
	.loop4:
		call checkZero
		test eax, eax
		jz .endLoop4
		call divideByTen
		add eax, '0'
		mov [edi], al
		inc edi
		jmp .loop4
	.endLoop4:
	cmp edi, digits
	jnz .revDigitsReady
	mov [edi], byte '0'
	inc edi
	
	.revDigitsReady:
	mov [edi], byte 0
	
	lea eax, [digits]
	neg eax
	lea eax, [eax + edi]
	
	xor ecx, ecx
	mov cl, [flags]
	and cl, flagsAffectingLength
	or cl, byte [isNegative]
	test cl, cl
	jnz .incLength
	
	.lengthCalculated:
	mov [numberLength], eax
	xor ebx, ebx
	mov bl, [length]
	
	sub ebx, eax
	jl .greaterLength
	.setSpaceCount:
	mov [length], bl

	dec edi
	lea esi, [digits]

	.loop5:
		mov al, [esi]
		mov ah, [edi]
		mov [esi], ah
		mov [edi], al
		inc esi
		dec edi
		cmp esi, edi
		jb .loop5
	
	xor eax, eax
	mov al, [flags]
	test al, flgMinus
	jnz .leftAligned
	test al, flgZero
	jnz .zeroSpacer
	
	; Right-aligned with spaces
	push eax
	xor ecx, ecx
	mov cl, [length]
	test cl, cl
	jz .endLoop10
	.loop10:
		printChar ' ', ecx
		loop .loop10
	.endLoop10:
	pop eax
	call .writePlusMinusOrSpace
	printNum
	
	.return:
	printChar 10, eax
	xor eax, eax
	ret
	

.greaterLength:
	xor ebx, ebx
	jmp .setSpaceCount
	
	
.zeroSpacer:
	call .writePlusMinusOrSpace
	xor ecx, ecx
	mov cl, [length]
	test cl, cl
	jz .endLoop9
	.loop9:
		printChar '0', ecx
		loop .loop9
	.endLoop9:
	printNum
	jmp .return

; al: flags
.writePlusMinusOrSpace:
	xor ecx, ecx
	mov cl, [isNegative]
	test cl, cl
	jnz .printMinus
	test al, flgPlus
	jnz .printPlus
	test al, flgSpace
	jnz .printSpace
	.wrtRet:
	ret
	
.printPlus:
	printChar '+', eax
	jmp .wrtRet
	
.printMinus:
	printChar '-', eax
	jmp .wrtRet
	
.printSpace:
	printChar ' ', eax
	jmp .wrtRet
	
.leftAligned:
	call .writePlusMinusOrSpace
	printNum
	xor ecx, ecx
	mov cl, [length]
	test cl, cl
	jz .return
	.loop6:
		printChar ' ', ecx
		loop .loop6
	jmp .return



.incLength:
	inc eax
	jmp .lengthCalculated

.negateNumber:
	mov eax, [isNegative]
	xor eax, 1
	mov [isNegative], eax
	
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
	call _puts
	add esp, 4
	xor eax, eax
	ret
	
.errorParsingNumber:
	pop ebp
	push numError
	call _puts
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
		mov [spacer], byte '0'
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

	
divideByTen:
	mov ecx, 4
	xor edx, edx
	lea esi, [number]
	mov ebx, 10
	.loop8:
		mov eax, [esi]
		div ebx
		mov [esi], eax
		lea esi, [esi + 4]
		loop .loop8
	mov eax, edx
	ret

checkZero:
	mov ecx, 4
	lea esi, [number]
	.loop7:
		mov eax, [esi]
		test eax, eax
		jnz .notZero
		lea esi, [esi + 4]
		loop .loop7
	.notZero:
		ret

