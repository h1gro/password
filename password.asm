.model tiny

.data
;---------------------------------------------------------
        cmd_addr equ 82h

        ;password dw m, a, x, i, m, l, o, h
        password dw 6Dh, 61h, 78h, 69h, 6Dh, 6Ch, 6Fh, 68h

        WrPasw   db 'Wrong password!$'
        RgPasw   db 'Right password!$'

        pasw_len dw 8h
;--------------------------------------------------------

.code
org 100h

Main    proc

        cld

        mov dx, 0h
        mov cx, 8h
        mov di, 0h
        mov si, cmd_addr

        call HashDefaulPasw

        call HashEnteredPasw

        call HashCmp

        ;call CheckPassword

        mov ax, 4c00h
        int 21h

        endp

;---------------------------------------------------------


;-----------------HASH_CMP-------------------
;HashCmp compares two hash-sums: defaul and users, which
;were made by HashDefaulPasw and HashEnteredPasw
;Entry: dx - users hash, bp - defualt hash
;Exit: none
;Distr: dx, bp, ax
;------------------------------------------

HashCmp proc

        cmp dx, bp
        jne Wrong

        mov ah, 09h
        mov dx, offset RgPasw
        int 21h

        endp
        ret

Wrong:
        mov ah, 09h
        mov dx, offset WrPasw
        int 21h

        endp
        ret

;------------------------------------------------------------------


;-------------HASH_DEFAULT_PASW------------
;HashDefaultPasw makes hash sum on default password
;Entry: pasw_len - password length
;Exit: bp - hash sum
;Distr: cx, bp, si, di
;-----------------------------------------

HashDefaulPasw   proc

        mov cx, pasw_len
        mov di, 0h
        mov bp, 0h

add_ascki1:

        add bp, [password + di]
        add di, 2h

        loop add_ascki1

        endp
        ret

;------------------------------------------------------------


;-------------HASH_ENTERED_PASW------------
;HashEnteredPasw makes hash sum on entered password
;Entry: pasw_len - password length
;Exit: dx - hash sum
;Distr: cx, dx, si, ax
;-----------------------------------------

HashEnteredPasw proc

        mov cx, pasw_len
        mov dx, 0h

        mov si, cmd_addr

add_aski2:

        lodsb

        add dx, ax

        loop add_aski2

        endp
        ret

;----------------------------------------------------------


;-------------CHECK_PASSWORD---------------
;CheckPassword compare two stings by bytes
;Entry: password - pointer on default str
;Exit:  none
;Distr: ax, cx, di, bx, dx
;------------------------------------------

CheckPassword   proc

        push cx

        mov cx, [password + di]       ;cx = symbol from const password
        add di, 2h

        lodsb                         ;al = symbol from entered password

        mov bl, al

        push ax
        push dx

        ;mov ah, 02h
        ;mov dl, bl
        ;int 21h

        ;mov ah, 02h
        ;mov dl, cl
        ;int 21h

        pop dx
        pop ax

        cmp al, cl

        pop cx

        jne Wrong_password

        xor ax, ax
        xor bx, bx
        xor dx, dx

        loop CheckPassword

        cmp cx, 0h
        je Password_Right

        Wrong_password:

        mov ah, 09h
        mov dx, offset WrPasw
        int 21h

        ret

        Password_Right:

        mov ah, 09h
        mov dx, offset RgPasw
        int 21h

        ret
        endp

;-----------------------------------------------------------

end     Main
