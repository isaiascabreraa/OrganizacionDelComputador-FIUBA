
global main
extern sprintf
extern printf
extern gets
extern puts
extern sscanf
extern scanf
extern fopen
extern fclose
extern fread
extern fwrite

;variables con contenido
section .data
    ;Manejo de ayuda al usuario:
    formatoIngresarLetras db "%c %c",0
    msjIngresarOperacion db "Ingrese 'E' para ENCRIPTAR el codigo o 'D' para DESENCRIPTAR",10,0
    formatoOperacion db "%c",0

    printfFormat db "Las letras %c %c ingresadas se guardaron correctamente",10,0
    printfOperacionFallida db "Los caracteres ingresados no son validos, intenta nuevamente",10,0

    printOperacionDesencriptado db "La operacion introducida fue la de DESENCRIPTACION",10,0
    printOperacionEncriptado db "La operacion introducida fue la de ENCRIPTACION",10,0
    printENCRIPTACION db "La letra ahora es %c",10,0
    printANTERIOR db "La letra antes es %c",10,0

    printfBUSCADO db "La fila: %i y la columna: %i ",10,0
    printfLETRA db "La letra encontrada %c",10,0

    printfSTRING db " %s ",10,0

    ;Manejo de dimensiones de la matriz
    LongELEMENTO equ 1
	cantidadCOLUMNAS equ 5

    ;MANEJO DE ARCHIVOS MATRIZ
    fileMatriz db 'matriz5x5.txt',0
    modeMatriz db 'rb',0

    filaExit db "textoencoded.txt",0
    modeExit db "wb",0

    vectorLetrasValidas db "A B C D E F G H I K L M N O P Q R S T U V W X Y Z "

    ;MANEJO DE ARCHIVOS CODE
    fileCode db 'texto.txt',0
    modeCode db 'rb',0

    vectorTextoValido db "ABCDEFGHIKLMNOPQRSTUVWXYZabcdefghiklmnopqrstuvwxyz "
    vectorTextoConvertir db "abcdefghiklmnopqrstuvwxyz"
    espacioVacio dw " "

;variables sin contenido
section .bss
    ;Reservo memoria para elementos de la contruccion de mi matriz
    contadorMatriz resw 1

    ;Reservo memoria para elementos de la contruccion de mi codigo a encriptar o desencriptar
    contadorCode resw 1

    ;Reservo memoria para elementos que me permiten recorrer el texto tupla a tupla
    contadorTupla resw 1

    ;Reservo memoria para el input del usuario
    letrasRecibidas resq 1
    operacionRecibida resq 1

    ;Reservo memoria para recorrer la matriz
    letraInicialTupla resq 1
    letraFinalTupla resq 1
    letraBuscada resq 1
    letraActual resq 1

    ;Reservo memoria para realizar la encriptacion y desencriptacion
    operacionARealizar resq 1

    letraEncriptadaActual resq 1
    letraEncriptada1 resq 1
    letraEncriptada2 resq 1
    letraEncriptada resq 1

    ;Reservo memoria para los elementos de mi matriz
    matriz times 5 resw 5
    columna resq 1
    fila resq 1

    filaElemento1 resq 1
    columnaElemento1 resq 1
    filaElemento2 resq 1
    columnaElemento2 resq 1

    ;Reservo memoria para la codificacion y decodifiacion
    textoCode resw 100

    ;Reservo memoria para el manejo de archivos de MATRIZ
    registroMatriz times 0 resw 1
        letra resw 1

    handleMatriz resq 1

    ;Reservo memoria para el manejo de archivos de CODE
    registroCode times 0 resw 1
        texto resw 1

    handleCode resq 1

    handleExit resq 1

    ;Reservo memoria para las validaciones
    letraEsValida resb 1
    textoEsValido resb 1

