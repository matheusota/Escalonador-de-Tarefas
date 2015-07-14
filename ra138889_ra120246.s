@ Projeto 3 - Escalonador de Tarefas Preemptivo
@ Matheus Jun Ota - RA:138889
@ Victor Camardelli - RA:120246

.org 0x0
.section .iv,"a"

_start:		

@@@@@@@@@ VETOR DE INTERRUPCOES @@@@@@@@@@@@@@

interrupt_vector:
	b reset_handler

	.org 0x8
	b syscall_handler

	.org 0x18
	b irq_handler

.org 0x100
.text

@@@@@@@@@ RESET_HANDLER @@@@@@@@@@@@@@@@@@@@@@

@ configura tzic, gpt e uart
reset_handler:

@Set interrupt table base address on coprocessor 15.
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0
    
@ configura as pilhas dos processos e dos modos de execucao
set_stack:
	@ Configurable STACK values for each ARM core operation mode
	.set SVC_STACK, 0x77601000
	.set UND_STACK, 0x77602000
	.set ABT_STACK, 0x77603000
	.set IRQ_STACK, 0x77604000
	.set FIQ_STACK, 0x77605000
	.set USR_STACK, 0x77606000

	@Configure stacks for all modes
	ldr sp, =SVC_STACK
	msr CPSR_c, #0xDF  @ Enter system mode, FIQ/IRQ disabled
	ldr sp, =PID0_STACK
	msr CPSR_c, #0xD1  @ Enter FIQ mode, FIQ/IRQ disabled
	ldr sp, =FIQ_STACK
	msr CPSR_c, #0xD2  @ Enter IRQ mode, FIQ/IRQ disabled
	ldr sp, =IRQ_STACK
	msr CPSR_c, #0xD7  @ Enter abort mode, FIQ/IRQ disabled
	ldr sp, =ABT_STACK
	msr CPSR_c, #0xDB  @ Enter undefined mode, FIQ/IRQ disabled
	ldr sp, =UND_STACK
	
	@ configura a pilha dos processos(pid 1 - pid 8)
	@ svc stack é a pilha para armazenar contextos
	@ stack é a pilha do processo
	.set PID0_STACK, 0x7770D000
	.set PID0_SVC_STACK, 0x7770C800
	.set PID1_STACK, 0x7770C000
	.set PID1_SVC_STACK, 0x7770B800
	.set PID2_STACK, 0x7770B000
	.set PID2_SVC_STACK, 0x7770A800
	.set PID3_STACK, 0x7770A000
	.set PID3_SVC_STACK, 0x77709800
	.set PID4_STACK, 0x77709000
	.set PID4_SVC_STACK, 0x77708800
	.set PID5_STACK, 0x77708000
	.set PID5_SVC_STACK, 0x77707800
	.set PID6_STACK, 0x77707000
	.set PID6_SVC_STACK, 0x77706800
	.set PID7_STACK, 0x77706000
	.set PID7_SVC_STACK, 0x77705800
	
@ configura o gpt
set_gpt:

@registradores do GPT
    .set GPT_CR, 0x53FA0000
    .set GPT_PR, 0x53FA0004
    .set GPT_OCR1, 0x53FA0010
    .set GPT_IR, 0x53FA000C
    .set GPT_SR, 0x53FA0008
    
@Habilita GPT_CR e configura o clock_src para periférico
    mov r1, #0x41
    ldr r0, =GPT_CR
    str r1, [r0]

@Zera prescaler
    mov r1, #0
    ldr r0, =GPT_PR
    str r1, [r0]

@Coloca em GPT_OCR1 o valor 100
    mov r1, #100
    ldr r0, = GPT_OCR1
    str r1, [r0]

@Habilita interrupção
    mov r1, #1
    ldr r0, =GPT_IR 
    str r1, [r0]

@configura tzic
set_tzic:
@ Constantes para os enderecos do TZIC
    .set TZIC_BASE,             0x0FFFC000
    .set TZIC_INTCTRL,          0x0
    .set TZIC_INTSEC1,          0x84 
    .set TZIC_ENSET1,           0x104
    .set TZIC_PRIOMASK,         0xC
    .set TZIC_PRIORITY9,        0x424

@ Liga o controlador de interrupcoes
@ R1 <= TZIC_BASE

    ldr	r1, =TZIC_BASE

@ Configura interrupcao 39 do GPT como nao segura
    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_INTSEC1]

@ Habilita interrupcao 39 (GPT)
@ reg1 bit 7 (gpt)

    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_ENSET1]

