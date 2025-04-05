//===========================================================
// Archivo: p19.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-04
// Descripción: Implementación del algoritmo Merge Sort en ARM64
//              para ordenar un arreglo de enteros de 64 bits
// Link: https://asciinema.org/a/gxtFfclrB3Zh1DKTTOZerVrGr
//
// Ejemplo en C:
// void mergeSort(long arr[], long temp[], long left, long right) {
//     if (left < right) {
//         long mid = (left + right) / 2;
//         mergeSort(arr, temp, left, mid);
//         mergeSort(arr, temp, mid+1, right);
//         merge(arr, temp, left, mid, right);
//     }
// }
// 
// void merge(long arr[], long temp[], long left, long mid, long right) {
//     // Copiar a array temporal
//     for (long i = left; i <= right; i++)
//         temp[i] = arr[i];
//     
//     long i = left, j = mid+1, k = left;
//     while (i <= mid && j <= right) {
//         if (temp[i] <= temp[j]) {
//             arr[k] = temp[i];
//             i++;
//         } else {
//             arr[k] = temp[j];
//             j++;
//         }
//         k++;
//     }
//     
//     // Copiar elementos restantes
//     while (i <= mid) {
//         arr[k] = temp[i];
//         k++;
//         i++;
//     }
//     while (j <= right) {
//         arr[k] = temp[j];
//         k++;
//         j++;
//     }
// }
//===========================================================

.data
array:      .quad   64, 34, 25, 12, 22, 11, 90, 1    // Array inicial
temp:       .fill   8, 8, 0                          // Array temporal para merge
n:          .quad   8                                // Tamaño del array
fmt_str:    .string "%ld "                           // Formato para imprimir
newline:    .string "\n"                             // Nueva línea para el final de la impresión
msg1:       .string "Array original:\n"              // Mensaje para el array original
msg2:       .string "Array ordenado:\n"              // Mensaje para el array ordenado

.text
.global main

// Función para imprimir el array
print_array:
    stp     x29, x30, [sp, -32]!     // Guardar registros
    mov     x29, sp
    str     x0, [sp, 16]             // Guardar dirección del formato
    
    mov     x19, #0                  // Índice = 0
