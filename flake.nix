{
  description = "A port of cargo-insta";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: 
    let
      name = "cargo-insta-flake";
      version = "1.39.0";

      packages = {
        aarch64-darwin = {
          label = "aarch64-darwin";
          triple = "aarch64-apple-darwin";
          checksum = "sha256-IgZLBUgK4HjYYZTQaLtmNDeQCF0VbwuwkSYz/H80R6k=";
          platform = "darwin";
        };
        x86_64-darwin = {
          label = "x86_64-darwin";
          triple = "x86_64-apple-darwin";
          checksum = "sha256-9+jd2LZn5Srro98scATAbRF+6nR+9pM4aGE4sdDD8ac=";
          platform = "darwin";
        };
        x86_64-linux = {
          label = "x86_64-linux";
          triple = "x86_64-unknown-linux-gnu";
          checksum = "sha256-Gunsc2eDYZd0PEGqECJtdTyr5yOwkPNE/8AXeUy8cZk=";
          platform = "linux";
        };
      };

      defaultPackage = build packages;

      # FUNCTIONS

      url = { triple, version }: "https://github.com/mitsuhiko/insta/releases/download/${version}/cargo-insta-${triple}.tar.xz";

      build = package: builtins.listToAttrs (map (system: {
        name = system;
        value = with import nixpkgs { system = package.${system}.label; };
          stdenvNoCC.mkDerivation rec {
            inherit name version;

            # https://nixos.wiki/wiki/Packaging/Binaries
            src = pkgs.fetchurl {
              url = url { 
                triple = package.${system}.triple;
                version = version; 
              };
              # Get the cheksum from the release on github
              # Convert it to base64
              # Then prefix it with 'sha256-'
              sha256 = package.${system}.checksum;
            };

            sourceRoot = ".";

            installPhase = ''
            install -m755 -D cargo-insta-${package.${system}.triple}/cargo-insta $out/bin/cargo-insta
            '';

            meta = with lib; {
              homepage = "https://github.com/mitsuhiko/insta";
              description = "A snapshot testing library for rust";
              platforms = platforms.${package.${system}.platform};
            };
          };
      }) (builtins.attrNames package));

    in
    {
      inherit defaultPackage;
    };

}