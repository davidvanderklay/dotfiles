{ config, pkgs, ... }:

{
  # This creates the actual user on the system
  users.users.geolan = {
    isNormalUser = true;
    description = "David";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
    ];

    # This sets your default login shell (Zsh)
    # Note: programs.zsh.enable = true; must also be set at system level (usually in core/default.nix)
    shell = pkgs.zsh;

    # If you have an SSH public key, add it here for easy remote login
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3Nza..."
    # ];
  };

  # Some apps (like Steam and some desktop managers) work better
  # when the system knows the user's shell is Zsh.
  programs.zsh.enable = true;
}
