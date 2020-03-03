#**********************************************************************************#
# Progetto di Architettura degli Elaboratori II       				   #                                                     
# Codice sorgente di Andrei Ciulpan; Matricola 872394 				   #                                                     
# Codice sorgente sviluppato e testato sul simulatore MARS v4.5			   #
# Il codice dovrebbe essere eseguito solo ed esclusivamente sul simulatore MARS    #                                                    
#**********************************************************************************#

######## SEGMENTO DATI ####################################################################################################################################################

	.data
	
	# DEFINIZIONE DELLE STRINGHE 
	
	insert_N: 		.asciiz "Inserisci un numero N>0: "
	err1: 			.asciiz "Il numero deve essere maggiore di 0. Riprova.\n"
	err2: 			.asciiz "Scelta invalida. Riprova.\n"
	result_random_str:	.asciiz "Numero generato casualmente: "
	result_pari_str:	.asciiz "Il numero è pari."
	result_dispari_str:	.asciiz "Il numero è dispari."
	result_collatz_str:	.asciiz "Sequenza di Collatz: "
	result_collatz_lungh:	.asciiz "\nLunghezza della sequenza: "
	result_primo_str:	.asciiz "Il numero è primo."
	result_non_primo_str:	.asciiz	"Il numero non è primo."
	blank_str:		.asciiz " "
	newline_str:		.asciiz "\n"
	
	# Segue una stringa lunga perchè MARS non mi permette di mettere una stessa stringa su piu' linee. 
	# La scelta di avere una stringa lunga anzichè averne piu' stringhe corte è stata fatta per
	# ridurre il numero delle syscall quando va stampato il menu.
	
	menu: 			.asciiz	"\n*************************** MENU ***************************\n1. Calcola la sequenza di Collatz\n2. Stabilisci se il numero è primo\n3. Stabilisci se il numero è pari o dispari\n4. Genera un numero casuale compreso tra 1 ed N (compreso)\n5. Riprova con un altro numero\n6. Esci dal programma\n*************************** MENU ***************************\n\nScegli una tra le opzioni del menu: "
					
######## SEGMENTO TESTO ##########################################################################################################################################################################################

	.text
	.globl main

######## MAIN ##################################################################################################################################################################################################
	
main:

	la $a0, insert_N		# indirizzo di insert_N caricato in $a0
	li $v0, 4			# selezione di print_string
	syscall 			# print_string 
	
	li $v0, 5			# selezione di read_int
	syscall				# read_int 
	move $s0, $v0			# $s0 contiene il numero N
		 
	ble $s0, 0, err_msg1		# if N <= 0 then salta a err_msg1
	j display_menu			# altrimenti salta a display_menu
	
######## DISPLAY_MENU ######################################################################################################################################################################################################
	
display_menu:

	la $a0, menu			# indirizzo di menu caricato in $a0
	li $v0, 4			# selezione di print_string
	syscall 			# print_string
	
	li $v0, 5			# selezione di read_int
	syscall				# read_int 
	move $t0, $v0			# $t0 contiene la scelta
	
	# SWITCH CASE 
	
	ble $t0, 0, err_msg2		# scelta <= 0 -> invalida, salta a err_msg2
	beq $t0, 1, collatz		# scelta = 1  -> calcoliamo la sequenza di collatz; salta a collatz
	beq $t0, 2, primo		# scelta = 2  -> stabiliamo se è primo; salta a primo
	beq $t0, 3, pari_dispari	# scelta = 3  -> stabiliamo se è pari o dispari; salta a pari_dispari
	beq $t0, 4, random		# scelta = 4  -> generiamo un numero casuale; salta a random
	beq $t0, 5, main		# scelta = 5  -> riprova con un altro numero; salta a main
	beq $t0, 6, exit		# scelta = 6  -> termina programma; salta a exit
	j err_msg2			# scelta > 6  -> invalida; salta a err_msg2
	
######## COLLATZ ##########################################################################################################################################################################################################

collatz:

	la $a0, result_collatz_str	# indirizzo di result_collatz_str caricato in $a0
	li $v0, 4			# selezione di print_string
	syscall 			# print_string
	
	la $a0, newline_str		# carica l'indirizzo di newline_str in $a0
	li $v0, 4			# seleziona print_string
	syscall				# print_string
		
	li $t3, 3			# salvo il valore 3 in $t3, servirà per dopo
	li $t4, 0			# conterà la lunghezza della sequenza
	li $t5, 0			# servirà per aggiungere newlines
	
	move $a0, $s0			# il numero N ($s0) è passato ad $a0 come parametro
	jal collatz_funct		# chiama la funzione collatz_funct(int N)
	
######## COLLATZ_FUNCT ####################################################################################################################################################################################################

