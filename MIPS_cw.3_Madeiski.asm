.data

start_msg: .asciiz "Lista obslugiwanych instrukcji: \nADD $r1, $r2, $r3 \nADDI $r1, $r2, wartosc \nJ label \nNOOP \nMULT $r1, $r2 \nJR $r1 \nJAL label \n \n"
enter_num_msg: .asciiz "Podaj liczbe instrukcji do przeanalizowania (od 1 do 5): "
enter_instruction_msg: .asciiz "Podaj instrukcje: "
num_error_msg: .asciiz "Podano niepoprawna liczbe instrukcji! \n"
instruction_error_msg: .asciiz "Podano niepoprawna instrukcje! \n"
end_msg: "Zakonczono dzialanie programu."
entered_instructions_msg: "Wprowadzone instrukcje: \n"
new_line: .asciiz "\n"
debug: .asciiz "debug"
input: .space 100

.text
#GLOWNA CZESC#
main:
	#lista instrukcji do wyboru
	li $v0, 4
	la $a0, start_msg
	syscall
	
	#pobranie liczby instrukcji i zapisanie do a2
enter_num:
	li $v0, 4
	la $a0, enter_num_msg
	syscall
	li $v0, 5
	syscall
	move $a2, $v0
	
	#sprawdzenie poprawnosci liczby instrukcji
	blez $a2, num_error
	bge $a2, 6, num_error
	
	#petla do wprowadzenia instrukcji i odk³adania na stos
	li $a3, 0
enter_instruction_loop:
	beq $a3, $a2, enter_instruction_loop_end
	
	li $v0, 4
	la $a0, enter_instruction_msg
	syscall
	
	li $v0, 8
    	la $a0, input
    	li $a1, 101
    	syscall
    	
    	j check_ADD
    	
    	input_correct:
    	#Kopiowanie wprowadzonego tekstu na stos
    	addi $sp, $sp, -101
    	la $t0, input
    	la $t1, 0($sp)
    	li $t2, 100

	copy_loop:
    	lb $t3, 0($t0)
    	sb $t3, 0($t1)
    	addi $t0, $t0, 1
    	addi $t1, $t1, 1
    	subi $t2, $t2, 1
    	bnez $t2, copy_loop

    	#Zwiekszenie licznika wprowadzonych instrukcji
    	addi $a3, $a3, 1
    	j enter_instruction_loop
    	
    	continue_loop:
    	j enter_instruction_loop
enter_instruction_loop_end:
	li $v0, 4
	la $a0, entered_instructions_msg
	syscall
	
	print_loop:
    	beq $a2, 0, end
    	la $a0, 0($sp)
    	li $v0, 4
    	syscall
    	addi $sp, $sp, 101
   	subi $a2, $a2, 1
    	j print_loop
#GLOWNA CZESC#

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#SPRAWDZANIE INPUTOW

#ADD
check_ADD:
	la $t0, input
	lb $t1, 0($t0)
    	lb $t2, 1($t0)
    	lb $t3, 2($t0)
    	li $t4, 'A'
    	li $t5, 'D'
    	li $t6, 'D'
    	bne $t1, $t4, check_ADDI
    	bne $t2, $t5, check_ADDI
    	bne $t3, $t6, check_ADDI
    	
    	addi $t0, $t0, 3
    	j check_registers_ADD
    	j continue_loop
    	
    	check_registers_ADD:
    	addi $t7, $zero, 3   # Licznik trzech liczb

check_loop_ADD:
    	beqz $t7, check_loop_end_ADD  # Jeœli $t7 == 0, zakoñcz sprawdzanie
    	lb $t1, 0($t0)
    	li $t4, ','
    	beq $t1, $t4, skip_ADD
    	li $t4, ' '
    	beq $t1, $t4, skip_ADD
    	li $t4, '$'
    	bne $t1, $t4, check_ADDI

    	addi $t0, $t0, 1
    	j read_number_ADD
    	number_correct_ADD:
    	subi $t7, $t7, 1
    	j check_loop_ADD

	skip_ADD:
    	addi $t0, $t0, 1
    	j check_loop_ADD
    	
check_loop_end_ADD:
    j input_correct

	#Funkcja czytaj¹ca liczbê po znaku $
