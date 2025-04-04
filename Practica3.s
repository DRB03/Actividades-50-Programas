//===========================================================
// Archivo: practica3.s
// Autor: [Romero Bravo Daniel]
// Fecha: [2025-04-02]
// Descripción: Muestra el resultado factorial
// Link: https://asciinema.org/a/ybAKYnMEcENAWFH10RE8wXXca
//
// Versión en C:
// #include <stdio.h>
// int main() {
//     int a = 5, b = 3;
//     printf("El resultado es: %d\n", a + b);
//     return 0;
// }
//===========================================================

.global _start

.section .data
    num1: .word 5       // Primer número (32 bits)
    num2: .word 3       // Segundo número (32 bits)
    msg: .asciz "El resultado es: "  // Mensaje de salida
    msg_len = . - msg   // Longitud del mensaje
    nl: .asciz "\n"     // Salto de línea

.section .bss
    .lcomm buffer, 2    // Buffer para resultado (dígito + null)

.section .text
_start:
    // 1. Cargar los números a sumar
    ldr x1, =num1       // Cargar dirección de num1
    ldr w1, [x1]        // Cargar valor de num1 (32 bits)
    ldr x2, =num2       // Cargar dirección de num2
    ldr w2, [x2]        // Cargar valor de num2 (32 bits)

    // 2. Realizar la suma
    add w3, w1, w2      // w3 = num1 + num2 (5 + 3 = 8)

    // 3. Preparar resultado para mostrar
    add w0, w3, '0'     // Convertir número a ASCII
    ldr x4, =buffer     // Cargar dirección del buffer
    strb w0, [x4]       // Guardar dígito ASCII
    mov w0, 0           // Null terminator
    strb w0, [x4, 1]    // Terminar cadena

    // 4. Mostrar mensaje "El resultado es: "
    mov x0, 1           // File descriptor (stdout)
    ldr x1, =msg        // Dirección del mensaje
    mov x2, msg_len     // Longitud del mensaje
    mov x8, 64          // syscall write
    svc 0

    // 5. Mostrar el resultado (dígito)
    mov x0, 1           // stdout
    ldr x1, =buffer     // Dirección del buffer
    mov x2, 1           // Longitud (1 byte)
    mov x8, 64          // syscall write
    svc 0

    // 6. Mostrar salto de línea
    mov x0, 1           // stdout
    ldr x1, =nl         // Dirección del salto de línea
    mov x2, 1           // Longitud (1 byte)
    mov x8, 64          // syscall write
    svc 0

    // 7. Terminar programa
    mov x8, 93          // syscall exit
    mov x0, 0           // Código de salida 0
    svc 0
