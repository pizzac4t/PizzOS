ORG 0
BITS 16

_start:
  jmp shprt start
  nop
  times 33 db 0 ;correct bytes to avoid BPB to corrupt code

start:
  jmp 0x7c0:run

run:
  cli ;Clears interrupts
  mov ax, 0x7c0
  mov ds, ax
  mov es, ax
  mov ax, 0x00
  mov ss, ax
  mov sp, 0x7c00 ;so it dosent depends on bios
  sti ;Enables interrupts
  mov si, msg
  call print
  jmp $

print:
  mov bx, 0

.loop:
  lodsb
  cmp al, 0
  je .done
  call print_char
  jmp .loop
.done:
  ret

print_char:
  mov ah, 0eh
  int 0x10
  ret
msg: db 'Hello!', 0

times 510- ($ - $$) db 0 ;jmp to the but to be signed
dw 0xAA55
