;SERBOI FLOREA-DAN 325CB
%include "include/io.inc"

extern atoi
extern printf
extern exit
extern free

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
        use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0
section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1
    
    linie_mesaj: resd 1
    cheie:  resd 1
    mesaj:      resb 1000
    
    indice_task3: resd 1
    final_mesaj: resd 1
    
    mesaj_task4: resb 1000
    indice_task4: resd 1

    indice_task5: resd 1
    img_blur: resd 10000000
    
section .text
    
xor_matrice:
    push ebp
    mov ebp, esp
    ;adresa sirului de intregi(imaginea)
    mov esi, dword[ebp + 8]
    ;cheia
    mov edi, dword[ebp + 12]
    ;in ecx tin minte nr liniei, iar in ebx, nr coloanei    
    mov ecx, 0
For_1x:
    mov ebx, 0
For_2x:
        ;calculez indicele elementului curent: 4*dword[width]*ecx + 4*ebx
        ;deoarece rezultatul nu depaseste niciodata 32 de biti,
        ;ne intereseaza doar eax dupa inmultire
        mov eax, dword[img_width]
        mov edx, 4
        mul edx
        mov edx, ecx
        mul edx
        times 4 add eax, ebx
        ;punem in edx elementul
        mov edx, [esi+eax]
        ;facem xor cu cheia
        xor edx, edi
        ;scriem rezultatul
        mov [esi+eax], edx
        ;incrementam indicele coloanei
        inc ebx
        cmp ebx, dword[img_width]
        jne For_2x
    ;incrementam indicele liniei
    inc ecx
    cmp ecx, dword[img_height]
    jne For_1x

    leave
    ret
    
cauta_revient:
    push ebp
    mov ebp, esp
    
    xor eax, eax
    mov esi, dword[ebp + 8]
    
    ;verifica R
    mov edi, [esi]
    cmp edi, 114
    jne termina
    ;verifica E
    mov edi, [esi + 4]
    cmp edi, 101
    jne termina
    ;verifica V
    mov edi, [esi + 8]
    cmp edi, 118
    jne termina
    ;verifica I
    mov edi, [esi + 12]
    cmp edi, 105
    jne termina
    ;verifica E
    mov edi, [esi + 16]
    cmp edi, 101
    jne termina
    ;verifica N
    mov edi, [esi + 20]
    cmp edi, 110
    jne termina
    ;verifica T
    mov edi, [esi + 24]
    cmp edi, 116
    jne termina
    ;daca e ok, tine minte in eax 1, altfel 0
    mov eax, 1
termina:
    leave
    ret

cauta_mesaj:
    push ebp
    mov ebp, esp
    ;adresa sirului de intregi(imaginea)
    mov esi, dword[ebp + 8]
    
    ;in ecx tin minte nr liniei, iar in ebx, nr coloanei    
    mov ecx, 0
For_1m:
    mov ebx, 0
For_2m:
        ;calculez indicele elementului curent: 4*dword[width]*ecx + 4*ebx
        ;deoarece rezultatul nu depaseste niciodata 32 de biti,
        ;ne intereseaza doar eax dupa inmultire
        mov eax, dword[img_width]
        mov edx, 4
        mul edx
        mov edx, ecx
        mul edx
        times 4 add eax, ebx
        ;in esi am adresa elementului
        add esi, eax
        
        push eax
        
        push esi
        call cauta_revient
        add esp, 4
        cmp eax, 1
        jne continua
        ;tin minte linia
        mov [linie_mesaj], ecx
        ;tin minte in esi adresa inceputului de linie
        times 4 sub esi, ebx
        
        xor eax, eax
stochez:
        mov edx, [esi+4*eax]
        mov byte[mesaj + eax], dl
        
        inc eax
        cmp dword[esi+4*eax], 0
        jne stochez
        mov eax, 1
        jmp termina2
continua:
        pop eax
        sub esi, eax
        ;incrementam indicele coloanei
        inc ebx
        mov eax, ebx
        ;verificarea cuvantului revient nu trebuie sa intre
	;intr-o zona de memorie la care nu are acces
        add eax, 6
        cmp eax, dword[img_width]
        jne For_2m
        
    ;incrementam indicele liniei
    inc ecx
    cmp ecx, dword[img_height]
    jne For_1m
    xor eax, eax
termina2:
    leave
    ret
    
bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
    
    mov ebx, 0
