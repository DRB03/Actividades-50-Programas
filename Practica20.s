//===========================================================
// Archivo: p20.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-04
// Descripción: Suma de dos matrices 3x3 en ensamblador ARM64
// Link: https://asciinema.org/a/ikaOzz1dAS5kVLlTkLo9U8WaB
//
// Ejemplo en Go:
// package main
//
// import "fmt"
//
// func main() {
//     // Definición de matrices
//     matriz1 := [3][3]int64{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}
//     matriz2 := [3][3]int64{{9, 8, 7}, {6, 5, 4}, {3, 2, 1}}
//     var resultado [3][3]int64
//
//     fmt.Println("\nSuma de Matrices 3x3")
//     
//     // Mostrar matrices originales
//     fmt.Println("\nMatriz 1:")
//     imprimirMatriz(matriz1)
//     
//     fmt.Println("\nMatriz 2:")
//     imprimirMatriz(matriz2)
//     
//     // Sumar matrices
//     for i := 0; i < 3; i++ {
//         for j := 0; j < 3; j++ {
//             resultado[i][j] = matriz1[i][j] + matriz2[i][j]
//         }
//     }
//     
//     // Mostrar resultado
//     fmt.Println("\nMatriz Resultado:")
//     imprimirMatriz(resultado)
// }
//
// func imprimirMatriz(matriz [3][3]int64) {
//     for i := 0; i < 3; i++ {
//         for j := 0; j < 3; j++ {
//             fmt.Printf("%3d ", matriz[i][j])
//         }
//         fmt.Println()
//     }
// }
//===========================================================

.data
    matriz1:    .quad   1, 2, 3,     // Primera matriz 3x3
                .quad   4, 5, 6,
                .quad   7, 8, 9

    matriz2:    .quad   9, 8, 7,     // Segunda matriz 3x3
                .quad   6, 5, 4,
                .quad   3, 2, 1

    resultado:  .skip   72           // Espacio para matriz resultado (3x3 * 8 bytes)
    
    dim:        .quad   3            // Dimensión de las matrices (3x3)

    // Mensajes para la salida
    msg_titulo: .asciz  "\nSuma de Matrices 3x3\n"
    msg_mat1:   .asciz  "\nMatriz 1:\n"
    msg_mat2:   .asciz  "\nMatriz 2:\n"
    msg_res:    .asciz  "\nMatriz Resultado:\n"
    msg_elem:   .asciz  "%3ld "      // Formato para imprimir elementos
    newline:    .asciz  "\n"

.text
.global main
main:
    // Prólogo
    stp     x29, x30, [sp, -64]!
    mov     x29, sp

    // Imprimir título
    ldr     x0, =msg_titulo
    bl      printf

    // Mostrar matriz 1
    ldr     x0, =msg_mat1
    bl      printf
    ldr     x0, =matriz1
    bl      imprimir_matriz

    // Mostrar matriz 2
    ldr     x0, =msg_mat2
    bl      printf
    ldr     x0, =matriz2
    bl      imprimir_matriz

    // Realizar la suma de matrices
    bl      sumar_matrices

    // Mostrar resultado
    ldr     x0, =msg_res
    bl      printf
    ldr     x0, =resultado
    bl      imprimir_matriz

    // Epílogo y retorno
    mov     w0, #0
    ldp     x29, x30, [sp], 64
    ret

// Subrutina para sumar las matrices
sumar_matrices:
    stp     x29, x30, [sp, -64]!
    mov     x29, sp

    mov     x19, #0          // i = 0
    ldr     x20, =dim
    ldr     x20, [x20]       // cargar dimensión
    mul     x21, x20, x20    // total de elementos (n^2)

suma_loop:
    cmp     x19, x21
    bge     suma_done

    // Cargar elementos de ambas matrices
    ldr     x22, =matriz1
    ldr     x23, =matriz2
    ldr     x24, [x22, x19, lsl #3]  // elemento de matriz1
    ldr     x25, [x23, x19, lsl #3]  // elemento de matriz2

    // Sumar elementos
    add     x24, x24, x25

    // Guardar resultado
    ldr     x22, =resultado
    str     x24, [x22, x19, lsl #3]

    add     x19, x19, #1     // incrementar contador
    b       suma_loop

suma_done:
    ldp     x29, x30, [sp], 64
    ret

// Subrutina para imprimir una matriz
imprimir_matriz:
    stp     x29, x30, [sp, -64]!
    mov     x29, sp
    str     x0, [sp, #16]    // guardar dirección de la matriz

    mov     x19, #0          // i = 0
    ldr     x20, =dim
    ldr     x20, [x20]       // cargar dimensión
    mul     x21, x20, x20    // total de elementos (n^2)

print_loop:
    cmp     x19, x21
    bge     print_done

    // Imprimir elemento
    ldr     x0, =msg_elem
    ldr     x22, [sp, #16]   // recuperar dirección de la matriz
    ldr     x1, [x22, x19, lsl #3]
    bl      printf

    // Nueva línea al final de cada fila
    add     x23, x19, #1     // i+1
    udiv    x24, x23, x20    // (i+1)/dimensión
    msub    x25, x24, x20, x23 // resto = (i+1) % dimensión
    cbnz    x25, no_newline  // si no es múltiplo de la dimensión, no nueva línea

    ldr     x0, =newline
    bl      printf

no_newline:
    add     x19, x19, #1     // incrementar contador
    b       print_loop

print_done:
    ldp     x29, x30, [sp], 64
    ret
