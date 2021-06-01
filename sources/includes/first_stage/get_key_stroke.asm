;************************************** get_key_stroke.asm **************************************      
        get_key_stroke: ; A routine to print a confirmation message and wait for key press to jump to second boot stage
        ; this function waits for the user to enter a key on the keyboard
        
        pusha ; pushing all the registers to the stack
        mov ah,0x0 ;  let ah = 0
        int 0x16 ; interrupt 16 is the keyboard interrupt which will wait until the user press on any key on the keyboard
        popa ; pop all the registers from the stack
        ret ; will return to the location where the function is called which is the main