verific_chei:
    ;aplic cheia pe matrice
    push ebx
    push dword[ebp+8]
    call xor_matrice
    add esp, 4
    pop ebx
    ;caut mesajul
    push ebx
    push dword[ebp+8]
    call cauta_mesaj
    add esp, 4
    pop ebx
    cmp eax, 1
    ;daca eax e 1 atunc am gasit mesajul
    jz termina_brute
    
    ;refac matricea daca cheia nu e buna
    push ebx
    push dword[ebp+8]
    call xor_matrice
    add esp, 4
    pop ebx
    
    inc ebx
    cmp ebx, 256
    jnz verific_chei

termina_brute:
    mov [cheie], ebx
    leave
    ret    

criptare:
    push ebp
    mov ebp, esp
    
    mov esi, dword[img]
    ;in eax punem indicele primului element de pe linia pe care vrem sa scriem
    mov eax, dword[img_width]
    mov edx, 4
    mul edx
    mov edx, [linie_mesaj]
    inc edx
    mul edx
    ;in esi avem adresa la care trebuie sa scriem
    add esi, eax
    ;scriu mesajul: C'est un proverbe francais.
    mov dword[esi], 67
    add esi, 4
    mov dword[esi], 39
    add esi, 4
    mov dword[esi], 101
    add esi, 4
    mov dword[esi], 115
    add esi, 4
    mov dword[esi], 116
    add esi, 4
    mov dword[esi], 32
    add esi, 4
    mov dword[esi], 117
    add esi, 4
    mov dword[esi], 110
    add esi, 4
    mov dword[esi], 32
    add esi, 4
    mov dword[esi], 112
    add esi, 4
    mov dword[esi], 114
    add esi, 4
    mov dword[esi], 111
    add esi, 4
    mov dword[esi], 118
    add esi, 4
    mov dword[esi], 101
    add esi, 4 
    mov dword[esi], 114
    add esi, 4
    mov dword[esi], 98
    add esi, 4
    mov dword[esi], 101
    add esi, 4
    mov dword[esi], 32
    add esi, 4
    mov dword[esi], 102
    add esi, 4
    mov dword[esi], 114
    add esi, 4
    mov dword[esi], 97
    add esi, 4
    mov dword[esi], 110
    add esi, 4
    mov dword[esi], 99
    add esi, 4
    mov dword[esi], 97
    add esi, 4
    mov dword[esi], 105
    add esi, 4
    mov dword[esi], 115
    add esi, 4
    mov dword[esi], 46
    add esi, 4
    mov dword[esi], 0
    mov eax, [cheie]
    mov ebx, 2
    mul ebx
    add eax, 3
    mov ebx, 5
    div ebx
    sub eax, 4
    ;criptezi cu noua cheie
    push eax
    push dword[img]
    call xor_matrice
    add esp, 4    
    
    leave
    ret
morse_encrypt:
    ;. 46
    ; 32
    ;- 45
    ; | 124
    ; A-Z 65 90
    ; 0-9 48 57
    push ebp
    mov ebp, esp
    ;in esi am adresa imagine
    mov esi, [ebp + 8]
    ;in edi am adresa mesaj
    mov edi, [ebp + 12]
    ;in ecx am indicele 
    mov ecx, [ebp + 16]
    ;in edx pun elementul cu indicele dat ca parametru
    ;mov edx, [esi + 4*ecx]
parcurg_mesaj:
    xor ebx, ebx
    mov bl, byte[edi]
A: 
    cmp bl, 65
    jne B
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
B:  
    cmp bl, 66
    jne C
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1    
    jmp final
C:
    cmp bl, 67
    jne D
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final    
D:
    cmp bl, 68
    jne E
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
E:
    cmp bl, 69
    jne F    
    mov dword[esi + 4*ecx], 46
    add ecx, 1
F:
    cmp bl, 70
    jne G    
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
G:
    cmp bl, 71
    jne H    
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1       
    jmp final
H:
    cmp bl, 72
    jne I    
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
I:
    cmp bl, 73
    jne J   
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
J:
    cmp bl, 74
    jne K    
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
K:
    cmp bl, 75
    jne L   
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
L:
    cmp bl, 76
    jne M   
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
M:
    cmp bl, 77
    jne N
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
N:
    cmp bl, 78
    jne O
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
O:
    cmp bl, 79
    jne P   
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
P:
    cmp bl, 80
    jne Q   
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
Q:
    cmp bl, 81
    jne R   
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
R:
    cmp bl, 82
    jne S
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
S:
    cmp bl, 83
    jne T
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
T:
    cmp bl, 84
    jne U
    mov dword[esi + 4*ecx], 45
    add ecx, 1    
    jmp final
U:
    cmp bl, 85
    jne V
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
V:
    cmp bl, 86
    jne W
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final 
W:
    cmp bl, 87
    jne X
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
X:
    cmp bl, 88
    jne Y
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final      
Y:
    cmp bl, 89
    jne Z
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
Z:
    cmp bl, 90
    jne Morse0
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
Morse0:
    cmp bl, 48 
    jne Morse1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
