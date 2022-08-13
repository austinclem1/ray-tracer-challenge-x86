default rel

section .data
global epsilon

fmt_str: db "Hi %d %d", 10, 0

epsilon: dd 1.19209289e-07
neg1_sse: times 4 dd -1.0

ppm_header_fmt: db "P3", 10, "%d %d", 10, "255", 10, 0
ppm_pixel_fmt: db "%d %d %d ", 0

section .text
extern malloc
extern free
extern printf
extern putchar

global equV4
equV4:
    push rbp
    mov rbp, rsp
    sub rsp, 8

    cmpeqps xmm0, xmm2
    cmpeqps xmm1, xmm3
    andps xmm0, xmm1
    movq [rsp], xmm0
    mov eax, [rsp]
    mov edi, [rsp + 4]
    and eax, edi

    add rsp, 8
    pop rbp
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
    movq rdi, xmm0
    shr rdi, 32
    movd xmm1, edi
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
writePixel:
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
    ret

global createCanvas
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

    lea rax, [white]
    movq xmm0, [rax]
    movd xmm1, [rax + 8]
    lea rdi, [rsp + 48]
    mov rsi, 0
    mov rdx, 0
    call writePixel
    lea rax, [white]
    movq xmm0, [rax]
    movd xmm1, [rax + 8]
    lea rdi, [rsp + 48]
    mov rsi, 1
    mov rdx, 0
    call writePixel

    lea rdi, [rsp + 48]
    call printCanvasPPM

    lea rdi, [rsp + 48]
    call destroyCanvas

    add rsp, 80
    pop rbp
    ret

section .data
env: dd 0.0, 0.0, 0.0, 0.0
proj:
    dd 0.0, 1.0, 0.0, 0.0 ; position
    dd 1.0, 1.0, 0.0, 0.0 ; velocity
white: dd 1.0, 1.0, 1.0
black: dd 0.0, 0.0, 0.0
