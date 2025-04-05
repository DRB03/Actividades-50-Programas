//===========================================================
// Archivo: p15.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-04
// Descripción: Implementa búsqueda binaria en un arreglo ordenado
// Link: https://asciinema.org/a/4dSCQofppPBDXMZ5bo9XBtN4f
//
// Ejemplo en JavaScript:
// function busquedaBinaria(arr, target) {
//   let izquierda = 0;
//   let derecha = arr.length - 1;
//   let pasos = 1;
//   
//   while (izquierda <= derecha) {
//     const medio = Math.floor((izquierda + derecha) / 2);
//     console.log(`Paso ${pasos}: Buscando entre ${izquierda} y ${derecha}, medio = ${medio}`);
//     
//     if (arr[medio] === target) return medio;
//     if (arr[medio] < target) izquierda = medio + 1;
//     else derecha = medio - 1;
//     pasos++;
//   }
//   return -1;
// }
// 
// const arreglo = [3, 6, 7, 9, 11, 12, 15, 18, 23, 45];
// const resultado = busquedaBinaria(arreglo, 18);
//===========================================================

.data
    arreglo:    .quad   3, 6, 7, 9, 11, 12, 15, 18, 23, 45  // Arreglo ordenado
    longitud:   .quad   10                                   // Longitud del arreglo
    buscar:     .quad   18                                   // Número a buscar
    msg_arr:    .asciz  "Arreglo: "
    msg_num:    .asciz  "%ld "                              // Formato para imprimir números
    msg_buscar: .asciz  "\nBuscando el número: %ld\n"       // Mensaje para número a buscar
    msg_enc:    .asciz  "Número encontrado en la posición: %ld\n" // Mensaje cuando se encuentra
    msg_no_enc: .asciz  "Número no encontrado en el arreglo\n"    // Mensaje cuando no se encuentra
    msg_paso:   .asciz  "Paso %ld: Buscando entre las posiciones %ld y %ld, medio = %ld\n" // Mensaje para seguimiento

.text
.global main
main:
    // Prólogo
    stp     x29, x30, [sp, -64]!    // Guarda el frame pointer y link register
    mov     x29, sp                 // Establece el frame pointer

    // Imprimir mensaje inicial
    ldr     x0, =msg_arr
    bl      printf

    // Inicializar variables
    ldr     x19, =arreglo           // x19 = dirección base del arreglo
    ldr     x20, =longitud          // Cargar dirección de longitud
    ldr     x20, [x20]              // x20 = longitud del arreglo
    mov     x21, #0                 // x21 = contador (i)
    
    // Imprimir todos los números del arreglo
print_loop:
    cmp     x21, x20
    bge     print_done              // Si i >= longitud, terminar impresión
    
    // Imprimir número actual
    ldr     x0, =msg_num
    ldr     x1, [x19, x21, lsl #3]  // Cargar arreglo[i]
    bl      printf
    
    add     x21, x21, #1           // i++
    b       print_loop
    
print_done:
    // Imprimir el número que vamos a buscar
    ldr     x0, =msg_buscar
    ldr     x1, =buscar
    ldr     x1, [x1]
    bl      printf

    // Inicializar búsqueda binaria
    mov     x21, #0                // x21 = izquierda = 0
    sub     x22, x20, #1           // x22 = derecha = longitud - 1
    ldr     x23, =buscar           // Cargar dirección del número a buscar
    ldr     x23, [x23]             // x23 = número a buscar
    mov     x24, #1                // x24 = contador de pasos

binary_search:
    cmp     x21, x22
    bgt     not_found              // Si izq > der, número no encontrado
    
    // Calcular punto medio
    add     x25, x21, x22          // x25 = izq + der
    lsr     x25, x25, #1           // x25 = (izq + der) / 2
    
    // Imprimir paso actual (con protección de registros)
    stp     x0, x1, [sp, #16]      // Guardar registros que printf podría modificar
    stp     x2, x3, [sp, #32]
    str     x4, [sp, #48]
    
    ldr     x0, =msg_paso
    mov     x1, x24                // Número de paso
    mov     x2, x21                // Izquierda
    mov     x3, x22                // Derecha
    mov     x4, x25                // Medio
    bl      printf
    
    ldp     x0, x1, [sp, #16]      // Restaurar registros
    ldp     x2, x3, [sp, #32]
    ldr     x4, [sp, #48]
    
    // Cargar elemento del medio
    ldr     x26, [x19, x25, lsl #3]  // x26 = arreglo[medio]
    
    // Comparar con el número buscado
    cmp     x26, x23
    beq     found                  // Si son iguales, número encontrado
    bgt     search_left            // Si medio > buscado, buscar en mitad izquierda
    
    // Buscar en mitad derecha
    add     x21, x25, #1           // izq = medio + 1
    b       continue_search
    
search_left:
    sub     x22, x25, #1           // der = medio - 1

continue_search:
    add     x24, x24, #1           // Incrementar contador de pasos
    b       binary_search

found:
    // Imprimir mensaje de éxito con la posición
    ldr     x0, =msg_enc
    mov     x1, x25
    bl      printf
    b       done

not_found:
    // Imprimir mensaje de no encontrado
    ldr     x0, =msg_no_enc
    bl      printf

done:
    // Epílogo y retorno
    mov     w0, #0
    ldp     x29, x30, [sp], 64
    ret
