section .text

global expression
global term
global factor

extern strlen
extern atoi


; `factor(char *p, int *i)`
;       Evaluates "(expression)" or "number" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
factor:
        push    ebp
        mov     ebp, esp

        push ecx
        push ebx

        mov ecx, [ebp + 12] ; int *i
        mov ebx, [ebp + 8]  ; char *p
        mov ecx, [ecx]      ; valoarea lui i

        ; adunam ecx lui ebx pentru a avansa in sirul p
        add ebx, ecx
        ; [ebx] --> caracterul de pe pozitia curenta;
        ; daca acesta este 40 inseamna ca este "(", deci urmeaza o expresie
        cmp byte [ebx], byte 40
        je isExpression

        ; altfel, apelam atoi pentru a obtine valoarea numerica de la pozitia
        ; curenta in string
        push ebx
        call atoi
        add esp, 4

        ; calculam lungimea numarului pentru a actualiza pozitia actuala
        ; in sir (i)
        xor ecx, ecx

checkLength:
        inc ecx

        ; [ebx + ecx] caracteul urmator;
        ; daca acesta este in afara intervalului inseamna ca nu reperezinta o
        ; cifra, deci se tree in update si se actualizeaza i;
        ; se repeta cat timp caracterul urmator este o cifra;
        ; ecx salveaza lungimea;
        cmp byte [ebx + ecx], byte 48
        jb updatei
        cmp byte [ebx + ecx], byte 57
        ja updatei
        jmp checkLength

;; actualizeaza i
updatei:
        push ebx
        mov ebx, ecx
        xor ecx, ecx
        mov ecx, [ebp + 12]

        add dword [ecx], ebx
        pop ebx

        jmp endFactor

;; se ajunge aici daca pe pozitia curenta este "(", deci urmeaza o expresie
isExpression:
        mov ecx, [ebp + 12]
        inc dword [ecx] ; actualizeaza i pentru a trece peste "("

        push dword [ebp + 12]
        push dword [ebp + 8]
        call expression
        add esp, 8

        ; incrementeaza i pentru a trece si peste ")" care o sa apara la
        ; finalul executiei functiei expression
        inc dword [ecx] 

;; sfarsitul functiei factor   
endFactor:
        pop ebx
        pop ecx
        
        leave
        ret

; `term(char *p, int *i)`
;       Evaluates "factor" * "factor" or "factor" / "factor" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
term:
        push    ebp
        mov     ebp, esp

        push ecx
        push ebx

        mov ecx, [ebp + 12] ; int *i
        mov ebx, [ebp + 8]  ; char *p

        push dword [ebp + 12]
        push dword [ebp + 8]
        call factor
        add esp, 8
        ; eax va retine valoarea de retur a functiei factor;
        ; dupa primul apel, eax reprezinta primul factor

        xor edi, edi
        mov edi, eax ; edi salveaza primul factor
        push edi

        ; adunam [ecx] lui ebx pentru a verifica daca dupa primul factor
        ; mai urmeaza unul
        add ebx, [ecx]

        ; daca valoarea caracterului este 42 sau 47 inseamna ca mai urmeaza
        ; un factor si se trece in okTerm; altfel, se trece in endTerm
        cmp byte [ebx], byte 42 ; caracterul "*"
        je okTerm
        cmp byte [ebx], byte 47 ; caracterul "/"
        je okTerm

        pop edi
        jmp endTerm

;; se ajunge aici daca mai exista inca un factor;
;; se verifica semnul si se calculeaza corespunzator;
okTerm:
        mov ecx, [ebp + 12]
        inc dword [ecx] ; incrementam i

        push dword [ebp + 12]
        push dword [ebp + 8]
        call factor
        add esp, 8

        pop edi
        ; eax retine al doilea factor
        ; edi retine primul factor
        
        ; se verifica semnul
        cmp byte [ebx], byte 42
        je multiply
        cmp byte [ebx], byte 47
        je divide

        jmp endTerm

;; daca semnul este "*"
multiply:
        mul edi
        
        jmp checkNextSignTerm

;; daca semnul este "/"
divide:
        push eax
        push edi
        pop eax
        pop edi

        xor edx, edx
        cdq ; edx va fi bitul de semn al eax
        idiv edi

;; se verifica existenta a mai multor operatori
checkNextSignTerm:
        xor edi, edi
        mov edi, eax ; primul factor
        push edi

        mov ebx, [ebp + 8]
        add ebx, [ecx]

        ; daca valoarea caracterului este 42 sau 47 inseamna ca mai urmeaza
        ; un factor si se trece in okTerm; altfel, se trece in endTerm
        cmp byte [ebx], byte 42
        je okTerm
        cmp byte [ebx], byte 47
        je okTerm
        pop edi

;; sfarsitul functiei term 
endTerm:
        pop ebx
        pop ecx

        leave
        ret

; `expression(char *p, int *i)`
;       Evaluates "term" + "term" or "term" - "term" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
expression:
        push    ebp
        mov     ebp, esp

        push ecx
        push ebx

        mov ecx, [ebp + 12] ; int *i
        mov ebx, [ebp + 8]  ; char *p

        push dword [ebp + 12]
        push dword [ebp + 8]
        call term
        add esp, 8
        ; eax va retine valoarea de retur a functiei term;
        ; dupa primul apel, eax reprezinta primul term

        xor edi, edi
        mov edi, eax ; edi salveaza primul term
        push edi

        ; adunam [ecx] lui ebx pentru a verifica daca dupa primul term
        ; mai urmeaza unul
        add ebx, [ecx]

        ; daca valoarea caracterului este 43 sau 45 inseamna ca mai urmeaza
        ; un term si se trece in okExpr; altfel, se trece in endExpression
        cmp byte [ebx], byte 43 ; caracterul "+"
        je okExpr
        cmp byte [ebx], byte 45 ; caracterul "-"
        je okExpr

        pop edi
        jmp endExpression ; expresia are doar un termen

;; se ajunge aici daca mai exista inca un term;
;; se verifica semnul si se calculeaza corespunzator;
okExpr:
        inc dword [ecx] ; incrementam i

        push dword [ebp + 12]
        push dword [ebp + 8]
        call term
        add esp, 8

        pop edi
        ; eax retine al doilea term
        ; edi retine primul term

        ; se verifica semnul
        cmp byte [ebx], byte 43
        je plus
        cmp byte [ebx], byte 45
        je minus

        jmp endExpression

;; daca semnul este "+"
plus:
        add eax, edi
        
        jmp checkNextSignExpr

;; daca semnul este "-"
minus:
        sub edi, eax
        xor eax, eax
        mov eax, edi
        
;; se verifica existenta a mai multor operatori
checkNextSignExpr:
        xor edi, edi
        mov edi, eax ; primul term
        push edi

        mov ebx, [ebp + 8]
        add ebx, [ecx]

        ; daca valoarea caracterului este 43 sau 45 inseamna ca mai urmeaza
        ; un term si se trece in okExpr; altfel, se trece in endExpression
        cmp byte [ebx], byte 43
        je okExpr
        cmp byte [ebx], byte 45
        je okExpr
        pop edi

;; sfarsitul functiei expression 
endExpression:
        pop ebx
        pop ecx
        
        leave
        ret