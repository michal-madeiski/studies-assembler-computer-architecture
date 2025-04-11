.data
	message1: .asciiz "Wybierz wyrazenie arytmetyczne do obliczenia: "
	message2: .asciiz "Podaj wartosci zmiennych: \n"
	message3: .asciiz "\nWartosc wyrazenia wynosi: "
	message4: .asciiz "Numer wyrazenia, ktorego wartosc nalezy obliczyc: "
	message5: .asciiz "\nCzy chcesz kontynuowac? (1 - tak; 0 - nie) "
	messageB: .asciiz "b = "
	messageC: .asciiz "c = "
	messageD: .asciiz "d = "
	message0: .asciiz "Nie mozna dzielic przez 0!"
	niepoprawnyNr: .asciiz "Wybierz poprawny numer rownania - od 1 do 3!"
	equation1: .asciiz "1. a = (b + c) / d \n"
	equation2: .asciiz "2. a = ((b - d) * c) + b  \n"
	equation3: .asciiz "3. a = ((c + d) * (c + b)) / b \n"
	endMessage: .asciiz "Zakonczono dzialanie programu."
	

.text
	#zapisanie 1 do t7 jako chec kontynuacji programu
	addi $t7, $zero, 1
main:
	while: 
		beq $t7, 0, exit
	
		#wyswietlenie dostepnych rownan
		li $v0, 4
		la $a0, equation1
		syscall
	
		li $v0, 4
		la $a0, equation2
		syscall
	
		li $v0, 4
		la $a0, equation3
		syscall
		
		#pobranie wartosci zmiennych i przeniesienie b do a1, c do a2, d do a3
		li $v0, 4
		la $a0, message2
		syscall
		
		li $v0, 4
		la $a0, messageB
		syscall
		li $v0, 5
		syscall
		move $a1, $v0
		
		li $v0, 4
		la $a0, messageC
		syscall
		li $v0, 5
		syscall
		move $a2, $v0
		
		li $v0, 4
		la $a0, messageD
		syscall
		li $v0, 5
		syscall
		move $a3, $v0
	
		#poproszenie uzytkownika o wybor rownnania
		li $v0, 4
		la $a0, message1
		syscall
		
		#pobranie numeru rownania do wykonania
		li $v0, 5
		syscall
	
		#przeniesienie numeru rownania do t0
		move $t0, $v0
	
		#wybrano rownanie nr1
		beq $t0, 1, eq1
		
		#wybrano rownanie nr2
		beq $t0, 2, eq2
		
		#wybrano rownanie nr1
		beq $t0, 3, eq3
		
		li $v0, 4
		la $a0, niepoprawnyNr
		syscall
		
		kontynuacja:
		
		#spytanie o chec kontynuacji i przeniesienie wyboru do t7
		li $v0, 4
		la $a0, message5
		syscall
		li $v0, 5
		syscall
		move $t7, $v0
	
		j while
		
	eq1:
		#wyswietlenie numeru rownania do wykonania
		li $v0, 4
		la $a0, message4
		syscall
	
		li $v0, 1
		move $a0, $t0
		syscall
		
		#wyswietlenie wartosci wyrazenia
		li $v0, 4
		la $a0, message3
		syscall
		
		add $t1, $a1, $a2
		beq $a3, 0, dziel0
		div $t2, $t1, $a3
		li $v0, 1
		la $a0, ($t2)
		syscall
		
		j kontynuacja
		
	eq2:
		#wyswietlenie numeru rownania do wykonania
		li $v0, 4
		la $a0, message4
		syscall
	
		li $v0, 1
		move $a0, $t0
		syscall
		
		#wyswietlenie wartosci wyrazenia
		li $v0, 4
		la $a0, message3
		syscall
		
		sub $t1, $a1, $a3
		mul $t2, $a2, $t1
		add $t3, $a1, $t2
		li $v0, 1
		la $a0, ($t3)
		syscall
		
		j kontynuacja
		
	eq3:
		#wyswietlenie numeru rownania do wykonania
		li $v0, 4
		la $a0, message4
		syscall
	
		li $v0, 1
		move $a0, $t0
		syscall
		
		#wyswietlenie wartosci wyrazenia
		li $v0, 4
		la $a0, message3
		syscall
		
		add $t1, $a2, $a3
	 	add $t2, $a2, $a1
	 	mul $t3, $t1, $t2
	 	beq $a1, 0, dziel0
	 	div $t1, $t3, $a1
	 	li $v0, 1
		la $a0, ($t1)
		syscall
		
		j kontynuacja
		
	dziel0:
		li $v0, 4
		la $a0, message0
		syscall
		
		j kontynuacja
		
	exit:
		#wyswietlenie wiadomosci koncowej
		li $v0, 4
		la $a0, endMessage
		syscall
		
		#koniec
		li $v0, 10
		syscall



	
	

	
		
		
	
	

	
	
	
