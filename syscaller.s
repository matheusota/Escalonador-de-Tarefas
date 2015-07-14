@ chama a syscall correspondente a cada funcao

.global write
.global fork
.global getpid
.global exit
	
write:
	push {r1-r3,lr}
	
	mov r7, #4
	svc 0x0
	
	pop {r1-r3,pc}
fork:
	push {r1-r3,lr}
	
	mov r1, lr
	mov r7, #2
	svc 0x0
	
	pop {r1-r3,pc}

getpid:
	push {r1-r3,lr}
	
	mov r7, #20
	svc 0x0
	
	pop {r1-r3,pc}
	
exit:
	mov r7, #1
	svc 0x0
