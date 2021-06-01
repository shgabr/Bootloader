 ;************************************** lba_2_chs.asm **************************************
 lba_2_chs:         ; Convert the value store in [lba_sector] to its equivelant CHS values and store them in [Cylinder],[Head], and [Sector]
                    ; This function need to be written by you.
; the equations 
                    ; Store them CHS in [Cylinder],[Head], and [Sector] respectively
;number of sectors  in  [Sector]   = Remainder of [lba_sector]/[spt] +1
;number of cylinders in [Cylinder] = Quotient of (([lba_sector]/[spt]) / [hpc])   
;number of heads in      [Head]    = Remainder of (([lba_sector]/[spt]) / [hpc])

pusha               ; store AX, CX, DX, BX, original SP, BP, SI, and DI 
xor dx,dx           ; xoring anything with itself is like moving zero to it 
                    ; this should be done before division to avoid problems 
mov ax, [lba_sector]; Move the value stored in the label refered to by lba_sector in ax
div word [spt]      ; divide DX:AX by the word stored in spt and store rem in DX and AX the quotient
inc dx              ; increment the remainder by 1 to get the number of sectors 
mov [Sector], dx    ; Store the sectors number in the label refered to by Sector

xor dx,dx           ; dx = 0 and Ax = quotient now after the div instruction 
div word [hpc]      ; divide Ax with the number of heads per cylinder 
mov [Cylinder], ax  ; After division the new quotient would contain the number of cylinders
                    ; so, we store it in [cylinders]
mov [Head], dl      ; move the lower 8 bytes of the remainder register into [head]

popa                ; pop back all the values stored on the stack by pusha in reverse order
ret                 ; Return back to the line after the call 