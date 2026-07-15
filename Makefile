gcc:
	x86_64-w64-mingw32-gcc efi/main.c \
	-std=c17 \
	-Wall \
	-Wextra \
	-Wpedantic \
	-ffreestanding \
	-nostdlib \
	-Wl, --subsystem,10 \
	-e efi_main \
	-o BOOTX64.EFI
