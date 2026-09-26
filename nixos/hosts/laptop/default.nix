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

  # Windows has its own ESP, so systemd-boot cannot discover its loader
  # automatically. Launch a signed EDK2 shell and let its script locate the
  # Windows ESP by checking the firmware's FS mappings.
  system.activationScripts.windowsBootEntry = {
    deps = [ "etc" ];
    text = ''
      if ! ${pkgs.util-linux}/bin/mountpoint -q /boot; then
        echo "Skipping Windows boot entry: /boot is not mounted"
        exit 0
      fi

      shellDir=/boot/EFI/windows-boot
      shellFile="$shellDir/shell.efi"
      install -d -m 0755 "$shellDir" /boot/loader/entries

      if ! ${pkgs.sbctl}/bin/sbctl sign \
        --output "$shellFile" \
        "${pkgs.edk2-uefi-shell}/shell.efi"; then
        echo "Could not sign the Windows boot helper; skipping its menu entry"
        exit 0
      fi

      cat > "$shellDir/startup.nsh" <<'UEFI_EOF'
      map -r
      if exist FS0:\EFI\Microsoft\Boot\bootmgfw.efi then
        FS0:\EFI\Microsoft\Boot\bootmgfw.efi
        exit
      endif
      if exist FS1:\EFI\Microsoft\Boot\bootmgfw.efi then
        FS1:\EFI\Microsoft\Boot\bootmgfw.efi
        exit
      endif
      if exist FS2:\EFI\Microsoft\Boot\bootmgfw.efi then
        FS2:\EFI\Microsoft\Boot\bootmgfw.efi
        exit
      endif
      if exist FS3:\EFI\Microsoft\Boot\bootmgfw.efi then
        FS3:\EFI\Microsoft\Boot\bootmgfw.efi
        exit
      endif
      if exist FS4:\EFI\Microsoft\Boot\bootmgfw.efi then
        FS4:\EFI\Microsoft\Boot\bootmgfw.efi
        exit
      endif
      if exist FS5:\EFI\Microsoft\Boot\bootmgfw.efi then
        FS5:\EFI\Microsoft\Boot\bootmgfw.efi
        exit
      endif
      if exist FS6:\EFI\Microsoft\Boot\bootmgfw.efi then
        FS6:\EFI\Microsoft\Boot\bootmgfw.efi
        exit
      endif
      if exist FS7:\EFI\Microsoft\Boot\bootmgfw.efi then
        FS7:\EFI\Microsoft\Boot\bootmgfw.efi
        exit
      endif
      echo Windows Boot Manager was not found. Run map -c to inspect the available filesystems.
      UEFI_EOF

      cat > /boot/loader/entries/windows.conf <<'ENTRY_EOF'
      title Windows
      efi /EFI/windows-boot/shell.efi
      options -nointerrupt
      sort-key o_windows
      ENTRY_EOF
    '';
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
