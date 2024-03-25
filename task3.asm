global get_words
global compare_func
global sort

section .text

extern qsort
extern strlen
extern strcmp

;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor 
;  dupa lungime si apoi lexicografix
sort:
    enter 0, 0
    xor eax, eax

    push dword compare_func ; functia de comparatie
    push dword [ebp + 16]   ; int size
    push dword [ebp + 12]   ; int number_of_words
    push dword [ebp + 8]    ; char **words

    call qsort
    add esp, 16

    leave
    ret

;; functia de comparatie pentru qsort
compare_func:
    enter 0, 0

    mov eax, dword [ebp + 12] ; al doilea parameteru al functiei
    push dword [eax]
    call strlen
    add esp, 4
    ; eax va retine lungimea celui de-al doilea string dat ca parametru

    push ebx
    xor ebx, ebx
    mov ebx, eax ; salveaza lungimea celui de-al doilea string

    xor eax, eax
    mov eax, dword [ebp + 8] ; primul parametru al functiei
    push dword [eax]
    call strlen
    add esp, 4
    ; eax va retine lungimea primului string dat ca parametru

    ; daca lungimile sunt egale, se sorteaza lexicografic;
    ; daca lungimea celui de-al doilea string este mai mare,
    ; se trece in below
    ; altfel, se trece in above
    cmp eax, ebx
    pop ebx
    je sortLex
    jb below
    ja above

above:
    xor eax, eax
    mov eax, dword 1
    jmp quit

below:
    xor eax, eax
    mov eax, dword -1
    jmp quit

;; sortare lexicografica folosind functia strcmp
sortLex:
    xor eax, eax
    mov eax, dword [ebp + 12]
    mov ecx, dword [ebp + 8]

    push dword [eax]
    push dword [ecx]

    call strcmp
    add esp, 8
    ; eax va retine rezultatul functiei strcmp

;; quit --> finalul functiei sort, , se restabilesc registrele
quit:
    leave
    ret


;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter 0, 0

    push eax
    push edx
    push ebx
    push edi ; numara cuvintele
    push ecx

    mov edx, [ebp + 8]  ; char *s
    mov eax, [ebp + 12] ; char **words
    mov ebx, [ebp + 16] ; int number_of_words

    
    xor ecx, ecx
    xor edi, edi
    jmp ignoreChars

;; edx reprezinta sirul s, iar incS reprezinta locul in care
;; se trece la urmatorul caracter din sir prin incrementarea edx
incS:
    inc edx

;; sari peste primele caractere daca acestea nu sunt litere sau cifre
ignoreChars:
    ; [edx] --> caracterul curent;
    ; daca este in afara intervalului [48, 122] inseamna ca
    ; nu este nici litera nici cifra si se trece in incS
    cmp byte [edx], byte 122
    ja incS
    cmp byte [edx], byte 48
    jb incS

    ; daca este in intervalul [48, 57] sau [97, 122] inseamna ca
    ; este ori litera, ori cifra si se trece in copyWords
    cmp byte [edx], byte 57
    jbe copyWords
    cmp byte [edx], byte 97
    jae copyWords

    ; daca este in intervalul [58, 64] sau [91, 96] inseamna ca
    ; nu este nici litera nici cifra si se trece in incS
    cmp byte [edx], byte 65
    jb incS
    cmp byte [edx], byte 90
    ja incS

    jmp copyWords

;; copyWords --> pozitionarea este pe primul caracter al unui cuvant care
;;                  trebuie copiat in words
copyWords:
    cmp edi, ebx ; verifcare pentru numarul de cuvinta
    jae end      ; daca edi ajunge egal cu ebx, functia se termina

    push esi
    mov esi, [eax + edi * 4] ; adresa de inceput a cuvantului curent din words

    xor ecx, ecx ; index in cadrul unui cuvant

;; copyLetters --> se copiaza fiecare caracter dintr-un cuvant cat timp acesta
;;                  este o litera, cifra, sau caracterul "-"
copyLetters:    
    push ebx
    xor ebx, ebx
    mov bl, byte [edx + ecx]
    mov [esi + ecx], ebx
    pop ebx
    inc ecx ; incrementarea se realizeaza pentru a verifica daca urmatorul
            ; caracter face parte din cuvant

    ; [edx + ecx] --> caracterul urmator;
    ; daca este egal cu 45 inseamna ca avem caracterul "-" si se trece in
    ; copyLetters pentru a il scrie in cuvant
    cmp byte [edx + ecx], byte 45
    je copyLetters

    ; daca este in afara intervalului [48, 122] inseamna ca
    ; nu este nici litera nici cifra si se trece in nextWord
    cmp byte [edx + ecx], byte 122
    ja nextWord
    cmp byte [edx + ecx], byte 48
    jb nextWord

    ; daca este in intervalul [48, 57] sau [97, 122] inseamna ca
    ; este ori litera, ori cifra si se trece in copyLetters
    cmp byte [edx + ecx], byte 57
    jbe copyLetters
    cmp byte [edx + ecx], byte 97
    jae copyLetters

    ; daca este in intervalul [58, 64] sau [91, 96] inseamna ca
    ; nu este nici litera nici cifra si se trece in nextWord
    cmp byte [edx + ecx], byte 65
    jb nextWord
    cmp byte [edx + ecx], byte 90
    ja nextWord

    jmp copyLetters

;; nextWord --> face trecerea la urmatorul cuvant din sirul de caractere
nextWord:
    inc edi         ; actualizeaza numarul de cuvinte scrise
    add edx, ecx    ; ecx reprezinta pozitia primului caracter care nu
                    ; apartine ultimului cuvant scris;
                    ; adunam ecx lui edx pentru a trece la urmatorul cuvant
    pop esi

    jmp incS

;; sfarsitul functiei get_words, se restabilesc registrele
end:
    pop esi
    pop ecx
    pop edi
    pop ebx
    pop edx
    pop eax

    leave
    ret