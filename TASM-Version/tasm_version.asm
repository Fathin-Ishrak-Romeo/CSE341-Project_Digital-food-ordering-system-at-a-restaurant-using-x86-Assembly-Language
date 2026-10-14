.MODEL SMALL
.STACK 100H

NUM_ITEMS   EQU 18
NAME_W      EQU 22

.DATA
; ---------------- Product tables ----------------
Prices      DW 80,150,100,250,180,160,400,320,450,90,60,110,120,60,90,250,380,950
Quantities  DB NUM_ITEMS DUP(0)

N00 DB 'Egg Omelette$'
N01 DB 'Pancake Stack$'
N02 DB 'Aloo Paratha$'
N03 DB 'Chicken Biryani$'
N04 DB 'Veg Thali$'
N05 DB 'Paneer Wrap$'
N06 DB 'Grilled Chicken$'
N07 DB 'Butter Naan Curry$'
N08 DB 'Fish Fry$'
N09 DB 'French Fries$'
N10 DB 'Veg Samosa Plate$'
N11 DB 'Club Sandwich$'
N12 DB 'Cold Coffee$'
N13 DB 'Fresh Lime Soda$'
N14 DB 'Mango Lassi$'
N15 DB 'Breakfast Combo$'
N16 DB 'Lunch Combo$'
N17 DB 'Family Dinner Combo$'

ItemNames DW OFFSET N00, OFFSET N01, OFFSET N02, OFFSET N03, OFFSET N04, OFFSET N05
          DW OFFSET N06, OFFSET N07, OFFSET N08, OFFSET N09, OFFSET N10, OFFSET N11
          DW OFFSET N12, OFFSET N13, OFFSET N14, OFFSET N15, OFFSET N16, OFFSET N17

C0 DB 13,10,'--- BREAKFAST ---',13,10,'$'
C1 DB 13,10,'--- LUNCH ---',13,10,'$'
C2 DB 13,10,'--- DINNER ---',13,10,'$'
C3 DB 13,10,'--- SNACKS ---',13,10,'$'
C4 DB 13,10,'--- DRINKS ---',13,10,'$'
C5 DB 13,10,'--- SPECIAL COMBOS (discounted) ---',13,10,'$'
CatNames DW OFFSET C0, OFFSET C1, OFFSET C2, OFFSET C3, OFFSET C4, OFFSET C5

; ---------------- Input buffer / variables ----------------
InBuf   DB 6,0,7 DUP(0)
CurCat  DB 0
SubRLo  DW 0
SubRHi  DW 0
SubPLo  DW 0
SubPHi  DW 0
DiscLo  DW 0
DiscHi  DW 0
AftLo   DW 0
AftHi   DW 0
GstLo   DW 0
GstHi   DW 0

; ---------------- Messages ----------------
MenuTxt DB 13,10,'=========================================',13,10
        DB '        RESTAURANT FOOD ORDERING',13,10
        DB '=========================================',13,10
        DB ' 1. Breakfast',13,10
        DB ' 2. Lunch',13,10
        DB ' 3. Dinner',13,10
        DB ' 4. Snacks',13,10
        DB ' 5. Drinks',13,10
        DB ' 6. Special Combos',13,10
        DB ' 7. View Bill',13,10
        DB ' 8. Update/Remove Item',13,10
        DB ' 9. New Customer',13,10
        DB ' 0. Exit',13,10,'$'
MsgChoice   DB 'Enter choice (0-9): $'
MsgInvalid  DB 'Invalid input! Please try again.',13,10,'$'
MsgParen    DB ') $'
MsgRs       DB ' Rs. $'
MsgBack     DB '  0) Back to main menu',13,10,'$'
MsgSelItem  DB 'Select item (0-3): $'
MsgQty      DB 'Enter quantity (1-99): $'
MsgAdded    DB 'Item added to cart.',13,10,'$'
MsgOver     DB 'Limit of 99 per item exceeded. Item not added.',13,10,'$'
MsgEmpty    DB 13,10,'Your cart is empty.',13,10,'$'
MsgBillHdr  DB 13,10,'================ ITEMIZED BILL ================',13,10
            DB 'Item                  Qty',9,'Price',9,'Subtotal',13,10
            DB '-----------------------------------------------',13,10,'$'
