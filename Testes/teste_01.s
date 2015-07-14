@ Esse teste visa verificar se o funcionamento do fork e seus retornos no pai e filho funcionam de maneira esperada
programa:
	mov r7, #2
	svc 0x0
	
	cmp r0, #0
	beq filho
	
	b pai
	
filho:
	@ escreve na tela
	ldr r1, =string_filho
	mov r2, #13
	mov r7, #4
	svc 0x0
	
	@ sai do processo
	mov r7, #1
	svc 0x0
	
pai:
	@ escreve na tela
	ldr r1, =string_pai
	mov r2, #11
	mov r7, #4
	svc 0x0
	
	@ sai do processo
	mov r7, #1
	svc 0x0

.data
string_filho: .asciz "Sou o filho!\n"
string_pai: .asciz "Sou o pai!\n"
