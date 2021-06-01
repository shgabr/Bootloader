;************************************** detect_boot_disk.asm **************************************
detect_boot_disk: ; A subroutine to detect the the storage device number of the device we have booted from
                  ; After the execution the memory variable [boot_drive] should contain the device number
                  ; Upon booting the bios stores the boot device number into DL
pusha             ; push all registers on the stack
mov si,fault_msg  ; Store in si the fault_msg
xor ax,ax         ; xor ing the register with itself stores a value of zero inside it. Consequently, the higher 8-bit register
                  ; AH will be equal to 0 in order to Reset Disk Drive
int 13h           ; This fires 0x13 BIOS interrupt
jc .exit_with_error   ; In case the a carry flag was set, this indicates an error. Thus, jump to exit_with_error
mov si,booted_from_msg  ; Else print a message to the screen "booted from" by loading its address in si and calling bios_print function
call bios_print
mov [boot_drive], dl  ; Store the boot drive number in "boot_drive" address from the dl register
cmp dl,0              ; If dl is equal to 0x0, this indicates it is a floppy disk and we should jump to .floppy.
je .floppy


call load_boot_drive_params ; In case the disk was not the floppy one, we override [spt] and [hpc] by calling load_boot_drive_params

mov si,drive_boot_msg        ; Store the address of the sting drive_boot_msg into si
jmp .finish                  ; Skip over the .floppy code
.floppy:
mov si,floppy_boot_msg ; Store the address of the sting floppy_boot_msg into si
jmp .finish
.exit_with_error:
jmp hang   
.finish:
call bios_print      ; Calling "bios_print" function keeps printing characters found in si register untill it hits the last zero bit 
                     ; and stops
                     
popa                 ; poping all general purpose registers from the stack
ret
