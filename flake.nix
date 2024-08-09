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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # QuasarOS
    quasaros.url = "github:quantum9innovation/quasaros/test2";

    # User configuration
    config.url = "github:quantum9innovation/netsanet/test2";
  };

  outputs = { self, nixpkgs, quasaros, config, ... }@inputs: {
    # Build the system
    nixosConfigurations.netsanet = (quasaros.make config).system;

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-classic;
  };
}
