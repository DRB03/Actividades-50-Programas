//===========================================================
// Archivo: nombre.s
// Autor: [Romero Bravo Daniel]
// Fecha: [2025-04-01]
// Serie: Captura de nombre en ARM64 Assembly
// Descripción: Ingresa tu nombre capturado del teclado y te muestra un mensaje.
// Link: https://asciinema.org/connect/ca05399a-a1b3-42c1-ba48-6fa7e7a755f1
//
// Versión en C#:
// using System;
// class Program {
//     static void Main() {
//         Console.Write("Ingrese su nombre: ");
//         string nombre = Console.ReadLine();
//         Console.WriteLine("Hola, " + nombre);
//     }
// }
//===========================================================

.global _start

.section .bss
nombre:    .skip 100   // Reservamos espacio para almacenar el nombre (100 bytes)

.section .data
msg_ingreso: .asciz "Ingrese su nombre: " 
msg_salida:  .asciz "Hola, "

.section .text
_start:
    // Imprimir mensaje de ingreso
    mov x0, 1             // File descriptor 1 (stdout)
    ldr x1, =msg_ingreso  // Dirección del mensaje
    mov x2, 18            // Tamaño del mensaje
    mov x8, 64            // syscall write
    svc 0                 // Llamada al sistema

    // Leer el nombre ingresado
    mov x0, 0             // File descriptor 0 (stdin)
    ldr x1, =nombre       // Buffer donde guardamos el nombre
    mov x2, 100           // Tamaño máximo del buffer
    mov x8, 63            // syscall read
    svc 0                 // Llamada al sistema

    // Imprimir mensaje de salida "Hola, "
    mov x0, 1             // File descriptor 1 (stdout)
    ldr x1, =msg_salida   // Dirección del mensaje
    mov x2, 6             // Tamaño del mensaje
    mov x8, 64            // syscall write
    svc 0                 // Llamada al sistema

    // Imprimir el nombre ingresado
    mov x0, 1             // File descriptor 1 (stdout)
    ldr x1, =nombre       // Dirección del buffer con el nombre
    mov x2, 100           // Tamaño máximo del buffer (puede ser menos)
    mov x8, 64            // syscall write
    svc 0                 // Llamada al sistema

    // Salir del programa
    mov x8, 93            // syscall exit
    mov x0, 0             // Código de salida
    svc 0                 // Llamada al sistema
