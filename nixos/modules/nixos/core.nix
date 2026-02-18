{ config, lib, pkgs, inputs, ... }:

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
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;

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

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
      flake = inputs.self.outPath;
      flags = [ "--update-input" "nixpkgs" "-L" ];
      dates = "02:00";
      randomizedDelaySec = "45min";
    };

    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = cfg.userDescription;
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;
    nixpkgs.config.allowUnfree = true;

    environment.variables.EDITOR = "nvim";

    environment.systemPackages = with pkgs; [
      gnumake
      gcc
      wget
      git
      ffmpeg
      openvpn
      networkmanager-openconnect
      openconnect
    ];

    system.stateVersion = "25.11";
  };
}
