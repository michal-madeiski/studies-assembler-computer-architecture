.data
x_y_msg: .asciiz "Podaj wartosci zmiennych: \n"
value_msg: .asciiz "Wartosc funkcji wynosi: "
enter_num_msg: .asciiz "Podaj numer funkcji - od 1 do 3 (lub 0, jesli chcesz zakonczyc program): "
enter_x_msg: .asciiz "x = "
enter_y_msg: .asciiz "y = "
error_num: .asciiz "Podaj poprawny numer funkcji - od 1 do 3! (lub 0, jesli chcesz zakonczyc program) \n"
functions_msg: .asciiz "1. f(x, y)= {1 dla x=y lub y=0 i [f(x-1, y)+f(x-1, y-1)] dla x>y} \n2. g(x, y)= {1 dla x=y lub y=0 i [2*g(x-1, y)+2*g(x-1, y-1)] dla x>y} \n3. h(x, y)= {2 dla x=y lub y=0 i [2*h(x-1, y)+h(x-1, y-1)] dla x>y} \n"
end_msg: .asciiz "Zakonczono dzialanie programu."
debug: .asciiz "debug \n"
new_line: .asciiz " \n"
undefined_val_msg: .asciiz "Wartosc funkcji jest nieokreslona dla podanych zmiennych! \n" 
zero: .float 0.0
one: .float 1.0
two: .float 2.0

.text
#------------------------------------------------------------------------------------------------------------------------------------------------------#

#GLOWNA CZESC
main:
	#lista funkcji do wyboru
	li $v0, 4
	la $a0, functions_msg
	syscall
enter_num:	
	#flaga koprocesora na false
	lwc1 $f0, zero
	lwc1, $f1, one
	c.eq.s $f0, $f1
	
	#nr funkcji od uzytkownika i sprawdzenie
	li $v0, 4
	la $a0, enter_num_msg
	syscall
	li $v0, 5
	syscall
	move $a2, $v0
	
	beq $a2, 0 , end
	bltz $a2, num_error
	bgt $a2, 3, num_error
	
	#pobranie zmiennych i przejscie do funkcji
	li $v0, 4
	la $a0, enter_x_msg
	syscall
	li $v0, 6                  
        syscall
    	mov.s $f12, $f0 
    	
	li $v0, 4
	la $a0, enter_y_msg
	syscall
	li $v0, 6                  
        syscall
    	mov.s $f14, $f0 
    	
    	#czy x<y
	c.lt.s $f12, $f14
	bc1t undefined_val
	
	beq $a2, 1, call_f
	beq $a2, 2, call_g
	beq $a2, 3, call_h
#GLOWNA CZESC	
	
#------------------------------------------------------------------------------------------------------------------------------------------------------#

#FUNKCJE

#funcF
call_f:
    jal f
    b print_result

f:
    subu $sp, $sp, 32     
    sw $ra, 28($sp)       
    sw $fp, 24($sp)       
    addu $fp, $sp, 32     
    
    mov.s $f4, $f12 #x
    mov.s $f5, $f14 #y
    
    l.s $f6, zero
    c.eq.s $f5, $f6
    bc1t f_val1
    
    c.eq.s $f4, $f5
    bc1t f_val1
    
    swc1 $f4, 20($sp)
    swc1 $f5, 16($sp)
    lwc1 $f6, one
    sub.s $f12, $f4, $f6 #x = x-1
    jal f
    mov.s $f8, $f0
    lwc1 $f4, 20($sp)
    lwc1 $f5, 16($sp)
    
    swc1 $f4, 20($sp)
    swc1 $f5, 16($sp)
    swc1 $f8, 12($sp)
    l.s $f6, one
    sub.s $f12, $f4, $f6 #x = x-1
    sub.s $f14, $f5, $f6 #y = y-1
    
    jal f
    mov.s $f7, $f0
    lwc1 $f4, 20($sp)
    lwc1 $f5, 16($sp)
    lwc1 $f6, 12($sp)
    add.s $f0, $f7, $f6
    b f_return_val
    
f_val1:
    l.s $f6, one
    mov.s $f0, $f6
    