section .text
main:

    ;Inicializo valores
    mov rax, 0
    mov [contadorMatriz], rax
    mov [contadorCode], rax
    mov [contadorTupla], rax

    ;Abro mis archivos
    call openMatriz
    cmp rax,0
    jle finPrograma
    mov [handleMatriz], rax ;Guardo la identificacion de mi archivo de matriz

    ;Abro el codigo a codificar o descodificar
    call openCode
    cmp rax,0
    jle cierreCodeFILE
    mov [handleCode], rax ;Guardo la identificacion de mi archivo de codigo

    ;Abro el codigo a codificar o descodificar
    call openExit
    cmp rax,0
    jle cierreCodeFILE
    mov [handleExit], rax ;Guardo la identificacion de mi archivo de codigo

    call leerRegistroMatriz
    call leerRegistroCode

    mov rcx, printfSTRING
    mov rdx, textoCode
    sub rsp, 32
    call printf
    add rsp, 32

    call ingresarInput

    ;EL LOOP ES DE ACA
    obtenerTuplas:
    mov rbx,0
    mov rcx, [contadorCode]
    push rcx
    primeraTupla:
    call encontrarPrimeraTupla
    cmp byte[letraEsValida], 'N'
    je primeraTupla
    cmp byte[letraEsValida], 'F'
    je agregarUltimaLetra

    segundaTupla:
    call encontrarSegundaTupla
    cmp byte[letraEsValida], 'N'
    je segundaTupla
    cmp byte[letraEsValida], 'F'
    je agregarUltimaLetra

    call obtenerPosiciones
    call determinarOperacion

    jmp finEncodeo

    agregarUltimaLetra:
    mov rax, [letraInicialTupla]
    mov [letraEncriptada], rax
    call writeExit
    jmp cierreDeArchivos

    finEncodeo:
    call escribirRegistroSalida
    pop rcx
    sub rcx, [contadorTupla]
    loop obtenerTuplas
    ;HASTA ACA

    cierreDeArchivos:

    cierreExitFILE:
    call closeExit

    cierreCodeFILE:
    call closeCode

    cierreMatrizFILE:
    call closeMatriz

    finPrograma:
ret


escribirRegistroSalida:
    mov rax, [letraEncriptada1]
    mov [letraEncriptada], rax
    call writeExit
    mov rax, [letraEncriptada2]
    mov [letraEncriptada], rax
    call writeExit
ret

ingresarInput:
    mov rcx, msjIngresarOperacion
    sub rsp, 32
    call printf
    add rsp, 32

    mov rcx, operacionRecibida
    sub rsp, 32
    call gets
    add rsp, 32

    mov rcx, operacionRecibida
    mov rdx, formatoOperacion
    mov r8, operacionARealizar
    sub rsp, 32
    call sscanf
    add rsp, 32

    call validacionInputOperacion
ret

encontrarPrimeraTupla:
    mov rbx, [contadorTupla]
    mov rcx, 1
    lea rsi, [textoCode+rbx]
    lea rdi, [letraInicialTupla]
    rep movsb
    call validarTuplaInicial
ret

encontrarSegundaTupla:
    mov rbx, [contadorTupla]
    mov rcx, 1
    lea rsi, [textoCode+rbx]
    lea rdi, [letraFinalTupla]
    rep movsb
    call validarTuplaFinal
ret


validarTuplaInicial:
    mov byte[letraEsValida],'S'

    mov bx, [letraInicialTupla]
    cmp bx, [espacioVacio]
    je tuplaInicialInvalida

    jmp finValidacionTuplaInicial

    tuplaInicialInvalida:
    mov byte[letraEsValida],'N'

    finValidacionTuplaInicial:
    inc word[contadorTupla]
    call verificarFinazalicionLectura
ret

validarTuplaFinal:
    mov byte[letraEsValida],'S'

    mov bx, [letraFinalTupla]
    cmp bx, [espacioVacio]
    je tuplaFinalInvalida

    cmp bx, [letraInicialTupla]
    je tuplaFinalInvalida

    jmp finValidacionTuplaFinal

    tuplaFinalInvalida:
    mov byte[letraEsValida],'N'

    finValidacionTuplaFinal:
    inc word[contadorTupla]
    call verificarFinazalicionLectura
ret

verificarFinazalicionLectura:
    mov bx, [contadorTupla]
    mov cx, [contadorCode]
    cmp bx, cx
    jle finValidacionLectura

    finRecorrido:
    mov byte[letraEsValida],'F'

    finValidacionLectura:
