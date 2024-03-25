section .text
	global sort

; struct node {
;     	int val;
;    	struct node* next;
; };

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list
sort:
	enter 0, 0

	push dword [ebp] ; numara nodurile
	mov [ebp], dword 0
	push edi ; salvam minimul local in edi

	xor eax, eax ; valoarea de retur

	push ebx
	xor ebx, ebx
	mov ebx, [ebp + 12] ; aflam adresa de inceput

	; ecx este folosit pentru a itera prin noduri
	; calculeaza adresa primului nod pentru a avea un punct de plecare
	add eax, ebx ; adunam adresa de inceput
	push ecx
	xor ecx, ecx
	

;; getAbsoluteMin afla nodul cu valoarea minima din lista
getAbsoluteMin:
	; cautarea se termina cand ecx ajunge egal cu numarul total de noduri
	cmp ecx, [ebp + 8]
	jge setRetVal


;; checkNodes compara valorile a doua noduri
;; eax va stoca mereu minimul
;; ecx * 8 deoarece sizeof(struct node) == 8
checkNodes:
	push esi
	push edx
	xor esi, esi
	xor edx, edx

	mov esi, [eax] ; valoarea nodului salvat prin eax
	mov edx, [ebx + ecx * 8] ; valoarea nodului curent
	cmp esi, edx
	jle dontModify

	; seteaza minimul, eax va avea adresa nodului cu valoarea minima
	lea eax, [ebx + ecx * 8]


;; dontModify --> minimul de la pasul curent nu trebuie schimbat
dontModify:
	pop edx
	pop esi

	inc ecx
	jmp getAbsoluteMin


;; se seteaza valoarea de retur, head-ul listei ordonate
setRetVal:
	push eax 


;; dupa ce minimul absolut al listei a fost gasit si setat,
;; trebuie faculta legatura cu celelate noduri in ordine corecta
;; linking --> actualieaza numarul de noduri pe care le-am legat
;; 				si reseteaza contorul de bucla si minimul local
;; eax va fi folosit pentru a retine valoarea minimului calculat
;; la un pas anterior
linking:
	inc dword [ebp] ; numara nodurile
	push eax ; folosim eax temporar pentru a verifica contitia de oprire
	mov eax, [ebp + 8] ; numarul total de noduri
	cmp [ebp], eax ; conditie de oprire
	pop eax ; restabilim eax
	jge end

	; ecx folosit, din nou, pentru a itera prin noduri
	xor ecx, ecx
	; seteaza minimul local pe 0
	; (presupunem ca un album nu poate avea valoarea <= 0)
	xor edi, edi


;; bucla in care parcurgem nodurile ramase si calculam minimul local
loopLabel:
	cmp ecx, [ebp + 8]  ; cat timp nu am terminat de verificat nodurile,
	jb checkCond		; verificam conditiile
	; daca am terminat de parcurs nodurile inseamna ca avem minimul
	; local salvat in edi si stabilim legaturile

	; minimul anterior (nodul cu adresa eax) are ca element urmator
	; nodul de la adresa edi (accesam campul next prin [eax + 4])
	mov [eax + 4], edi
	; actualizeaza minimul anterior
	mov eax, edi

	jmp linking


;; verificam daca nodul curent indeplineste conditiile de minim
checkCond:
	push edx
	xor edx, edx

	mov edx, [ebx + ecx * 8] ; edx salveaza valoarea de la nodul curent
	
	; comparam valoarea din nodul curent cu valoarea
	; minimului precedent;
	; daca valoarea este mai mare strict inseamna ca nodul actual
	; poate deveni minimul curent
	cmp edx, [eax]  
	jg possibleMin

	; incrementam contorul pentru noduri si repetam algoritmul,
	; nodul curent nu poate fi minim la pasul actual
	inc ecx 
	pop edx
	jmp loopLabel


;; verificam daca nodul curent este minim pentru pasul actual
possibleMin:
	; daca edi este 0 inseamna ca nu am setat pana acum un mininim pentru
	; ciclul curent, deci nodul cu valoarea edx este minim local
	cmp edi, 0
	je modifyMin

	; daca edi nu este 0 inseamna ca un minim a fost setat pentru
	; ciclul curent, deci acea valoarea trebuie comparata cu ce am salvat
	; acum in edx
	; daca valoarea din edi este mai mare strict, minimul local se modifica
	cmp [edi], edx
	jg modifyMin

	; altfel, incrementam contorul pentru noduri si repetam algoritmul
	inc ecx
	pop edx
	jmp loopLabel


;; modifica minimul curent
modifyMin:
	; edi stocheaza adresa nodului cu valoarea minima
	lea edi, [ebx + ecx * 8]

	; incrementam contorul pentru noduri si repetam algoritmul
	inc ecx
	pop edx
	jmp loopLabel
	

;; sfarsitul programului, se restabilesc registrele, iar in eax
;; vom avea inceputul listei sortate
end:
	pop eax ; valoarea de retur

	pop ecx
	pop ebx

	pop edi
	pop dword [ebp]

	leave
	ret