collatz_funct:

	addi $sp, $sp, -4		# alloco spazio sullo stack per il frame
	sw $ra, 0($sp)			# salvo il return address $ra sullo stack
	
	move $t0, $a0			# $t0 ora contiene il valore corrente passato come parametro
		
	move $a0, $t0			# aggiorniamo $a0 con il valore corrente
	jal stampa_numero_collatz	# salta a stampa_numero_collatz; NB: $a0 contiene già il numero
		
	beq $t0, 1, collatz_base 	# se N = 1 allora si ha il caso base
					# altrimenti continuiamo, dobbiamo vedere se siamo in caso di pari o dispari
	move $a0, $t0			# aggiorniamo $a0 con il valore corrente
	jal pari_dispari_funct		# chiama la funzione pari_dispari_funct(int N); NB: $a0 contiene già il numero
	move $t1, $v0			# ora $t1 contiene il valore restituito (0 = PARI, 1 = DISPARI)				
	
	move $a0, $t0			# aggiorniamo $a0 con il valore corrente ($a0 è stato modificato dalla funzione stampa_numero_collatz e non va piu' bene)
	bne $t1, 0, collatz_dispari	# risultato != 0 -> siamo nel caso del numero dispari; salta a collatz_dispari
					# se arriviamo qui allora siamo nel caso del numero pari; continua l'esecuzione		
	srl $a0, $t0, 1			# $a0 ora contiene numero_corrente/2
	jal collatz_funct		# salta a collatz_funct(ora con valore $a0 modificato)
		
collatz_base:

	j collatz_return		# salta a collatz_return
	
collatz_dispari:

	mul $a0, $t3, $a0		# $a0 = 3 x numero_corrente
	addi $a0, $a0, 1		# $a0 = (3 x numero_corrente)+1
	jal collatz_funct		# salta a collatz_funct(ora con valore $a0 modificato)
	
collatz_return:

	lw $ra, 0($sp)			# ripristino $ra
	addi $sp, $sp, 4		# dealloco lo spazio sullo stack per il frame
	
	la $a0, result_collatz_lungh	# carichiamo l'indirizzo di result_collatz_lungh in $a0
	li $v0, 4			# selezione di print_string
	syscall				# print_string
	
	move $a0, $t4			# carichiamo la lunghezza della sequenza in $a0
	li $v0, 1			# selezione di print_int
	syscall				# print_int
	
	j display_menu			# torniamo al menu
	
stampa_numero_collatz:

	move $t0, $a0 			# $t0 contiene il parametro passato in $a0
	
	move $a0, $t0			# carichiamo $a0 con l'intero da stampare
	li $v0, 1			# selezione di print_int sul valore dentro $a0 passato come parametro
	syscall 			# print_int
	
	la $a0, blank_str		# carica l'indirizzo di blank_str in $a0
	li $v0, 4			# selezione di print_string
	syscall				# print_string
	
	addi $t4, $t4, 1		# incrementiamo la lunghezza della sequenza
	
	addi $t5, $t5, 1		# incrementiamo anche $t5, servirà per poter aggiungere newlines ogni 15 numeri in sequenza (per lettura piu' pulita)
	ble $t5, 15, continua		# if $t5 <= 15 then salta a continua
					# altrimenti stampa una newline
	li $t5, 0			# azzerra $t5
	
	la $a0, newline_str		# carica l'indirizzo di newline_str in $a0
	li $v0, 4			# seleziona print_string
	syscall				# print_string
	
continua: 

	jr $ra				# torniamo all'indirizzo salvato dal chiamante
	
######## PRIMO ##########################################################################################################################################################################################################

primo:

	move $a0, $s0			# il numero N ($s0) è passato ad $a0 come parametro
	jal primo_funct			# chiama la funzione primo_funct(int N)
	move $t0, $v0			# ora $t0 contiene il valore restituito (0 = PRIMO, 1 = NON PRIMO)
	
	bne $t0, 1, primo_msg		# risultato != 1; salta a non_primo_msg	
	j non_primo_msg			# altrimenti risultato = 1; salta a primo_msg
	
	
######## PRIMO_FUNCT ####################################################################################################################################################################################################

primo_funct:

	move $t0, $a0 			# ora $t0 contiene N
	
	# CICLO for(i=2; i<=N/2; i++)
	
	li $t1, 2			# $t1 rappresenta la variabile i che parte da 2
	
	li $t2, 2			# assegniamo 2 a $t2
	div $t0, $t2			# esegue N/2 ---> LO: quoziente, HI:resto
	mflo $t2			# ora $t2 contiene l'upper bound per il ciclo for (N/2)
	
	li $t4, 0			# assegniamo 0 al flag $t4 che restituiremo a fine ciclo

for: 

	bgt $t1, $t2, endfor		# if i > N/2 then salta a endfor (il ciclo finisce)
	
	div $t0, $t1			# esegue N/i ---> LO: quoziente, HI:resto
	mfhi $t3			# $t3 contiene il resto
	
	beq $t3, 0, flagtrue		# if resto=0 allora il numero non è primo; salta a flagtrue
	addi $t1, $t1, 1		# i++
	j for				# il ciclo non è ancora finito, torna a for

