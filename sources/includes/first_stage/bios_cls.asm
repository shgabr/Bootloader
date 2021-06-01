;************************************** bios_cls.asm **************************************            
      bios_cls:   ; A routine to initialize video mode 80x25 which also clears the screen            
      pusha       ; It saves all general purpose registers on the stack
      mov ah,0x0  ; Moving 0x0 in ah allows us to use Video Mode Function and set it to whatever suits us
      mov al,0x3  ; 0x3 value inside al register allows us to intialize the video mode to 80x25 16 color text mode
      int 0x10    ; Issue INT 0x10  
      popa        ; Restore all general purpose registers from the stack            
      ret
