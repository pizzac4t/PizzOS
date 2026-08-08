SRC_DIR=src
BUILD_DIR=build
LEGACY_DIR=src/boot/Legacy

legacy:

	mkdir -p $(BUILD_DIR)
	/usr/bin/nasm $(LEGACY_DIR)/boot.asm -f bin -o $(BUILD_DIR)/bootLegacy.bin

	/usr/bin/dd if=/dev/zero of=$(BUILD_DIR)/floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "PZZOS" $(BUILD_DIR)/floppy.img
	/usr/bin/dd if=$(BUILD_DIR)/bootLegacy.bin of=$(BUILD_DIR)/floppy.img conv=notrunc
	/usr/bin/truncate -s 1440k $(BUILD_DIR)/floppy.img
#NOTE add kernel section
efi:
	mkdir -p $(BUILD_DIR)
	gcc -Ignu-efi-dir/inc -fpic -ffreestanding -fno-stack-protector -fno-stack-check -fshort-wchar -mno-red-zone -maccumulate-outgoing-args -c $(EFI_DIR)/main.c -o $(BUILD_DIR)/main.o
	ld -shared -Bsymbolic -Lheaders/x86_64 -Lheaders/x86_64/gnuefi -T$(EFI_DIR)/headers/x86_64/gnuefi/elf_x86_64_efi.lds $(EFI_DIR)/headers/x86_64/gnuefi/crt0-efi-x86_64.o $(BUILD_DIR)/main.o -o $(BUILD_DIR)/main.so
	objcopy -j .text -j .sdata -j .data -j .rodata -j .dynamic -j .dynsym  -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --output-target efi-app-x86_64 --subsystem=10 $(BUILD_DIR)/main.so $(BUILD_DIR)/main.efi

	/usr/bin/dd if=$(BUILD_DIR)/main.efi of=$(BUILD_DIR)/floppy_efi.img conv=notrunc