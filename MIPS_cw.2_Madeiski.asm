.data 

wybierzOperacje: .asciiz "Wybierz operacje do wykonania: S - szyfrowanie, D - deszyfrowanie, X - zakoncz dzialanie programu: "
podajKlucz: .asciiz "Podaj klucz o dlugosci 3 - 8 znakow (skladajacy sie z niepowtarzajacych sie cyfr w zakresie od 1 do dlugosci klucza): "
podajTekst: .asciiz "Podaj tekst (o dlugosci do 50 znakow, bez cyfr): "
niepoprawnyKlucz: .asciiz "Podano niepoprawny klucz! \n"
niepoprawnyTekstJawny: .asciiz "Podano niepoprawny tekst jawny! \n"
niepoprawnyKryptogram: .asciiz "Podano niepoprawny kryptogram! \n"
niepoprawnaOperacja: .asciiz "Podano niepoprawna operacje! \n"
koniecProgramu: .asciiz "Zakonczono dzialanie programu."
key: .word 0 #klucz
dlKlucza: .word 0 #dlugosc klucza
cyfryWKluczu: .word 10, 20, 30, 40, 50, 60, 80 #tablica cyfr klucza
keyChanged: .word 0, 0, 0, 0, 0, 0, 0, 0 #klucz po zmianie do deszyfrowania
tablicaUnikalnosci: .word 0, 0, 0, 0, 0, 0, 0, 0 #tablica do sprawdzania unikalnosci cyfr klucza
input: .space 50 #slowo od uzytkownika
inputNorm: .space 50 #slowo po normalizacji
dlInputa: .word 0
tekstPoNormalizacji: .asciiz "Wprowadzony tekst po normalizacji: "
tekstPoOperacji: .asciiz "Wprowadzony tekst po operacji: "
petla2_iter: .word 0
nowaLinia: .asciiz "\n"
debug: .asciiz "debug"

.text
#GLOWNA CZESC
main:
	#pobranie wyboru operacji i przeniesienie wyboru do a1
	li $v0, 4
	la $a0, wybierzOperacje
	syscall
	li $v0, 12
	syscall
	move $a1, $v0
	
	#nowa linia
	li $v0, 4
	la $a0, nowaLinia
	syscall
	
	#warunki co wykonac zaleznie od wybranej operacji
	beq $a1, 'S', podawanieKlucza
	beq $a1, 'D', deszyfrowanie
	beq $a1, 'X', koniec
	
	#podanie niepoprawnej operacji
	li $v0, 4
	la $a0, niepoprawnaOperacja
	syscall
	j main

	#skok do podawania klucza
	j podawanieKlucza
	
poSprawdzonymKluczu:
	#wczytanie tekstu
	li $v0, 4
	la $a0, podajTekst
	syscall
	
	#slowo do a2
	li $v0, 8         
	la $a0, input
	li $a2, 51       
	syscall
	
	j normalizacja
	
poNormalizacji:
	li $v0, 4
	la $a0, tekstPoNormalizacji
	syscall

	la $t0, inputNorm
	lw $t1, dlInputa
	li $t2, 0
wyswietlInput:
	beq $t1, $t2, koniecWyswietlania
	lb $t3, 0($t0)
	li $v0, 11
	move $a0, $t3
	syscall
	add $t2, $t2, 1
	add $t0, $t0, 1
	j wyswietlInput
koniecWyswietlania: 
	li $v0, 11          
	li $a0, 10          
	syscall
	
	j szyfrowanie
#GLOWNA CZESC
		
#------------------------------------------------------------------------------------------------------------------------------------------------------#

#KLUCZ	
podawanieKlucza:
	#wczytanie klucza i przypisanie do zmiennej key
	li $v0, 4
	la $a0, podajKlucz
	syscall
	li $v0, 5
	syscall
	move $a2, $v0
	sw $a2, key
	#zaladowanie tablicyUnikalnosci i innych pomocniczych
	li $t6, 0
	la $t7, tablicaUnikalnosci
	li $t8, 8
