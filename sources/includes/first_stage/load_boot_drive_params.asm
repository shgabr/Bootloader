;************************************** load_boot_drive_params.asm **************************************
load_boot_drive_params: ; A subroutine to read the [boot_drive] parameters and update [hpc] and [spt]
      pusha             ; store AX, CX, DX, BX, original SP, BP, SI, and DI 
      xor di,di         ; to avoid bugs in some bioses we have to store 0x0000:0x0000 in es:di
     
      mov es,di         ; since we cannot set es directly, we move di into it 

      mov ah,0x8        ; function 0x8 in interrupt 13 fetches all disk parameters

      mov dl,[boot_drive] ; move the disk number into dl

      int 0x13            ; execute BIOS interrupt 0x13

      inc dh              ; we increment to get the head count in base 1
      mov word [hpc],0x0  ; move 0 into heads per cylinder, this will set both bytes to zero
      mov [hpc+1],dh      ; then store dh into the lower byte of [hpc].
      ; We are defining [hpc] as a word to ease calculating the CHS from LBS
      and cx,0000000000111111b ; Extract the lower 6 bits from CX that has the sectors/track and and zero the number of cylinders
      mov word [spt], cx ; move the number of sectors per track to [spt]. No need to increment 
      popa              ; pop back all the values stored on the stack by pusha in reverse order
      ret               ; Return back to the line after the call 