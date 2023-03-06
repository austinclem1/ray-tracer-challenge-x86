default rel

section .data

fmt_str: db "Hi %d %d", 10, 0

epsilon: times 4 dd 1.19209289e-06
neg_epsilon: times 4 dd -1.19209289e-06
neg1_sse: times 4 dd -1.0

ppm_header_fmt: db "P3", 10, "%d %d", 10, "255", 10, 0
ppm_pixel_fmt: db "%d %d %d ", 0

section .text
extern malloc
extern free
extern printf
extern putchar
extern printStructs

global equV4
equV4:
    subps xmm0, xmm2
    subps xmm1, xmm3
    mov rax, ~((1 << 63) + (1 << 31))
    movq xmm2, rax
    pand xmm0, xmm2
    pand xmm1, xmm2

    lea rax, [epsilon]
    movq xmm2, [rax]
    cmpleps xmm0, xmm2
    cmpleps xmm1, xmm2
    andps xmm0, xmm1
    movups xmm1, xmm0
    psrldq xmm0, 4
    andps xmm0, xmm1
    movd eax, xmm0
    and eax, 1

    ret

global addV4
addV4:
    addps xmm0, xmm2
    addps xmm1, xmm3
    ret

global subV4
subV4:
    subps xmm0, xmm2
    subps xmm1, xmm3
    ret

global negV4
negV4:
    movq xmm2, qword [neg1_sse]
    mulps xmm0, xmm2
    mulps xmm1, xmm2
    ret

global mulV4
mulV4:
    mulps xmm0, xmm2
    mulps xmm1, xmm3
    ret

global mulV4Scalar
mulV4Scalar:
    movd edi, xmm2
    movd esi, xmm2
    shl rsi, 32
    or rdi, rsi
    movq xmm2, rdi
    mulps xmm0, xmm2
    mulps xmm1, xmm2
    ret

global divV4
divV4:
    divps xmm0, xmm2
    divps xmm1, xmm3
    ret

global divV4Scalar
divV4Scalar:
    movd edi, xmm2
    movd esi, xmm2
    shl rsi, 32
    or rdi, rsi
    movq xmm2, rdi
    divps xmm0, xmm2
    divps xmm1, xmm2
    ret

global magV4
magV4:
    mulps xmm0, xmm0
    mulps xmm1, xmm1
    addps xmm0, xmm1
    movq rsi, xmm0
    shr rsi, 32
    movd xmm1, esi
    addss xmm0, xmm1
    sqrtss xmm0, xmm0
    ret

global normV4
normV4:
    movups xmm2, xmm0
    movups xmm3, xmm1
    push rbx
    call magV4
    pop rbx
    movd edi, xmm0
    mov rsi, rdi
    shl rsi, 32
    or rdi, rsi
    movq xmm4, rdi
    movups xmm0, xmm2
    movups xmm1, xmm3
    divps xmm0, xmm4
    divps xmm1, xmm4
    ret

global dotV4
dotV4:
    mulps xmm0, xmm2
    mulps xmm1, xmm3
    addps xmm0, xmm1
    movq rax, xmm0
    shr rax, 32
    movd xmm1, eax
    addss xmm0, xmm1
    ret

global cross
cross:
    ; xmm0: a.x, a.y
    ; xmm1: a.z, a.w
    ; xmm2: b.x, b.y
    ; xmm3: b.z, b.w
    movd edi, xmm1
    movd esi, xmm3
    movq xmm1, rdi
    movq xmm3, rsi
    movlhps xmm0, xmm1
    movlhps xmm2, xmm3
    ; xmm0: a.x, a.y, a.z, 0
    ; xmm1: b.x, b.y, b.z, 0
    pshufd xmm3, xmm0, 0b00001001
    pshufd xmm4, xmm0, 0b00010010
    pshufd xmm5, xmm2, 0b00010010
    pshufd xmm6, xmm2, 0b00001001
    mulps xmm3, xmm5
    mulps xmm4, xmm6
    subps xmm3, xmm4
    movups xmm0, xmm3
    movhlps xmm1, xmm3
    ret

