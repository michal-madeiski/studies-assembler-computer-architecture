.data
choice_msg: .asciiz "Wybierz znak(O - kolko, X - krzyzyk): "
choice_error_msg: .asciiz "\nWybierz poprawny znak! \n"
num_msg: "Podaj ile rund chcesz zagrac(1, 2, 3, 4 lub 5): "
num_error_msg: "Podano niepoprawna ilosc rund!"
place_error_msg_already: "Na podanym polu znajduje sie juz znak! \n"
place_error_msg: "Podaj poprawny numer pola! \n"
place_error_msg2: "Na podanym polu jest juz wartosc! \n"
place_msg: "Podaj numer pola na ktorym chcesz umiescic znak(od 0 do 8): "
end_msg: .asciiz "Zakonczono dzialanie programu."
debug: .asciiz "debug \n"
new_line: .asciiz " \n"
wynik_u: .asciiz "Wynik uzytkownika: "
wynik_k: .asciiz "Wynik komputera: "
wygrywa_u: .asciiz "Wygrales! \n"
wygrywa_k: .asciiz "Przegrales :( \n"
remis_: .asciiz "Remis... \n"
board: .byte '-','-','-','-','-','-','-','-','-' 9
round_win: .asciiz "Wygrales runde! \n"
round_lose: .asciiz "Przegrales runde :( \n"
round_draw: .asciiz "Remis w rundzie... \n"
koniec_gry: .asciiz "Zakonczono rozgrywke! Ponizej podsumowanie: \n"


.text
#------------------------------------------------------------------------------------------------------------------------------------------------------#

#GLOWNA CZESC
main:
	#wybieranie znaku i zapisanie do a1, znak komputera do a2
	li $v0, 4
	la $a0, choice_msg
	syscall
	li $v0, 12
	syscall
	move $a1, $v0
	
	beq $a1, 'X', krzyzyk
	beq $a1, 'O', kolko
	
	li $v0, 4
	la $a0, choice_error_msg
	syscall
	j main
	
	krzyzyk:
	add $a2, $zero, 'O'
	j enter_num
	
	kolko:
	add $a2, $zero, 'X'
	j enter_num
	
	#ilosc gier do t0
	enter_num:
	
	#nowa linia
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $v0, 4
	la $a0, num_msg
	syscall
	li $v0, 5
	syscall
	move $t0, $v0
	
	blt $t0, 1, num_error
	bgt $t0, 5, num_error
	
	j start_game
#GLOWNA CZESC

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#ROZGRYWKA		
start_game:
	#t1 - zagrane gry, t2 - wygranie uzytkownika, t3 - wygrane komputera, t4 - plansza
	la $t4, board
	add $t1, $zero, 0
	add $t2, $zero, 0
	add $t3, $zero, 0
	new_game:
	beq $t1, $t0, podsumowanie
	j clear_tab
	after_clear:
	
	round:
	#miejsce na planszy do a3
	enter_place:
	li $v0, 4
	la $a0, place_msg
	syscall
	li $v0, 5
	syscall
	move $a3, $v0
	
	blt $a3, 0, place_error
	bgt $a3, 8, place_error
	
	j check_place
	
	after_check:
	j print_u
	
	after_print_u:
	j check_wU
	
	after_check_wU:
	j check_remis
	
	after_check_remis:
	j ruch_k
	
	after_ruch_k:
	#nowa linia
	li $v0, 4
	la $a0, new_line
	syscall
	j print_K
	
	after_print_K:
	j check_wK
	
	after_check_wK:
	j round

podsumowanie:
	li $v0, 4
	la $a0, koniec_gry
	syscall
	
	li $v0, 4
	la $a0, wynik_u
	syscall
	
	li $v0, 1
	la $a0, ($t2)
	syscall
	
	#nowa linia
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $v0, 4
	la $a0, wynik_k
	syscall
	
	li $v0, 1
	la $a0, ($t3)
	syscall
	
	#nowa linia
	li $v0, 4
	la $a0, new_line
	syscall
	
	
	beq $t2, $t3, remis
	bgt $t2, $t3, wygrana
	bgt $t3, $t2, przegrana
	
	remis:
	li $v0, 4
	la $a0, remis_
	syscall
	j end
	
	wygrana:
	li $v0, 4
	la $a0, wygrywa_u
	syscall
	j end
	
	przegrana:
	li $v0, 4
	la $a0, wygrywa_k
	syscall
	j end
#ROZGRYWKA	
		
#------------------------------------------------------------------------------------------------------------------------------------------------------#

#SPRAWDZANIE WYGRANEJ
check_wU:
	j line_check_U
	after_line_check_U:
	