MsgLine     DB '-----------------------------------------------',13,10,'$'
MsgSub      DB 'Subtotal          : Rs. $'
MsgDisc     DB 'Discount (10%)    : -Rs. $'
MsgNoDisc   DB 'Discount          : Not applicable (below Rs. 1000)',13,10,'$'
MsgAft      DB 'After discount    : Rs. $'
MsgGst      DB 'GST (5%)          : Rs. $'
MsgTotal    DB 'GRAND TOTAL       : Rs. $'
MsgUpdHdr   DB 13,10,'Items in cart:',13,10,'$'
MsgX        DB ' x $'
MsgUpdSel   DB 'Enter item number to update (1-18): $'
MsgNotIn    DB 'That item is not in your cart.',13,10,'$'
MsgNewQty   DB 'New quantity (0 = remove, 1-99): $'
MsgUpdated  DB 'Quantity updated.',13,10,'$'
MsgRemoved  DB 'Item removed from cart.',13,10,'$'
MsgNewCust  DB 'Clear cart for a new customer? (Y/N): $'
MsgCleared  DB 'Cart cleared. Ready for new customer.',13,10,'$'
MsgKept     DB 'Cart kept. No changes made.',13,10,'$'
MsgBye      DB 13,10,'Thank you for visiting! Goodbye.',13,10,'$'

.CODE
; =====================================================
MAIN PROC
    mov ax,@data
    mov ds,ax
    mov es,ax
ml_top:
    mov dx,OFFSET MenuTxt
    call PrintStr
    mov dx,OFFSET MsgChoice
    call PrintStr
    call ReadNumber
    jnc ml_num
    jmp ml_bad
ml_num:
    cmp ax,9
    jbe ml_rng
    jmp ml_bad
ml_rng:
    cmp al,0
    jne ml_c1
    jmp ml_exit
ml_c1:
    cmp al,6
    ja ml_c7
    dec al
    mov bl,al
    call CategoryMenu
    jmp ml_top
ml_c7:
    cmp al,7
    jne ml_c8
    call ShowBill
    jmp ml_top
ml_c8:
    cmp al,8
    jne ml_c9
    call UpdateItem
    jmp ml_top
ml_c9:
    call NewCustomer
    jmp ml_top
ml_bad:
    mov dx,OFFSET MsgInvalid
    call PrintStr
    jmp ml_top
ml_exit:
    mov dx,OFFSET MsgBye
    call PrintStr
    mov ax,4C00h
    int 21h
MAIN ENDP

; ---------------- Basic output ----------------
PutChar PROC            ; DL = char
    push ax
    mov ah,2
    int 21h
    pop ax
    ret
PutChar ENDP

PrintStr PROC           ; DX = offset of '$' string
    push ax
    mov ah,9
    int 21h
    pop ax
    ret
PrintStr ENDP

NewLine PROC
    push dx
    mov dl,13
    call PutChar
    mov dl,10
    call PutChar
    pop dx
    ret
NewLine ENDP

; ---------------- 32-bit helpers ----------------
Mul32x16 PROC           ; DX:AX = DX:AX * BX (result fits 32 bits)
    push cx
    mov cx,ax
    mov ax,dx
    mul bx
    xchg ax,cx          ; AX=orig low, CX=high*bx low word
    mul bx
    add dx,cx
    pop cx
    ret
Mul32x16 ENDP

Div32by16 PROC          ; DX:AX / BX -> DX:AX quotient, CX remainder
    mov cx,ax
    mov ax,dx
    xor dx,dx
    div bx
    push ax             ; high quotient
    mov ax,cx
    div bx
    mov cx,dx           ; remainder
    pop dx
    ret
Div32by16 ENDP

PrintU32 PROC           ; print unsigned DX:AX in decimal
    push ax
    push bx
    push cx
    push dx
    push si
    xor si,si
    mov bx,10
pu_div:
    call Div32by16
    push cx
    inc si
    mov cx,ax
    or cx,dx
    jnz pu_div
pu_out:
    pop dx
    add dl,'0'
    call PutChar
    dec si
    jnz pu_out
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintU32 ENDP

