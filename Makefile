NASM=/usr/local/bin/nasm
DD=/bin/dd
CAT=/bin/cat
QEMU=/usr/local/bin/qemu-system-x86_64
BIN=./bin
IMAGES=./images
SOURCES=./sources

all: $(IMAGES)/myos.flp $(IMAGES)/myos.drv

$(BIN)/boot_hello.bin: $(SOURCES)/boot_hello.asm
	$(NASM) -f bin $(SOURCES)/boot_hello.asm -o $(BIN)/boot_hello.bin

$(IMAGES)/boot_hello.flp: $(BIN)/boot_hello.bin
	$(CAT) $(BIN)/boot_hello.bin /dev/zero | $(DD) bs=512 count=2880 of=$(IMAGES)/boot_hello.flp

run_hello: $(IMAGES)/boot_hello.flp
	$(QEMU)  -drive file=$(IMAGES)/boot_hello.flp,format=raw,index=0,if=floppy

$(BIN)/first_stage.bin: $(SOURCES)/first_stage.asm $(SOURCES)/includes/first_stage/*.asm
	$(NASM) -f bin $(SOURCES)/first_stage.asm -o $(BIN)/first_stage.bin

$(BIN)/second_stage.bin: $(SOURCES)/second_stage.asm $(SOURCES)/includes/second_stage/*.asm
	$(NASM) -f bin $(SOURCES)/second_stage.asm -o $(BIN)/second_stage.bin

$(BIN)/third_stage.bin: $(SOURCES)/third_stage.asm $(SOURCES)/includes/third_stage/*.asm
	$(NASM) -f bin $(SOURCES)/third_stage.asm -o $(BIN)/third_stage.bin

$(IMAGES)/myos.flp: $(BIN)/first_stage.bin $(BIN)/second_stage.bin $(BIN)/third_stage.bin
	$(CAT) $(BIN)/first_stage.bin $(BIN)/second_stage.bin $(BIN)/third_stage.bin ./pci.ids /dev/zero | $(DD) bs=512 count=2880 of=$(IMAGES)/myos.flp

#./pci.ids
$(IMAGES)/myos.drv: $(BIN)/first_stage.bin $(BIN)/second_stage.bin $(BIN)/third_stage.bin 
	$(CAT) $(BIN)/first_stage.bin $(BIN)/second_stage.bin $(BIN)/third_stage.bin ./pci.ids /dev/zero | $(DD) bs=512 count=61440 of=$(IMAGES)/myos.drv
#122880
run_myos: $(IMAGES)/myos.flp
	$(QEMU) -m 4096 -drive file=$(IMAGES)/myos.flp,format=raw,index=0,if=floppy -drive file=$(IMAGES)/disk0.qcow2,format=qcow2,index=0,media=disk  -drive file=$(IMAGES)/disk1.qcow2,format=qcow2,index=1,media=disk -drive file=$(IMAGES)/disk2.qcow2,format=qcow2,index=2,media=disk -drive file=$(IMAGES)/disk3.qcow2,format=qcow2,index=3,media=disk -net nic -net user,hostfwd=tcp::5555-:22

run_myos2: $(IMAGES)/myos.flp
	$(QEMU) -m 4096 -hda $(IMAGES)/myos.flp -net nic -net user,hostfwd=tcp::5555-:22

run_myos1: $(IMAGES)/myos.flp
	$(QEMU) -m 4096 -drive file=$(IMAGES)/myos.flp,format=raw,index=0,media=disk -drive file=$(IMAGES)/disk1.qcow2,format=qcow2,index=1,media=disk -drive file=$(IMAGES)/disk2.qcow2,format=qcow2,index=2,media=disk -drive file=$(IMAGES)/disk3.qcow2,format=qcow2,index=3,media=disk -net nic -net user,hostfwd=tcp::5555-:22

run_myos_drv: $(IMAGES)/myos.drv
	$(QEMU) -m 4096 -drive file=$(IMAGES)/myos.drv,format=raw,index=0,media=disk -drive file=$(IMAGES)/disk0.qcow2,format=qcow2,index=1,media=disk  -drive file=$(IMAGES)/disk1.qcow2,format=qcow2,index=2,media=disk -drive file=$(IMAGES)/disk2.qcow2,format=qcow2,index=3,media=disk  -net nic -net user,hostfwd=tcp::5555-:22

run_myos_drv1: $(IMAGES)/myos.drv
	$(QEMU) -m 4096 -drive file=$(IMAGES)/myos.drv,format=raw,index=0,if=floppy -drive file=$(IMAGES)/disk0.qcow2,format=qcow2,index=0,media=disk  -drive file=$(IMAGES)/disk1.qcow2,format=qcow2,index=1,media=disk -drive file=$(IMAGES)/disk2.qcow2,format=qcow2,index=2,media=disk -drive file=$(IMAGES)/disk3.qcow2,format=qcow2,index=3,media=disk -net nic -net user,hostfwd=tcp::5555-:22


runvbox: $(IMAGES)/myos.drv $(IMAGES)/myos.flp
	/usr/local/bin/VBoxManage unregistervm baremetalvm --delete 2> /dev/null ;true
	/usr/local/bin/VBoxManage closemedium disk ./baremetalvm/boot_drive.vdi 2> /dev/null ;true
	rm -rf "/Users/kmsobh/bosmlsb/baremetal/baremetalvm"
	/usr/local/bin/VBoxManage createvm --name baremetalvm --ostype Other_64 --basefolder /Users/kmsobh/bosmlsb/baremetal/ --register 2> /dev/null ;true
	/usr/local/bin/VBoxManage modifyvm baremetalvm --memory 4096 2> /dev/null ;true
	/usr/local/bin/VBoxManage modifyvm baremetalvm --cpu 1 2> /dev/null ;true
	/usr/local/bin/VBoxManage modifyvm baremetalvm --nested-hw-virt on 1 2> /dev/null ;true
	/usr/local/bin/VBoxManage storagectl baremetalvm --name "IDE Controller" --add ide 2> /dev/null ;true
	cp ./images/myos.drv ./baremetalvm/boot_drive.raw 2> /dev/null ;true
	/usr/local/bin/VBoxManage convertdd ./baremetalvm/boot_drive.raw ./baremetalvm/boot_drive.vdi --format VDI --variant Fixed
	chown $(id -n -u):$(id -n -g) ./baremetalvm/boot_drive.vdi 2> /dev/null ;true
	/usr/local/bin/VBoxManage storageattach baremetalvm --storagectl "IDE Controller" --device 0 --port 0 --type hdd --medium ./baremetalvm/boot_drive.vdi 2> /dev/null ;true
	/usr/local/bin/VBoxManage modifyvm baremetalvm --nic1 hostonly  --hostonlyadapter1 vboxnet1 --nictype1 82540EM  2> /dev/null ;true
	/usr/local/bin/VBoxManage modifyvm baremetalvm --boot1 disk  --boot2 none --boot3 none --boot4 none  2> /dev/null ;true
	/usr/local/bin/VBoxManage setextradata baremetalvm GUI/ScaleFactor 1.25  2> /dev/null ;true
	/usr/local/bin/VBoxManage startvm baremetalvm
clean:
	rm -rf $(BIN)/* $(IMAGES)/*.flp $(IMAGES)/*.drv
