{ lib, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/core.nix
    ../../modules/nixos/gnome.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/android.nix
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
    android.enable = true;
  };

  # Deploy the versions committed from the desktop, without updating inputs here.
  system.autoUpgrade = {
    enable = true;
    flake = "github:davidvanderklay/dotfiles/main?dir=nixos#agent";
    upgrade = false;
    flags = [
      "--no-update-lock-file"
      "-L"
    ];
    dates = "06:00";
    # Skip missed runs rather than restarting services during the workday.
    persistent = false;
    allowReboot = true;
    # Local America/Chicago time. Long builds retry the reboot on the next run.
    rebootWindow = {
      # NixOS uses strict bounds, so include builds that finish at 06:00.
      lower = "05:59";
      upper = "07:00";
    };
  };

  # Pull shared config before Home Manager activation discovers new skills.
  systemd.services.agent-config-sync = {
    description = "Pull shared agent configuration";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [
      pkgs.git
      pkgs.openssh
    ];

    environment = {
      HOME = "/home/geolan";
      GIT_TERMINAL_PROMPT = "0";
      GIT_SSH_COMMAND = "ssh -o BatchMode=yes";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "geolan";
      WorkingDirectory = "/home/geolan/Projects/agent-config";
      TimeoutStartSec = "2min";
    };

    script = ''
      git pull --ff-only
    '';
  };

  # A failed pull is logged without blocking the system upgrade.
  systemd.services.nixos-upgrade = {
    wants = [ "agent-config-sync.service" ];
    after = [ "agent-config-sync.service" ];
  };

  # Start a graphical session for the browser and Android tools after reboot.
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
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
    };
  };
  security.pam.services.sshd.enableGnomeKeyring = true;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

  # Android Emulator uses KVM on Linux. The firmware must also enable VT-x or AMD-V.
  users.users.geolan = {
    extraGroups = [ "kvm" ];
    linger = true;
  };
}