line_check_U:
	la $t4, board
	lb $t9, 0($t4)
	bne $t9, $a1, next_line1_U
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a1, next_line1_U
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a1, next_line1_U
	j win_u
	next_line1_U:
	la $t4, board
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a1, next_line2_U
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a1, next_line2_U
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a1, next_line2_U
	j win_u
	next_line2_U:
	la $t4, board
	addi $t4, $t4, 6
	lb $t9, 0($t4)
	bne $t9, $a1, column_check_U
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a1, column_check_U
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a1, column_check_U
	j win_u

column_check_U:
	la $t4, board
	lb $t9, 0($t4)
	bne $t9, $a1, next_col1_U
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a1, next_col1_U
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a1, next_col1_U
	j win_u
	next_col1_U:
	la $t4, board
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a1, next_col2_U
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a1, next_col2_U
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a1, next_col2_U
	j win_u
	next_col2_U:
	la $t4, board
	addi $t4, $t4, 2
	lb $t9, 0($t4)
	bne $t9, $a1, skos_check_U
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a1, skos_check_U
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a1, skos_check_U
	j win_u
skos_check_U:
	la $t4, board
	lb $t9, 0($t4)
	bne $t9, $a1, next_s_U
	addi $t4, $t4, 4
	lb $t9, 0($t4)
	bne $t9, $a1, next_s_U
	addi $t4, $t4, 4
	lb $t9, 0($t4)
	bne $t9, $a1, next_s_U
	j win_u
	next_s_U:
	la $t4, board
	addi $t4, $t4, 2
	lb $t9, 0($t4)
	bne $t9, $a1, after_check_wU
	addi $t4, $t4, 2
	lb $t9, 0($t4)
	bne $t9, $a1, after_check_wU
	addi $t4, $t4, 2
	lb $t9, 0($t4)
	bne $t9, $a1, after_check_wU
	j win_u
	
check_wK:
	j line_check_K
	after_line_check_K:
	
line_check_K:
	la $t4, board
	lb $t9, 0($t4)
	bne $t9, $a2, next_line1_K
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a2, next_line1_K
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a2, next_line1_K
	j win_k
	next_line1_K:
	la $t4, board
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a2, next_line2_K
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a2, next_line2_K
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a2, next_line2_K
	j win_k
	next_line2_K:
	la $t4, board
	addi $t4, $t4, 6
	lb $t9, 0($t4)
	bne $t9, $a2, column_check_K
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a2, column_check_K
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a2, column_check_K
	j win_k

column_check_K:
	la $t4, board
	lb $t9, 0($t4)
	bne $t9, $a2, next_col1_K
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a2, next_col1_K
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a2, next_col1_K
	j win_k
	next_col1_K:
	la $t4, board
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, $a2, next_col2_K
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a2, next_col2_K
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a2, next_col2_K
	j win_k
	next_col2_K:
	la $t4, board
	addi $t4, $t4, 2
	lb $t9, 0($t4)
	bne $t9, $a2, skos_check_K
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a2, skos_check_K
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, $a2, skos_check_K
	j win_k
skos_check_K:
	la $t4, board
	lb $t9, 0($t4)
	bne $t9, $a2, next_s_K
	addi $t4, $t4, 4
	lb $t9, 0($t4)
	bne $t9, $a2, next_s_K
	addi $t4, $t4, 4
	lb $t9, 0($t4)
	bne $t9, $a2, next_s_K
	j win_k
	next_s_K:
	la $t4, board
	addi $t4, $t4, 2
	lb $t9, 0($t4)
	bne $t9, $a2, after_check_wK
	addi $t4, $t4, 2
	lb $t9, 0($t4)
	bne $t9, $a2, after_check_wK
	addi $t4, $t4, 2
	lb $t9, 0($t4)
	bne $t9, $a2, after_check_wK
	j win_k
	
win_u:
	li $v0, 4
	la $a0, round_win
	syscall	
	
	add $t2, $t2, 1
	add $t1, $t1, 1
	j new_game
win_k:
	li $v0, 4
	la $a0, round_lose
	syscall	
	
	add $t1, $t1, 1
	add $t3, $t3, 1
	j new_game
