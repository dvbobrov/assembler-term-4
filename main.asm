extern printf

section .bss
dct_matrix resd 64
dct_matrix_transposed resd 64

section .data
initialized db 0

section .text

global fdct
global idct
global calculate_dct_matrix


fdct: ; (float * in, float * out, int n) {
    call calculate_dct_matrix

    push ebx
    push esi
    push edi
    push ebp
    mov ebp, esp
    mov esi, [ebp + 20]
    mov edi, [ebp + 24]
    mov ebx, [ebp + 28]

    sub esp, 16
    mov [esp + 12], dword 0.125

    mov [esp], dword dct_matrix

    .loop:
        mov [esp + 4], esi
        mov [esp + 8], edi
        call dct_impl
        add esi, 64 * 4
        add edi, 64 * 4
        
        dec ebx
        test ebx, ebx
        jnz .loop

    mov esp, ebp
    pop ebp
    pop edi
    pop esi
    pop ebx
    ret
; }

idct: ; (float * in, float * out, int n) {
    call calculate_dct_matrix

    push ebx
    push esi
    push edi
    push ebp
    mov ebp, esp
    mov esi, [ebp + 20]
    mov edi, [ebp + 24]
    mov ebx, [ebp + 28]

    sub esp, 16
    mov [esp + 12], dword 8.0

    mov [esp], dword dct_matrix_transposed

    .loop:
        mov [esp + 4], esi
        mov [esp + 8], edi
        call dct_impl
        add esi, 64 * 4
        add edi, 64 * 4

        dec ebx
        test ebx, ebx
        jnz .loop

    mov esp, ebp
    pop ebp
    pop edi
    pop esi
    pop ebx
    ret
; }


dct_impl: ; (float * t, float * data, float * out, float multiplier) {
    push ebx
    push esi
    push edi
    push ebp
    mov ebp, esp

    and esp, -16
    sub esp, 64 * 4
    mov edi, esp
    mov esi, [ebp + 24]
    mov ebx, [ebp + 20]

    xor eax, eax
    .loop1:
        cmp eax, 8
        je .endloop1

        mov ebx, [ebp + 20]
        xor ecx, ecx
        .loop2:
            cmp ecx, 8
            je .endloop2

            movaps xmm0, [ebx]
            mulps xmm0, [esi]

            movapd xmm1, [ebx + 16]
            mulps xmm1, [esi + 16]

            addps xmm0, xmm1
            
            haddps xmm0, xmm0
            haddps xmm0, xmm0
            mulss xmm0, [ebp + 32]

            lea edx, [eax + ecx * 8]
            movd [edi + edx * 4], xmm0

            add ebx, 32

            inc ecx
            jmp .loop2

        .endloop2:
        add esi, 32
        inc eax
        jmp .loop1

    .endloop1:

    mov esi, esp
    mov edi, [ebp + 28]
    mov ebx, [ebp + 20]

    xor eax, eax
    .loop3:
        cmp eax, 8
        je .endloop3

        mov esi, esp
        xor ecx, ecx
        .loop4:
            cmp ecx, 8
            je .endloop4

            movaps xmm0, [ebx]
            mulps xmm0, [esi]

            movapd xmm1, [ebx + 16]
            mulps xmm1, [esi + 16]

            addps xmm0, xmm1
            
            haddps xmm0, xmm0
            haddps xmm0, xmm0

            lea edx, [ecx + eax * 8]
            movd [edi + edx * 4], xmm0

            add esi, 32

            inc ecx
            jmp .loop4

        .endloop4:
        add ebx, 32
        inc eax
        jmp .loop3

    .endloop3:

    mov esp, ebp
    pop ebp
    pop edi
    pop esi
    pop ebx
    ret
; }


calculate_dct_matrix: ; () {
   push ebx
   mov ebx, [initialized]
   test ebx, ebx
   jnz .finish

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

    mov [initialized], byte 1
    .finish:
        pop ebx
        ret

; }

calculate_dct_element: ; (eax &, ebx &) {
    test eax, eax
    jz .dct_el_zero

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

    mov edx, [dct_matrix + ecx * 4]
    lea ecx, [ebx * 8 + eax]
    mov [dct_matrix_transposed + ecx * 4], edx
    ;fstp dword [dct_matrix_transposed + ecx * 4]
    

    ret

    .dct_el_zero:
        push dword 0.125
        fld dword [esp]
        add esp, 4
        fsqrt
        fst dword [dct_matrix + ebx * 4]
        lea ecx, [ebx * 8]
        fstp dword [dct_matrix_transposed + ecx * 4]
        ret
; }
