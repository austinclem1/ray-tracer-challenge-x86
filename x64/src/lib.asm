default rel

section .data
global epsilon

epsilon: dd 1.19209289e-07
neg1_sse: times 4 dd -1.0

section .text
extern malloc
extern printf

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
    call magV4
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
    mov rcx, 3
    mul rcx
    push rdi
    mov rdi, rax
    call malloc
    pop rdi
    mov qword [rdi + 16], rax
    ret

global doPrint
doPrint:
    lea rdi, [fmt_str]
    mov rsi, 5
    call printf wrt ..plt
    ret

; global printCanvasPPM
; printCanvasPPM:
    
;     ret