global addV3
addV3:
    addps xmm0, xmm2
    addps xmm1, xmm3
    ret

global subV3
subV3:
    subps xmm0, xmm2
    subps xmm1, xmm3
    ret

global mulV3
mulV3:
    mulps xmm0, xmm2
    mulps xmm1, xmm3
    ret

global writePixel
; rdi = &canvas
; rsi = x
; rdx = y
; xmm0 = red, blue
; xmm1 = green
writePixel:
    cmp rsi, 0
    jl .end
    cmp rdx, 0
    jl .end
    cmp rsi, qword [rdi]
    jge .end
    cmp rdx, qword [rdi + 8]
    jge .end
    mov rcx, [rdi]

    mov rax, rdx
    xor rdx, rdx
    mul qword [rdi]
    add rax, rsi
    mov rcx, 3
    xor rdx, rdx
    mul rcx
    mov rdi, [rdi + 16]
    movq [rdi + rax * 4], xmm0
    add rdi, 8
    movss [rdi + rax * 4], xmm1
.end:
    ret

global createCanvas
; rdi = &dest
; rsi = width
; rdx = height
createCanvas:
    mov [rdi], rsi
    mov [rdi + 8], rdx
    mov rax, rsi
    xor rdx, rdx
    mul qword [rdi + 8]
    xor rdx, rdx
    mov rcx, 12
    mul rcx
    push rdi
    mov rdi, rax
    call malloc
    pop rdi
    mov qword [rdi + 16], rax
    ret

global destroyCanvas:
; rdi = &canvas
destroyCanvas:
    mov rdi, [rdi + 16]
    push rbx
    call free
    pop rbx
    ret

global fillCanvas:
fillCanvas:
    mov rax, qword [rdi]
    mov rcx, qword [rdi + 8]
    mov rdi, qword [rdi + 16]
    xor rdx, rdx
    mul rcx
    mov rcx, 12
    xor rdx, rdx
    mul rcx
    add rax, rdi
.loop_start:
    cmp rdi, rax
    jae .loop_end

    movq [rdi], xmm0
    movd [rdi + 8], xmm1

    add rdi, 12
    jmp .loop_start
.loop_end:
    ret

global doPrint
doPrint:
    lea rdi, [fmt_str]
    mov rsi, 5
    mov rdx, 4
    push rbx
    call printf
    pop rbx
    ret

global printCanvasPPM
; rdi = &canvas
printCanvasPPM:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov rsi, [rdi]
    mov rdx, [rdi + 8]
    mov rcx, [rdi + 16]
    mov [rsp], rsi
    mov [rsp + 8], rdx
    mov [rsp + 16], rcx
    lea rdi, [ppm_header_fmt]
    call printf

    mov rax, [rsp]
    mov rcx, 12
    xor rdx, rdx
    mul rcx
    mov [rsp + 24], rax ; pixel row stride in bytes
    mov rcx, [rsp + 8]
    xor rdx, rdx
    mul rcx
    mov [rsp + 32], rax ; entire pixel data size in bytes

    xor r8, r8
.pixel_row_loop:
    mov r9, [rsp + 32]
    cmp r8, r9
    jae .pixel_row_loop_end

    mov r9, r8
    add r9, [rsp + 24]
    .pixel_col_loop:
        cmp r8, r9
        jae .pixel_col_loop_end

        mov eax, __float32__(0.0)
        movd xmm1, eax
        mov eax, __float32__(1.0)
        movd xmm2, eax
        mov eax, __float32__(255.0)
        movd xmm3, eax

        mov rax, [rsp + 16]
        movd xmm0, [rax + r8]
        maxss xmm0, xmm1
        minss xmm0, xmm2
        mulss xmm0, xmm3
        cvtss2si rsi, xmm0
        movd xmm0, [rax + r8 + 4]
        maxss xmm0, xmm1
        minss xmm0, xmm2
        mulss xmm0, xmm3
        cvtss2si rdx, xmm0
        movd xmm0, [rax + r8 + 8]
        maxss xmm0, xmm1
        minss xmm0, xmm2
        mulss xmm0, xmm3
        cvtss2si rcx, xmm0

        push r8
        push r9
        lea rdi, [ppm_pixel_fmt]
        call printf
        pop r9
        pop r8

        add r8, 12
        jmp .pixel_col_loop

    .pixel_col_loop_end:

        mov rdi, 10
        push r8
        push r8
        call putchar
        pop r8
        pop r8

        jmp .pixel_row_loop

