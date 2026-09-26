{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  mymod.nixos = {
    core = {
      enable = true;
      hostName = "nixos-laptop";
    };

    gnome.enable = true;
    gaming.enable = true;
    docker.enable = true;

    nvidia = {
      enable = true;
      laptop = {
        enable = true;
        amdgpuBusId = "PCI:7:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    services.enable = true;
  };

  # Match the desktop's Lanzaboote Secure Boot setup. Keys are created
  # locally on this machine and are not stored in the Nix configuration.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # systemd stage 1 can use systemd-cryptenroll TPM2 tokens to unlock LUKS.
  boot.initrd.systemd = {
    enable = true;
    tpm2.enable = true;
  };

  # Add TPM2 as an unlock method while retaining the existing passphrase.
  # Root's device path is defined in hardware-configuration.nix. Swap is a
  # separate LUKS volume and therefore needs its own initrd mapping/token.
  boot.initrd.luks.devices = {
    "luks-9db4ac27-e25a-4afa-94a2-9d835133a6c5".crypttabExtraOpts = [
      "tpm2-device=auto"
    ];

    "luks-5753cf4a-fcda-42e7-983a-942c37f2af2f" = {
      device = "/dev/disk/by-uuid/5753cf4a-fcda-42e7-983a-942c37f2af2f";
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };

  services.asusd.enable = true;

  environment.systemPackages = with pkgs; [
    sbctl
    nicotine-plus
    feishin
  ];
}