PrintPaise PROC         ; DX:AX = paise, prints R.PP
    push ax
    push bx
    push cx
    push dx
    mov bx,100
    call Div32by16      ; DX:AX rupees, CX paise
    call PrintU32
    mov dl,'.'
    call PutChar
    mov ax,cx
    mov bl,10
    div bl              ; AL tens, AH ones
    mov cx,ax
    mov dl,cl
    add dl,'0'
    call PutChar
    mov dl,ch
    add dl,'0'
    call PutChar
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintPaise ENDP

PrintName PROC          ; BX = item index, prints name padded to NAME_W
    push ax
    push bx
    push cx
    push dx
    push si
    shl bx,1
    mov si,ItemNames[bx]
    xor cx,cx
pn_l:
    mov al,[si]
    cmp al,'$'
    je pn_pad
    mov dl,al
    call PutChar
    inc si
    inc cx
    jmp pn_l
pn_pad:
    cmp cx,NAME_W
    jae pn_done
    mov dl,' '
    call PutChar
    inc cx
    jmp pn_pad
pn_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintName ENDP

; ---------------- Input ----------------
ReadNumber PROC         ; returns AX=value (1-2 digits), CF=1 if invalid
    push bx
    push cx
    push dx
    push si
    mov dx,OFFSET InBuf
    mov ah,0Ah
    int 21h
    call NewLine
    xor ch,ch
    mov cl,InBuf+1
    cmp cl,1
    jb rn_bad
    cmp cl,2
    ja rn_bad
    xor ax,ax
    mov si,OFFSET InBuf+2
rn_loop:
    mov bl,[si]
    cmp bl,'0'
    jb rn_bad
    cmp bl,'9'
    ja rn_bad
    sub bl,'0'
    xor bh,bh
    mov dx,10
    mul dx
    add ax,bx
    inc si
    loop rn_loop
    clc
    jmp rn_done
rn_bad:
    xor ax,ax
    stc
rn_done:
    pop si
    pop dx
    pop cx
    pop bx
    ret
ReadNumber ENDP

ReadYN PROC             ; AL=1 yes, AL=0 no, CF=1 invalid
    push bx
    push dx
    mov dx,OFFSET InBuf
    mov ah,0Ah
    int 21h
    call NewLine
    cmp byte ptr InBuf+1,1
    jne ry_bad
    mov al,InBuf+2
    cmp al,'Y'
    je ry_yes
    cmp al,'y'
    je ry_yes
    cmp al,'N'
    je ry_no
    cmp al,'n'
    je ry_no
ry_bad:
    stc
    jmp ry_done
ry_yes:
    mov al,1
    clc
    jmp ry_done
ry_no:
    mov al,0
    clc
ry_done:
    pop dx
    pop bx
    ret
ReadYN ENDP

; ---------------- Cart logic ----------------
AddToCart PROC          ; BX=item, AX=qty ; CF=1 if rejected (>99)
    push dx
    mov dl,Quantities[bx]
    xor dh,dh
    add dx,ax
    cmp dx,99
    ja ac_rej
    mov Quantities[bx],dl
    clc
    jmp ac_done
ac_rej:
    stc
ac_done:
    pop dx
    ret
AddToCart ENDP

CountItems PROC         ; AX = number of distinct items in cart
    push bx
    push cx
    xor ax,ax
    xor bx,bx
ci_loop:
    mov cl,Quantities[bx]
    or cl,cl
    jz ci_next
    inc ax
ci_next:
    inc bx
    cmp bx,NUM_ITEMS
    jb ci_loop
    pop cx
    pop bx
    ret
CountItems ENDP

CalcSubtotal PROC       ; DX:AX = subtotal in rupees (fresh from cart)
    push bx
    push cx
    push si
    push di
    xor di,di
    xor cx,cx
    xor bx,bx
cs_loop:
    mov al,Quantities[bx]
    xor ah,ah
    mov si,bx
    shl si,1
    mul word ptr Prices[si]
    add di,ax
    adc cx,dx
    inc bx
    cmp bx,NUM_ITEMS
    jb cs_loop
    mov ax,di
    mov dx,cx
    pop di
    pop si
    pop cx
    pop bx
    ret
CalcSubtotal ENDP

