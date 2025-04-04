//===========================================================
// Archivo: p10.s
// Autor: Romero Bravo Daniel
// Fecha: 2025-04-03
// Descripción: Lee dos números enteros y muestra su división
//              con manejo de división por cero
// Link: https://asciinema.org/a/cmGqnQSspUgDuNhSTFfcO2t7q
//
// Ejemplo en C++:
// #include <iostream>
// using namespace std;
// int main() {
//     long num1, num2;
//     cout << "Ingresa el primer número: ";
//     cin >> num1;
//     cout << "Ingresa el segundo número: ";
//     cin >> num2;
//     if (num2 == 0) {
//         cerr << "Error: División por cero" << endl;
//     } else {
//         cout << "División: " << (num1 / num2) << endl;
//     }
//     return 0;
// }
//===========================================================

.global _start

.section .data
    msg_prompt1:   .asciz "Ingresa el primer número: "
    msg_prompt2:   .asciz "Ingresa el segundo número: "
    msg_div:       .asciz "División: "
    msg_div_zero:  .asciz "Error: División por cero\n"
    newline:       .asciz "\n"

.section .bss
    .lcomm num1, 21    // Buffer para primer número
    .lcomm num2, 21    // Buffer para segundo número
    .lcomm result, 21  // Buffer para resultado

.section .text

_start:
    // Mostrar primer mensaje
    mov x0, #1
    ldr x1, =msg_prompt1
    mov x2, #23         // Longitud de msg_prompt1
    mov x8, #64         // syscall write
    svc #0

    // Leer primer número
    mov x0, #0          // stdin
    ldr x1, =num1
    mov x2, #20         // Máximo 20 dígitos
    mov x8, #63         // syscall read
    svc #0

    // Mostrar segundo mensaje
    mov x0, #1
    ldr x1, =msg_prompt2
    mov x2, #23         // Longitud de msg_prompt2
    mov x8, #64
    svc #0

    // Leer segundo número
    mov x0, #0
    ldr x1, =num2
    mov x2, #20
    mov x8, #63
    svc #0

    // Convertir cadenas a números
    ldr x1, =num1
    bl atoi
    mov x19, x0         // Guardar primer número en x19

    ldr x1, =num2
    bl atoi
    mov x20, x0         // Guardar segundo número en x20

    // Verificar división por cero
    cmp x20, #0
    b.eq division_by_zero

    // Realizar división
    udiv x21, x19, x20  // División sin signo
    mov x0, x21
    ldr x1, =result
    bl itoa

    // Mostrar mensaje de resultado
    mov x0, #1
    ldr x1, =msg_div
    mov x2, #10         // Longitud de "División: "
    mov x8, #64
    svc #0

    // Mostrar resultado numérico
    mov x0, #1
    ldr x1, =result
    bl strlen
    mov x2, x0          // Longitud del string resultante
    mov x0, #1
    mov x8, #64
    svc #0

    // Mostrar salto de línea
    mov x0, #1
    ldr x1, =newline
    mov x2, #1
    mov x8, #64
    svc #0

    b exit_program

division_by_zero:
    // Mostrar mensaje de error
    mov x0, #1
    ldr x1, =msg_div_zero
    mov x2, #24         // Longitud de msg_div_zero
    mov x8, #64
    svc #0

exit_program:
    // Salir
    mov x0, #0          // Código de retorno 0
    mov x8, #93         // syscall exit
    svc #0

// ========= Funciones Auxiliares =========
// (Las mismas funciones atoi, itoa y strlen del ejemplo anterior)
atoi:
    mov x0, #0
    mov x3, #10
atoi_loop:
    ldrb w2, [x1], #1
    cmp w2, #10
    beq atoi_done
    cmp w2, #'0'
    blt atoi_done
    cmp w2, #'9'
    bgt atoi_done
    sub w2, w2, #'0'
    mul x0, x0, x3
    add x0, x0, x2
    b atoi_loop
atoi_done:
    ret

itoa:
    mov x2, x1
    mov x3, #10
    mov x4, #0
itoa_loop:
    udiv x5, x0, x3
    msub x6, x5, x3, x0
    add x6, x6, #'0'
    strb w6, [x1], #1
    add x4, x4, #1
    mov x0, x5
    cbnz x0, itoa_loop

    mov x0, x2
    sub x1, x1, #1
itoa_reverse:
    cmp x0, x1
    bge itoa_done
    ldrb w5, [x0]
    ldrb w6, [x1]
    strb w5, [x1]
    strb w6, [x0]
    add x0, x0, #1
    sub x1, x1, #1
    b itoa_reverse
itoa_done:
    mov w5, #0
    strb w5, [x2, x4]
    ret

strlen:
    mov x0, #0
strlen_loop:
    ldrb w2, [x1, x0]
    cbz w2, strlen_done
    add x0, x0, #1
    b strlen_loop
strlen_done:
    ret
