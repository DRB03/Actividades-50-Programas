//===========================================================
// Archivo: p8.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-03
// Descripción: Lee dos números enteros y muestra su resta
// Link: https://asciinema.org/a/2tu248lNwkw9SGfjrUUglihEC
//
// Ejemplo en Python:
// num1 = int(input("Ingresa el primer número: "))
// num2 = int(input("Ingresa el segundo número: "))
// print(f"Resta: {num1 - num2}")
//===========================================================

.global _start

.section .data
    msg_prompt1:   .asciz "Ingresa el primer número: "
    msg_prompt2:   .asciz "Ingresa el segundo número: "
    msg_result:    .asciz "Resta: "
    newline:      .asciz "\n"

.section .bss
    .lcomm num1, 21
    .lcomm num2, 21
    .lcomm result, 21

.section .text

_start:
    // Mostrar primer mensaje
    mov x0, #1
    ldr x1, =msg_prompt1
    mov x2, #23
    mov x8, #64
    svc #0

    // Leer primer número
    mov x0, #0
    ldr x1, =num1
    mov x2, #20
    mov x8, #63
    svc #0

    // Mostrar segundo mensaje
    mov x0, #1
    ldr x1, =msg_prompt2
    mov x2, #23
    mov x8, #64
    svc #0

    // Leer segundo número
    mov x0, #0
    ldr x1, =num2
    mov x2, #20
    mov x8, #63
    svc #0

    // Convertir cadenas a números
    ldr x1, =num1
    bl atoi
    mov x19, x0

    ldr x1, =num2
    bl atoi
    mov x20, x0

    // Realizar resta
    sub x21, x19, x20

    // Convertir resultado a cadena
    mov x0, x21
    ldr x1, =result
    bl itoa

    // Mostrar mensaje de resultado
    mov x0, #1
    ldr x1, =msg_result
    mov x2, #7
    mov x8, #64
    svc #0

    // Mostrar resultado numérico
    mov x0, #1
    ldr x1, =result
    bl strlen
    mov x2, x0
    mov x0, #1
    mov x8, #64
    svc #0

    // Mostrar salto de línea
    mov x0, #1
    ldr x1, =newline
    mov x2, #1
    mov x8, #64
    svc #0

    // Salir
    mov x0, #0
    mov x8, #93
    svc #0

atoi:
    mov x0, #0
    mov x3, #10
atoi_loop:
    ldrb w2, [x1], #1
    cmp w2, #10
    beq atoi_done
    cmp w2, #'0'
    blt atoi_done
    cmp w2, #'9'
    bgt atoi_done
    sub w2, w2, #'0'
    mul x0, x0, x3
    add x0, x0, x2
    b atoi_loop
atoi_done:
    ret

itoa:
    mov x2, x1
    mov x3, #10
    mov x4, #0
itoa_loop:
    udiv x5, x0, x3
    msub x6, x5, x3, x0
    add x6, x6, #'0'
    strb w6, [x1], #1
    add x4, x4, #1
    mov x0, x5
    cbnz x0, itoa_loop

    mov x0, x2
    sub x1, x1, #1
itoa_reverse:
    cmp x0, x1
    bge itoa_done
    ldrb w5, [x0]
    ldrb w6, [x1]
    strb w5, [x1]
    strb w6, [x0]
    add x0, x0, #1
    sub x1, x1, #1
    b itoa_reverse
itoa_done:
    mov w5, #0
    strb w5, [x2, x4]
    ret

strlen:
    mov x0, #0
strlen_loop:
    ldrb w2, [x1, x0]
    cbz w2, strlen_done
    add x0, x0, #1
    b strlen_loop
strlen_done:
    ret
