extern printf

section .bss
dct_matrix resd 64

section .rodata

sixteen dd 16.0
half dd 0.5
fmt db "%.10f",10,0

section .text

global dct8x8
global idct8x8
global calculate_dct_matrix
global print_dct_matrix


dct8x8: 



idct8x8:

print_dct_matrix:
    push ebx
    xor ebx, ebx
    .loop3:
        cmp ebx, 64
        je .endloop3

        push dword [dct_matrix + 4 * ebx]
        push fmt
        call printf
        add esp, 8
        inc ebx

        jmp .loop3
    .endloop3:
    pop ebx
    ret


calculate_dct_matrix:
   push ebx
   xor eax, eax

   .loop1:
      cmp eax, 8
      je .endloop1

      xor ebx, ebx
      .loop2:
        cmp ebx, 8
        je .endloop2

        call calculate_dct_element

        inc ebx
        jmp .loop2

    .endloop2:
        inc eax
        jmp .loop1
    .endloop1:
        pop ebx
        ret

calculate_dct_element: ; i = eax; j = ebx
    test eax, eax
    jz dct_el_zero

    push eax

    mov ecx, ebx
    shl ecx, 1
    inc ecx
    mul ecx
    push eax
    fild dword [esp]
    add esp, 4

    fldpi
    push dword 0.0625
    fmul dword [esp]
    add esp, 4

    fmulp
    fcos
    push dword 0.5
    fmul dword [esp]
    add esp, 4

    pop eax
    lea ecx, [eax * 8 + ebx]
    fstp dword [dct_matrix + ecx * 4]

    ret
    

dct_el_zero:
    push dword 0.125
    fld dword [esp]
    add esp, 4
    fsqrt
    lea ecx, [eax * 8 + ebx]
    fstp dword [dct_matrix + ecx * 4]
    ret
