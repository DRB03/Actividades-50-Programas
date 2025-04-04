//===========================================================
// Archivo: practica5.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-02
// Descripción: Muestra el factorial
// Link: https://asciinema.org/a/GGsUzsFU0B85JZzOgwd4v0IEE
//
// Versión en C:
// #include <stdio.h>
// int main() {
//     int n = 5, factorial = 1;
//     for(int i = 1; i <= n; i++) {
//         factorial *= i;
//     }
//     printf("El factorial de %d es: %d\n", n, factorial);
//     return 0;
// }
//===========================================================
.global _start
.section .data
    num: .word 5                            // Número para calcular factorial
    msg1: .asciz "El factorial de "         // Primera parte del mensaje
    msg1_len = . - msg1
    msg2: .asciz " es: "                    // Segunda parte del mensaje
    msg2_len = . - msg2
    nl: .asciz "\n"                         // Salto de línea
.section .bss
    .lcomm buffer, 12                       // Buffer para convertir números a ASCII
.section .text
_start:
    // 1. Cargar el número y preparar registro para factorial
    ldr x1, =num                            // Cargar dirección de num
    ldr w1, [x1]                            // w1 = 5 (valor de num)
    mov w2, #1                              // w2 = 1 (factorial inicial)
    mov w3, #1                              // w3 = 1 (contador i)

factorial_loop:
    cmp w3, w1                              // Comparar i con n
    bgt print_result                        // Si i > n, salir del bucle
    mul w2, w2, w3                          // factorial *= i
    add w3, w3, #1                          // i++
    b factorial_loop                        // Siguiente iteración

print_result:
    // 2. Mostrar "El factorial de "
    mov x0, #1                              // stdout
    ldr x1, =msg1                           // Dirección del mensaje 1
    mov x2, msg1_len                        // Longitud del mensaje 1
    mov x8, #64                             // syscall write
    svc #0

    // 3. Mostrar el número (5)
    ldr x1, =num                            // Cargar dirección de num
    ldr w1, [x1]                            // w1 = 5
    add w1, w1, #'0'                        // Convertir a ASCII
    ldr x2, =buffer                         // Dirección del buffer
    strb w1, [x2]                           // Guardar en buffer
    
    mov x0, #1                              // stdout
    ldr x1, =buffer                         // Dirección del buffer
    mov x2, #1                              // Longitud (1 byte)
    mov x8, #64                             // syscall write
    svc #0

    // 4. Mostrar " es: "
    mov x0, #1                              // stdout
    ldr x1, =msg2                           // Dirección del mensaje 2
    mov x2, msg2_len                        // Longitud del mensaje 2
    mov x8, #64                             // syscall write
    svc #0

    // 5. Convertir el resultado (120) a ASCII y mostrarlo
    mov w1, w2                              // w1 = factorial (120)
    ldr x2, =buffer                         // Dirección del buffer
    add x2, x2, #11                         // Empezar desde el final del buffer
    mov w3, #0                              // Inicializar terminador nulo
    strb w3, [x2]                           // Poner terminador al final
    sub x2, x2, #1                          // Mover puntero hacia atrás
    
    mov w4, #10                             // Divisor (10)

convert_loop:
    udiv w5, w1, w4                         // w5 = w1 / 10
    msub w6, w5, w4, w1                     // w6 = w1 - (w5 * 10) [resto]
    add w6, w6, #'0'                        // Convertir resto a ASCII
    strb w6, [x2]                           // Guardar dígito en buffer
    sub x2, x2, #1                          // Mover puntero hacia atrás
    mov w1, w5                              // w1 = w1 / 10
    cbnz w1, convert_loop                   // Si w1 != 0, continuar
    
    add x2, x2, #1                          // Ajustar puntero al primer dígito
    
    // 6. Mostrar el resultado
    mov x0, #1                              // stdout
    mov x1, x2                              // Dirección del primer dígito
    ldr x3, =buffer                         // Dirección del buffer
    add x3, x3, #11                         // Final del buffer
    sub x2, x3, x2                          // Calcular longitud (final - inicio)
    mov x8, #64                             // syscall write
    svc #0

    // 7. Mostrar salto de línea
    mov x0, #1                              // stdout
    ldr x1, =nl                             // Dirección del salto de línea
    mov x2, #1                              // Longitud (1 byte)
    mov x8, #64                             // syscall write
    svc #0

    // 8. Terminar programa
    mov x8, #93                             // syscall exit
    mov x0, #0                              // Código de salida 0
    svc #0
