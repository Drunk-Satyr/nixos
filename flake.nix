{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-orcaslicer.url = "github:nixos/nixpkgs/ce7d0299aa14e2b2bd70ed2669d513b008217229";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nixcord.url = "github:4evy/nixcord";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      zen-browser,
      nixpkgs-orcaslicer,
      ...
    }@inputs:
    {
      nixosConfigurations.sheepytower = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            # home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "HMBackup";
            home-manager.useUserPackages = true;
            home-manager.users.caro.imports = [
              ./home.nix
            ];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              system = "x86_64-linux";
            };
          }
        ];
      };
    };
}
