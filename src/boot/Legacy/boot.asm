ORG 0
BITS 16

_start:
  jmp short start
  nop
  times 33 db 0 ;correct bytes to avoid BPB to corrupt code

  ;
  ;Fat 12 header
  ;
  bdb_oem:                   db 'MSWIN4.1' ;8 bytes
  bdb_byte_per_sector:       dw 512
  bdb_sectores_per_cluster:  db 1
  bdb_reserved_sectore:      dw 1
  bdb_fat_count:             db 2
  bdb_dir_entries_count:     dw 0E0h
  bdb_total_sectors:         dw 2880 ;1.4mb I think
  bdb_media_descriptor_type: db 0E0h ; F0 = 3.5" floppy
  bdb_sectores_per_fat:      dw 9
  bdb_sectors_per_track:     dw 18
  bdb_heads:                 dw 2
  bdb_hidedn_sectors:        dd 0
  bdb_large_sector_count:    dd 0

  ;Extended boot record
  ebr_drive_number:          db 0 ;for floppy
                             db 0 ;reserved
  ebr_signature:             dw 28h
  ;ebr_volume_id:            db 12h   no serial number for now...
  ebr_volume_label:          db 'PIZZOS     ' ;11 bytes, see what I did there?
  ebr_system_id:             db 'FAT12   '


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


  in al, 0x92
  or al, 2
  out 0x92, al
  ;jmp $


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

msg: db 'Preparing for protected mode', 0
stagetwo_confirm: db 'Moving to protected mode', 0
;
;GDT, Super duper simple.
;
gdt_start:
; null

gdt_null:
  dq 0x0000000000000000

gdt_code:
  dw 0xFFFF       ;Limit
  dw 0x0000       ;Base
  db 0x00         ;Another one
  db 10011010b    ;Acces byte i think...
  db 11001111b    ;Flags and the limit
  db 0x00         ;Base
  ; for acces byte, see https://wiki.osdev.org/Global_Descriptor_Table#Segment_Descriptor
gdt_data:

  dw 0xFFFF
  dw 0x0000
  db 0x00
  db 10010010b
  db 11001111b
  db 0x00

gdt_end:
;GDT descriptor for lgdt
;
gdt_descriptor:
  dd gdt_start + 0x7c00
  dw gdt_end - gdt_start - 1 ;Limit og GDT minus 1
  dd gdt_start ;linear addr

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

switch_to_pm:
  cli
  lgdt [gdt_descriptor]
  mov eax, cr0
  or eax, 1
  mov cr0, eax
  jmp CODE_SEG:protected_mode_start


BITS 32
  protected_mode_start:
      mov ax, DATA_SEG
      mov ds, ax
      mov es, ax
      mov fs, ax
      mov gs, ax
      mov ss, ax
      mov esp, 0x80000   ;somewhere safe

      mov si, stagetwo_confirm
      call print
times 510- ($ - $$) db 0 ;jmp to the bit to be signed
dw 0xAA55
