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
