.data 0

direccion_base_periferico_1: .word 1610612736 # posicion 0 (x"60000000") aqui esta conectado directamente el puerto 0 (configuracion) del periferico 1

direccion_base_periferico_2: .word 1610612992 # posicion 4 (x"60000100") aqui esta el comienzo del periferico 2

configuracion_lectura: .word 2 # posicion 8

configuracion_escritura: .word 4 # posicion 12

num0: .word 1 # posicion 16

num1: .word 2 # posicion 20

num2: .word 4 #posicion 24

num3: .word 0 # posicion 28

num4: .word 0 # posicion 32

num5: .word 0 # posicion 36

num6: .word 0 # posicion 40

.text 0

main:

lw $t9, 16($zero) # lw $r25, 16($zero)

# carga en el registro r8 la direccion base de comienzo del periferico 1

lw $t0, 0($zero) # lw $r8, 0($zero)

# carga en el registro r9 la direccion base de comienzo del periferico 2

lw $t1, 4($zero) # lw $r9, 4($zero)

# carga en el registro r10 la palabra de configuracion para lectura de los perifericos

lw $t2, 8($zero) # lw $r10, 8($zero)

# carga en el registro r11 la palabra de configuracion para escritura en los perifericos

lw $t3, 12($zero) # lw $r11, 12($zero)

# manda el comando de configuracion al periferico 1, que es de entrada, por lo tanto hay que configurarle como lectura

sw $t2, 0($t0) # sw $r10, 0($r8)

# manda el comando de configuracion al periferico 2, que es de salida, por lo tanto hay que configurarle como escritura

sw $t3, 0($t1) # sw $r11, 0($r9)

##########################
lw $t7, 4($t0) #Carga el numero del periferico en el registro 15 # ld periferico r15
lw $t4, 16($zero)	#Carga un 1 en el registro 12 # ld memoria r12
lw $t5, 16($zero)	#Carga un 1 en el registro 13 # ld memoria r13
lw $t6, 16($zero)	#Carga un 1 en el registro 14 # ld memoria r14


bucle: 
beq $t7,$t5, fin
add $t4,$t4,$t4
add $t5,$t5,$t6
beq $t6, $t6,bucle	#esto salta siempre, es como jmp
fin: 
sw $t4, 4($t1)
