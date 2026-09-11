.PHONY: iso
iso:
	nix build ~/Projects/nix#iso -o ~/Downloads/nixos-iso

.PHONY: iso-minimal
iso-minimal:
	nix build ~/Projects/nix#iso-minimal -o ~/Downloads/nixos-minimal-iso

.PHONY: iso-boomer
iso-boomer:
	nix build ~/Projects/nix#boomer-iso --impure -o ~/Downloads/boomer-iso

.PHONY: run-iso
run-iso:
	qemu-system-x86_64 -enable-kvm -cpu host -m 4G -smp 2 \
    -vga virtio -display gtk \
    -drive file=home-pc.qcow2,if=virtio \
    -cdrom ./result/*-iso/iso/nixos-*.iso -boot d \
    -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22 \
    -audiodev pa,id=snd -device intel-hda -device hda-duplex,audiodev=snd