.pixel_row_loop_end:

    add rsp, 48
    pop rbp
    ret

global doSim
doSim:
    push rbp
    mov rbp, rsp
    sub rsp, 80

    lea rax, [env]
    movups xmm0, [rax]
    movups [rsp], xmm0
    lea rax, [proj]
    movups xmm0, [rax]
    movups [rsp + 16], xmm0
    movups xmm0, [rax + 16]
    movups [rsp + 32], xmm0
    lea rdi, [rsp + 48]
    mov rsi, 60
    mov rdx, 80
    call createCanvas

    lea rax, [black]
    movq xmm0, [rax]
    movd xmm1, [rax + 8]
    lea rdi, [rsp + 48]
    call fillCanvas

.tick_loop:
    lea rax, [proj]
    movd xmm0, [rax + 4]
    mov eax, __float32__(0.0)
    movd xmm1, eax
    cmpltss xmm0, xmm1
    movq rax, xmm0
    test rax, rax
    jnz .tick_loop_end

    sub rsp, 64
    lea rax, [env]
    lea rdi, [proj]
    movups xmm0, [rax] ; wind
    movups xmm1, [rax + 16] ; gravity
    movups xmm2, [rdi] ; position
    movups xmm3, [rdi + 16] ; velocity
    movups [rsp + 48], xmm3
    movups [rsp + 32], xmm2
    movups [rsp + 16], xmm1
    movups [rsp], xmm0
    call tick
    call printStructs
    add rsp, 64

    lea rdi, [rsp + 48]
    lea rax, [proj]
    movd xmm0, [rax]
    cvtss2si rsi, xmm0
    movd xmm0, [rax + 4]
    cvtss2si rax, xmm0
    mov rdx, qword [rdi + 8]
    sub rdx, rax
    lea rax, [white]
    movq xmm0, [rax]
    movd xmm1, [rax + 8]
    call writePixel

    jmp .tick_loop

.tick_loop_end:

    lea rdi, [rsp + 48]
    call printCanvasPPM

    lea rdi, [rsp + 48]
    call destroyCanvas

    add rsp, 80
    pop rbp
    ret

tick:
    lea rax, [time_factor]
    movups xmm3, [rax] ; time_factor
    movups xmm0, [rsp + 40] ; position
    movups xmm1, [rsp + 56] ; velocity
    movups xmm2, [rsp + 24] ; gravity
    mulps xmm2, xmm3
    addps xmm1, xmm2
    movups [rdi + 16], xmm1
    mulps xmm1, xmm3
    addps xmm0, xmm1
    movups [rdi], xmm0
    ret

global equM4
equM4:
    lea rax, [epsilon]
    movups xmm3, [rax]
    mov rax, ~((1 << 63) + (1 << 31))
    movq xmm4, rax
    movq xmm5, rax
    pslldq xmm4, 8
    por xmm4, xmm5

    movups xmm0, [rdi]
    movups xmm1, [rsi]
    subps xmm0, xmm1
    pand xmm0, xmm4
    cmpleps xmm0, xmm3

    movups xmm1, [rdi + 16]
    movups xmm2, [rsi + 16]
    subps xmm1, xmm2
    pand xmm1, xmm4
    cmpleps xmm1, xmm3
    andps xmm0, xmm1

    movups xmm1, [rdi + 32]
    movups xmm2, [rsi + 32]
    subps xmm1, xmm2
    pand xmm1, xmm4
    cmpleps xmm1, xmm3
    andps xmm0, xmm1

    movups xmm1, [rdi + 48]
    movups xmm2, [rsi + 48]
    subps xmm1, xmm2
    pand xmm1, xmm4
    cmpleps xmm1, xmm3
    andps xmm0, xmm1

    movups xmm1, xmm0
    psrldq xmm1, 8
    andps xmm0, xmm1
    movups xmm1, xmm0
    psrldq xmm1, 4
    andps xmm0, xmm1

    movq rax, xmm0
    and rax, 1

    ret