read_number_ADD:
    li $t9, 0  # Wartoœæ liczby
    li $t8, 0  # Flaga, czy by³a cyfra
read_number_loop_ADD:
    lb $t1, 0($t0)
    li $t4, '0'
    li $t5, '9'
    blt $t1, $t4, read_end_ADD
    bgt $t1, $t5, read_end_ADD
    
    mul $t9, $t9, 10    # Przesuniêcie liczby dziesiêtnej o 1 cyfrê w lewo
    sub $t1, $t1, $t4   # Odjêcie wartoœci kodu ASCII '0' (48), aby uzyskaæ wartoœæ liczbow¹ cyfry
    add $t9, $t9, $t1   # Dodanie cyfry do liczby
    
    li $t8, 1
    addi $t0, $t0, 1
    j read_number_loop_ADD
read_end_ADD:
    beqz $t1, input_error
    # Sprawdzenie czy liczba mieœci siê w zakresie od 0 do 31
    blt $t9, 0, check_ADDI   
    bgt $t9, 31, check_ADDI  
    li $t9, 0
    j number_correct_ADD
#ADD

#ADDI
check_ADDI:
	la $t0, input
	lb $t1, 0($t0)
    	lb $t2, 1($t0)
    	lb $t3, 2($t0)
    	lb $t4, 3($t0)
    	bne $t1, 'A', check_Jlabel
    	bne $t2, 'D', check_Jlabel
    	bne $t3, 'D', check_Jlabel
    	bne $t4, 'I', check_Jlabel
    	
    	addi $t0, $t0, 4
    	j check_registers_ADDI
    	j continue_loop
    	
    	check_registers_ADDI:
    	addi $t7, $zero, 2   # Licznik trzech liczb

check_loop_ADDI:
    	beqz $t7, check_loop_end_ADDI  # Jeœli $t7 == 0, zakoñcz sprawdzanie
    	lb $t1, 0($t0)
    	li $t4, ','
    	beq $t1, $t4, skip_ADDI
    	li $t4, ' '
    	beq $t1, $t4, skip_ADDI
    	li $t4, '$'
    	bne $t1, $t4, check_Jlabel

    	addi $t0, $t0, 1
    	j read_number_ADDI
    	number_correct_ADDI:
    	subi $t7, $t7, 1
    	j check_loop_ADDI

	skip_ADDI:
    	addi $t0, $t0, 1
    	j check_loop_ADDI
    	
check_loop_end_ADDI:
    lb $t1, 0($t0)
    beq $t1, ',', skip_ADDI2
    beq $t1, ' ', skip_ADDI2
    #addi $t0, $t0, 1
    
    j read_val_ADDI
    
    val_correct_ADDI:
    j input_correct
    
    read_val_ADDI:
    li $t8, 0  # Flaga, czy by³a cyfra
read_val_loop_ADDI:
    lb $t1, 0($t0)
    beq $t1, '\n', read_val_end_ADDI
    blt $t1, '0', input_error
    bgt $t1, '9', input_error
    li $t8, 1
    addi $t0, $t0, 1
    j read_val_loop_ADDI
read_val_end_ADDI:
    j val_correct_ADDI
   
skip_ADDI2:
    	addi $t0, $t0, 1
    	j check_loop_end_ADDI
	# Funkcja czytaj¹ca liczbê po znaku $
read_number_ADDI:
    li $t9, 0  # Wartoœæ liczby
    li $t8, 0  # Flaga, czy by³a cyfra
read_number_loop_ADDI:
    lb $t1, 0($t0)
    li $t4, '0'
    li $t5, '9'
    blt $t1, $t4, read_end_ADDI
    bgt $t1, $t5, read_end_ADDI
    
    mul $t9, $t9, 10    # Przesuniêcie liczby dziesiêtnej o 1 cyfrê w lewo
    sub $t1, $t1, $t4   # Odjêcie wartoœci kodu ASCII '0' (48), aby uzyskaæ wartoœæ liczbow¹ cyfry
    add $t9, $t9, $t1   # Dodanie cyfry do liczby
    
    li $t8, 1
    addi $t0, $t0, 1
    j read_number_loop_ADDI
read_end_ADDI:
    beqz $t1, input_error
    # Sprawdzenie czy liczba mieœci siê w zakresie od 0 do 31
    blt $t9, 0, check_Jlabel   
    bgt $t9, 31, check_Jlabel   
    j number_correct_ADDI
