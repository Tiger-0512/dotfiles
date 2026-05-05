{
  description = "taigamat's nix-darwin configuration (Phase 2.1 PoC)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin }: {
    # darwin-rebuild switch --flake .#default で起動する
    # ホスト名依存を避けるため "default" に固定している
    darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin.nix ];
      specialArgs = { inherit inputs; };
    };
  };
}