Morse1:
    cmp bl, 49
    jne Morse2
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final    
Morse2:
    cmp bl, 50 
    jne Morse3
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
Morse3:
    cmp bl, 51
    jne Morse4
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
Morse4:
    cmp bl, 52
    jne Morse5
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
Morse5:
    cmp bl, 53
    jne Morse6
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
Morse6:
    cmp bl, 54
    jne Morse7
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
Morse7:
    cmp bl, 55
    jne Morse8
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
Morse8:
    cmp bl, 56
    jne Morse9
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
Morse9:
    cmp bl, 57
    jne virgula
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    jmp final
virgula:
    cmp bl, 44
    jne spatiu
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 46
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    mov dword[esi + 4*ecx], 45
    add ecx, 1
    jmp final
spatiu:
    cmp bl, 32
    jne final
    mov dword[esi + 4*ecx], 124
    add ecx, 1
final:

    inc edi
    cmp edi, [final_mesaj]
    je termina_morse
    ;pun spatiu dupa fiecare caracter
    mov dword[esi + 4*ecx], 32
    add ecx, 1    
    jmp parcurg_mesaj

termina_morse:
    ;pun null
    mov dword[esi + 4*ecx], 0
    leave
    ret

lsb_encode:
    push ebp
    mov ebp, esp
    ;in esi am adresa imagine
    mov esi, dword[ebp + 8]
    ;in edi am adresa mesaj
    mov edi, dword[ebp + 12]
    ;in ecx am indicele 
    mov ecx, dword[ebp + 16]
    dec ecx
    ;in edx pun elementul cu indicele dat ca parametru
    ;mov edx, [esi + 4*ecx]
parcurg_mesaj_4:
    xor ebx, ebx
    mov bl, byte[edi]
    ;trebuie parcurs fiecare bit din caracterul mesajului
    ;si scris in intregul imaginii
    mov eax, 8; nr-ul de biti
parcurgere_biti:
    dec eax
    push ebx
    push ecx
    mov ecx, eax
    cmp ecx, 0
    shr ebx, cl
    pop ecx

    mov dl, bl
    or bl, 1

    cmp dl, bl
    je scrie_1

    xor edx, edx
    mov edx, 1
    not edx

    and edx, [esi + 4*ecx]
    mov [esi + 4*ecx], edx
    jmp dupa_scriere 
scrie_1:
    mov edx, [esi + 4*ecx]
    or edx, 1
    mov [esi + 4*ecx], edx

dupa_scriere:
    pop ebx
    inc ecx
    cmp eax, 0
    jne parcurgere_biti
    inc edi
    cmp edi, [mesaj_task4]
    je termina_lsb_encode   
    jmp parcurg_mesaj_4
termina_lsb_encode:
    mov eax, 8
null:
    xor edx, edx
    mov edx, 1
    not edx
    and edx, [esi + 4*ecx]
    mov [esi + 4*ecx], edx
    inc ecx
    dec eax
    cmp eax, 0
    jne null
    
    leave
    ret

lsb_decode:
    push ebp
    mov ebp, esp
    ;in esi am adresa imagine
    mov esi, dword[ebp + 8]
    ;in ecx am indicele 
    mov ecx, dword[ebp + 12]
    dec ecx
decodez_mes:
    xor ebx, ebx
    mov eax, 8
compun_caracter:
    ;in edi pun elementul cu indicele dat ca parametru
    mov edi, [esi + 4*ecx]
    inc ecx
    ;verific daca are primul bit 1/0 si introduc bitul in bl
    mov edx, edi
    or edx, 1
    cmp edi, edx
    jne lsb_zero
    shl bl, 1
    inc bl
    jmp fara_zero
lsb_zero:
    shl bl, 1
fara_zero:
    dec eax
    cmp eax, 0
    jne compun_caracter
    cmp bl, 0
    je fara_null
    PRINT_CHAR bl
fara_null:
    cmp bl, 0
    jne decodez_mes
    
    leave
    ret

blur:
    push ebp
    mov ebp, esp
    ;adresa sirului de intregi(imaginea)
    mov esi, dword[ebp + 8]

    ;in ecx tin minte nr liniei, iar in ebx, nr coloanei    
    mov ecx, 0
For_linie:
    mov ebx, 0
For_coloana:
        ;calculez indicele elementului curent: 4*dword[width]*ecx + 4*ebx
        ;deoarece rezultatul nu depaseste niciodata 32 de biti,
        ;ne intereseaza doar eax dupa inmultire
        cmp ecx, 0
        je copiere_margini
        
        mov edx, [img_height]
        dec edx
        cmp ecx, edx
        je copiere_margini
        
        cmp ebx, 0
        je copiere_margini
        
        mov edx, [img_width]
        dec edx
        cmp ebx, edx
        je copiere_margini
        
        
        
