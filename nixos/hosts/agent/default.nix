{ lib, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/core.nix
    ../../modules/nixos/gnome.nix
    ../../modules/nixos/docker.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  assertions = [
    {
      assertion = builtins.pathExists ./hardware-configuration.nix;
      message = "Generate hosts/agent/hardware-configuration.nix on the new machine before building this host.";
    }
  ];

  mymod.nixos = {
    core = {
      enable = true;
      hostName = "nixos-agent";
    };
    gnome.enable = true;
    docker.enable = true;
  };

  # Start the graphical session for T3 Code and remote desktop after reboot.
  services.displayManager.autoLogin = {
    enable = true;
    user = "geolan";
  };

  # Standard UEFI boot. Replace with the machine's boot setup if needed.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # The machine is reached over Tailscale. SSH only accepts traffic there.
  services.tailscale.enable = true;
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

  # Android Emulator uses KVM on Linux. The firmware must also enable VT-x or AMD-V.
  users.users.geolan.extraGroups = [ "kvm" ];
  nixpkgs.config.android_sdk.accept_license = true;
  environment.systemPackages = [ pkgs.android-studio ];
}
