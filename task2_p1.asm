section .text
	global cmmmc

;; int cmmmc(int a, int b)
;
;; calculate least common multiple for 2 numbers, a and b
cmmmc:
	pop esi
	pop eax ; primul parametru (a)
	pop ebx ; al doilea parametru (b)
	
	push eax
	pop ecx ; copie a lui eax
	push ebx
	pop edx ; copie a lui ebx

;; la finalul gcd, ecx va retine cel mai mare divizor comun al a si b;
;; daca cele doua numere ajung egale, se efectueaza inmultirea lor;
;; daca primul este mai mare, din el se scade cel de-al doilea numar
;; si se repeta bucla;
;; daca al doilea este mai mare, din el se scade primul numar si se
;; repeta bucla.
gcd: ; greatest common divisor
	cmp ecx, ebx
	je multiply
	jl second

	sub ecx, ebx
	jmp gcd

second:
	sub ebx, ecx
	jmp gcd

multiply:
	push edx
	pop ebx ; restabileste ebx

	mul ebx ; eax retine a * b

	; pentru a afla cmmmc, impartim a * b la cel mai mare divizor comun
	div ecx

	push ebx
	push eax
	push esi

	ret
