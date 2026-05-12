{
  description = "taigamat's nix configuration (macOS via nix-darwin, Linux via home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }: {
    # macOS: nix-darwin + home-manager を束ねて適用する
    # darwin-switch alias から 'darwin-rebuild switch --flake .#default --impure' で起動
    darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.taigamat = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
      specialArgs = { inherit inputs; };
    };

    # Linux (Ubuntu / Amazon Linux 等):
    # NIXPKGS_ALLOW_UNFREE=1 nix run --impure home-manager/master -- switch --flake .#default
    # で起動 ( --impure は下の $USER 参照、NIXPKGS_ALLOW_UNFREE=1 は kiro-cli が unfree のため )
    # 現状 x86_64-linux のみ想定。Amazon Linux on Graviton (aarch64-linux) が必要に
    # なったら別途 homeConfigurations を追加する。
    # username / homeDirectory は個人識別子を flake に焼かないため $USER から取る。
    # pure evaluation では builtins.getEnv が空文字列を返すため --impure 必須。
    homeConfigurations."default" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      modules = [
        ./home.nix
        {
          home.username = builtins.getEnv "USER";
          home.homeDirectory = "/home/${builtins.getEnv "USER"}";
        }
      ];
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
