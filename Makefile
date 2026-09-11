iso-boomer:
	nix build ~/Projects/nix#boomer-iso --impure -o ~/Downloads/boomer-iso

iso-minimal:
	nix build ~/Projects/nix#iso -o ~/Downloads/nixos-minimal-iso
