SRC_DIR=src
BUILD_DIR=build
LEGACY_DIR=src/boot/Legacy

legacy:

	mkdir -p $(BUILD_DIR)
	/usr/bin/nasm $(LEGACY_DIR)/boot.asm  -f bin -o $(BUILD_DIR)/boot.o
	/usr/bin/nasm $(LEGACY_DIR)/stage2.asm -f bin -o $(BUILD_DIR)/stage2.o
	ld boot.o stage2.o -o bootLegacy.bin

	/usr/bin/dd if=/dev/zero of=$(BUILD_DIR)/floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "PZZOS" $(BUILD_DIR)/floppy.img
	/usr/bin/dd if=$(BUILD_DIR)/bootLegacy.bin of=$(BUILD_DIR)/floppy.img conv=notrunc
	/usr/bin/truncate -s 1440k $(BUILD_DIR)/floppy.img
#NOTE add kernel section

efi:
	mkdir -p $(BUILD_DIR)
	include src/boot/EFI/Headers/uefi/Makefile
	gcc  -pedantic -Wall -Wextra -Werror --std=c11 -O2 $(SRC_DIR)/boot/EFI/main.c $(BUILD_DIR)/main.efi
