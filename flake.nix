{

  #  /*****                                                 /******   /****
  #  |*    |  |*   |    **     ****     **    *****        |*    |  /*    *
  #  |*    |  |*   |   /* *   /*       /* *   |*   |      |*    |  |*
  #  |*    |  |*   |  /*   *   ****   /*   *  |*   /     |*    |   ******
  #  |*  * |  |*   |  ******       |  ******  *****     |*    |         |
  #  |*   *   |*   |  |*   |   *   |  |*   |  |*  *    |*    |   *     |
  #   **** *   ****   |*   |    ****  |*   |  |*   *   ******    *****
  #
  #  ==========================================================================

  # This is the default QuasarOS on-device system configuration flake.
  # It loads your remote configuration,
  # in conjunction with the QuasarOS default configuration,
  # and builds your system environment.
  # You can change the versions of the inputs to revert
  # to previous system configurations.
  # However, you should keep this flake's lockfile,
  # so you can declaratively restore packages to previous versions if necessary.
  description = "On-device system configuration flake, checked with Hercules CI";

  inputs = {
    # QuasarOS uses the nixpkgs unstable channel,
    # so new package updates are always immediately available.
    # Many user packages are also built directly
    # from the latest stable git source,
    # usually the last commit on the `main` branch.
    # This is the recommended way to install user packages
    # which are not critical for system functionality on QuasarOS.

    # Share the nixpkgs instance in quasaros
    nixpkgs.follows = "quasaros/nixpkgs";

    # Enable pre-commit hooks on this repository
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    # QuasarOS
    quasaros.url = "github:quantum9innovation/quasaros/main";

    # User configuration
    config.url = "github:quantum9innovation/netsanet/main";
  };

  outputs =
    {
      self,
      nixpkgs,
      quasaros,
      config,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      checks = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            check-merge-conflicts.enable = true;
            commitizen.enable = true;
            convco.enable = true;
            forbid-new-submodules.enable = true;
            gitlint.enable = true;
            markdownlint.enable = true;
            mdformat.enable = true;
            mdsh.enable = true;
            deadnix.enable = true;
            flake-checker.enable = true;
            nil.enable = true;
            statix.enable = true;
            nixfmt-rfc-style.enable = true;
            ripsecrets.enable = true;
            trufflehog.enable = false;
            shellcheck.enable = true;
            shfmt.enable = true;
            typos.enable = true;
            check-yaml.enable = true;
            yamlfmt.enable = true;
            yamllint.enable = true;
            yamllint.settings.preset = "relaxed";
            actionlint.enable = true;
            check-added-large-files.enable = true;
            check-case-conflicts.enable = true;
            check-executables-have-shebangs.enable = true;
            check-shebang-scripts-are-executable.enable = true;
            check-symlinks.enable = true;
            detect-private-keys.enable = true;
            end-of-file-fixer.enable = true;
            mixed-line-endings.enable = true;
            tagref.enable = true;
            trim-trailing-whitespace.enable = true;
            check-toml.enable = true;
          };
        };
      });

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });

      # Build the system
      nixosConfigurations.netsanet = (quasaros.make config).system;

      formatter = forAllSystems (_system: nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style);
    };
}
