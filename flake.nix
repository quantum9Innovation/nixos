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
  description = "On-device system configuration flake";

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

    # QuasarOS
    quasaros.url = "github:quantum9innovation/quasaros/main";

    # User configuration
    config.url = "github:quantum9innovation/netsanet/main";
  };

  outputs =
    {
      nixpkgs,
      quasaros,
      config,
      ...
    }:
    {
      # Build the system
      nixosConfigurations.netsanet = (quasaros.make config).system;

      formatter =
        let
          systems = [
            "x86_64-linux"
          ];
          forAll = value: nixpkgs.lib.genAttrs systems (key: value);
        in
        forAll nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
