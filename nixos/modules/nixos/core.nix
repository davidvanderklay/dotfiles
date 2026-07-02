{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mymod.core;
in
{
  options.mymod.core = {
    enable = lib.mkEnableOption "core system configuration";

    userName = lib.mkOption {
      type = lib.types.str;
      default = "geolan";
    };

    userDescription = lib.mkOption {
      type = lib.types.str;
      default = "geolan";
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/Chicago";
    };

    autoUpgrade = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    networking = {
      hostName = cfg.hostName;
      networkmanager = {
        enable = true;
        plugins = with pkgs; [
          networkmanager-openvpn
          networkmanager-openconnect
        ];
      };
    };

    time.timeZone = cfg.timeZone;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://cache.numtide.com"
        "https://ezkea.cachix.org"
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };

    nix = {
      settings.auto-optimise-store = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    system.autoUpgrade = lib.mkIf cfg.autoUpgrade {
      enable = true;
      persistent = true;
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L"
      ];
      dates = "02:00";
      randomizedDelaySec = "45min";
    };

    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = cfg.userDescription;
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;
    programs.ssh.knownHosts.github = {
      hostNames = [
        "github.com"
        "ssh.github.com"
      ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];

    environment.variables.EDITOR = "nvim";

    environment.systemPackages = with pkgs; [
      gnumake
      gcc
      wget
      git
      gh
      ffmpeg
      openvpn
      networkmanager-openconnect
      openconnect
    ];

    system.stateVersion = "25.11";
  };
}
