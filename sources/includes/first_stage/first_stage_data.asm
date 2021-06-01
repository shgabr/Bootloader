;************************************** first_stage_data.asm **************************************

      boot_drive  db 0x0      ;memory variable to store boot device number that we booted from
      lba_sector  dw 0x1      ;memory variable to store number of sectors loaded
                              ;it starts with 0x1 because the first sector (lba 0x0) is already loaded by the hardware
                        
      spt   dw 0x12     ;memory variable to store the number of sectors/track (default value set to the floppy's)
      hpc   dw 0x2      ;memory variable to store the number of head/cylinder (default value set to the floppy's)
      
      ;used in lba_2_chs (conversion from LBA to CHS) used while reading sectors (with INT 0x13/fn2)
      Cylinder    dw 0x0      ;contains index of cylinders
      Head        db 0x0      ;contains index of head   
      Sector      dw 0x0      ;contains index of sector

      ;several messages used by functions to indicate state of execution
      disk_error_msg                db 'Disk Error', 13, 10, 0                                  ;printed if failed to read sectors (read_disk_sectors)
      fault_msg                     db 'Unknown Boot Device', 13, 10, 0                         ;printed if failed to identify boot drive (detect_boot_disk)
      booted_from_msg               db 'Booted from ', 0                                        ;printed if boot drive was successfully identified (detect_boot_disk)
      floppy_boot_msg               db 'Floppy', 13, 10, 0                                      ;printed if boot drive was a floppy (detect_boot_disk)
      drive_boot_msg                db 'Disk', 13, 10, 0                                        ;printed if boot drive was a disk (detect_boot_disk)
      greeting_msg                  db '1st Stage Loader', 13, 10, 0                            ;printed at the first stage bootloader (first_stage)
      second_stage_loaded_msg       db 13,10,'2nd Stage loaded, press key to resume!', 0    ;printed after loading second & third satges (first_stage)
      dot                           db '.',0                                                    ;printed after a successful read of sector (read_disk_sectors)
      newline                       db 13,10,0                                                  ;print a new line (not used)
      
      disk_read_segment             dw 0        ;memory varaible to store the segment address 
      disk_read_offset              dw 0        ;memory variable to store the memory offset
