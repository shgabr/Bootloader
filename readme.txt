To run bootloader on qemu virtual machine, there are 2 ways:

1) To boot from a floppy, the following command is to be entered "make run_myos"
2) To boot from a non-floppy disk, the following command is to be entered "make run_myos_drv"
*In order for the previous commands to work, the makefile must be located at in the same directory as the source, image, and bin directories.

After executing command,
1) bin files of first_stage.asm, second_stage.asm, and third_stage.asm will be located inside the bin directory.
2) the disk image will be located in the image directory.

After a successful make of the files, a qemu window should pop-up executing (booting) from the instructions.