; ---------------- Category menu ----------------
CategoryMenu PROC       ; BL = category 0-5
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov CurCat,bl
    xor bh,bh
    shl bx,1
    mov dx,CatNames[bx]
    call PrintStr
    mov al,CurCat
    mov bl,3
    mul bl
    mov di,ax           ; base item index
    mov si,1            ; display number
cm_list:
    mov dl,' '
    call PutChar
    call PutChar
    mov ax,si
    xor dx,dx
    call PrintU32
    mov dx,OFFSET MsgParen
    call PrintStr
    mov bx,di
    call PrintName
    mov dx,OFFSET MsgRs
    call PrintStr
    mov bx,di
    shl bx,1
    mov ax,Prices[bx]
    xor dx,dx
    call PrintU32
    call NewLine
    inc di
    inc si
    cmp si,4
    jae cm_listdone
    jmp cm_list
cm_listdone:
    mov dx,OFFSET MsgBack
    call PrintStr
    mov dx,OFFSET MsgSelItem
    call PrintStr
    call ReadNumber
    jnc cm_num
    jmp cm_invalid
cm_num:
    cmp ax,3
    jbe cm_rng
    jmp cm_invalid
cm_rng:
    or ax,ax
    jnz cm_item
    jmp cm_done
cm_item:
    mov bx,ax
    add bx,di
    sub bx,4            ; item index = base + choice - 1
    mov si,bx
    mov dx,OFFSET MsgQty
    call PrintStr
    call ReadNumber
    jnc cm_q1
    jmp cm_invalid
cm_q1:
    cmp ax,1
    jae cm_q2
    jmp cm_invalid
cm_q2:
    cmp ax,99
    jbe cm_q3
    jmp cm_invalid
cm_q3:
    mov bx,si
    call AddToCart
    jnc cm_ok
    mov dx,OFFSET MsgOver
    call PrintStr
    jmp cm_done
cm_ok:
    mov dx,OFFSET MsgAdded
    call PrintStr
    jmp cm_done
cm_invalid:
    mov dx,OFFSET MsgInvalid
    call PrintStr
cm_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
CategoryMenu ENDP

; ---------------- Bill ----------------
ShowBill PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    call CountItems
    or ax,ax
    jnz sb_has
    mov dx,OFFSET MsgEmpty
    call PrintStr
    jmp sb_done
sb_has:
    mov dx,OFFSET MsgBillHdr
    call PrintStr
    xor bx,bx
sb_loop:
    mov al,Quantities[bx]
    or al,al
    jnz sb_print
    jmp sb_next
sb_print:
    call PrintName
    mov dl,9
    call PutChar
    mov al,Quantities[bx]
    xor ah,ah
    xor dx,dx
    call PrintU32
    mov dl,9
    call PutChar
    mov si,bx
    shl si,1
    mov ax,Prices[si]
    xor dx,dx
    call PrintU32
    mov dl,9
    call PutChar
    mov al,Quantities[bx]
    xor ah,ah
    mul word ptr Prices[si]
    call PrintU32
    call NewLine
sb_next:
    inc bx
    cmp bx,NUM_ITEMS
    jae sb_totals
    jmp sb_loop
sb_totals:
    mov dx,OFFSET MsgLine
    call PrintStr
    call CalcSubtotal
    mov SubRLo,ax
    mov SubRHi,dx
    mov bx,100
    call Mul32x16
    mov SubPLo,ax
    mov SubPHi,dx
    mov dx,OFFSET MsgSub
    call PrintStr
    mov ax,SubPLo
    mov dx,SubPHi
    call PrintPaise
    call NewLine
    ; discount: 10% of rupees = rupees*10 paise
    mov DiscLo,0
    mov DiscHi,0
    mov ax,SubRLo
    mov dx,SubRHi
    or dx,dx
    jnz sb_disc
    cmp ax,1000
    jae sb_disc
    jmp sb_nodisc
sb_disc:
    mov bx,10
    call Mul32x16
    mov DiscLo,ax
    mov DiscHi,dx
    mov dx,OFFSET MsgDisc
    call PrintStr
    mov ax,DiscLo
    mov dx,DiscHi
    call PrintPaise
    call NewLine
    jmp sb_after
sb_nodisc:
    mov dx,OFFSET MsgNoDisc
    call PrintStr