ret

determinarOperacion:
    mov rdx, [filaElemento1]
    cmp rdx, [filaElemento2]
    je DeLado
    mov rdx, [columnaElemento1]
    cmp rdx, [columnaElemento2]
    je PorDebajo
    jne Rectangular
ret

DeLado:
    mov al, [operacionARealizar]
    cmp al, 'E'
    je encriptacionLado
    jne desencriptacionLado

    encriptacionLado:
    mov rcx, [columnaElemento1]
    cmp rcx, 4
    je continuoEncriptacion3A
    add rcx, 1
    mov [columnaElemento1], rcx
    continuoEncriptacion3A:
    mov [columna], rcx
    mov rdx, [filaElemento1]
    mov [fila], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada1], rbx

    mov rcx, [columnaElemento2]
    cmp rcx, 4
    je continuoEncriptacion3B
    add rcx, 1
    mov [columnaElemento2], rcx
    continuoEncriptacion3B:
    mov [columna], rcx
    mov rdx, [filaElemento2]
    mov [fila], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada2], rbx

    jmp finEncodeo

    desencriptacionLado:
    mov rcx, [columnaElemento1]
    cmp rcx, 4
    je continuoDesencriptacion3A
    cmp rcx, 0
    je continuoDesencriptacion3A
    sub rcx, 1
    mov [columnaElemento1], rcx
    continuoDesencriptacion3A:
    mov [columna], rcx
    mov rdx, [filaElemento1]
    mov [fila], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada1], rbx

    mov rcx, [columnaElemento2]
    cmp rcx, 4
    je continuoDesencriptacion3B
    cmp rcx, 0
    je continuoDesencriptacion3B
    sub rcx, 1
    mov [columnaElemento2], rcx
    continuoDesencriptacion3B:
    mov [columna], rcx
    mov rdx, [filaElemento2]
    mov [fila], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada2], rbx

    jmp finEncodeo
ret

PorDebajo:
    mov al, [operacionARealizar]
    cmp al, 'E'
    je encriptacionPorDebajo
    jne desencriptacionPorDebajo

    encriptacionPorDebajo:
    mov rcx, [filaElemento1]
    cmp rcx, 4
    je continuoEncriptacion2A
    add rcx, 1
    mov [filaElemento1], rcx
    continuoEncriptacion2A:
    mov [fila], rcx
    mov rdx, [columnaElemento1]
    mov [columna], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada1], rbx

    mov rcx, [filaElemento2]
    cmp rcx, 4
    je continuoEncriptacion2B
    add rcx, 1
    mov [filaElemento2], rcx
    continuoEncriptacion2B:
    mov [fila], rcx
    mov rdx, [columnaElemento2]
    mov [columna], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada2], rbx

    jmp finEncodeo

    desencriptacionPorDebajo:
    mov rcx, [filaElemento1]
    cmp rcx, 4
    je continuoDesencriptacion2A
    cmp rcx, 0
    je continuoDesencriptacion2A
    sub rcx, 1
    mov [filaElemento1], rcx
    continuoDesencriptacion2A:
    mov [fila], rcx
    mov rdx, [columnaElemento1]
    mov [columna], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada1], rbx

    mov rcx, [filaElemento2]
    cmp rcx, 4
    je continuoDesencriptacion2B
    cmp rcx, 0
    je continuoDesencriptacion2B
    sub rcx, 1
    mov [filaElemento2], rcx
    continuoDesencriptacion2B:
    mov [fila], rcx
    mov rdx, [columnaElemento2]
    mov [columna], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada2], rbx

    jmp finEncodeo
ret

Rectangular:
    mov rcx, [filaElemento1]
    mov [fila], rcx
    mov rdx, [columnaElemento2]
    mov [columna], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada1], rbx

    mov rcx, [filaElemento2]
    mov [fila], rcx
    mov rdx, [columnaElemento1]
    mov [columna], rdx
    call buscarEncriptacion
    mov rbx, [letraEncriptadaActual]
    mov [letraEncriptada2], rbx

    jmp finEncodeo