global mulM4
; rdi: a
; rsi: b
; rdx: out
mulM4:
    xor r9, r9 ; row
    xor r10, r10 ; col

    xor rcx, rcx
.loop:
    cmp rcx, 64
    jge .loop_end

    mov r9, rcx
    and r9, 0b11110000
    mov r10, rcx
    and r10, 0b00001111

    pxor xmm0, xmm0

    movd xmm1, [rdi + r9]
    movd xmm2, [rsi + r10]
    mulss xmm1, xmm2
    addss xmm0, xmm1
    movd xmm1, [rdi + r9 + 4]
    movd xmm2, [rsi + r10 + 16]
    mulss xmm1, xmm2
    addss xmm0, xmm1
    movd xmm1, [rdi + r9 + 8]
    movd xmm2, [rsi + r10 + 32]
    mulss xmm1, xmm2
    addss xmm0, xmm1
    movd xmm1, [rdi + r9 + 12]
    movd xmm2, [rsi + r10 + 48]
    mulss xmm1, xmm2
    addss xmm0, xmm1

    movd [rdx + rcx], xmm0
    add rcx, 4
    jmp .loop
.loop_end:

    ret

global mulM4V4
; rdi = &matrix
; xmm0 = (x, y)
; xmm1 = (z, w)
mulM4V4:
    movq xmm2, xmm1
    pslldq xmm2, 8
    orps xmm2, xmm0
    movups xmm3, xmm2

    pxor xmm0, xmm0
    pxor xmm1, xmm1

    movups xmm4, [rdi + 16]
    mulps xmm3, xmm4
    addss xmm0, xmm3
    psrldq xmm3, 4
    addss xmm0, xmm3
    psrldq xmm3, 4
    addss xmm0, xmm3
    psrldq xmm3, 4
    addss xmm0, xmm3

    pslldq xmm0, 4

    movups xmm4, [rdi]
    movups xmm3, xmm2
    mulps xmm3, xmm4
    addss xmm0, xmm3
    psrldq xmm3, 4
    addss xmm0, xmm3
    psrldq xmm3, 4
    addss xmm0, xmm3
    psrldq xmm3, 4
    addss xmm0, xmm3

    movups xmm4, [rdi + 48]
    movups xmm3, xmm2
    mulps xmm3, xmm4
    addss xmm1, xmm3
    psrldq xmm3, 4
    addss xmm1, xmm3
    psrldq xmm3, 4
    addss xmm1, xmm3
    psrldq xmm3, 4
    addss xmm1, xmm3

    pslldq xmm1, 4

    movups xmm4, [rdi + 32]
    movups xmm3, xmm2
    mulps xmm3, xmm4
    addss xmm1, xmm3
    psrldq xmm3, 4
    addss xmm1, xmm3
    psrldq xmm3, 4
    addss xmm1, xmm3
    psrldq xmm3, 4
    addss xmm1, xmm3

    ret

global transposeM4
transposeM4:
    xor rax, rax
    xor rcx, rcx

.loop:
    cmp rcx, 16
    jae .loop_end

    mov eax, [rdi + rcx + 0]
    mov [rsi + rcx * 4 + 0], eax
    mov eax, [rdi + rcx + 16]
    mov [rsi + rcx * 4 + 4], eax
    mov eax, [rdi + rcx + 32]
    mov [rsi + rcx * 4 + 8], eax
    mov eax, [rdi + rcx + 48]
    mov [rsi + rcx * 4 + 12], eax

    add rcx, 4
    jmp .loop
.loop_end:

    ret

global subMat4
; rdi - row
; rsi - col
; rdx - &inMat
; rcx - &outMat
subMat4:
    shl rdi, 4
    shl rsi, 2
    mov r9, rcx
    add r9, 4 * 3 * 3
    xor rax, rax