print_loop:
    ldr     x20, =n                  // Cargar tamaño del array
    ldr     x20, [x20]
    cmp     x19, x20                 // Comparar índice con n
    bge     print_end                // Si índice >= n, terminar
    
    ldr     x0, [sp, 16]             // Recuperar formato
    ldr     x1, =array
    ldr     x1, [x1, x19, lsl #3]    // Cargar elemento array[i]
    bl      printf
    
    add     x19, x19, #1             // Incrementar índice
    b       print_loop
    
print_end:
    ldr     x0, =newline             // Imprimir nueva línea
    bl      printf
    
    ldp     x29, x30, [sp], 32       // Restaurar registros
    ret

// Función principal
main:
    stp     x29, x30, [sp, -16]!     // Guardar frame pointer y link register
    mov     x29, sp                  // Actualizar frame pointer
    
    // Imprimir mensaje inicial "Array original"
    ldr     x0, =msg1
    bl      printf
    
    // Imprimir array original
    ldr     x0, =fmt_str
    bl      print_array
    
    // Llamar a merge sort
    mov     x0, #0                   // left = 0
    ldr     x1, =n
    ldr     x1, [x1]
    sub     x1, x1, #1               // right = n-1
    bl      merge_sort
    
    // Imprimir mensaje final "Array ordenado"
    ldr     x0, =msg2
    bl      printf
    
    // Imprimir array ordenado
    ldr     x0, =fmt_str
    bl      print_array
    
    // Finalizar y retornar 0
    mov     w0, #0                   // Retornar 0
    ldp     x29, x30, [sp], 16       // Restaurar registros
    ret

// Función merge_sort
merge_sort:
    stp     x29, x30, [sp, -48]!     // Guardar registros
    mov     x29, sp                  
    
    // Guardar left y right en la pila
    str     x0, [sp, 16]             // left
    str     x1, [sp, 24]             // right
    
    cmp     x0, x1                   // Si left >= right, retornar
    bge     merge_sort_end
    
    // Calcular medio = (left + right) / 2
    add     x2, x0, x1
    lsr     x2, x2, #1               // x2 = mid
    str     x2, [sp, 32]             // Guardar mid
    
    // Llamada recursiva para la mitad izquierda
    mov     x1, x2                   // right = mid
    bl      merge_sort
    
    // Llamada recursiva para la mitad derecha
    ldr     x0, [sp, 32]             // left = mid + 1
    add     x0, x0, #1
    ldr     x1, [sp, 24]             // right original
    bl      merge_sort
    
    // Merge de las dos mitades
    ldr     x0, [sp, 16]             // left original
    ldr     x1, [sp, 32]             // mid
    ldr     x2, [sp, 24]             // right
    bl      merge

merge_sort_end:
    ldp     x29, x30, [sp], 48       // Restaurar registros y retornar
    ret

// Función merge para combinar dos sub-arrays ordenados
merge:
    stp     x29, x30, [sp, -64]!     // Guardar registros
    mov     x29, sp
    
    // Guardar parámetros
    str     x0, [sp, 16]             // left
    str     x1, [sp, 24]             // mid
    str     x2, [sp, 32]             // right
    
    // Copiar elementos al array temporal
    mov     x3, x0                   // i = left
copy_loop:
    cmp     x3, x2                   // mientras i <= right
    bgt     copy_end
    
    ldr     x4, =array
    ldr     x5, [x4, x3, lsl #3]     // cargar array[i]
    
    ldr     x4, =temp
    str     x5, [x4, x3, lsl #3]     // temp[i] = array[i]
    
    add     x3, x3, #1               // i++
    b       copy_loop
    
copy_end:
    // Inicializar índices para merge
    ldr     x3, [sp, 16]             // i = left
    ldr     x4, [sp, 16]             // k = left
    ldr     x5, [sp, 24]
    add     x5, x5, #1               // j = mid + 1
    
merge_loop:
    ldr     x6, [sp, 24]             // Cargar mid
    cmp     x3, x6                   // Si i > mid
    bgt     copy_remaining_right
    
    ldr     x6, [sp, 32]             // Cargar right
    cmp     x5, x6                   // Si j > right
    bgt     copy_remaining_left
    
    // Comparar temp[i] y temp[j]
    ldr     x6, =temp
    ldr     x7, [x6, x3, lsl #3]     // temp[i]
    ldr     x8, [x6, x5, lsl #3]     // temp[j]
    
    cmp     x7, x8
    bgt     copy_right
    
copy_left:
    ldr     x6, =array
    str     x7, [x6, x4, lsl #3]     // array[k] = temp[i]
    add     x3, x3, #1               // i++
    b       next_merge
    
copy_right:
    ldr     x6, =array
    str     x8, [x6, x4, lsl #3]     // array[k] = temp[j]
    add     x5, x5, #1               // j++
    
next_merge:
    add     x4, x4, #1               // k++
    b       merge_loop
    
copy_remaining_left:
    ldr     x6, [sp, 24]             // Cargar mid
    cmp     x3, x6                   // Si i > mid
    bgt     merge_end
    
    ldr     x6, =temp
    ldr     x7, [x6, x3, lsl #3]     // temp[i]
    
    ldr     x6, =array
    str     x7, [x6, x4, lsl #3]     // array[k] = temp[i]
    
    add     x3, x3, #1               // i++
    add     x4, x4, #1               // k++
    b       copy_remaining_left
    
copy_remaining_right:
    ldr     x6, [sp, 32]             // Cargar right
    cmp     x5, x6                   // Si j > right
    bgt     merge_end
    
    ldr     x6, =temp
    ldr     x7, [x6, x5, lsl #3]     // temp[j]
    
    ldr     x6, =array
    str     x7, [x6, x4, lsl #3]     // array[k] = temp[j]
    
    add     x5, x5, #1               // j++
    add     x4, x4, #1               // k++
    b       copy_remaining_right
    
merge_end:
    ldp     x29, x30, [sp], 64       // Restaurar registros
    ret