flagtrue:

	li $t4, 1			# assegniamo 1 al flag $t4 che restituiremo a fine ciclo
	j endfor			# il ciclo è finito (il numero non è primo); salta a endfor
	
endfor:
	
	move $v0, $t4			# mettiamo il flag in $v0 e lo restituiamo
	jr $ra				# torniamo all'indirizzo salvato dal chiamante
	
######## PARI_DISPARI ##########################################################################################################################################################################################################

pari_dispari:

	move $a0, $s0			# il numero N ($s0) è passato ad $a0 come parametro
	jal pari_dispari_funct		# chiama la funzione pari_dispari_funct(int N)
	move $t0, $v0			# ora $t0 contiene il valore restituito (0 = PARI, 1 = DISPARI)
	
	bne $t0, 0, dispari_msg		# risultato != 0; salta a dispari_msg
	j pari_msg			# altrimenti risultato = 0; salta a pari_msg
	
######## PARI_DISPARI_FUNCT ################################################################

pari_dispari_funct:

	move $t0, $a0			# ora $t0 contiene N
	li $t1, 2			# mettiamo il valore 2 in $t1
	
	div $t0, $t1			# esegue N/2 ---> LO: quoziente, HI:resto
	mfhi $t2			# $t2 contiene il resto
	
	move $v0, $t2			# la funzione restituirà il risultato
	jr $ra				# torniamo all'indirizzo salvato dal chiamante
				
######## RANDOM ########################################################################################################################################################################################################################################################

random:
	
	move $a0, $s0 			# il numero N ($s0) è passato ad $a0 come parametro
	jal random_funct		# chiama la funzione random_funct(int N)
	move $t0, $v0			# ora $t0 contiene il valore restituito
				
	addi $t0, $t0, 1		# incrementiamo il numero generato in modo tale che sia compreso tra 1 e N (anzichè 0 e N-1)
	
	la $a0, result_random_str	# indirizzo di result_random_str caricato in $a0
	move $a1, $t0			# risultato caricato in $a1
	li $v0, 56			# selezione di MessageDialogInt (stampa stringa + int rispettivamente in $a0 e $a1)
	syscall 			# MessageDialogInt
	
	j display_menu			# torna al menu
	
######## RANDOM_FUNCT ##########################################################################################################################################################################################################

random_funct:

	move $a1, $a0			# spostiamo N in $a1 (upper bound) 
	li $a0, 0			# seed del generatore = 0
	li $v0, 42			# selezione di "random int range"
	syscall				# "random int range"
	
	move $v0, $a0			# ora $v0 contiene il numero random
	jr $ra				# torniamo all'indirizzo salvato dal chiamante
	
######## ERR_MSG1 ################################################################
		
err_msg1: 

	la $a0, err1			# indirizzo di err1 caricato in $a0
	li $a1, 2			# tipo di messaggio: warning
	li $v0, 55			# selezione di MessageDialog
	syscall				# MessageDialog
	
	j main				# salta a main (in questo modo chiede di nuovo per un numero N)
	
######## ERR_MSG2 ########################################################################################################################################################################################################################################################

err_msg2: 

	la $a0, err2			# indirizzo di err2 caricato in $a0
	li $a1, 2			# tipo di messaggio: warning
	li $v0, 55			# selezione di MessageDialog
	syscall				# MessageDialog
	
	j display_menu			# torna al menu
	
######## PARI_MSG ########################################################################################################################################################################################################################################################

pari_msg: 

	la $a0, result_pari_str		# indirizzo di result_pari_str caricato in $a0
	li $a1, 1			# tipo di messaggio: info
	li $v0, 55			# Selezione di MessageDialog
	syscall				# MessageDialog
	
	j display_menu			# torna al menu
	
	
######## DISPARI_MSG ##########################################################################################################################################################################################################

dispari_msg: 

	la $a0, result_dispari_str	# indirizzo di result_dispari_str caricato in $a0
	li $a1, 1			# tipo di messaggio: info
	li $v0, 55			# Selezione di MessageDialog
	syscall				# MessageDialog
	
	j display_menu			# torna al menu


######## PRIMO_MSG ########################################################################################################################################################################################################################################################

primo_msg: 

	la $a0, result_primo_str	# indirizzo di result_primo_str caricato in $a0
	li $a1, 1			# tipo di messaggio: info
	li $v0, 55			# Selezione di MessageDialog
	syscall				# MessageDialog
	
	j display_menu			# torna al menu
	
######## NON_PRIMO_MSG ########################################################################################################################################################################################################################################################

non_primo_msg: 

	la $a0, result_non_primo_str	# indirizzo di result_non_primo_str caricato in $a0
	li $a1, 1			# tipo di messaggio: info
	li $v0, 55			# Selezione di MessageDialog
	syscall				# MessageDialog
	
	j display_menu			# torna al menu
	
######## EXIT ########################################################################################################################################################################################################################################################

exit:
	
	li $v0, 10			# selezione di exit
	syscall				# exit program
	
	