.loop:
    cmp rcx, r9
    jae .loop_end
    mov r8, rax
    and r8, ~0x0f
    cmp r8, rdi
    je .skip_loop
    mov r8, rax
    and r8, 0x0f
    cmp r8, rsi
    je .skip_loop

    movd xmm0, [rdx + rax]
    movd [rcx], xmm0
    add rcx, 4

.skip_loop:
    add rax, 4
    jmp .loop
.loop_end:

    ret

global subMat3
; rdi - row
; rsi - col
; rdx - &inMat
; rcx - &outMat
subMat3:
    shl rdi, 2
    shl rsi, 2
    mov r10, rcx
    add r10, 16

    xor r8, r8
.row_loop:
    cmp r8, 12
    jae .done
    cmp r8, rdi
    je .row_loop_skip

    xor r9, r9
    .col_loop:
    cmp r9, 12
    jae .col_loop_end
    cmp r9, rsi
    je .col_loop_skip

    lea rax, [0 + r8 * 2 + r8]
    add rax, r9
    movd xmm0, [rdx + rax]
    movd [rcx], xmm0
    add rcx, 4
    cmp rcx, r10
    jae .done

    .col_loop_skip:
    add r9, 4
    jmp .col_loop
    .col_loop_end:

.row_loop_skip:
    add r8, 4
    jmp .row_loop
.done:
    ret

global determinantM2
determinantM2:
    movd xmm0, [rdi]
    movd xmm1, [rdi + 12]
    mulss xmm0, xmm1
    movd xmm1, [rdi + 4]
    movd xmm2, [rdi + 8]
    mulss xmm1, xmm2
    subss xmm0, xmm1
    ret

global determinantM3
determinantM3:
    push rbp
    mov rbp, rsp
    sub rsp, 28

    mov [rbp - 8], rdi

    xor rdi, rdi
    xor rsi, rsi
    mov rdx, [rbp - 8]
    lea rcx, [rbp - 24]
    call subMat3
    lea rdi, [rbp - 24]
    call determinantM2
    mov rax, [rbp - 8]
    movd xmm1, [rax]
    mulss xmm0, xmm1
    movd [rbp - 28], xmm0

    xor rdi, rdi
    mov rsi, 1
    mov rdx, [rbp - 8]
    lea rcx, [rbp - 24]
    call subMat3
    lea rdi, [rbp - 24]
    call determinantM2
    mov rax, [rbp - 8]
    movd xmm1, [rax + 4]
    mulss xmm1, xmm0
    movd xmm0, [rbp - 28]
    subss xmm0, xmm1
    movd [rbp - 28], xmm0

    xor rdi, rdi
    mov rsi, 2
    mov rdx, [rbp - 8]
    lea rcx, [rbp - 24]
    call subMat3
    lea rdi, [rbp - 24]
    call determinantM2
    mov rax, [rbp - 8]
    movd xmm1, [rax + 8]
    mulss xmm1, xmm0
    movd xmm0, [rbp - 28]
    addss xmm0, xmm1

    add rsp, 28
    pop rbp
    ret

global determinantM4
determinantM4:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov [rbp - 8], rdi
    xor rdi, rdi
    xor rsi, rsi
    mov rdx, [rbp - 8]
    lea rcx, [rbp - 44]
    call subMat4
    lea rdi, [rbp - 44]
    call determinantM3
    mov rax, [rbp - 8]
    movd xmm1, [rax]
    mulss xmm1, xmm0
    movd [rbp - 48], xmm1

    xor rdi, rdi
    mov rsi, 1
    mov rdx, [rbp - 8]
    lea rcx, [rbp - 44]
    call subMat4
    lea rdi, [rbp - 44]
    call determinantM3
    mov rax, [rbp - 8]
    movd xmm1, [rax + 4]
    mulss xmm1, xmm0
    movd xmm0, [rbp - 48]
    subss xmm0, xmm1
    movd [rbp - 48], xmm0

    xor rdi, rdi
    mov rsi, 2
    mov rdx, [rbp - 8]
    lea rcx, [rbp - 44]
    call subMat4
    lea rdi, [rbp - 44]
    call determinantM3
    mov rax, [rbp - 8]
    movd xmm1, [rax + 8]
    mulss xmm1, xmm0
    movd xmm0, [rbp - 48]
    addss xmm0, xmm1
    movd [rbp - 48], xmm0

    xor rdi, rdi
    mov rsi, 3
    mov rdx, [rbp - 8]
    lea rcx, [rbp - 44]
    call subMat4
    lea rdi, [rbp - 44]
    call determinantM3
    mov rax, [rbp - 8]
    movd xmm1, [rax + 12]
    mulss xmm1, xmm0
    movd xmm0, [rbp - 48]
    subss xmm0, xmm1

    add rsp, 48
    pop rbp
    ret