#ADDI

#Jlabel
check_Jlabel:
	la $t0, input
	lb $t1, 0($t0)
	lb $t2, 1($t0)
	bne $t1, 'J', check_NOOP
	bne $t2, ' ', check_NOOP
	addi $t0, $t0, 2
	
	lb $t1, 0($t0)
	beq $t1, '_', skip_
	blt $t1, 'A', input_error
	bgt $t1, 'Z', check_a
	j ok1
	check_a:
	blt $t1, 'a' input_error
	bgt $t1, 'z', input_error
	j ok1
	
	ok1:
	addi $t0, $t0, 1
	j check_lab_loop
	
check_lab_loop:
	lb $t1, 0($t0)
	beq $t1, '\n', input_correct
	beq $t1, '_', skip_
	blt $t1, '0', input_error
	bgt $t1, '9', check_A
	j ok
	check_A:
	blt $t1, 'A', input_error
	bgt $t2, 'Z', check_a2
	j ok
	check_a2:
	blt $t1, 'a' input_error
	bgt $t1, 'z' input_error
	j ok

	ok:
	addi $t0, $t0, 1
	j check_lab_loop
skip_:
 	addi $t0, $t0, 1
 	j check_lab_loop
#Jlabel

#NOOP
check_NOOP:
	la $t0, input
	lb $t1, 0($t0)
	lb $t2, 1($t0)
	lb $t3, 2($t0)
	lb $t4, 3($t0)
	bne $t1, 'N', check_MULT
	bne $t2, 'O', check_MULT
	bne $t3, 'O', check_MULT
	bne $t4, 'P', check_MULT
	addi $t0, $t0, 4
	lb $t1, 0($t0)
	bne $t1 '\n', check_MULT
	j input_correct
#NOOP

#MULT
check_MULT:
	la $t0, input
	lb $t1, 0($t0)
    	lb $t2, 1($t0)
    	lb $t3, 2($t0)
    	lb $t4, 3($t0)
    	bne $t1, 'M', check_JR
    	bne $t2, 'U', check_JR
    	bne $t3, 'L', check_JR
    	bne $t4, 'T', check_JR
    	
    	addi $t0, $t0, 4
    	j check_registers_MULT
    	j continue_loop
    	
    	check_registers_MULT:
    	addi $t7, $zero, 2   # Licznik dwoch liczb

check_loop_MULT:
    	beqz $t7, check_loop_end_MULT  # Jeœli $t7 == 0, zakoñcz sprawdzanie
    	lb $t1, 0($t0)
    	li $t4, ','
    	beq $t1, $t4, skip_MULT
    	li $t4, ' '
    	beq $t1, $t4, skip_MULT
    	li $t4, '$'
    	bne $t1, $t4, check_JR

    	addi $t0, $t0, 1
    	j read_number_MULT
    	number_correct_MULT:
    	subi $t7, $t7, 1
    	j check_loop_MULT

	skip_MULT:
    	addi $t0, $t0, 1
    	j check_loop_MULT
    	
check_loop_end_MULT:
    j input_correct

	#Funkcja czytaj¹ca liczbê po znaku $
read_number_MULT:
    li $t9, 0  # Wartoœæ liczby
    li $t8, 0  # Flaga, czy by³a cyfra
read_number_loop_MULT:
    lb $t1, 0($t0)
    li $t4, '0'
    li $t5, '9'
    blt $t1, $t4, read_end_MULT
    bgt $t1, $t5, read_end_MULT
    
    mul $t9, $t9, 10    # Przesuniêcie liczby dziesiêtnej o 1 cyfrê w lewo
    sub $t1, $t1, $t4   # Odjêcie wartoœci kodu ASCII '0' (48), aby uzyskaæ wartoœæ liczbow¹ cyfry
    add $t9, $t9, $t1   # Dodanie cyfry do liczby
    
    li $t8, 1
    addi $t0, $t0, 1
    j read_number_loop_MULT
read_end_MULT:
    beqz $t1, input_error
    # Sprawdzenie czy liczba mieœci siê w zakresie od 0 do 31
    blt $t9, 0, check_JR   
    bgt $t9, 31, check_JR   
    li $t9, 0
    j number_correct_MULT