wyczyscTab:
	beq $t6, $t8, wyczyszczonaTab
	li $t9, 0
	sw $t9, 0($t7)
	addi $t7, $t7, 4
	add $t6, $t6,1 
	j wyczyscTab
wyczyszczonaTab:
	#sprawdzenie poprawnosci klucza
	j sprawdzKlucz
sprawdzKlucz:
	#pierwszy warunek na dlugosc klucza
	lw $t0, key
	bgt $t0, 122, pierwszyWarCz2
	j bladKlucza
	pierwszyWarCz2:
	blt $t0, 87654322, kontynuacjaSprawdzania
	j bladKlucza
kontynuacjaSprawdzania:
	#klucz do t0 oraz cyfry klucza do t3 i dlugosc klucza do t1
	lw $t0, key
	li $t1, 0
	la $t3, cyfryWKluczu
	li $t5, 10
rozkladKlucza:
	beq $t0, 0, poRozkladzie
	div $t0, $t0, $t5
	mfhi $t4
	sw $t4, 0($t3)
	add $t3, $t3, 4
	add $t1, $t1, 1
	j rozkladKlucza
poRozkladzie:
	sw $t1, dlKlucza
	li $t0, 0
	la $t3, cyfryWKluczu
	la $t4, tablicaUnikalnosci
	lw $t1, dlKlucza
sprPowtarzania:
	#$t2 przechowuje wartosc z tab
	beq $t0, $t1, poSprawdzonymKluczu
	lw $t2, 0($t3)
	ble $t2, $t1, sprUnikalnosci
	j bladKlucza
	
sprUnikalnosci:
	la $t4, tablicaUnikalnosci
	sub $t5, $t2, 1
	mul $t5, $t5, 4
	add $t4, $t4, $t5
	lw $t5, 0($t4)
	beq $t5, 0, dalej
	j bladKlucza
	
dalej:
	li $t6, 1
	sw $t6, 0($t4)
	add $t3, $t3, 4
	add $t0, $t0, 1
	j sprPowtarzania
#KLUCZ

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#NORMALIZACJA	
normalizacja:
	la $t0, input 
	la $t1, inputNorm
	li $t3, 0
norm_petla:
	lb $t2, 0($t0)       
 	beq $t2, $zero, koniec_norm_petla
	li $t4, 65 #wartosc ASCII 'A'
	li $t5, 90 #wartosc ASCII 'Z'
	blt $t2, $t4, pominZnak  	
	bgt $t2, $t5, sprawdzMale 	
	j poSprZnakow
sprawdzMale: 
	li $t4, 97   #wartosc ASCII 'a'
	li $t5, 122  #wartosc ASCII 'z'
	blt $t2, $t4, pominZnak  
	bgt $t2, $t5, pominZnak  
	j poSprZnakow 
poSprZnakow:
 	sb $t2, 0($t1)       
	addi $t0, $t0, 1      
	add $t3, $t3, 1
	add $t1, $t1, 1
	j norm_petla 
pominZnak: 
	addi $t0, $t0, 1 
	j norm_petla               
koniec_norm_petla:
	sw $t3, dlInputa 
	j poNormalizacji
#NORMALIZACJA	

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#SZYFROWANIE
szyfrowanie:
	li $v0, 4 		 
	la $a0, tekstPoOperacji
	syscall

	lw $t3, dlKlucza 	#rozmiar klucza
	lw $t4, dlInputa	#rozmiar podanego s³owa 
	li $t5, 0		#licznik do pêtli1
	li $t6, 0		#iteracje pêtli z szyfrowaniem 
	div $t6, $t4, $t3	#ile wykonano szyfrowan
	mfhi $t7		#iteracje pêtli bez szyfrowania 
	sw $t7, petla2_iter 	#zapis do zmiennej - zwolnienie $t7
