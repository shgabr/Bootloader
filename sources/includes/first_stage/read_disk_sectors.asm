 ;************************************** read_disk_sectors.asm **************************************
      read_disk_sectors: ; This function will read a number of 512-sectors stored in DI 
                         ; The sectors should be loaded at the address starting at [disk_read_segment:disk_read_offset]
          
          pusha                              ;push all general purpose registers to stack (to restore values back from)
          add di,[lba_sector]                ;lba_sector contains the number of sectors that has already been loaded so we add lba_sector to DI to know index of last sector to read
          mov ax,[disk_read_segment]         ;set AX to the segment address which contains the sectors to be read
          mov es,ax                          ;we cannot set ES directly from memory so we set AX to the segment address then set ES to AX
          add bx,[disk_read_offset]          ;INT 0x13 requires [disk_read_segment:disk_read_offset] to be in [es:bx] so we set BX to the memory offset
          mov dl,[boot_drive]                ;set DL to the boot drive we booted from
          .read_sector_loop:       
               call lba_2_chs                ;call lba_2_chs to get the corresponding cylinders,heads,sectors from the lba_sector
               mov ah, 0x2                   ;interrupt function that reads sectors
               mov al,0x1                    ;number of sectors to read
               mov cx,[Cylinder]             ;move number of cylinders (returned from lba_2_chs) to CX
               shr cx,0x2                    ;shift CX by 2 so that bit 9 & 10 of cylinder become in CL
               mov ch,[Cylinder]             ;move the lower 8-bits of cylinder to CH
               and cl,0xC0                   ;and CL with 0xC0 or 11000000b (to set first 6 bits in CL to zero)
               or cx,[Sector]                ;set CX to the first 6-bits of sector (returned from lba_2_chs)
               mov dh,[Head]                 ;set DH to head (returned from lba_2_chs)
               int 0x13                      ;call INT 0x13 that reads sectors
               jc .read_disk_error           ;if an error occurred then go to read_disk_error
               mov si,dot                    ;else set SI to dot '.'
               call bios_print               ;call bios_print to print '.' to indicate successful read of sector
               inc word [lba_sector]         ;increment lba_sector to go to next sector to read
               add bx,0x200                  ;increment offset by 0x200 (512 bytes) to point to the address of next sector to read
               cmp word[lba_sector],di       ;compare number of sectors read (lba_sector) to DI 
               jl .read_sector_loop          ;if less than then loop again
               jmp .finish                   ;else go to finish
          .read_disk_error:
               mov si,disk_error_msg         ;set SI to disk_error_msg
               call bios_print               ;call bios_print to print error message to indicate an error has occurred while reading sectors
               jmp hang                      ;then go to hang
          .finish:
               popa                          ;retore back all general purpose registers' values from stack
               ret                           ;return back to where the function was called