global inverseM4
; rdi: &inMat
; rsi: &outMat
inverseM4:
    push rbp
    mov rbp, rsp
    sub rsp, 20

    mov [rbp - 8], rdi
    mov [rbp - 16], rsi

    call determinantM4
    ptest xmm0, xmm0
    jz .not_invertible
    movd [rbp - 20], xmm0

    xor rdi, rdi
.row_loop:
    cmp rdi, 4
    jae .row_loop_end
    xor rsi, rsi
    .col_loop:
        cmp rsi, 4
        jae .col_loop_end

        push rdi
        push rsi
        mov rdx, [rbp - 8]
        call cofactorM4
        pop rsi
        pop rdi
        movd xmm1, [rbp - 20]
        divss xmm0, xmm1
        mov rax, rsi
        shl rax, 2
        add rax, rdi
        mov rcx, [rbp - 16]
        movd [rcx + rax * 4], xmm0

        inc rsi
        jmp .col_loop
    .col_loop_end:

    inc rdi
    jmp .row_loop
.row_loop_end:

    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret

.not_invertible:
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret

global cofactorM4
cofactorM4:
    push rbp
    mov rbp, rsp
    sub rsp, 40

    mov rax, rdi
    add rax, rsi
    test rax, 0x01
    mov eax, 0
    mov ecx, (1 << 31)
    cmovnz eax, ecx
    mov [rbp - 40], eax

    lea rcx, [rbp - 36]
    call subMat4
    lea rdi, [rbp - 36]
    call determinantM3

    movd xmm1, [rbp - 40]
    pxor xmm0, xmm1

    mov rsp, rbp
    pop rbp
    ret

global translation
; rdi = &outMat
; xmm0 = x
; xmm1 = y
; xmm2 = z
translation:
    pslldq xmm0, 12
    pslldq xmm1, 12
    pslldq xmm2, 12
    pxor xmm3, xmm3
    mov eax, __float32__(1.0)
    movd xmm3, eax
    por xmm0, xmm3
    pslldq xmm3, 4
    por xmm1, xmm3
    pslldq xmm3, 4
    por xmm2, xmm3
    pslldq xmm3, 4
    movups [rdi], xmm0
    movups [rdi + 16], xmm1
    movups [rdi + 32], xmm2
    movups [rdi + 48], xmm3
    ret

global scaling
; rdi = &outMat
; xmm0 = x
; xmm1 = y
; xmm2 = z
scaling:
    pxor xmm3, xmm3
    movups [rdi], xmm3
    movups [rdi + 16], xmm3
    movups [rdi + 32], xmm3
    movups [rdi + 48], xmm3
    movd [rdi], xmm0
    movd [rdi + 20], xmm1
    movd [rdi + 40], xmm2
    mov dword[rdi + 60], __float32__(1.0)
    ret

global rotation_x
; rdi = &outMat
; xmm0 = radians
rotation_x:
    sub rsp, 4

    movd [rsp], xmm0
    fld dword[rsp]
    fsincos

    pxor xmm1, xmm1
    movups [rdi], xmm1
    movups [rdi + 16], xmm1
    movups [rdi + 32], xmm1
    movups [rdi + 48], xmm1
    mov dword[rdi], __float32__(1.0)
    fst dword[rdi + 20] ; cos
    fstp dword[rdi + 40] ; cos
    fst dword[rdi + 36] ; sin
    fldz
    fsubrp
    fstp dword[rdi + 24] ; -sin
    mov dword[rdi + 60], __float32__(1.0)

    add rsp, 4
    ret