ret

buscarEncriptacion:
    mov rax, [fila]
    imul rax, LongELEMENTO
    imul rax, cantidadCOLUMNAS
    mov rbx, rax
    mov rax, [columna]
    imul rax, LongELEMENTO
    add rbx, rax
    mov rax, [matriz+rbx]

    obtengoLetraEncriptada:
    mov [letraEncriptadaActual], rax

    jmp finEncriptacion

    incrementoColumnaEncriptar:
    mov rdx, [columna]
    add rdx, 1
    mov [columna], rdx
    jmp buscarEncriptacion

    finEncriptacion:
ret


;***********************************************************************************************************
;                                               Rutinas internas
;***********************************************************************************************************

;---------------------------------------------ARCHIVOS DE MATRIZ--------------------------------------------

openMatriz:
    mov rcx,fileMatriz
    mov rdx,modeMatriz
    sub rsp, 32
    call fopen
    add rsp, 32
ret

leerRegistroMatriz:
    mov byte[letraEsValida],'N'

    leerSiguienteMatriz:
    mov rcx, registroMatriz
    mov rdx, 2
    mov r8, 1
    mov r9, [handleMatriz]
    sub rsp, 32
    call fread
    add rsp, 32

    cmp rax, 0
    jle finLecturaMatriz
    call validarLetrasMatriz
    cmp byte[letraEsValida],'N'
    je leerSiguienteMatriz

    call buildMatriz
    jmp leerSiguienteMatriz
    finLecturaMatriz:
ret

validarLetrasMatriz:
    mov byte[letraEsValida],'S'
    mov rbx,0
    mov rcx, 25

    proximaLetra:
    push rcx
    mov rcx,2
    lea rsi,[letra]
    lea rdi,[vectorLetrasValidas+rbx]
    repe cmpsb
    pop rcx
    je finValidacionMatriz
    add rbx,2
    loop proximaLetra
    mov byte[letraEsValida],'N'

    finValidacionMatriz:
ret

buildMatriz:
    mov rax, [contadorMatriz]
    mov rbx, [registroMatriz]
    mov [matriz+rax], rbx
    add rax, 1
    mov [contadorMatriz], rax
ret

closeMatriz:
    mov rcx, [handleMatriz]
    sub rsp, 32
    call fclose
    add rsp, 32
ret

;------------------------------------------------Archivos de Code------------------------------------------

openCode:
    mov rcx,fileCode
    mov rdx,modeCode
    sub rsp, 32
    call fopen
    add rsp, 32
ret

leerRegistroCode:
    mov byte[textoEsValido],'N'

    leerSiguienteTexto:
    mov rcx, registroCode
    mov rdx, 1
    mov r8, 1
    mov r9, [handleCode]
    sub rsp, 32
    call fread
    add rsp, 32
    cmp rax, 0
    jle finLecturaCode

    ;Si contadorCode supera 180, se termina la lectura porque el texto a recibir tiene un tamaño estatico, no es dinamico
    mov rax,[contadorCode]
    cmp rax, 180
    jg finLecturaCode
    call validarTextoCode
    cmp byte[textoEsValido],'N'
    je leerSiguienteTexto

    ;Si el registro es valido hago algo: Lleno mi matriz
    call buildCode
    jmp leerSiguienteTexto
    finLecturaCode:
ret


validarTextoCode:
    mov byte[textoEsValido],'S'
    mov rbx,0
    mov rcx, 51

    proximoTexto:
    push rcx
    mov rcx,1
    lea rsi,[texto]
    lea rdi,[vectorTextoValido+rbx]
    repe cmpsb
    pop rcx
    je finValidacionCode
    add rbx,1
    loop proximoTexto
    mov byte[textoEsValido],'N'

    finValidacionCode:
    call convertirMinusculas
ret

convertirMinusculas:
    mov rbx,0
    mov rcx, 25

    proximoTextoConvertir:
    push rcx
    mov rcx,1
    lea rsi,[texto]
    lea rdi,[vectorTextoConvertir+rbx]
    repe cmpsb
    pop rcx
    je convertir
    add rbx,1
    loop proximoTextoConvertir
    jmp finConversion
    
    convertir:
    mov ax, [texto]
    sub ax, 32
    mov [texto], ax
    finConversion:
