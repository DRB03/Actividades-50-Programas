//===========================================================
// Archivo: p18.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-04
// Descripción: Implementación del algoritmo Selection Sort en ARM64
//              para ordenar un arreglo de enteros de 64 bits
// Link: https://asciinema.org/a/sLMCevbnmg4HvRMqihggwVSZN
//
// Ejemplo en C:
// void selectionSort(long arr[], long n) {
//     for (long i = 0; i < n-1; i++) {
//         long min_idx = i;
//         for (long j = i+1; j < n; j++)
//             if (arr[j] < arr[min_idx])
//                 min_idx = j;
//         
//         // Intercambiar el mínimo encontrado con el primer elemento
//         long temp = arr[min_idx];
//         arr[min_idx] = arr[i];
//         arr[i] = temp;
//     }
// }
//===========================================================

.data
array:      .quad   64, 34, 25, 12, 22, 11, 90, 1    // Array inicial
n:          .quad   8                                 // Tamaño del array
fmt_str:    .string "%ld "                           // Formato para imprimir
newline:    .string "\n"
msg_original: .string "Array original: "
msg_sorted:  .string "Array ordenado: "

.text
.global main

// Función principal
main:
    stp     x29, x30, [sp, -16]!    // Guardar frame pointer y link register
    mov     x29, sp                  // Actualizar frame pointer

    // Imprimir array original
    ldr     x0, =msg_original
    bl      printf
    ldr     x0, =fmt_str
    bl      printf_array

    // Llamar a selection sort
    bl      selection_sort

    // Imprimir array ordenado
    ldr     x0, =msg_sorted
    bl      printf
    ldr     x0, =fmt_str
    bl      printf_array

    mov     w0, #0                   // Retornar 0
    ldp     x29, x30, [sp], 16       // Restaurar registros
    ret

// Función de ordenamiento por selección
selection_sort:
    stp     x29, x30, [sp, -48]!     // Guardar registros
    mov     x29, sp
    stp     x19, x20, [sp, #16]      // Guardar registros preservados
    stp     x21, x22, [sp, #32]

    ldr     x19, =array               // x19 = dirección base del array
    ldr     x20, =n                   // x20 = dirección de n
    ldr     x20, [x20]                // x20 = tamaño del array (n)
    mov     x21, #0                   // x21 = i = 0

outer_loop:
    cmp     x21, x20                  // Comparar i con n
    bge     sort_end                  // Si i >= n, terminar
    
    mov     x22, x21                  // x22 = min_idx = i
    add     x23, x21, #1              // x23 = j = i + 1

inner_loop:
    cmp     x23, x20                  // Comparar j con n
    bge     swap_min                  // Si j >= n, hacer swap

    // Cargar y comparar elementos
    ldr     x24, [x19, x23, lsl #3]   // x24 = array[j]
    ldr     x25, [x19, x22, lsl #3]   // x25 = array[min_idx]
    cmp     x24, x25                  // Comparar array[j] con array[min_idx]
    bge     next_j                    // Si array[j] >= array[min_idx], siguiente j
    
    mov     x22, x23                  // min_idx = j

next_j:
    add     x23, x23, #1              // j++
    b       inner_loop

swap_min:
    cmp     x22, x21                  // Comparar min_idx con i
    beq     next_i                    // Si son iguales, no hacer swap

    // Intercambiar elementos
    ldr     x24, [x19, x21, lsl #3]   // x24 = temp = array[i]
    ldr     x25, [x19, x22, lsl #3]   // x25 = array[min_idx]
    str     x25, [x19, x21, lsl #3]   // array[i] = array[min_idx]
    str     x24, [x19, x22, lsl #3]   // array[min_idx] = temp

next_i:
    add     x21, x21, #1              // i++
    b       outer_loop

sort_end:
    ldp     x21, x22, [sp, #32]       // Restaurar registros
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], 48
    ret

// Función para imprimir array
printf_array:
    stp     x29, x30, [sp, -48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]      // Guardar registros preservados
    stp     x21, x22, [sp, #32]

    mov     x19, x0                   // Guardar formato en x19
    mov     x20, #0                   // x20 = i = 0
    ldr     x21, =array               // x21 = dirección del array
    ldr     x22, =n                   // x22 = dirección de n
    ldr     x22, [x22]                // x22 = tamaño del array

print_loop:
    cmp     x20, x22                  // Comparar i con n
    bge     print_end                 // Si i >= n, terminar

    ldr     x1, [x21, x20, lsl #3]    // Cargar array[i]
    mov     x0, x19                   // Cargar formato
    bl      printf                    // Llamar printf

    add     x20, x20, #1              // i++
    b       print_loop

print_end:
    ldr     x0, =newline              // Imprimir salto de línea
    bl      printf

    ldp     x21, x22, [sp, #32]       // Restaurar registros
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], 48
    ret