global rotation_y
; rdi = &outMat
; xmm0 = radians
rotation_y:
    sub rsp, 4

    movd [rsp], xmm0
    fld dword[rsp]
    fsincos

    pxor xmm1, xmm1
    movups [rdi], xmm1
    movups [rdi + 16], xmm1
    movups [rdi + 32], xmm1
    movups [rdi + 48], xmm1
    mov dword[rdi + 20], __float32__(1.0)
    mov dword[rdi + 60], __float32__(1.0)
    fst dword[rdi] ; cos
    fstp dword[rdi + 40] ; cos
    fst dword[rdi + 8] ; sin
    fldz
    fsubrp
    fstp dword[rdi + 32] ; -sin

    add rsp, 4
    ret

global rotation_z
; rdi = &outMat
; xmm0 = radians
rotation_z:
    sub rsp, 4

    movd [rsp], xmm0
    fld dword[rsp]
    fsincos

    pxor xmm1, xmm1
    movups [rdi], xmm1
    movups [rdi + 16], xmm1
    movups [rdi + 32], xmm1
    movups [rdi + 48], xmm1
    mov dword[rdi + 40], __float32__(1.0)
    mov dword[rdi + 60], __float32__(1.0)
    fst dword[rdi] ; cos
    fstp dword[rdi + 20] ; cos
    fst dword[rdi + 16] ; sin
    fldz
    fsubrp
    fstp dword[rdi + 4] ; -sin

    add rsp, 4
    ret

global shearing
shearing:
    mov dword[rdi], __float32__(1.0)
    movd [rdi + 4], xmm0
    movd [rdi + 8], xmm1
    mov dword[rdi + 12], __float32__(0.0)

    movd [rdi + 16], xmm2
    mov dword[rdi + 20], __float32__(1.0)
    movd [rdi + 24], xmm3
    mov dword[rdi + 28], __float32__(0.0)

    movd [rdi + 32], xmm4
    movd [rdi + 36], xmm5
    mov dword[rdi + 40], __float32__(1.0)
    mov dword[rdi + 44], __float32__(0.0)

    mov dword[rdi + 48], __float32__(0.0)
    mov dword[rdi + 52], __float32__(0.0)
    mov dword[rdi + 56], __float32__(0.0)
    mov dword[rdi + 60], __float32__(1.0)

    ret

global makeClock
makeClock:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    ; [rbp - 24]: canvas
    ; [rbp - 88]: transform
    ; [rbp - 142]: m_rotate
    ; [rbp - 206]: m_translate
    ; [rbp - 222]: point

    lea rdi, [rbp - 24]
    mov rsi, 32
    mov rdx, 32
    call createCanvas

    lea rdi, [rbp - 206]
    mov eax, __float32__(16.0)
    movd xmm0, eax
    mov eax, __float32__(16.0)
    movd xmm1, eax
    mov eax, __float32__(0.0)
    movd xmm2, eax
    call translation

    lea rdi, [rbp - 142]
    mov eax, __float32__(-0.52359877559829887307710723054658)
    movd xmm0, eax
    call rotation_z

    mov dword[rbp - 222], 0
    mov dword[rbp - 218], __float32__(15.0)
    mov dword[rbp - 214], 0
    mov dword[rbp - 210], __float32__(1.0)

    mov r9, 12
.loop:
    push r9
    movq xmm0, [rbp - 222]
    movq xmm1, [rbp - 214]
    lea rdi, [rbp - 142]
    call mulM4V4
    movq [rbp - 222], xmm0
    movq [rbp - 214], xmm1
    lea rdi, [rbp - 206]
    call mulM4V4
    cvttps2dq xmm0, xmm0
    movd esi, xmm0
    psrldq xmm0, 4
    movd eax, xmm0
    mov rdx, qword[(rbp - 24) + 8]
    sub rdx, rax
    lea rax, [white]
    movq xmm0, [rax]
    movd xmm1, [rax + 8]
    lea rdi, [rbp - 24]
    call writePixel
    pop r9

    dec r9
    jnz .loop

    lea rdi, [rbp - 24]
    call printCanvasPPM

    lea rdi, [rbp - 24]
    call destroyCanvas

    add rsp, 224
    pop rbp
    ret

