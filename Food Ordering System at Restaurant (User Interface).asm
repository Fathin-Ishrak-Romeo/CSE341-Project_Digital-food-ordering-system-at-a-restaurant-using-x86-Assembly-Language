.model small
.stack 100h
.data
    ; Messages
    welcome_msg     db '===============================', 10, 13
                   db '   Welcome to Our Restaurant!', 10, 13
                   db '===============================', 10, 13, '$'
    categories_msg  db 10, 13, '=== Categories ===', 10, 13, '$'
    select_cat_msg  db 10, 13, 'Select a category: $'
    menu_title_msg  db 10, 13, '=== Menu Items ===', 10, 13, '$'
    select_food_msg db 10, 13, 10, 13, 'Select a food item: $'
    quantity_msg    db 10, 13, 'Enter quantity (1-9): $'
    total_msg       db 10, 13, 10, 13, 'Total price: BDT $'
    invalid_msg     db 10, 13, 'Invalid input! Press any key to continue...', 10, 13, '$'
    bill_msg        db 10, 13, '=== Your Bill ===', 10, 13, '$'
    options_msg     db 10, 13, 10, 13, '1. Main Menu', 10, 13, '2. Previous Menu', 10, 13, '3. Show Bill', 10, 13, 10, 13, 'Select option: $'
    final_msg       db 10, 13, 10, 13, '1. Main Menu', 10, 13, '2. Exit', 10, 13, 10, 13, 'Select option: $'
    newline         db 10, 13, '$'
    space           db ' $'
    
    ; Categories
    cat1 db '1. Breakfast$'
    cat2 db 10, 13, '2. Lunch$'
    cat3 db 10, 13, '3. Dinner$'
    cat4 db 10, 13, '4. Snacks$'
    cat5 db 10, 13, '5. Drinks$'
    cat6 db 10, 13, 10, 13, '6. Exit$'
    
    ; Breakfast Menu (8 items)
    b_menu1 db '1. Porota           - BDT 10$'
    b_menu2 db 10, 13, '2. Ruti             - BDT 10$'
    b_menu3 db 10, 13, '3. Naan             - BDT 20$'
    b_menu4 db 10, 13, '4. Daal             - BDT 20$'
    b_menu5 db 10, 13, '5. Egg              - BDT 25$'
    b_menu6 db 10, 13, '6. Mixed Vegetables - BDT 20$'
    b_menu7 db 10, 13, '7. Halwa            - BDT 30$'
    b_menu8 db 10, 13, '8. Milk Tea         - BDT 15$'
    b_price dw 10, 10, 20, 20, 25, 20, 30, 15
    
    ; Lunch Menu (8 items)
    l_menu1 db '1. Kacchi Biryani   - BDT 180$'
    l_menu2 db 10, 13, '2. Tehari           - BDT 100$'
    l_menu3 db 10, 13, '3. Beef Polao       - BDT 150$'
    l_menu4 db 10, 13, '4. Chicken Polao    - BDT 130$'
    l_menu5 db 10, 13, '5. Beef Khichuri    - BDT 150$'
    l_menu6 db 10, 13, '6. Egg Polao        - BDT 60$'
    l_menu7 db 10, 13, '7. Chatni           - BDT 20$'
    l_menu8 db 10, 13, '8. Jali Kabab       - BDT 40$'
    l_price dw 180, 100, 150, 130, 150, 60, 20, 40
    
    ; Dinner Menu (8 items)
    d_menu1 db '1. Plain Rice       - BDT 30$'
    d_menu2 db 10, 13, '2. Fish Curry       - BDT 130$'
    d_menu3 db 10, 13, '3. Beef Curry       - BDT 170$'
    d_menu4 db 10, 13, '4. Chicken Curry    - BDT 150$'
    d_menu5 db 10, 13, '5. Mixed Vegetable  - BDT 30$'
    d_menu6 db 10, 13, '6. Daal             - BDT 30$'
    d_menu7 db 10, 13, '7. Chicken Liver    - BDT 100$'
    d_menu8 db 10, 13, '8. Beef Liver       - BDT 120$'
    d_price dw 30, 130, 170, 150, 30, 30, 100, 120
    
    ; Snacks Menu (8 items)
    s_menu1 db '1. Singara         - BDT 10$'
    s_menu2 db 10, 13, '2. Samosa          - BDT 10$'
    s_menu3 db 10, 13, '3. Chicken Roll    - BDT 35$'
    s_menu4 db 10, 13, '4. Vegetable Roll  - BDT 20$'
    s_menu5 db 10, 13, '5. Shawarma        - BDT 60$'
    s_menu6 db 10, 13, '6. Chicken Burger  - BDT 130$'
    s_menu7 db 10, 13, '7. French Fries    - BDT 90$'
    s_menu8 db 10, 13, '8. Chicken Fry     - BDT 100$'
    s_price dw 10, 10, 35, 20, 60, 130, 90, 100

    ; Drinks Menu (8 items)
    dr_menu1 db '1. Mineral Water   - BDT 15$'
    dr_menu2 db 10, 13, '2. Coca Cola       - BDT 20$'
    dr_menu3 db 10, 13, '3. Pepsi           - BDT 20$'
    dr_menu4 db 10, 13, '4. Lemonade        - BDT 30$'
    dr_menu5 db 10, 13, '5. Orange Juice    - BDT 50$'
    dr_menu6 db 10, 13, '6. Apple Juice     - BDT 70$'
    dr_menu7 db 10, 13, '7. Milk Shake      - BDT 100$'
    dr_menu8 db 10, 13, '8. Lacchi          - BDT 90$'
    dr_price dw 15, 20, 20, 30, 50, 70, 100, 90
    
    total_price dw 0
    current_price dw ?
    current_quant db ?
    current_category db ? ; New variable to store current category