sb_after:
    mov ax,SubPLo
    mov dx,SubPHi
    sub ax,DiscLo
    sbb dx,DiscHi
    mov AftLo,ax
    mov AftHi,dx
    mov dx,OFFSET MsgAft
    call PrintStr
    mov ax,AftLo
    mov dx,AftHi
    call PrintPaise
    call NewLine
    ; GST 5% on discounted amount
    mov ax,AftLo
    mov dx,AftHi
    mov bx,5
    call Mul32x16
    mov bx,100
    call Div32by16
    mov GstLo,ax
    mov GstHi,dx
    mov dx,OFFSET MsgGst
    call PrintStr
    mov ax,GstLo
    mov dx,GstHi
    call PrintPaise
    call NewLine
    mov ax,AftLo
    mov dx,AftHi
    add ax,GstLo
    adc dx,GstHi
    push ax
    push dx
    mov dx,OFFSET MsgLine
    call PrintStr
    mov dx,OFFSET MsgTotal
    call PrintStr
    pop dx
    pop ax
    call PrintPaise
    call NewLine
sb_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ShowBill ENDP

; ---------------- Update / Remove ----------------
ShowCartList PROC
    push ax
    push bx
    push dx
    mov dx,OFFSET MsgUpdHdr
    call PrintStr
    xor bx,bx
sl_loop:
    mov al,Quantities[bx]
    or al,al
    jnz sl_show
    jmp sl_next
sl_show:
    mov ax,bx
    inc ax
    cmp ax,10
    jae sl_nopad
    mov dl,' '
    call PutChar
sl_nopad:
    xor dx,dx
    call PrintU32
    mov dx,OFFSET MsgParen
    call PrintStr
    call PrintName
    mov dx,OFFSET MsgX
    call PrintStr
    mov al,Quantities[bx]
    xor ah,ah
    xor dx,dx
    call PrintU32
    call NewLine
sl_next:
    inc bx
    cmp bx,NUM_ITEMS
    jae sl_done
    jmp sl_loop
sl_done:
    pop dx
    pop bx
    pop ax
    ret
ShowCartList ENDP

UpdateItem PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    call CountItems
    or ax,ax
    jnz ui_has
    mov dx,OFFSET MsgEmpty
    call PrintStr
    jmp ui_done
ui_has:
    call ShowCartList
    mov dx,OFFSET MsgUpdSel
    call PrintStr
    call ReadNumber
    jnc ui_n1
    jmp ui_bad
ui_n1:
    cmp ax,1
    jae ui_n2
    jmp ui_bad
ui_n2:
    cmp ax,NUM_ITEMS
    jbe ui_n3
    jmp ui_bad
ui_n3:
    dec ax
    mov di,ax
    mov al,Quantities[di]
    or al,al
    jnz ui_in
    mov dx,OFFSET MsgNotIn
    call PrintStr
    jmp ui_done
ui_in:
    mov dx,OFFSET MsgNewQty
    call PrintStr
    call ReadNumber
    jnc ui_q1
    jmp ui_bad
ui_q1:
    cmp ax,99
    jbe ui_q2
    jmp ui_bad
ui_q2:
    mov Quantities[di],al
    or al,al
    jnz ui_upd
    mov dx,OFFSET MsgRemoved
    call PrintStr
    jmp ui_done
ui_upd:
    mov dx,OFFSET MsgUpdated
    call PrintStr
    jmp ui_done
ui_bad:
    mov dx,OFFSET MsgInvalid
    call PrintStr
ui_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
UpdateItem ENDP

; ---------------- New customer ----------------
NewCustomer PROC
    push ax
    push bx
    push dx
    mov dx,OFFSET MsgNewCust
    call PrintStr
    call ReadYN
    jnc nc_valid
    mov dx,OFFSET MsgInvalid
    call PrintStr
    jmp nc_done
nc_valid:
    or al,al
    jnz nc_clear
    mov dx,OFFSET MsgKept
    call PrintStr
    jmp nc_done
nc_clear:
    xor bx,bx
nc_clr:
    mov Quantities[bx],0
    inc bx
    cmp bx,NUM_ITEMS
    jb nc_clr
    mov dx,OFFSET MsgCleared
    call PrintStr
nc_done:
    pop dx
    pop bx
    pop ax
    ret
NewCustomer ENDP

END MAIN