global rayAt
; rdi = &ray
; xmm0 = t
rayAt:
    push rbp
    mov rbp, rsp
    movups xmm2, xmm0
    movq xmm0, [rdi + 16]
    movq xmm1, [rdi + 24]
    push rdi
    call mulV4Scalar
    pop rdi

    movq xmm2, [rdi]
    movq xmm3, [rdi + 8]

    call addV4

    mov rsp, rbp
    pop rbp
    ret

global sphere
; rdi = &sphere_count
; returns eax = new sphere id
sphere:
    mov eax, [rdi]
    inc dword [rdi]
    ret

global intersectSphere
; edi = sphere id
; rsi = &ray
; rdx = &out_intersections ([2]f32)
; rax = did_intersect: bool
intersectSphere:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov dword [rbp - 4], edi
    mov qword [rbp - 12], rsi
    mov qword [rbp - 20], rdx

    movups xmm0, [rsi]
    lea rax, [origin_point]
    movups xmm1, [rax]
    subps xmm0, xmm1
    movups [rbp - 36], xmm0 ; ray to sphere vector

    movq xmm0, [rsi + 16]
    movq xmm1, [rsi + 24]
    movq xmm2, xmm0
    movq xmm3, xmm1
    call dotV4
    movd [rbp - 40], xmm0

    movq xmm0, [rsi + 16]
    movq xmm1, [rsi + 24]
    movq xmm2, [rbp - 36]
    movq xmm3, [rbp - 28]
    call dotV4
    addss xmm0, xmm0
    movd [rbp - 44], xmm0

    movq xmm0, [rbp - 36]
    movq xmm1, [rbp - 28]
    movq xmm2, xmm0
    movq xmm3, xmm1
    call dotV4
    mov eax, __float32__(1.0)
    movd xmm1, eax
    subss xmm0, xmm1
    movd [rbp - 48], xmm0

    movd xmm0, [rbp - 44]
    mulss xmm0, xmm0

    mov eax, __float32__(4.0)
    movd xmm1, eax
    movd xmm2, [rbp - 40]
    mulss xmm1, xmm2
    movd xmm2, [rbp - 48]
    mulss xmm1, xmm2

    subss xmm0, xmm1
    movups xmm1, xmm0

    lea rax, [epsilon]
    movd xmm2, [rax]
    mov eax, 1 << 31
    movd xmm3, eax
    orps xmm2, xmm3
    mov rax, 0
    comiss xmm1, xmm2
    jb .done

    mov eax, 0
    movd xmm1, eax
    subss xmm1, [rbp - 44]
    movups xmm2, xmm1
    sqrtss xmm0, xmm0
    subss xmm1, xmm0
    addss xmm2, xmm0
    movd xmm3, [rbp - 40]
    addss xmm3, xmm3
    divss xmm1, xmm3
    divss xmm2, xmm3

    mov rdx, [rbp - 20]
    movd [rdx], xmm1
    movd [rdx + 4], xmm2

    mov rax, 1

.done:

    mov rsp, rbp
    pop rbp
    ret

section .data
env: dd 0.0, 0.0, 0.0, 0.0 ; wind
     dd 0.0, -1.0, 0.0, 0.0 ; gravity
proj:
    dd 0.0, 0.0, 0.0, 0.0 ; position
    dd 4.0, 10.0, 0.0, 0.0 ; velocity
white: dd 1.0, 1.0, 1.0
black: dd 0.0, 0.0, 0.0
time_factor: times 4 dd 0.1

global identM4
identM4:
    dd 1.0, 0.0, 0.0, 0.0
    dd 0.0, 1.0, 0.0, 0.0
    dd 0.0, 0.0, 1.0, 0.0
    dd 0.0, 0.0, 0.0, 1.0

origin_point:
    dd 0.0, 0.0, 0.0, 1.0