@ Configure interrupt39 priority as 1
@ reg9, byte 3

    ldr r0, [r1, #TZIC_PRIORITY9]
    bic r0, r0, #0xFF000000
    mov r2, #1
    orr r0, r0, r2, lsl #24
    str r0, [r1, #TZIC_PRIORITY9]

@ Configure PRIOMASK as 0
    eor r0, r0, r0
    str r0, [r1, #TZIC_PRIOMASK]

@ Habilita o controlador de interrupcoes
    mov	r0, #1
    str	r0, [r1, #TZIC_INTCTRL]

@configura uart
set_uart:
@contantes dos enderecos e valores do uart
    .set UCR1, 0x53FBC080
    .set UCR1_RESET, 0x00000001
    .set UCR2, 0x53FBC084
    .set UCR2_RESET, 0x00002127
    .set UCR3, 0x53FBC088
    .set UCR3_RESET, 0x00000704
    .set UCR4, 0x53FBC08C
    .set UCR4_RESET, 0x00007C00
    .set UFCR, 0x53FBC090
    .set UFCR_RESET, 0x0000089E
    .set UBIR, 0x53FBC0A4
    .set UBIR_RESET, 0x000008FF
    .set UBMR, 0x53FBC0A8
    .set UBMR_RESET, 0x00000C34
	
@escreve os valores
    ldr r0, =UCR1
    ldr r1, =UCR1_RESET
    str r1, [r0]

    ldr r0, =UCR2
    ldr r1, =UCR2_RESET
    str r1, [r0]

    ldr r0, =UCR3
    ldr r1, =UCR3_RESET
    str r1, [r0]

    ldr r0, =UCR4
    ldr r1, =UCR4_RESET
    str r1, [r0]

    ldr r0, =UFCR
    ldr r1, =UFCR_RESET
    str r1, [r0]

    ldr r0, =UBIR
    ldr r1, =UBIR_RESET
    str r1, [r0]

    ldr r0, =UBMR
    ldr r1, =UBIR_RESET
    str r1, [r0]
    
@instrucao msr - habilita interrupcoes
    msr  CPSR_c, #0x10       @ USER mode, IRQ/FIQ enabled
    
    ldr r0, =USER_CODE
    ldr r0, [r0]
    bx r0

@@@@@@@@@ SYSCALL_HANDLER @@@@@@@@@@@@@@@@@@@@
@ verifica qual chamada do sistema foi realizada de acordo com o valor em r7

syscall_handler:
	@ desabilita interrupcoes no modo SVC
	msr CPSR_c, #0xD3
	
	@ salva registradores callee save
	push {r4 - r11, lr}
	
	@ verifica se é a chamada fork, caso sim, salva o contexto
	cmp r7, #2
	bne jump_syscall
	
	@ salva r0 - r4 para poder usar esses registradores como variaveis
    push {r0 -r4}
    
    @ r0 <= SPSR(CPSR do modo user)
    mrs r0, SPSR
    
    @@@@@@@@ esse trecho do codigo deve ser comentado para rodar testes em c @@@@@@
    @ r1 <= lr(pc do modo user)
     mov r1, lr
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	@ salva contexto
	bl save_context_svc

jump_syscall:	
	@ write
	cmp r7, #4
	bleq _write
	
	@ fork
	cmp r7, #2
	bleq _fork
	
	@ getpid
	cmp r7, #20
	bleq _getpid
	
	@ exit
	cmp r7, #1
	bleq _exit
	
	@ recupera registradores callee save
	pop {r4 - r11, lr}
	
	@ retorna
	movs pc, lr

@@@@@@@@@ WRITE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
@ entrada -> r0: descritor do arquivo, r1: ponteiro para os dados, r2: quantidade de bytes a serem escritos
@ saida -> r0: numero de bytes que foi escrito com sucesso

_write:
	.set UART_USR1, 0x53FBC094
	.set UART_UTXD, 0x53FBC040
	
	mov r8, r2
		
	@ loop que escreve na UART até escrever todos r2 bytes
	write_loop:
		
		@ coloca em r0 o valor do bit 3 de UART_USR1
		ldr r3, =UART_USR1
		ldr r3, [r3]
		mov r4, #0x00002000
		and r3, r3, r4
		mov r3, r3, lsr #13
		
		@ se o bit for 0, espera ficar 1
		cmp r3, #0
		beq write_loop
		
		@ se for 1, transmite o byte pela UART escrevendo em UART_UTXD
		ldr r5, [r1], #1
		mov r6, #0xFF
		and r5, r5, r6
		ldr r6, =UART_UTXD
		str r5, [r6]
		
		@ decrementa o numero de bytes a serem escritos, 
		sub r2, r2, #1

		@ verifica se já enviou todos bytes
		cmp r2, #0
		bgt write_loop
		
	@ retorna em r0 número de bytes transmitidos com sucesso pela UART
	mov r0, r8
		
	@ retorna da subrotina
	mov pc, lr

@@@@@@@@@ FORK @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          
@ saida -> r0: process id do processo criado. -1 se já foram criados 8 processos

_fork:
	ldr r0, =PROC_VECTOR
	ldr r0, [r0]
	
	@ r1 será usado como variável de iteração no loop
	mov r1, #0
	
fork_loop:
	@ faz o shift para ver o valor do bit
	mov r2, r0, lsr r1 
	and r3, r2, #1
	
	@ se encontrar um zero
	cmp r3, #0
	beq fork_loop_end
	
	add r1, r1, #1
	b fork_loop

fork_loop_end:

	cmp r1, #8
	bne fork_correct
	
	@ se todos 8 processos ja foram ocupados
	mov r0, #-1
	b fork_end

	@ se ainda não foi ocupado os 8 processos
fork_correct:
	
	@ coloca 1 na posicao livre do vetor de processo para ativá-lo
	mov r3, #1
	mov r2, r3, lsl r1
	orr r0, r0, r2
	ldr r2, =PROC_VECTOR 
	str r0, [r2]
	
	@ copia o contexto do processo pai para o filho
	mov r0, r1
	push {r0, lr}
	bl copy_context
	pop {r0, lr}
	
	@ correcao antes de retornar
	add r0, r0, #1
	
fork_end:

	@ retorna
	mov pc, lr

@@@@@@@@@ GETPID @@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ saida -> r0: id do processo que está rodando

_getpid:
	ldr r0, =PROC_RUNNING
	ldr r0, [r0]
	
	@ correcao porque o id comeca em 1 e não em 0
	add r0, r0, #1
	
	mov pc, lr

@@@@@@@@@ EXIT @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ sai do processo rodando

_exit:
	ldr r0, =PROC_RUNNING
	ldr r0, [r0]
	ldr r1, =PROC_VECTOR
	ldr r2, [r1]
	
	@ limpa o processo do vetor
	mov r3, #1
	mov r3, r3, lsl r0
	eor r2, r2, r3
	str r2, [r1] 
	
	@ troca o processo se ainda tiver processos vivos
	cmp r2, #0
	beq  loop_infinito
	push {lr}
	bl change_process
	pop {lr}
	
	@ para garantir consistencia da pilha
	pop {r4 - r11, lr}
	
	b recover_context_svc

@@@@@@@@@ SAVE_CONTEXT_SVC @@@@@@@@@@@@@@@@@@@@@@@
@ salva o contexto do processo rodando

save_context_svc:
	ldr r2, =PROC_RUNNING
	ldr r2, [r2]
	
	@ recupera o endereco da pilha correspondente ao processo rodando
	ldr r3, =PID0_SVC_STACK
	mov r4, #0x1000
	mul r2, r4, r2
	sub r3, r3, r2

	@ vai para o modo System
	msr CPSR_c, #0xDF
	
	@ r4 <- sp
	mov r4, sp
	
	@ atualiza sp para a pilha correspondente ao processo
	mov sp, r3
	
	push {r0} @ CPSR do modo user
	push {r1} @ pc do modo user
	push {lr} @ lr do modo user
	push {r4} @ sp do modo user(não é necessario, só estamos salvando para manter o padrão da pilha)
	push {r5 - r12} @ r5 - r12 do modo user
	
	@ volta para o modo Supervisor
	msr CPSR_c, #0xD3
	
	@ r5 - r9 recebe r0 - r4 do modo user
	pop {r5 -r9}
	
	@ volta para o modo System
	msr CPSR_c, #0xDF
	
	@ coloca r0 - r4 na pilha
	push {r5 - r9}
	
	@ recupera sp
	mov sp, r4

	@ sai da chamada no modo Supervisor
	msr CPSR_c, #0xD3
	
	@ corrige valor do r7
	mov r7, #2
	
	mov pc, lr
	
@@@@@@@@@ RECOVER_CONTEXT_SVC @@@@@@@@@@@@@@@@@@@@
@ recupera o contexto do proximo processo a ser rodado

recover_context_svc:
	ldr r0, =PROC_RUNNING
	ldr r0, [r0]

	@ recupera o endereco da pilha correspondente ao contexto do processo rodando
	ldr r1, =PID0_SVC_STACK
	mov r2, #0x1000
	mul r0, r2, r0
	sub r1, r1, r0
	
	@ r1 recebe primeiro elemento da pilha
	sub r1, r1, #68
	
	@ vai para o modo System
	msr CPSR_c, #0xDF
	
	@ sp <- pilha do novo processo
	mov sp, r1
	
	@ recupera r0 - r12
	pop {r0 - r12}
	
	@ salva r0 - r2 na pilha Supervisor para usar como variaveis
	msr CPSR_c, #0xD3
	push {r0 - r2}
	
	@ volta para o modo System
	msr CPSR_c, #0xDF
	
	@ recupera o endereco da pilha do processo rodando
	ldr r0, =PROC_RUNNING
	ldr r0, [r0]
	
	@ r0 <- sp do Processo
	pop {r0}
	
	@ recupera lr
	pop {lr}
	
	@ r1 <- pc do Processo, r2 <- CPSR do Processo
	pop {r1}
	pop {r2}
	
	@ corrige sp
	mov sp, r0
	
	@ vai para o modo Supervisor
	msr CPSR_c, #0xD3
	
	@ escreve em lr e SPSR do modo Supervisor
	mov lr, r1
	msr SPSR, r2
	
	@ recupera r0 - r2
	pop {r0 - r2}
	
	@ retorna para o novo processo
    movs pc, lr

@@@@@@@@@ COPY_CONTEXT @@@@@@@@@@@@@@@@@@@@@@@
@ copia contexto do processo rodando para outro processo
@ entrada -> r0: id do processo destino

copy_context:
	ldr r1, =PROC_RUNNING
	ldr r1, [r1]
	
	@ r2 recebe endereco da pilha do processo rodando
	ldr r2, =PID0_SVC_STACK
	mov r3, #0x1000
	mul r1, r3, r1
	sub r2, r2, r1
	
	@ r2 recebe primeiro elemento da pilha
	sub r2, r2, #68
	
@ r3 recebe endereco da pilha do processo destino
	ldr r3, =PID0_SVC_STACK
	mov r4, #0x1000
	mul r0, r4, r0
	sub r3, r3, r0

	@ r3 recebe a posicao do primeiro elemento da pilha
	sub r3, r3, #68

@ r4 recebe o sp do processo destino
	ldr r4, =PID0_STACK
	sub r4, r4, r0
		
@ copia contexto
	
	ldmia r2!, {r0} @ r0
	mov r0, #0 @ r0 é o retorno no filho
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r1
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r2
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r3
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r4
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r5
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r6
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r7
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r8
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r9
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r10
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r11
	stmia r3!, {r0}
	ldmia r2!, {r0} @ r12
	stmia r3!, {r0}
	ldmia r2!, {r0} @ sp
	stmia r3!, {r4}
	ldmia r2!, {r0} @ lr
	stmia r3!, {r0}
	ldmia r2!, {r0} @ pc
	stmia r3!, {r0}
	ldmia r2!, {r0} @ CPSR
	stmia r3!, {r0}

	mov pc, lr
	
@@@@@@@@@ IRQ_HANDLER @@@@@@@@@@@@@@@@@@@@@@@@

irq_handler:
	
	@ Desabilita interrupcoes
	msr CPSR_c, #0xD2
	
	@Correcao antes do retorno
    sub lr, lr, #4
    
    @ salva r0 - r4 para poder usar esses registradores como variaveis
    push {r0 -r4}
    
    @grava 0x1 no GPT_SR
	mov r1, #1
	ldr r0, =GPT_SR
	str r1, [r0]
	
    @ r0 <= SPSR(CPSR do modo user)
    mrs r0, SPSR
    
    @ r1 <= lr(pc do modo user)
    mov r1, lr
    
	@ salva o contexto
	bl save_context
	
	@ r0 recebe o id do proximo processo a ser rodado
	bl change_process
	
	@ recupera o contexto do proximo processo e retorna para o proximo processo
	b recover_context

@@@@@@@@@ SAVE_CONTEXT @@@@@@@@@@@@@@@@@@@@@@@
@ salva o contexto do processo rodando

save_context:
	ldr r2, =PROC_RUNNING
	ldr r2, [r2]
	
	@ recupera o endereco da pilha correspondente ao processo rodando
	ldr r3, =PID0_SVC_STACK
	mov r4, #0x1000
	mul r2, r4, r2
	sub r3, r3, r2

	@ vai para o modo System
	msr CPSR_c, #0xDF
	
	@ atualiza sp para a pilha correspondente a tarefa
	mov r4, sp
	mov sp, r3
	
	push {r0} @ CPSR do modo user
	push {r1} @ pc do modo user
	push {lr} @ lr do modo user
	push {r4} @ sp do modo user
	push {r5 - r12} @ r5 - r12 do modo user
	
	@ volta para o modo IRQ
	msr CPSR_c, #0xD2
	
	@ r5 - r9 recebe r0 - r4 do modo user
	pop {r5 -r9}
	
	@ volta para o modo System
	msr CPSR_c, #0xDF
	
	@ coloca r0 - r4 na pilha
	push {r5 - r9}

	@ sai da chamada no modo IRQ
	msr CPSR_c, #0xD2
	mov pc, lr

@@@@@@@@@ RECOVER_CONTEXT @@@@@@@@@@@@@@@@@@@@
@ recupera o contexto do proximo processo a ser rodado

recover_context:
	ldr r0, =PROC_RUNNING
	ldr r0, [r0]

	@ recupera o endereco da pilha correspondente ao processo rodando
	ldr r1, =PID0_SVC_STACK
	mov r2, #0x1000
	mul r0, r2, r0
	sub r1, r1, r0
	
	@ r1 recebe primeiro elemento da pilha
	sub r1, r1, #68
	
	@ vai para o modo System
	msr CPSR_c, #0xDF
	
	@ sp <- pilha do novo processo
	mov sp, r1
	
	@ recupera r0 - r12
	pop {r0 - r12}
	
	@ salva r0 - r2 na pilha IRQ para usar como variaveis
	msr CPSR_c, #0xD2
	push {r0 - r2}
	
	@ volta para o modo System
	msr CPSR_c, #0xDF
	
	@ r0 <- sp do Processo
	pop {r0}
	
	@ recupera lr
	pop {lr}
	
	@ r1 <- pc do Processo, r2 <- CPSR do Processo
	pop {r1}
	pop {r2}
	
	@ corrige sp
	mov sp, r0
	
	@ vai para o modo IRQ
	msr CPSR_c, #0xD2
	
	@ escreve em lr e SPSR do modo IRQ
	mov lr, r1
	msr SPSR, r2
	
	@ recupera r0 - r2
	pop {r0 - r2}
	
	@ retorna para o novo processo
    stmfd sp!, {lr}
    ldmfd sp!, {pc}^
	
@@@@@@@@@ CHANGE_PROCESS @@@@@@@@@@@@@@@@@@@@@
@ alterna entre os processos rodando segundo o algoritmo round-robin
@ saida -> r0: id do proximo processo a ser rodado 

change_process:
	@ recupera o id do processo rodando e vetor dos processos
	ldr r0, =PROC_RUNNING
	ldr r0, [r0]
	ldr r1, =PROC_VECTOR
	ldr r1, [r1]
	
change_process_loop:
	@ faz o shift no vetor e recupera o valor do próximo processo
	add r0, r0, #1
	mov r2, r1, lsr r0
	and r2, r2, #1
	
	@ se for 1, então o processo foi inicializado, retorna o id desse processo
	cmp r2, #1
	beq change_process_end
	
	@ se for 0, busca o proximo processo segundo o round-robin
	cmp r0, #8
	bge change_process_return
	b change_process_loop

@ retorna para o primeiro processo
change_process_return:
	mov r0, #-1
	b change_process_loop

	@ fim da subrotina
change_process_end:
	@ altera processo rodando
	ldr r1, =PROC_RUNNING
	str r0, [r1]
	
	@ retorna
	mov pc, lr

@@@@@@@@@ LOOP INFINITO @@@@@@@@@@@@@@@@@@@@@@
loop_infinito:
	b loop_infinito

@@@@@@@@@ SECAO DE DADOS @@@@@@@@@@@@@@@@@@@@@
.data
@ variaveis globais auxiliares
@ variavel que guarda o id do processo rodando
	PROC_RUNNING : .word 0
@ se o bit PROC_VECTOR[i](31 downto 0) = 1 então o processo i está ativo. Caso contrário, está inativo.
	PROC_VECTOR : .word 1 
@ endereco do codigo do usuario
	USER_CODE : .word 0x77802000
	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.text

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

