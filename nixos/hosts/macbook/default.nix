{ pkgs, inputs, ... }:

{
  # 1. Basic System Config
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 6;
  system.primaryUser = "geolan";
  users.users.geolan.home = "/Users/geolan";

  # Nix Settings
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "geolan"
      ];
    };

    optimise.automatic = true; # ADD THIS

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };

  # macOS Specifics
  security.pam.services.sudo_local.touchIdAuth = true;

  # 2. Homebrew Integration
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    taps = [
      "homebrew/services"
      "nikitabobko/tap"
    ];

    brews = [
      "imagemagick"
      "postgresql@14"
      "mariadb"
    ];

    casks = [
      "aerospace"
      "alfred"
      "maccy"
      "rectangle"
      "localsend"
      "xquartz"
      "zen"
      "signal"
      "zoom"
      "helium-browser"
      "ghostty"
      "iina"
      "font-hack-nerd-font"
      "font-iosevka-nerd-font"
    ];
  };

  # 3. macOS System Settings
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };

  # 4. Global Shell Config
  programs.zsh.enable = true;
}