#SPRAWDZANIE WYGRANEJ

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#RUCH KOMPUTERA
ruch_k:
	srodek:
	la $t4, board
	addi $t4, $t4, 4
	lb $t9, 0($t4)
	bne $t9, '-', pG
	sb $a2, 0($t4)
	j after_ruch_k
	
	pG:
	la $t4, board
	addi $t4, $t4, 2
	lb $t9, 0($t4)
	bne $t9, '-', sG
	sb $a2, 0($t4)
	j after_ruch_k
	
	sG:
	la $t4, board
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	bne $t9, '-', lG
	sb $a2, 0($t4)
	j after_ruch_k
	
	lG:
	la $t4, board
	lb $t9, 0($t4)
	bne $t9, '-', ls
	sb $a2, 0($t4)
	j after_ruch_k
	
	ls:
	la $t4, board
	addi $t4, $t4, 3
	lb $t9, 0($t4)
	bne $t9, '-', ps
	sb $a2, 0($t4)
	j after_ruch_k
	
	ps:
	la $t4, board
	addi $t4, $t4, 5
	lb $t9, 0($t4)
	bne $t9, '-', ldol
	sb $a2, 0($t4)
	j after_ruch_k
	
	ldol:
	la $t4, board
	addi $t4, $t4, 6
	lb $t9, 0($t4)
	bne $t9, '-', sdol
	sb $a2, 0($t4)
	j after_ruch_k
	
	sdol:
	la $t4, board
	addi $t4, $t4, 7
	lb $t9, 0($t4)
	bne $t9, '-', pdol
	sb $a2, 0($t4)
	j after_ruch_k
	
	pdol:
	la $t4, board
	addi $t4, $t4, 8
	lb $t9, 0($t4)
	sb $a2, 0($t4)
	j after_ruch_k
#RUCH KOMPUTERA

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#SPRAWDZANIE REMISU	
check_remis:
	la $t4, board
	lb $t9, 0($t4)
	beq $t9, '-', after_check_remis
	
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	beq $t9, '-', after_check_remis
	
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	beq $t9, '-', after_check_remis
	
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	beq $t9, '-', after_check_remis
	
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	beq $t9, '-', after_check_remis
	
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	beq $t9, '-', after_check_remis
	
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	beq $t9, '-', after_check_remis
	
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	beq $t9, '-', after_check_remis
	
	addi $t4, $t4, 1
	lb $t9, 0($t4)
	beq $t9, '-', after_check_remis
	
	j remiss
remiss:
	li $v0, 4
	la $a0, round_draw
	syscall	
	
	add $t1, $t1, 1
	j new_game
#SPRAWDZANIE REMISU

#------------------------------------------------------------------------------------------------------------------------------------------------------#
		
#INNE i koniec	
print_u:
    la $t4, board
    li $t6, 9   
    li $t7, 0     

print_loop:
    	#wypisz komórke ze znakiem 
    	lb $a0, 0($t4)
    	li $v0, 11
    	syscall         
    
    	li $a0, ' '      #odstep
    	li $v0, 11
    	syscall
    
    	addi $t4, $t4, 1
    	addi $t7, $t7, 1
    	li $t8, 3
    	div $t7, $t8    #sprawdzenie czy czas na nowa linie
    	mfhi $t9
    	bne $t9, $zero, skip_endl
    
    	li $v0, 11 #nowa linia
    	li $a0, 10
    	syscall
    
    	skip_endl:
    	subi $t6, $t6, 1
    	bnez $t6, print_loop
    	
	j after_print_u
	
print_K:
    la $t4, board
    li $t6, 9   
    li $t7, 0     

print_loop_k:
    	#wypisz komórke ze znakiem 
    	lb $a0, 0($t4)
    	li $v0, 11
    	syscall         
    
    	li $a0, ' '      #odstep
    	li $v0, 11
    	syscall
    
    	addi $t4, $t4, 1
    	addi $t7, $t7, 1
    	li $t8, 3
    	div $t7, $t8    #sprawdzenie czy czas na nowa linie
    	mfhi $t9
    	bne $t9, $zero, skip_endl_K
    
    	li $v0, 11 #nowa linia
    	li $a0, 10
    	syscall
    
    	skip_endl_K:
    	subi $t6, $t6, 1
    	bnez $t6, print_loop_k
    	
	j after_print_K

check_place:
	la $t4, board
	loop:
	beqz $a3, end_loop
	sub $a3, $a3, 1
	addi $t4, $t4, 1
	j loop
	end_loop:
	
	lb $t8, 0($t4)
	bne $t8, '-', place_error2
	
	#wlozenie do tablicy wyboru uzytkownika
	sb $a1, 0($t4)
	j after_check
	
clear_tab:
	la $t4, board
	li $t9, '-'
	sb $t9, 0($t4)
	addi $t4, $t4, 1
	
	sb $t9, 0($t4)
	addi $t4, $t4, 1
	
	sb $t9, 0($t4)
	addi $t4, $t4, 1
	
	sb $t9, 0($t4)
	addi $t4, $t4, 1
	
	sb $t9, 0($t4)
	addi $t4, $t4, 1
	
	sb $t9, 0($t4)
	addi $t4, $t4, 1
	
	sb $t9, 0($t4)
	addi $t4, $t4, 1
	
	sb $t9, 0($t4)
	addi $t4, $t4, 1
	
	sb $t9, 0($t4)
	
	j after_clear
	
place_error:
	li $v0, 4
	la $a0, place_error_msg
	syscall
	j enter_place
place_error2:
	li $v0, 4
	la $a0, place_error_msg2
	syscall
	j enter_place
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