f_return_val:
    lw $ra, 28($sp)       
    lw $fp, 24($sp)       
    addu $sp, $sp, 32     
    jr $ra                

print_result:
    li $v0, 4
    la $a0, value_msg
    syscall

    li $v0, 2
    mov.s $f12, $f0
    syscall
    
    li $v0, 4
    la $a0, new_line
    syscall
    
    j enter_num
#funcF

#funcG
call_g:
    jal g
    b print_result
g:
    subu $sp, $sp, 32     
    sw $ra, 28($sp)       
    sw $fp, 24($sp)       
    addu $fp, $sp, 32     
    
    mov.s $f4, $f12 #x
    mov.s $f5, $f14 #y
    
    l.s $f6, zero
    c.eq.s $f5, $f6
    bc1t g_val1
    
    c.eq.s $f4, $f5
    bc1t g_val1
    
    swc1 $f4, 20($sp)
    swc1 $f5, 16($sp)
    lwc1 $f6, one
    sub.s $f12, $f4, $f6  #x = x-1
    jal g
    mov.s $f8, $f0
    lwc1 $f4, 20($sp)
    lwc1 $f5, 16($sp)
    
    swc1 $f4, 20($sp)
    swc1 $f5, 16($sp)
    swc1 $f8, 12($sp)
    l.s $f6, one
    sub.s $f12, $f4, $f6 #x = x-1
    sub.s $f14, $f5, $f6 #y = y-1
    jal g
    mov.s $f7, $f0	
    lwc1 $f4, 20($sp)	
    lwc1 $f5, 16($sp)	
    lwc1 $f6, 12($sp)	
    
    l.s $f9, two
    mul.s $f6, $f6, $f9	#g(x-1, y) = 2*g(x-1, y)
    mul.s $f7, $f7, $f9	#g(x-1, y-1) = 2*g(x-1, y-1)
    add.s $f0, $f7, $f6
    b g_return_val
    
g_val1:
    l.s $f6, one
    mov.s $f0, $f6
    
g_return_val:
    lw $ra, 28($sp)       
    lw $fp, 24($sp)       
    addu $sp, $sp, 32     
    jr $ra

#funcG

#funcH
call_h:
    jal h
    b print_result
h:
    subu $sp, $sp, 32     
    sw $ra, 28($sp)       
    sw $fp, 24($sp)       
    addu $fp, $sp, 32     
    
    mov.s $f4, $f12 #x
    mov.s $f5, $f14 #y
    
    l.s $f6, zero
    c.eq.s $f5, $f6
    bc1t h_val1
    
    c.eq.s $f4, $f5
    bc1t h_val1
    
    swc1 $f4, 20($sp)
    swc1 $f5, 16($sp)
    lwc1 $f6, one
    sub.s $f12, $f4, $f6  #x = x-1
    jal h
    mov.s $f8, $f0
    lwc1 $f4, 20($sp)
    lwc1 $f5, 16($sp)
    
    swc1 $f4, 20($sp)
    swc1 $f5, 16($sp)
    swc1 $f8, 12($sp)
    l.s $f6, one
    sub.s $f12, $f4, $f6 #x = x-1
    sub.s $f14, $f5, $f6 #y = y-1
    jal h
    mov.s $f7, $f0	
    lwc1 $f4, 20($sp)	
    lwc1 $f5, 16($sp)	
    lwc1 $f6, 12($sp)	
    
    l.s $f9, two
    mul.s $f6, $f6, $f9	#h(x-1, y) = 2*h(x-1, y)
    add.s $f0, $f7, $f6
    b h_return_val
    
h_val1:
    l.s $f6, one
    mov.s $f0, $f6
    
h_return_val:
    lw $ra, 28($sp)       
    lw $fp, 24($sp)       
    addu $sp, $sp, 32     
    jr $ra
#funcH

#FUNKCJE

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#INNE i koniec	
undefined_val:
	li $v0, 4
	la $a0, undefined_val_msg
	syscall
	j enter_num
	
num_error:
	li $v0, 4
	la $a0, error_num
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