ret

buildCode:
    mov rax, [contadorCode]
    mov rbx, [registroCode]
    mov [textoCode+rax], rbx
    add rax, 1
    mov [contadorCode], rax
ret

closeCode:
    mov rcx, [handleCode]
    sub rsp, 32
    call fclose
    add rsp, 32
ret

;---------------------------------------------ARCHIVOS DE SALIDA--------------------------------------------
openExit:
    mov rcx, filaExit
    mov rdx, modeExit
    sub rsp, 32
    call fopen
    add rsp, 32
ret

writeExit:
    mov rcx, letraEncriptada
    mov rdx, 1
    mov r8, 1
    mov r9, [handleExit]
    sub rsp, 32
    call fwrite
    add rsp,32
ret

closeExit:
    mov rcx, [handleExit]
    sub rsp, 32
    call fclose
    add rsp, 32
ret

;------------------------------------------------------DEMAS--------------------------------------------------

validacionInputOperacion:

    verificacionPrimeraOperacion:
    mov al, [operacionARealizar] ; Cargar la variable en el registro al
    cmp al, 'E' ; Comparar la variable con la operacion de ENCRIPTACION
    je operacionEncriptado

    verificacionSegundaOperacion:
    cmp al, 'D' ; Comparar la operacion de DESENCRIPTACION
    je operacionDesencriptado

    operacionIncorrecta:
    mov rcx, printfOperacionFallida
    sub rsp, 32
    call printf
    add rsp, 32
    jmp ingresarInput

    operacionEncriptado:
    mov rcx, printOperacionEncriptado
    sub rsp, 32
    call printf
    add rsp, 32
    jmp finDeVerificacionOperacion

    operacionDesencriptado:
    mov rcx, printOperacionDesencriptado
    sub rsp, 32
    call printf
    add rsp, 32
    jmp finDeVerificacionOperacion

    finDeVerificacionOperacion:

ret

;************************************
;Busqueda de posiciones en la matriz
;************************************
obtenerPosiciones:

    ;Basandono en la letra de la tupla inicial obtenemos una fila y columna
    mov rbx, [letraInicialTupla]
    mov [letraBuscada], rbx
    ;Busoco la posicion
    call posicionarse

    ;Guardo la informacion de la primer tupla
    mov rcx, [fila]
    mov [filaElemento1], rcx
    mov rdx, [columna]
    mov [columnaElemento1], rdx

    ;Basandono en la letra de la tupla final obtenemos una fila y columna
    mov rbx, [letraFinalTupla]
    mov [letraBuscada], rbx

    ;Busco la posicion
    call posicionarse

    ;Guardo la informacion de la segunda tupla
    mov rcx, [fila]
    mov [filaElemento2], rcx
    mov rdx, [columna]
    mov [columnaElemento2], rdx
ret

posicionarse:
    ;inicializar valores
    mov rax, 0
    mov [letraActual], rax
    mov [fila], rax
    reestablecerColumna:
    mov rax, 0
    mov [columna], rax

    recorrerMatriz:
    mov rax, [fila]
    imul rax, LongELEMENTO
    imul rax, cantidadCOLUMNAS
    mov rbx, rax
    mov rax, [columna]
    imul rax, LongELEMENTO
    add rbx, rax
    mov rcx, [matriz+rbx]
    mov [letraActual], rcx

    comparar:
    mov al, [letraActual]
    cmp al, [letraBuscada]
    je encontroLetra
    jne incrementoColumna

    incrementoColumna:
    mov rdx, [columna]
    add rdx, 1
    mov [columna], rdx
    mov rdx, [columna]
    cmp rdx, 5
    jne recorrerMatriz

    incrementarFila:
    mov rdx, [fila]
    add rdx, 1
    mov [fila], rdx
    mov rdx, [columna]
    mov [letraActual], rdx
    jmp reestablecerColumna

    encontroLetra:
ret