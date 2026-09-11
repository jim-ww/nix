.PHONY: iso-boomer
iso-boomer:
	nix build ~/Projects/nix#boomer-iso --impure -o ~/Downloads/boomer-iso

.PHONY: iso-minimal
iso-minimal:
	nix build ~/Projects/nix#iso -o ~/Downloads/nixos-minimal-iso