#MULT

#JR
check_JR:
	la $t0, input
	lb $t1, 0($t0)
    	lb $t2, 1($t0)
    	bne $t1, 'J', check_JAL
    	bne $t2, 'R', check_JAL
    	
    	addi $t0, $t0, 2
    	j check_registers_JR
    	j continue_loop
    	
    	check_registers_JR:
    	addi $t7, $zero, 1   # Licznik jednej liczby

check_loop_JR:
    	beqz $t7, check_loop_end_JR  # Jeœli $t7 == 0, zakoñcz sprawdzanie
    	lb $t1, 0($t0)
    	li $t4, ' '
    	beq $t1, $t4, skip_JR
    	li $t4, '$'
    	bne $t1, $t4, check_JAL

    	addi $t0, $t0, 1
    	j read_number_JR
    	number_correct_JR:
    	subi $t7, $t7, 1
    	j check_loop_JR

	skip_JR:
    	addi $t0, $t0, 1
    	j check_loop_JR
    	
check_loop_end_JR:
    j input_correct

	#Funkcja czytaj¹ca liczbê po znaku $
read_number_JR:
    li $t9, 0  # Wartoœæ liczby
    li $t8, 0  # Flaga, czy by³a cyfra
read_number_loop_JR:
    lb $t1, 0($t0)
    li $t4, '0'
    li $t5, '9'
    beq $t1, '\n', read_end_JR
    blt $t1, $t4, input_error
    bgt $t1, $t5, input_error
    
    mul $t9, $t9, 10    # Przesuniêcie liczby dziesiêtnej o 1 cyfrê w lewo
    sub $t1, $t1, $t4   # Odjêcie wartoœci kodu ASCII '0' (48), aby uzyskaæ wartoœæ liczbow¹ cyfry
    add $t9, $t9, $t1   # Dodanie cyfry do liczby
    
    li $t8, 1
    addi $t0, $t0, 1
    j read_number_loop_JR
read_end_JR:
    # Sprawdzenie czy liczba mieœci siê w zakresie od 0 do 31
    blt $t9, 0, check_JAL  
    bgt $t9, 31, check_JAL   
    li $t9, 0
    j number_correct_JR
#JR
   
#JAL
check_JAL:
	la $t0, input
	lb $t1, 0($t0)
	lb $t2, 1($t0)
	lb $t3, 2($t0)
	lb $t4, 3($t0)
	bne $t1, 'J', input_error
	bne $t2, 'A', input_error
	bne $t3, 'L', input_error
	bne $t4, ' ', input_error
	addi $t0, $t0, 4
	
	lb $t1, 0($t0)
	beq $t1, '_', skip_JAL
	blt $t1, 'A', input_error
	bgt $t1, 'Z', check_aJAL
	j ok1JAL
	check_aJAL:
	blt $t1, 'a' input_error
	bgt $t1, 'z', input_error
	j ok1JAL
	
	ok1JAL:
	addi $t0, $t0, 1
	j check_lab_loopJAL
	
check_lab_loopJAL:
	lb $t1, 0($t0)
	beq $t1, '\n', input_correct
	beq $t1, '_', skip_JAL
	blt $t1, '0', input_error
	bgt $t1, '9', check_AJAL
	j okJAL
	check_AJAL:
	blt $t1, 'A', input_error
	bgt $t2, 'Z', check_a2JAL
	j okJAL
	check_a2JAL:
	blt $t1, 'a' input_error
	bgt $t1, 'z' input_error
	j okJAL

	okJAL:
	addi $t0, $t0, 1
	j check_lab_loopJAL
skip_JAL:
 	addi $t0, $t0, 1
 	j check_lab_loopJAL	
#JAL
	
#SPRAWDZANIE INPUTOW

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#INNE i koniec
input_error:
	li $v0, 4
	la $a0, instruction_error_msg
	syscall
	j continue_loop
	
num_error:
	li $v0, 4
	la $a0, num_error_msg
	syscall
	j enter_num

print_debug:
	li $v0, 4
	la $a0, debug
	syscall
end:
	li $v0, 4
	la $a0, end_msg
	syscall
		
	li $v0, 10
	syscall
#INNE i koniec

#------------------------------------------------------------------------------------------------------------------------------------------------------#
