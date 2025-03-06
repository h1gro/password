.model tiny

.data
;---------------------------------------------------------
        cmd_addr equ 82h

        god_dame_word dw 4Eh, 78h, 69h, 6Ch, 41h, 6Dh, 6Dh, 6Ch
        password      dw 69h, 69h, 69h, 69h, 69h, 69h, 69h, 69h
        another_trash dw 4Eh, 45h, 53h, 4Ch, 40h, 6Dh, 41h, 54h

        WrPasw    db 'Wrong password!$'
        RgPasw    db 'Right password!$'
        PlsWrPasw db 'Please, write your password:$'
        Frame     db '=======================================$'

        hs       dw 35Fh
        hs1      dw 03ADh
        pasw_len dw 8h

        users_pasw dw 10 dup(?)
;--------------------------------------------------------

.code
org 100h

Main    proc

        cld

        mov [users_pasw], 10h

        call EnterPassword

        call next_line

        call HashDefaultPasw

        call HashEnteredPasw

        call HashCmp

        call write_frame

        mov ax, 4c00h
        int 21h

        endp

;---------------------------------------------------------

EnterPassword   proc

        call write_frame

        mov ah, 09h
        mov dx, offset PlsWrPasw
        int 21h

        call next_line

        mov ah, 0Ah
        mov dx, offset users_pasw
        int 21h

        call next_line

        endp
        ret

;-------------------------------------------------------------------------------

;-----------------HASH_CMP-------------------
;HashCmp compares two hash-sums: defaul and users, which
;were made by HashDefaulPasw and HashEnteredPasw
;Entry: dx - users hash, bp - defualt hash
;Exit: none
;Distr: dx, bp, ax
;------------------------------------------

HashCmp proc

        mov bp, hs

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

HashDefaultPasw   proc

        mov cx, pasw_len
        mov di, 0h
        mov bp, 0h

add_ascki1:

        mov ax, [password + di]
        add bp, ax
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
        mov ax, 0h
        mov di, 1h

add_aski2:

        mov ax, [users_pasw + di]
        mov al, 0h
        mov al, ah
        mov ah, 0h
        add dx, ax

        inc di

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

;------------------------------------------------------------------------------

next_line proc

        mov ah, 02h
        mov dl, 0Ah
        int 21h

        endp
        ret

;-------------------------------------------------------------------------------

write_frame proc

        call next_line

        mov ah, 09h
        mov dx, offset Frame
        int 21h

        call next_line

        endp
        ret
;-----------------------------------------------------------

end     Main
