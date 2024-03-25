section .text
	global par

;; int par(int str_length, char* str)
;
; check for balanced brackets in an expression
par:
	pop esi
	pop ebx ; int str_length
	pop eax ; char* str

	push ecx
	xor ecx, ecx ; indexul pentru sirul de paranteze
	push edx
	xor edx, edx

	push esi
	xor esi, esi

;; loopLabel --> bucla prin care verificam daca sirul de paranteze este corect
;; verificarea se face cu ajutorul registrului edx;
;; edx se incrementeaza in momentul in care se intalneste o paranteza deschisa
;; si se decrementeaza cand se intalneste o paranteza inchisa;
;; daca edx ajunge negativ inseamna ca s-au inchis mai multe paranteze decat
;; s-au deschis si se returneaza 0;
;; daca s-a terminat de parcurs sirul, se trece la eticheta check unde se
;; verifica daca edx este 0, caz in care parantezele sunt echilibrate si se
;; returneaza 1; altfel, se returneaza 0.
loopLabel:
	cmp ecx, ebx ; verifica daca am terminat de parcurs sirul de paranteze
	jae check

	push ebx
	push dword [eax + ecx] ; salveaza caracterul curent in ebx
	pop ebx
	shl ebx, 24 ; sterge ceilalti octeti din ebx
	shr ebx, 24

	cmp ebx, dword 40 ; 40 --> "("
	pop ebx
	ja substract ; daca ebx este mai mare strict decat 40 inseamna ca avem ")" (41)

	inc edx
	inc ecx ; actualizeaza indexul
	jmp loopLabel

substract:
	dec edx
	cmp edx, 0
	; daca valoarea din edx este mai mica strict decat 0 programul se termina
	; cu valoarea de retur 0
	jl finish0

	inc ecx ; actualizeaza indexul
	jmp loopLabel

;; stabileste rezultatul final
;; daca edx este diferit de 0 valoarea de retur este 0
;; altfel, se returneaza 1
check:
	cmp edx, 0
	je finish1

finish0:
	xor eax, eax
	jmp end

finish1:
	xor eax, eax
	inc eax

;; restabileste registrele
end:
	pop esi
	pop edx
	pop ecx
	
	push eax
	push ebx
	push esi

	ret
