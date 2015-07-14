@ Esse teste imprime duas sequências de fibonacci iguais de maneira paralela
programa:
	@ cria um novo processo
	mov r7, #2
	svc 0x0

loop:
	@ r0 recebe o pid do processo
	mov r7, #20
	svc 0x0
	
	cmp r0, #1
	beq fib1
	
	b fib2

@ calcula fibonacci(n)
@ entrada: r0: n
fib:
	cmp r0, #2
	bge fib_jump
	mov r0, #1
	mov pc, lr

fib_jump:	
	mov r1, r0
	
	sub r0, r0, #1
	push {r1, lr}
	bl fib
	mov r2, r0
	pop {r1, lr}
	
	sub r1, r1, #2
	push {r2, lr}
	mov r0, r1
	bl fib
	pop {r2, lr}
	
	add r0, r0, r2
	
	mov pc, lr
		
fib1:
	ldr r0, =i_fib1
	ldr r0, [r0]
	
	bl fib
	
	@ imprime
	mov r10, #0
	bl print_number
	
	@ incrementa
	ldr r1, =i_fib1
	ldr r0, [r1]
	add r0, r0, #1
	str r0, [r1]
	
	b loop

fib2:
	ldr r0, =i_fib2
	ldr r0, [r0]
	
	bl fib
	
	@ imprime
	mov r10, #1
	bl print_number
	
	@ incrementa
	ldr r1, =i_fib2
	ldr r0, [r1]
	add r0, r0, #1
	str r0, [r1]
	
	b loop
	
@ imprime um numero
@ entrada: r0 : numero a ser impresso r10: 0 se for fib1, 1 se for fib2

print_number:
	@ r11 recebe a constante 10
	mov r11, #10
	
	@ encontra a maior potencia de 10 em r0 e coloca em r8
	mov r8, #1
	loop1:
		cmp r8, r0
		bgt print_loop
		mul r8, r11, r8
		b loop1
		
	print_loop:
		
		@ r8 = r8 / 10
		mov r2, #0
		
		div_loop_10:
			sub r8, r8, r11
			cmp r8, #0
			blt pula1
			add r2, r2, #1
			b div_loop_10
		pula1:
		mov r8, r2

		@ r3 = r0 / r8. r0 fica com o resto
		mov r3, #0
		mov r5, r0
		
		div_loop:
			sub r5, r5, r8
			cmp r5, #0
			blt pula2
			add r3, r3, #1
			mov r0, r5
			b div_loop

		@ imprime o digito
		pula2:
		add r3, r3, #48 @ converte r3 para ASCII somando caractere '0'
		ldr r1, =caractere @ salva em 'caractere' o valor de r3
		str r3, [r1]
		mov r2, #1 @ carrega em r2 o tamanho da cadeia. r0,r1 e r2 serao
		@ os argumentos da syscall write
		mov r4, r0
		mov r7, #4 @ carrega o valor 4 para r7, indica a chamada de sistema
		svc 0x0 @ realiza uma chamada de sistema (syscall)
		mov r0, r4

		@ verifica se esse foi o ultimo digito, se não for continua o loop com o resto da divisao inteira
		cmp r8, #1
		bgt print_loop

	@ imprime a quebra de linha
	cmp r10, #0
	bne pula_impar
	
	ldr r1, =pula_linha_par @ carrega em r1 o endereco da cadeia de caracteres
	mov r2, #1 @ carrega em r2 o tamanho da cadeia. r0,r1 e r2 serao
	@ os argumentos da syscall write
	mov r7, #4 @ carrega o valor 4 para r7, indica a chamada de sistema
	svc 0x0 @ realiza uma chamada de sistema (syscall)
	b imprime_fim
	
pula_impar:
	ldr r1, =pula_linha_impar @ carrega em r1 o endereco da cadeia de caracteres
	mov r2, #2 @ carrega em r2 o tamanho da cadeia. r0,r1 e r2 serao
	@ os argumentos da syscall write
	mov r7, #4 @ carrega o valor 4 para r7, indica a chamada de sistema
	svc 0x0 @ realiza uma chamada de sistema (syscall)
	
imprime_fim:
	mov pc, lr


.data
i_fib1: .word 0
i_fib2: .word 0
pula_linha_par: .asciz "\n"
pula_linha_impar: .asciz "*\n"
caractere: .asciz "a"
