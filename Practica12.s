//===========================================================
// Archivo: p12.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-04
// Descripción: Programa que invierte una cadena de texto ingresada por el usuario
// Link:  https://asciinema.org/a/luUSRg5eGyvh8hx3EnCqSlBr7
//
// Ejemplo en C:
// #include <stdio.h>
// #include <string.h>
// 
// int main() {
//     char text[256], reversed[256];
//     printf("Ingrese un texto: ");
//     fgets(text, sizeof(text), stdin);
//     text[strcspn(text, "\n")] = '\0'; // Eliminar newline
//     
//     int len = strlen(text);
//     for (int i = 0; i < len; i++) {
//         reversed[i] = text[len - 1 - i];
//     }
//     reversed[len] = '\0';
//     
//     printf("Texto invertido: %s\n", reversed);
//     return 0;
// }
//===========================================================

.data
    prompt:         .asciz "Ingrese un texto: "    // Prompt para el usuario
    input_buffer:   .skip 256                      // Buffer para entrada del usuario
    msg_result:     .asciz "Texto invertido: %s\n" // Mensaje para mostrar resultado
    scanf_format:   .asciz "%[^\n]"               // Formato para scanf (lee hasta newline)
    result:         .skip 256                      // Buffer para el resultado

.text
.global main

main:
    // Prólogo
    stp     x29, x30, [sp, -16]!       // Guarda el frame pointer y link register
    mov     x29, sp                    // Establece el frame pointer

    // Mostrar prompt
    adr     x0, prompt                 // Cargar la dirección del mensaje de entrada
    bl      printf                     // Llamada a printf para mostrar el mensaje

    // Leer entrada del usuario
    adr     x0, scanf_format           // Formato de entrada para scanf
    adr     x1, input_buffer           // Dirección del buffer para guardar la entrada
    bl      scanf                      // Llamada a scanf para leer la entrada

    // Calcular longitud de la cadena ingresada
    adr     x0, input_buffer           // Dirección del buffer de entrada
    bl      strlen                     // Llamada a strlen, el resultado estará en x0
    mov     x2, x0                     // Guardar longitud de la cadena en x2

    // Preparar para invertir la cadena
    adr     x0, input_buffer           // Dirección de la cadena de entrada
    add     x0, x0, x2                 // Mover al final de la cadena
    sub     x0, x0, #1                 // Retroceder uno para apuntar al último carácter
    adr     x1, result                 // Dirección del buffer para el resultado

reverse_loop:
    // Verificar si hemos terminado
    cmp     x2, #0                     // Comparar longitud con cero
    ble     print_result               // Si es 0 o menor, imprimir el resultado

    // Copiar un carácter
    ldrb    w3, [x0]                  // Cargar byte de la cadena origen
    strb    w3, [x1]                  // Almacenar byte en el destino

    // Actualizar punteros y contador
    sub     x0, x0, #1                 // Mover puntero origen hacia atrás
    add     x1, x1, #1                 // Mover puntero destino hacia adelante
    sub     x2, x2, #1                 // Decrementar contador
    b       reverse_loop               // Volver al inicio del bucle

print_result:
    // Agregar terminador nulo al resultado
    mov     w3, #0                     // Establecer el valor 0
    strb    w3, [x1]                   // Almacenar terminador nulo en el resultado

    // Imprimir resultado
    adr     x0, msg_result             // Cargar mensaje de resultado
    adr     x1, result                 // Dirección del resultado invertido
    bl      printf                     // Llamada a printf para imprimir el resultado

    // Epílogo y retorno
    mov     w0, #0                     // Código de retorno 0
    ldp     x29, x30, [sp], 16         // Restaura el frame pointer y link register
    ret                                // Retorna al sistema operativo
