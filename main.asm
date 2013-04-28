section .data
dct_matrix resd 64
PI dd 3.141592653589793238462

section .text

global dct
global idct


dct8x8: 




idct8x8:


dct8:


calculate_dct_matrix:
    

calculate_dct_element: ; i = eax; j = ebx
    push eax
    test eax, eax
    jz dct_el_zero

    mov ebx, ecx
    shl ecx, 1
    inc ecx
    mul ecx
    fild eax

    fld dword [PI]
    fld dword 16.0
    fdivp
    fmulp
    fcos
    fld 0.5
    fmulp

    lea ecx, [eax * 8 + ebx]
    fstp dword [dct_matrix + ecx * 4]
    

dct_el_zero:
    fld dword 0.125
    fsqrt
    lea ecx, [eax * 8 + ebx]
    fstp dword [dct_matrix + ecx * 4]

