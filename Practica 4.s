//===========================================================
// Archivo: practica4.s
// Autor: [Romero Bravo Daniel]
// Fecha: [2025-04-02]
// Serie: Contador del 1 al 10 en ARM64 Assembly
// Descripción: Muestra la secuencia del 1 al 10
// Link: https://asciinema.org/a/SwuBjT6pqq7JnV7JC6fIHXuAe
//
// Versión en Java:
// public class Contador {
//     public static void main(String[] args) {
//         for (int i = 1; i <= 10; i++) {
//             System.out.println(i);
//         }
//     }
// }
//===========================================================

.global _start

.section .bss
.lcomm buffer, 2      // Buffer para almacenar número como cadena (1 dígito + null)

.section .text
_start:
    mov x19, 1        // Inicializamos contador en 1 (x19 es registro preservado)

loop:
    cmp x19, 10       // ¿Es mayor a 10?
    bgt fin           // Si sí, terminamos

    // Convertir número a cadena ASCII
    add w0, w19, '0'  // Convierte número a ASCII
    ldr x1, =buffer   // Cargar dirección del buffer en registro x1
    strb w0, [x1]     // Almacena en buffer[0] (usando registro como dirección base)
    mov w0, 0         // Null terminator
    strb w0, [x1, 1]  // Almacena null en buffer[1]

    // Imprimir número
    mov x0, 1         // stdout
    ldr x1, =buffer   // dirección del buffer
    mov x2, 1         // longitud (1 carácter)
    mov x8, 64        // syscall write
    svc 0

    // Imprimir salto de línea
    mov x0, 1         // stdout
    ldr x1, =nl       // carácter de nueva línea
    mov x2, 1         // longitud
    mov x8, 64        // syscall write
    svc 0

    add x19, x19, 1   // Incrementar contador
    b loop

fin:
    // Salir del programa
    mov x8, 93        // syscall exit
    mov x0, 0         // código 0
    svc 0

.section .data
nl: .asciz "\n"       // Carácter de nueva línea
