//===========================================================
// Archivo: p7.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-03
// Descripción: Lee un valor en grados Celsius y lo convierte a Fahrenheit
// Link: https://asciinema.org/a/XbP6yrLZ8ZbthXSv8JF1GeL06
//
// Versión en Java:
// import java.util.Scanner;
// public class ConversorTemperatura {
//     public static void main(String[] args) {
//         Scanner sc = new Scanner(System.in);
//         System.out.print("Introduce grados Celsius: ");
//         int celsius = sc.nextInt();
//         int fahrenheit = (celsius * 9/5) + 32;
//         System.out.println("Grados Fahrenheit: " + fahrenheit);
//     }
// }
//===========================================================

.global _start

.section .data
    prompt:     .asciz "Introduce grados Celsius: "
    prompt_len = . - prompt

    result_msg: .asciz "Grados Fahrenheit: "
    result_len = . - result_msg

    newline:    .asciz "\n"

.section .bss
    .lcomm buffer, 100
    .lcomm outstr, 100

.section .text
_start:
    // Mostrar mensaje de entrada
    mov x0, #1
    ldr x1, =prompt
    mov x2, prompt_len
    mov x8, #64
    svc #0

    // Leer entrada
    mov x0, #0
    ldr x1, =buffer
    mov x2, #100
    mov x8, #63
    svc #0

    // Convertir cadena a número
    ldr x1, =buffer
    bl atoi
    mov w19, w0                // w19 = Celsius

    // Convertir a Fahrenheit: F = C * 9 / 5 + 32
    mov w0, w19
    mov w1, #9
    mul w0, w0, w1             // C * 9
    mov w1, #5
    udiv w0, w0, w1            // / 5
    add w0, w0, #32            // + 32
    mov w20, w0                // w20 = Fahrenheit

    // Mostrar mensaje de resultado
    mov x0, #1
    ldr x1, =result_msg
    mov x2, result_len
    mov x8, #64
    svc #0

    // Convertir resultado a cadena
    mov w0, w20
    ldr x1, =outstr
    bl itoa

    // Mostrar resultado numérico
    mov x0, #1
    ldr x1, =outstr
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
    mov x8, #93
    mov x0, #0
    svc #0

// ========= Funciones =========

atoi:
    mov w0, #0
    mov w3, #10                // Base 10
atoi_loop:
    ldrb w2, [x1], #1
    cmp w2, #10                // Verificar salto de línea
    beq atoi_done
    cmp w2, #'0'
    blt atoi_done
    cmp w2, #'9'
    bgt atoi_done
    sub w2, w2, #'0'
    mul w0, w0, w3
    add w0, w0, w2
    b atoi_loop
atoi_done:
    ret

itoa:
    mov x2, x1
    mov w3, w0
    mov w4, #10
    mov x5, x2
itoa_loop:
    udiv w6, w3, w4
    msub w7, w6, w4, w3
    add w7, w7, #'0'
    strb w7, [x2]
    add x2, x2, #1
    mov w3, w6
    cbz w3, itoa_end
    b itoa_loop
itoa_end:
    mov w0, #0
    strb w0, [x2]
    // Invertir cadena
    sub x3, x2, x5
    sub x3, x3, #1
    mov x4, #0
itoa_reverse:
    cmp x4, x3
    bge itoa_done
    ldrb w6, [x5, x4]
    ldrb w7, [x5, x3]
    strb w6, [x5, x3]
    strb w7, [x5, x4]
    add x4, x4, #1
    sub x3, x3, #1
    b itoa_reverse
itoa_done:
    ret

strlen:
    mov x0, #0
strlen_loop:
    ldrb w2, [x1, x0]
    cbz w2, strlen_end
    add x0, x0, #1
    b strlen_loop
strlen_end:
    ret
