section .text
	global intertwine

;; void intertwine(int *v1, int n1, int *v2, int n2, int *v);
;
;  Take the 2 arrays, v1 and v2 with varying lengths, n1 and n2,
;  and intertwine them
;  The resulting array is stored in v
intertwine:
	enter 0, 0

	; rdi - int *v1
	; rsi - int n1
	; rdx - int *v2
	; rcx - int n2
	; r8 - int *v

	mov rax, r8 ; vectorul rezultat

	push r9 
	xor r9, r9 ; index pentru vectorul rezultat

	push r11
	xor r11, r11 ; index pentru vectorul 1
	push r12
	xor r12, r12 ; index pentru vectorul 2

;; bucla se executa cat timp mai sunt elemente in ambii vectori;
;; altfel, se trece in end
loopLabel:
	; r11b --> cel mai putin semnificativ octet al r11
	; sil --> cel mai putin semnificativ octet al rsi
	cmp r11b, sil
	je end
	; r12b --> cel mai putin semnificativ octet al r12
	; cl --> cel mai putin semnificativ octet al rcx
	cmp r12b, cl
	je end

	; se verifica daca indexul pentru vectorul rezultat este par sau impar
	; pentru index impar, elementul care va trebui mutat va fi din v1
	; pentru index par, elementul care va trebui mutat va fi din v2
	test r9b, byte 1
	jnz vect2
	
;; element din vectorul 1
vect1:
	push rdi
	mov rdi, [rdi + r11 * 4] ; 4 --> sizeof(int)
	mov [rax + r9 * 4], edi
	pop rdi

	inc r9b
	inc r11b
	jmp loopLabel

;; element din vectorul 2
vect2:
	push rdx
	mov rdx, [rdx + r12 * 4]
	mov [rax + r9 * 4], edx
	pop rdx

	inc r9b
	inc r12b
	jmp loopLabel

;; sfarsitul functiei
;; se verifica fiecare vector pentru elemente ramase
end:
	cmp r11b, sil
	jb vect1
	cmp r12b, cl
	jb vect2

	pop r12
	pop r11
	pop r9

	leave
	ret
