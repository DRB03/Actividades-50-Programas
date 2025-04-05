//===========================================================
// Archivo: p16.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-03
// Descripción: Genera e imprime la serie de Fibonacci
// Link:  https://asciinema.org/a/CwxWZJiywPehGYjpcv7pn0tBZ
//
// Ejemplo en Java:
// public class Fibonacci {
//     public static void main(String[] args) {
//         System.out.println("Serie de Fibonacci:");
//         long a = 0, b = 1;
//         System.out.print(a + " " + b + " ");
//         for (int i = 2; i < 8; i++) {
//             long c = a + b;
//             System.out.print(c + " ");
//             a = b;
//             b = c;
//         }
//         System.out.println();
//     }
// }
//===========================================================

.data
    msg_titulo:     .asciz "Serie de Fibonacci:\n"   // Título de la serie
    msg_numero:     .asciz "%ld "                    // Formato para imprimir números
    msg_newline:    .asciz "\n"                      // Salto de línea
    cantidad:       .quad 8                          // Cantidad de números a generar

.text
.global main
main:
    // Prólogo - Configuración del stack frame
    stp     x29, x30, [sp, -48]!   // Reservar espacio en el stack (48 bytes)
    mov     x29, sp                // Establecer frame pointer

    // Imprimir título
    ldr     x0, =msg_titulo        // Cargar dirección del mensaje
    bl      printf                 // Llamar a printf

    // Inicializar primeros dos números de Fibonacci
    mov     x19, #0                // x19 = F0 = 0 (primer número)
    mov     x20, #1                // x20 = F1 = 1 (segundo número)
    
    // Imprimir F0 (0)
    ldr     x0, =msg_numero        // Cargar formato de impresión
    mov     x1, x19                // Cargar valor a imprimir
    bl      printf                 // Llamar a printf

    // Imprimir F1 (1)
    ldr     x0, =msg_numero        // Cargar formato de impresión
    mov     x1, x20                // Cargar valor a imprimir
    bl      printf                 // Llamar a printf

    // Configurar bucle para los siguientes números
    mov     x21, #2                // x21 = contador (empezamos desde el tercer número)
    ldr     x22, =cantidad         // Cargar dirección de la cantidad total
    ldr     x22, [x22]             // x22 = cantidad total (8)

fibonacci_loop:
    // Verificar condición de término del bucle
    cmp     x21, x22               // Comparar contador con cantidad total
    bge     done                   // Si contador >= cantidad, terminar

    // Calcular siguiente número de Fibonacci
    mov     x23, x20               // Guardar F[n-1] temporalmente
    add     x20, x19, x20          // F[n] = F[n-2] + F[n-1]
    mov     x19, x23               // Actualizar F[n-2] = antiguo F[n-1]

    // Imprimir el nuevo número
    ldr     x0, =msg_numero        // Cargar formato de impresión
    mov     x1, x20                // Cargar valor a imprimir
    bl      printf                 // Llamar a printf

    // Incrementar contador y repetir
    add     x21, x21, #1           // Incrementar contador
    b       fibonacci_loop         // Repetir bucle

done:
    // Imprimir salto de línea final
    ldr     x0, =msg_newline       // Cargar salto de línea
    bl      printf                 // Llamar a printf

    // Epílogo - Restaurar estado y retornar
    mov     w0, #0                 // Código de retorno 0 (éxito)
    ldp     x29, x30, [sp], 48     // Restaurar frame pointer y link register
    ret                            // Retornar al sistema operativo