szyfr_petla: 
	beq $t5, $t6, koniec_szyfr_petla
	li $t8, 0		#licznik pêtli wewnêtrznej 
	la $t0, inputNorm
	la $t1, cyfryWKluczu	#klucz w odwroconej kolejnoœci  
	li $t4, 0		
	sub $t4, $t3 ,1 
	mul $t4, $t4, 4
	add $t1, $t1, $t4
	li $t4, 0
	mul $t4, $t5, $t3
	add $t0, $t0, $t4 
petlaDoKlucza:
	beq $t8, $t3, koniec_petlaDoKlucza
	lw $t4, 0($t1)
	sub $t4, $t4,1
	add $t0, $t0, $t4
	lb $t7, 0($t0)
	li $v0, 11 
	move $a0, $t7
	syscall
	sub $t0, $t0, $t4 
	add $t1, $t1, -4 
	add $t8, $t8, 1
	j petlaDoKlucza
koniec_petlaDoKlucza:
	add $t5, $t5, 1
	j szyfr_petla
koniec_szyfr_petla:
	la $t0, inputNorm
	li $t4, 0
	mul $t4, $t5, $t3
	add $t0, $t0, $t4
	lw $t1, petla2_iter
	li $t2, 0
szyfr_petla2:
	beq $t2, $t1, koniec_szyfr_petla2
	lb $t3, 0($t0)
	li $v0, 11 
	move $a0, $t3
	syscall
	add $t2, $t2, 1
	add $t0, $t0 ,1 
	j szyfr_petla2
koniec_szyfr_petla2:
	li $v0, 11      
	li $a0, 10       
	syscall
	j main
#SZYFROWANIE

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#DESZYFROWANIE
deszyfrowanie:
	#skok do podawania klucza
	j podawanieKlucza
	#skok do zmiany klucza
	j zmianaKlucza
	#powrot do szyfrowania ze zmienionym kluczem
	j poSprawdzonymKluczu
#DESZYFROWANIE

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#ZMIANA KLUCZA
zmianaKlucza:
	beq $t2, $t1, zakonczonoZmianeKlucza
	la $t0, cyfryWKluczu
	sub $t4, $t5, $t2
	mul $t4, $t4, 4
	add $t0, $t0, $t4
	lw $t6, 0($t0) 
	la $t0, cyfryWKluczu
	sub $t4, $t1, $t6
	mul $t4, $t4, 4
	add $t0, $t0, $t4
	lw $t7, 0($t0) 
	la $t3, keyChanged
	sub $t4, $t1, $t7
	mul $t4, $t4, 4
	add $t3, $t3, $t4
	sw $t6, 0($t3) 
	add $t2, $t2,1
	j zmianaKlucza
zakonczonoZmianeKlucza:
	la $t0, keyChanged       #nowa tab klucza
	la $t3, cyfryWKluczu     #pierwotna tab klucza
	li $t2, 0                #licznik pêtli

skopiujKlucz:
	beq $t2, $t1, szyfrowanie   
	lw $t6, 0($t0)                   
	sw $t6, 0($t3)                    
	add $t0, $t0, 4                 
	add $t3, $t3, 4                  
	add $t2, $t2, 1                   
	j skopiujKlucz   
               
#ZMIANA KLUCZA

#------------------------------------------------------------------------------------------------------------------------------------------------------#

#INNE i koniec
bladKlucza:
	li $v0, 4
	la $a0, niepoprawnyKlucz
	syscall
	j podawanieKlucza
printDebug:
	li $v0, 4
	la $a0, debug
	syscall
koniec:
	#wyswietlenie wiadomosci koncowej
	li $v0, 4
	la $a0, koniecProgramu
	syscall
		
	#koniec
	li $v0, 10
	syscall
#INNE i koniec

#------------------------------------------------------------------------------------------------------------------------------------------------------#