; Print macro for strings
print macro msg
    push ax
    push dx
    lea dx, msg
    mov ah, 09h
    int 21h
    pop dx
    pop ax
endm

.code
main proc
    mov ax, @data
    mov ds, ax
    
start:
    call clear_screen
    print welcome_msg
    
show_menu:
    print categories_msg
    print cat1
    print cat2
    print cat3
    print cat4
    print cat5
    print cat6
    print select_cat_msg
    print space
    
    ; Get category input
    mov ah, 01h
    int 21h
    
    ; Store the category selection
    mov current_category, al
    
    cmp al, '1'
    je breakfast
    cmp al, '2'
    je lunch
    cmp al, '3'
    je dinner
    cmp al, '4'
    je snacks
    cmp al, '5'
    je drinks
    cmp al, '6'
    je exit_prog
    
    jmp invalid_input

return_to_category:
    mov al, current_category
    cmp al, '1'
    je breakfast
    cmp al, '2'
    je lunch
    cmp al, '3'
    je dinner
    cmp al, '4'
    je snacks
    cmp al, '5'
    je drinks
    jmp show_menu

breakfast:
    call clear_screen
    print menu_title_msg
    print b_menu1
    print b_menu2
    print b_menu3
    print b_menu4
    print b_menu5
    print b_menu6
    print b_menu7
    print b_menu8
    print select_food_msg
    mov bx, offset b_price
    jmp process_selection

lunch:
    call clear_screen
    print menu_title_msg
    print l_menu1
    print l_menu2
    print l_menu3
    print l_menu4
    print l_menu5
    print l_menu6
    print l_menu7
    print l_menu8
    print select_food_msg
    mov bx, offset l_price
    jmp process_selection

dinner:
    call clear_screen
    print menu_title_msg
    print d_menu1
    print d_menu2
    print d_menu3
    print d_menu4
    print d_menu5
    print d_menu6
    print d_menu7
    print d_menu8
    print select_food_msg
    mov bx, offset d_price
    jmp process_selection

snacks:
    call clear_screen
    print menu_title_msg
    print s_menu1
    print s_menu2
    print s_menu3
    print s_menu4
    print s_menu5
    print s_menu6
    print s_menu7
    print s_menu8
    print select_food_msg
    mov bx, offset s_price
    jmp process_selection

drinks:
    call clear_screen
    print menu_title_msg
    print dr_menu1
    print dr_menu2
    print dr_menu3
    print dr_menu4
    print dr_menu5
    print dr_menu6
    print dr_menu7
    print dr_menu8
    print select_food_msg
    mov bx, offset dr_price
    jmp process_selection

invalid_input:
    call clear_screen
    print invalid_msg
    mov ah, 01h
    int 21h
    jmp show_menu

exit_prog:
    mov ah, 4ch
    int 21h

main endp

process_selection proc
    ; Get food selection
    mov ah, 01h
    int 21h
    
    ; Validate input (1-8)
    cmp al, '1'
    jl invalid_input
    cmp al, '8'
    jg invalid_input
    
    ; Calculate price array index
    sub al, '1'
    mov ah, 0
    mov si, ax
    add si, si
    
    ; Get price
    mov ax, [bx+si]
    mov current_price, ax
    
    ; Get quantity
    print quantity_msg
    mov ah, 01h
    int 21h
    
    ; Validate quantity
    cmp al, '1'
    jl invalid_input
    cmp al, '9'
    jg invalid_input
    
    ; Save quantity and calculate total
    sub al, '0'
    mov current_quant, al
    mov bl, al
    mov bh, 0
    mov ax, current_price
    mul bx              ; Multiply price by quantity
    add total_price, ax ; Add to total price
    
    ; Show current total
    print total_msg
    mov ax, total_price
    call print_number
    
    ; Show options
    print options_msg
    mov ah, 01h
    int 21h
    
    cmp al, '1'
    je start
    cmp al, '2'
    je return_to_category ; Modified to use new label
    cmp al, '3'
    je show_bill
    
    jmp invalid_input
    ret
process_selection endp

show_bill proc
    call clear_screen
    print bill_msg
    print total_msg
    
    mov ax, total_price
    call print_number
    
    print final_msg
    mov ah, 01h
    int 21h
    
    cmp al, '1'
    je start
    cmp al, '2'
    je exit_prog
    
    jmp invalid_input
    ret
show_bill endp

clear_screen proc
    mov ah, 00h
    mov al, 02h
    int 10h
    ret
clear_screen endp

print_number proc
    push bx
    push cx
    push dx
    
    mov bx, 10
    xor cx, cx
    
divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz divide
    
print_digits:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_digits
    
    pop dx
    pop cx
    pop bx
    ret
print_number endp

end main
