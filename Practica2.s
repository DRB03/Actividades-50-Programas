//===========================================================
// Archivo: practica2.s
// Autor: [Romero Bravo Daniel]
// Fecha: [2025-04-02]
// Serie: Suma de dos números en ARM64 Assembly
// Descripción:  Se ingresan 2 numero del teclado y regresa el resultado de la suma
// Link: https://asciinema.org/a/RlsRXoy6lTpDJUyhOKKOB6SVI
//===========================================================

.global _start

.section .bss
.lcomm num1, 21       // Buffer para primer número (como cadena)
.lcomm num2, 21       // Buffer para segundo número (como cadena)
.lcomm res, 21        // Buffer para resultado (como cadena)

.section .text
_start:
    // Pedir primer número
    mov x0, 1         // stdout
    ldr x1, =msg1     // mensaje
    mov x2, msg1_len  // longitud
    mov x8, 64        // syscall write
    svc 0

    // Leer primer número (como cadena)
    mov x0, 0         // stdin
    ldr x1, =num1     // buffer
    mov x2, 20        // tamaño máximo
    mov x8, 63        // syscall read
    svc 0

    // Pedir segundo número
    mov x0, 1         // stdout
    ldr x1, =msg2     // mensaje
    mov x2, msg2_len  // longitud
    mov x8, 64        // syscall write
    svc 0

    // Leer segundo número (como cadena)
    mov x0, 0         // stdin
    ldr x1, =num2     // buffer
    mov x2, 20        // tamaño máximo
    mov x8, 63        // syscall read
    svc 0

    // Convertir num1 a entero
    ldr x0, =num1
    bl atoi
    mov x19, x0       // guardar primer número en x19

    // Convertir num2 a entero
    ldr x0, =num2
    bl atoi
    mov x20, x0       // guardar segundo número en x20

    // Realizar la suma
    add x21, x19, x20 // x21 = x19 + x20

    // Convertir resultado a cadena
    ldr x0, =res
    mov x1, x21
    bl itoa

    // Imprimir mensaje de resultado
    mov x0, 1         // stdout
    ldr x1, =msg3     // mensaje
    mov x2, msg3_len  // longitud
    mov x8, 64        // syscall write
    svc 0

    // Imprimir resultado
    mov x0, 1         // stdout
    ldr x1, =res      // buffer resultado
    bl strlen         // obtener longitud
    mov x2, x0        // longitud en x2
    mov x8, 64        // syscall write
    svc 0

    // Imprimir salto de línea
    mov x0, 1         // stdout
    ldr x1, =newline  // carácter de nueva línea
    mov x2, 1         // longitud
    mov x8, 64        // syscall write
    svc 0

    // Salir del programa
    mov x8, 93        // syscall exit
    mov x0, 0         // código 0
    svc 0

// Función atoi: convierte cadena a entero
// Entrada: x0 = dirección de la cadena
// Salida: x0 = valor entero
atoi:
    mov x1, 0         // acumulador
    mov x2, 10        // base 10
    mov x3, 0         // índice
atoi_loop:
    ldrb w4, [x0, x3] // carga byte
    cbz w4, atoi_end  // si es null termina
    cmp w4, 10        // verifica si es salto de línea
    beq atoi_end
    sub w4, w4, '0'   // convierte a dígito
    madd x1, x1, x2, x4 // acum = acum * 10 + dígito
    add x3, x3, 1     // incrementa índice
    b atoi_loop
atoi_end:
    mov x0, x1        // retorna resultado
    ret

// Función itoa: convierte entero a cadena
// Entrada: x0 = dirección del buffer, x1 = valor
// Salida: cadena en buffer
itoa:
    mov x2, 10        // base 10
    mov x3, 0         // contador de dígitos
    mov x4, x1        // copia del valor
itoa_count:
    udiv x4, x4, x2   // divide por 10
    add x3, x3, 1     // incrementa contador
    cbnz x4, itoa_count // hasta que sea cero

    strb wzr, [x0, x3] // null terminator
    sub x3, x3, 1     // posición del último dígito
itoa_loop:
    udiv x5, x1, x2   // divide por 10
    msub x6, x5, x2, x1 // x6 = x1 - (x5*10) (resto)
    add x6, x6, '0'   // convierte a ASCII
    strb w6, [x0, x3] // almacena dígito
    mov x1, x5        // actualiza valor
    sub x3, x3, 1     // decrementa posición
    cbnz x1, itoa_loop // repite si no es cero
    ret

// Función strlen: calcula longitud de cadena
// Entrada: x1 = dirección de la cadena
// Salida: x0 = longitud
strlen:
    mov x0, 0         // contador
strlen_loop:
    ldrb w2, [x1, x0] // carga byte
    cbz w2, strlen_end // si es null termina
    add x0, x0, 1     // incrementa contador
    b strlen_loop
strlen_end:
    ret

.section .data
msg1: .asciz "Ingresa el primer número: "
msg1_len = . - msg1

msg2: .asciz "Ingresa el segundo número: "
msg2_len = . - msg2

msg3: .asciz "La suma es: "
msg3_len = . - msg3

newline: .asciz "\n"