prelucrare:
        ;in edi voi retine suma celor 5 elemente
        xor edi, edi
        ;calculez elementul de deasupra 4*dword[width]*(ecx-1) + 4*ebx
        mov eax, dword[img_width]
        mov edx, 4
        mul edx
        mov edx, ecx
        dec edx
        mul edx
        times 4 add eax, ebx
        add edi, [esi + eax]


        ;calculez elementul de dedesubt 4*dword[width]*(ecx+1) + 4*ebx
        mov eax, dword[img_width]
        mov edx, 4
        mul edx
        mov edx, ecx
        inc edx
        mul edx
        times 4 add eax, ebx
        add edi, [esi + eax]

        ;calculez elementul din stanga 4*dword[width]*ecx + 4*(ebx-1)
        mov eax, dword[img_width]
        mov edx, 4
        mul edx
        mov edx, ecx
        mul edx
        dec ebx
        times 4 add eax, ebx
        inc ebx
        add edi, [esi + eax]


        ;calculez elementul din dreapta 4*dword[width]*ecx + 4*(ebx+1)
        mov eax, dword[img_width]
        mov edx, 4
        mul edx
        mov edx, ecx
        mul edx
        inc ebx
        times 4 add eax, ebx
        dec ebx
        add edi, [esi + eax]

        ;calculez elementul curent
        mov eax, dword[img_width]
        mov edx, 4
        mul edx
        mov edx, ecx
        mul edx
        times 4 add eax, ebx
        add edi, [esi + eax]
        
        ;efectuez impartirea
        push eax
        mov eax, edi
        push ebx
        mov ebx, 5
        div ebx
        pop ebx
        mov edi, eax
        pop eax
        
        ;retin rezultatul
        mov [img_blur+eax], edi
        
        jmp dupa_prelucrare
        
copiere_margini:
        mov eax, dword[img_width]
        mov edx, 4
        mul edx
        mov edx, ecx
        mul edx
        times 4 add eax, ebx
        mov edi, [esi + eax]
        mov [img_blur+eax], edi
                        
dupa_prelucrare:
        ;incrementam indicele coloanei
        inc ebx
        cmp ebx, dword[img_width]
        jne For_coloana
    ;incrementam indicele liniei
    inc ecx
    cmp ecx, dword[img_height]
    jne For_linie

    leave
    ret
    
global main
main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param
    
    push use_str
    call printf
    add esp, 4
    
    push -1
    call exit
    
not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:

    push dword[img]; pun pe stiva adresa de unde incepe sirul de integi
    call bruteforce_singlebyte_xor
    add esp, 4    
    
    PRINT_STRING mesaj
    NEWLINE
    PRINT_DEC 4, cheie  
    NEWLINE
    PRINT_DEC 4, linie_mesaj
    NEWLINE

    jmp done
solve_task2:
    
    push dword[img]; pun pe stiva adresa de unde incepe sirul de integi
    call bruteforce_singlebyte_xor
    add esp, 4    
    call criptare
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
        
    jmp done
solve_task3:

    mov eax, [ebp + 12]
    ;adresa indice
    push DWORD[eax + 16]
    call atoi
    pop ebx
    sub ebx, 1
    mov [final_mesaj], ebx
    mov [indice_task3], eax

    mov eax, [ebp + 12]
    ;adresa mesajului
    mov ebx, DWORD[eax + 12]
    push dword[indice_task3]
    push ebx
    push dword[img]
    call morse_encrypt
    add esp, 12
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    
    jmp done
solve_task4:
    ; TODO Task4
    mov eax, [ebp + 12]
    ;adresa indice
    push DWORD[eax + 16]
    call atoi
    pop ebx
    sub ebx, 1
    mov [mesaj_task4], ebx
    mov [indice_task4], eax

    mov eax, [ebp + 12]
    ;adresa mesajului
    mov ebx, DWORD[eax + 12]
    push dword[indice_task4]
    push ebx
    push dword[img]
    call lsb_encode
    add esp, 12
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    
    jmp done
solve_task5:

    mov eax, [ebp + 12]
    ;adresa indice
    push DWORD[eax + 12]
    call atoi
    add esp, 4
    mov [indice_task5], eax

    push dword[indice_task5]
    push dword[img]
    call lsb_decode
    add esp, 8
    
    jmp done
solve_task6:

    push dword[img]
    call blur
    add esp, 4

    push dword[img_height]
    push dword[img_width]
    push img_blur
    call print_image    
    
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4


    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    