@ Esse teste cria processos e entra em loop infinito. Ele não imprime nada, examinamos os registradores pelo gdb

programa:
	mov r0, #0
	mov r1, #1
	mov r2, #2
	mov r3, #3
	mov r4, #4
	mov r5, #5
	mov r6, #6
	mov r7, #2
	svc 0x0
	
	b programa
