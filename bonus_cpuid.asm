section .text
	global cpu_manufact_id
	global features
	global l2_cache_info

;; void cpu_manufact_id(char *id_string);
;
;  reads the manufacturer id string from cpuid and stores it in id_string
cpu_manufact_id:
	enter 	0, 0

	pusha

	xor eax, eax
	push edi
	xor edi, edi
	mov edi, [ebp + 8] ; char *id_string
	cpuid
	; ebx, edx si ecx retin string-ul referitor la manufacturer id;
	; salvam fiecare registru folosind registrul edi
	mov [edi], ebx
	mov [edi + 4], edx
	mov [edi + 8], ecx

	pop edi
	
	popa

	leave
	ret

;; void features(char *vmx, char *rdrand, char *avx)
;
;  checks whether vmx, rdrand and avx are supported by the cpu
;  if a feature is supported, 1 is written in the corresponding variable
;  0 is written otherwise
features:
	enter 	0, 0
	
	pusha

	xor eax, eax
	inc eax ; pentru features --> eax trebuie sa fie 1

	cpuid
	; vmx --> bit 5 din ecx
	shr ecx, 5
	xor edx, edx
	mov edx, [ebp + 8] ; char *vmx

	; vmx se seteaza pe 0 sau 1 in functie de bitul cel mai putin
	; semnificativ al ecx
	test ecx, 1
	jz skipVMX
	
	mov [edx], dword 1
	jmp avxreg

skipVMX:
	mov [edx], dword 0

avxreg:
	; avx --> bit 28 din ecx
	; shifam la dreapta cu 23 ecx deoarece am shiftat deja cu 5 pentru vmx
	shr ecx, 23
	xor edx, edx
	mov edx, [ebp + 16] ; char *avx

	; avx se seteaza pe 0 sau 1 in functie de bitul cel mai putin
	; semnificativ al ecx
	test ecx, 1
	jz skipAVX
	
	mov [edx], dword 1
	jmp rd

skipAVX:
	mov [edx], dword 0

rd:
	; rdrnd --> bit 30 din ecx
	; shifam la dreapta cu 2 ecx deoarece am shiftat deja cu 28 pentru
	; vmx si avx
	shr ecx, 2
	xor edx, edx
	mov edx, [ebp + 12] ; char *rdrand

	; rdrand se seteaza pe 0 sau 1 in functie de bitul cel mai putin
	; semnificativ al ecx
	test ecx, 1
	jz skipRD
	
	mov [edx], dword 1
	jmp end

skipRD:
	mov [edx], dword 0

end:
	popa
	leave
	ret

;; void l2_cache_info(int *line_size, int *cache_size)
;
;  reads from cpuid the cache line size, and total cache size for the current
;  cpu, and stores them in the corresponding parameters
l2_cache_info:
	enter 0, 0
	
	pusha

	xor eax, eax
	mov eax, 80000006h ; L2 cache features --> eax trebuie sa fie 80000006h
	cpuid

	xor edi, edi
	mov edi, [ebp + 8] ; int *line_size
	mov [edi], dword 0

	; detaliile vor fi salvate in ecx
	; cel mai putin semnificativ octet semnifica line_size
	mov byte [edi], cl

	shr ecx, 16 ; ramanem doar cu cei mai semnificativi 16 biti
	xor edi, edi
	mov edi, [ebp + 12] ; int *cache_size
	mov [edi], dword 0
	
	; cei mai semnificativi 2 octeti semnifica cache_size
	mov word [edi], cx

	popa

	leave
	ret
