//===========================================================
// Archivo: p11.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-04
// Descripción: Verifica si un número ingresado es primo
// Link: https://asciinema.org/a/SLA0zVEMIInKmo1RXq2I1FxR5
// Compilación:
//   as -o primo_arm.o primo_arm.s
//   ld -o primo_arm primo_arm.o
// Ejecución:
//   ./primo_arm
//
// Ejemplo en Python:
// n = int(input("Ingrese un número para verificar si es primo: "))
// if n <= 1:
//     print(f"{n} no es un número primo")
// else:
//     for i in range(2, int(n**0.5) + 1):
//         if n % i == 0:
//             print(f"{n} no es un número primo")
//             break
//     else:
//         print(f"{n} es un número primo")
//===========================================================

.global _start

.section .data
    msg_prompt:    .asciz "Ingrese un número para verificar si es primo: "
    msg_es_primo:  .asciz " es un número primo\n"
    msg_no_primo:  .asciz " no es un número primo\n"
    newline:      .asciz "\n"

.section .bss
    .lcomm numero, 21    // Buffer para el número ingresado (20 dígitos + null)
    .lcomm resultado, 21 // Buffer para mensaje de resultado

.section .text

_start:
    // Mostrar mensaje de entrada
    mov x0, #1          // stdout
    ldr x1, =msg_prompt // dirección del mensaje
    mov x2, #44         // longitud del mensaje
    mov x8, #64         // syscall write
    svc #0

    // Leer número desde consola
    mov x0, #0          // stdin
    ldr x1, =numero     // buffer de entrada
    mov x2, #20         // tamaño máximo
    mov x8, #63         // syscall read
    svc #0

    // Convertir cadena ASCII a número entero
    ldr x1, =numero
    bl atoi
    mov x19, x0         // guardar número en x19

    // Verificación de número primo
    cmp x19, #1         // comparar con 1
    ble no_primo        // si <= 1, no es primo

    mov x20, #2         // inicializar divisor (i = 2)

check_loop:
    // Verificar hasta sqrt(n)
    mul x21, x20, x20   // i^2
    cmp x21, x19        // comparar i^2 con n
    bgt es_primo        // si i^2 > n, es primo

    // Verificar divisibilidad n % i == 0
    udiv x22, x19, x20  // n / i
    mul x23, x22, x20   // (n/i)*i
    cmp x23, x19        // comparar con n original
    beq no_primo       // si igual, es divisible

    add x20, x20, #1    // incrementar i
    b check_loop        // repetir

es_primo:
    // Convertir número a cadena para impresión
    mov x0, x19
    ldr x1, =resultado
    bl itoa

    // Imprimir número
    mov x0, #1
    ldr x1, =resultado
    bl strlen          // obtener longitud
    mov x2, x0        // longitud como parámetro
    mov x0, #1
    mov x8, #64
    svc #0

    // Imprimir mensaje "es primo"
    mov x0, #1
    ldr x1, =msg_es_primo
    mov x2, #19       // longitud del mensaje
    mov x8, #64
    svc #0
    b exit_program

no_primo:
    // Convertir número a cadena para impresión
    mov x0, x19
    ldr x1, =resultado
    bl itoa

    // Imprimir número
    mov x0, #1
    ldr x1, =resultado
    bl strlen
    mov x2, x0
    mov x0, #1
    mov x8, #64
    svc #0

    // Imprimir mensaje "no es primo"
    mov x0, #1
    ldr x1, =msg_no_primo
    mov x2, #22       // longitud del mensaje
    mov x8, #64
    svc #0

exit_program:
    // Terminar programa
    mov x0, #0        // código de salida 0
    mov x8, #93       // syscall exit
    svc #0

// ========= Funciones Auxiliares =========

// Función atoi: Convierte cadena ASCII a entero
// Entrada: x1 = dirección de la cadena
// Salida:  x0 = valor entero
atoi:
    mov x0, #0          // inicializar resultado a 0
    mov x3, #10         // base decimal
atoi_loop:
    ldrb w2, [x1], #1   // cargar byte y avanzar puntero
    cmp w2, #10         // verificar fin de línea
    beq atoi_done
    cmp w2, #'0'        // validar dígito
    blt atoi_done
    cmp w2, #'9'
    bgt atoi_done
    sub w2, w2, #'0'    // convertir ASCII a dígito
    mul x0, x0, x3      // resultado *= 10
    add x0, x0, x2      // resultado += dígito
    b atoi_loop
atoi_done:
    ret

// Función itoa: Convierte entero a cadena ASCII
// Entrada: x0 = número, x1 = dirección del buffer
itoa:
    mov x2, x1          // guardar dirección inicial
    mov x3, #10         // divisor
    mov x4, #0          // contador de dígitos
itoa_loop:
    udiv x5, x0, x3     // x5 = x0 / 10
    msub x6, x5, x3, x0 // x6 = x0 % 10
    add x6, x6, #'0'    // convertir a ASCII
    strb w6, [x1], #1   // almacenar dígito
    add x4, x4, #1      // incrementar contador
    mov x0, x5          // actualizar cociente
    cbnz x0, itoa_loop  // repetir si cociente != 0

    // Invertir cadena (se almacenó en orden inverso)
    mov x0, x2          // inicio del buffer
    sub x1, x1, #1      // fin del buffer
itoa_reverse:
    cmp x0, x1
    bge itoa_done
    ldrb w5, [x0]       // intercambiar bytes
    ldrb w6, [x1]
    strb w5, [x1]
    strb w6, [x0]
    add x0, x0, #1
    sub x1, x1, #1
    b itoa_reverse
itoa_done:
    mov w5, #0          // terminador nulo
    strb w5, [x2, x4]   // al final del buffer
    ret

// Función strlen: Calcula longitud de cadena ASCII
// Entrada: x1 = dirección de la cadena
// Salida:  x0 = longitud (sin contar el null)
strlen:
    mov x0, #0          // inicializar contador
strlen_loop:
    ldrb w2, [x1, x0]   // cargar byte
    cbz w2, strlen_done // terminar si es null
    add x0, x0, #1      // incrementar contador
    b strlen_loop
strlen_done:
    ret
