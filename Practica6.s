//===========================================================
// Archivo: p6.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-03
// Descripción: Lee una cadena de texto y la convierte a minúsculas
// Link: https://asciinema.org/a/5fb0z0QNWfEZcc3xyVUwp8N0s
//
// Versión en C:
// #include <stdio.h>
// #include <ctype.h>
// int main() {
//     char buffer[100];
//     printf("Introduce un texto: ");
//     fgets(buffer, sizeof(buffer), stdin);
//     for(int i = 0; buffer[i]; i++) {
//         buffer[i] = tolower(buffer[i]);
//     }
//     printf("Texto en minúsculas: %s", buffer);
//     return 0;
// }
//===========================================================
.global _start
.section .data
    prompt: .asciz "Introduce un texto: "          // Mensaje de solicitud
    prompt_len = . - prompt
    output_msg: .asciz "Texto en minúsculas: "     // Mensaje de salida
    output_len = . - output_msg
    
.section .bss
    .lcomm buffer, 100                             // Buffer para almacenar la entrada
    .lcomm lowercase, 100                          // Buffer para la cadena convertida

.section .text
_start:
    // 1. Mostrar mensaje de solicitud
    mov x0, #1                          // stdout
    ldr x1, =prompt                     // Dirección del mensaje
    mov x2, prompt_len                  // Longitud del mensaje
    mov x8, #64                         // syscall write
    svc #0
    
    // 2. Leer entrada del usuario
    mov x0, #0                          // stdin
    ldr x1, =buffer                     // Dirección del buffer
    mov x2, #100                        // Tamaño máximo a leer
    mov x8, #63                         // syscall read
    svc #0
    
    // Guardar longitud de la cadena leída
    mov x3, x0                          // x3 = longitud de la cadena leída
    
    // 3. Copiar y convertir a minúsculas
    ldr x1, =buffer                     // Dirección del buffer de entrada
    ldr x2, =lowercase                  // Dirección del buffer de salida
    mov x4, #0                          // Inicializar contador a 0
    
conversion_loop:
    cmp x4, x3                          // Comprobar si hemos llegado al final
    beq print_result                    // Si es así, imprimir resultado
    
    ldrb w5, [x1, x4]                   // Cargar carácter actual
    
    // Comprobar si es mayúscula (ASCII 'A'-'Z' = 65-90)
    cmp w5, #'A'
    blt no_conversion                   // Si es menor que 'A', no convertir
    cmp w5, #'Z'
    bgt no_conversion                   // Si es mayor que 'Z', no convertir
    
    // Convertir: minúscula = mayúscula + 32
    add w5, w5, #32                     // Convertir a minúscula
    
no_conversion:
    strb w5, [x2, x4]                   // Guardar carácter (convertido o no)
    add x4, x4, #1                      // Incrementar contador
    b conversion_loop                   // Siguiente carácter
    
print_result:
    // 4. Mostrar mensaje de salida
    mov x0, #1                          // stdout
    ldr x1, =output_msg                 // Dirección del mensaje
    mov x2, output_len                  // Longitud del mensaje
    mov x8, #64                         // syscall write
    svc #0
    
    // 5. Mostrar la cadena en minúsculas
    mov x0, #1                          // stdout
    ldr x1, =lowercase                  // Dirección de la cadena convertida
    mov x2, x3                          // Longitud de la cadena
    mov x8, #64                         // syscall write
    svc #0
    
    // 6. Terminar programa
    mov x8, #93                         // syscall exit
    mov x0, #0                          // Código de salida 0
    svc #0
