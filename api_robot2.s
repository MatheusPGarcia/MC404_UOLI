@
@   Biblioteca de Controle - BiCo - api_robot2.h
@
@   Criado por Matheus Pompeo Garcia - 156743
@
@   MC404 - Segundo semestre de 2017
@


@ Códigos das SYSCALLS
.set SYS_READ_SONAR,          16 @ read_sonar
.set SYS_PROX_CALLB,          17 @ register_proximity_callback
.set SYS_SET_MSPEED1,         18 @ set_motor_speed
.set SYS_SET_MSPEED2,         19 @ set_motors_speed
.set SYS_GET_TIME,            20 @ get_time
.set SYS_SET_TIME,            21 @ set_time
.set SYS_SET_ALARM,           22 @ set_alarm


.global set_time, set_motor_speed, set_motors_speed
.global add_alarm, get_time
.global read_sonar, read_sonars, register_proximity_callback


.org 0x0
.align 4


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Função responsável por mudar a velocidade de um motor.  
@
@   Parametro:                                              
@     r0: Ponteiro para a struct que representa o motor     
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
set_motor_speed:

  stmfd sp!, {r7, lr}       @ Salva os registradores na pilha

  mov r2, r0                @ Move para r2 o valor de r0, que é um apontador para o primeiro dado da struct que representa o motor.

  ldrb r0, [r2]             @ Carrega em r0 o ID do motor
  ldrb r1, [r2, #1]         @ Carrega em r1 a velocidade desejada no motor

  mov r7, #SYS_SET_MSPEED1  @ Move para r7 o identificador da Syscall desejada
  svc 0x0                   @ Realiza a Syscall

  ldmfd sp!, {r7, pc}       @ Restaura os registradores
  mov pc, lr                @ Retorna o fluxo da função


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Função responsável por mudar a velocidade dos dois motores
@
@   Parametro:
@     r0: Ponteiro para a struct que representa o primeiro motor
@     r1: Ponteiro para a struct que representa o segundo motor
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
set_motors_speed:

  stmfd sp!, {r4, r7, lr}   @ Salva os registradores callee-save que serão usados na função

  mov r3, r0                @ Move para r3 o endereço do primeiro motor
  mov r4, r1                @ Move para r4 o endereço do segundo motor

  ldrb r0, [r3]             @ Move para r0 o ID do primeiro motor

  cmp r0, #0                @ Compara o ID do primeiro motor com o número zero
  beq certo                 @ Se o ID do primeiro motor igual a zero, o fluxo vai para certo
  b inverte                 @ Caso contrário inverte a ordem dos motores ao chamar a Syscall

certo:
  ldrb r0, [r3, #1]         @ Move para r0 a velocidade do primeiro motor
  ldrb r1, [r4, #1]         @ Move para r1 a velocidade do segundo motor

  b continua                @ Muda o fluxo para continua, onde ira realizar a Syscall

inverte:
  ldrb r1, [r4, #1]         @ Move para r0 a velocidade do primeiro motor
  ldrb r0, [r3, #1]         @ Move para r1 a velocidade do segundo motor

continua:

  mov r7, #SYS_SET_MSPEED2  @ Move para r7 o identificador da Syscall desejada
  svc 0x0                   @ Realiza a Syscall

  ldmfd sp!, {r4, r7, lr}   @ Restaura os registradores
  mov pc, lr                @ retorna o fluxo da função


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Função responsável por ler um sonar
@
@   Parametro:
@     r0: ID do sonar que deve ter seu valor lido
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
read_sonar:

  stmfd sp!, {r7, lr}     @ Salva os registradores na pilha

  mov r7, #SYS_READ_SONAR @ Move para r7 o identificador da Syscall desejada
  svc 0x0                 @ Realiza a Syscall

  ldmfd sp!, {r7, lr}     @ Restaura os registradores
  mov pc, lr              @ retorna o fluxo da função


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Função responsável por ler uma série de sonares
@
@   Parametro:
@     r0: ID do primeiro sonar que deve ser lido
@     r1: ID do ultimo sonar que deve ser lido
@     r2: Ponteiro para um vetor que irá armazer o valor dos sonares
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
read_sonars:

  stmfd sp!, {r7, lr}     @ Salva os registradores na pilha

  mov r7, #SYS_READ_SONAR @ Move para r7 o identificador da Syscall desejada

  mov r3, r0              @ Carrega em r3 o valor de r0, responsável pelo ID do primeiro sonar a ser lido

sonars_loop:
  mov r0, r3              @ Carrega em r0 o valor de r3, que contém o ID do sonar a ser lido na interação atual
  svc 0x0                 @ Realiza a Syscall

  str r0, [r2]            @ Carrega no endereço apontado por r2 (vetor de retornos dos sonares) o valor retornado do sonar atual

  add r2, r2, #4          @ Incremente em r2 o valor de um INT
  add r3, r3, #4          @ Incrementa em r3 o valor de um INT

  cmp r3, r1              @ Compara r3 (sonar a ser lido na próxima interação) com r1 (ultimo sonar que deve ser lido)
  ble sonars_loop         @ Enquanto r3 menor ou igual a r1 repete o laço para a leitura de sonares

  ldmfd sp!, {r7, lr}     @ Restaura os registradores
  mov pc, lr              @ retorna o fluxo da função


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Função responsável por reportar que um limiar de ditância foi atingido
@
@   Parametro:
@     r0: ID do sensor que deve ser monitorado
@     r1: O limiar da distância
@     r2: endereço da função que deve ser chamada quando o limiar for atingido
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
register_proximity_callback:

  stmfd sp!, {r7, lr}       @ Salva os registradores na pilha

  mov r7, #SYS_PROX_CALLB   @ Move para r7 o identificador da Syscall desejada
  svc 0x0                   @ Realiza a Syscall

  ldmfd sp!, {r7, lr}       @ Restaura os registradores
  mov pc, lr                @ retorna o fluxo da função


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Função responsável por adicionar um alarme ao sistema
@
@   Parametro:
@     r0: Apontador para função que deve ser chamada quando o alarme disparar
@     r1: tempo do sistema em que o alarme deve disparar
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
add_alarm:

  stmfd sp!, {r7, lr}       @ Salva os registradores na pilha

  mov r7, #SYS_SET_ALARM    @ Move para r7 o identificador da Syscall desejada
  svc 0x0                   @ Realiza a Syscall

  ldmfd sp!, {r7, lr}       @ Restaura os registradores
  mov pc, lr                @ retorna o fluxo da função


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Função responsável por retornar o tempo do sistema
@
@   Parametro:
@     r0: The value of the new system time
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
get_time:

  stmfd sp!, {r4, r7, lr}     @ Salva os registradores na pilha

  mov r4, r0              @ Move para r1 o valor armazenado em r0, que é o endereço da variavel que deve receber o tempo do sistema

  mov r7, #SYS_GET_TIME   @ Move para r7 o identificador da Syscall desejada
  svc 0x0                 @ Realiza a Syscall

  str r0, [r4]            @ Salva o tempo do sistema (r0) na variavel do endereço r1

  ldmfd sp!, {r4, r7, lr}     @ Restaura os registradores
  mov pc, lr              @ retorna o fluxo da função

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Função responsável por definir um tempo para o sistema
@
@   Parametro:
@     r0: The value of the new system time
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
set_time:

  stmfd sp!, {r7, lr}     @ Salva os registradores na pilha

  mov r7, #SYS_SET_TIME   @ Move para r7 o identificador da Syscall desejada
  svc 0x0                 @ Realiza a Syscall

  ldmfd sp!, {r7, lr}     @ Restaura os registradores
  mov pc, lr              @ retorna o fluxo da função
  