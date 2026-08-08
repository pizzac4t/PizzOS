# PizzOS

**My simple OS project :D!**

# PizzOS

**My simple OS project :D!**

**How to test**

```shell
#Efi: 
 sudo qemu-system-x86_64 \
 -machine q35,accel=kvm \
 -m 4G \
 -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/OVMF.fd\
 -drive if=pflash,format=raw,file=/usr/share/ovmf/OVMF.fd \
 -drive format=raw,file=build/floppy_efi.img \
 -boot c   
 ```
```shell
#Legacy Bios:
  qemu-system-x86_64 -hda build/floppy.img
```