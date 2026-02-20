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
      "jupytext"
      "ghostscript"
      "opencode"
    ];

    casks = [
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
    # Custom Keybindings for Workspaces (Cmd + 1, 2, 3, etc.)
    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Mission Control (Overview) - ID 32
          # This example maps it to Option + Space (as a middle ground)
          # "32" = { enabled = true; value = { parameters = [ 32 49 524288 ]; type = "standard"; }; };

          # Switch to Desktop 1 (Cmd + 1)
          "118" = {
            enabled = true;
            value = {
              parameters = [
                65535
                18
                1048576
              ];
              type = "standard";
            };
          };
          # Switch to Desktop 2 (Cmd + 2)
          "119" = {
            enabled = true;
            value = {
              parameters = [
                65535
                19
                1048576
              ];
              type = "standard";
            };
          };
          # Switch to Desktop 3 (Cmd + 3)
          "120" = {
            enabled = true;
            value = {
              parameters = [
                65535
                20
                1048576
              ];
              type = "standard";
            };
          };
          # Switch to Desktop 4 (Cmd + 4)
          "121" = {
            enabled = true;
            value = {
              parameters = [
                65535
                21
                1048576
              ];
              type = "standard";
            };
          };
          "122" = {
            enabled = true;
            value = {
              parameters = [
                65535
                23
                1048576
              ];
              type = "standard";
            };
          };
        };
      };
    };
  };

  # 4. SKHD - The "Aerospace Replacement"
  services.skhd = {
    enable = true;
    # Corrected option name: skhdConfig
    skhdConfig = ''
      # Open Browser (Zen)
      alt - w : open -na "Zen"

      # Open Terminal (Ghostty)
      alt - u : open -na "Ghostty"

      # Open Finder (Focuses it or opens a new window at Home)
      alt - r : open -a "Finder" ~

      # Close current Window
      alt - q : skhd -k "cmd - w"

      # Quit current App
      alt + shift - q : skhd -k "cmd - q"

      # Overview (Mission Control)
      # Ergonomic bind that doesn't conflict with Cmd+Space
      alt - space : open -a "Mission Control"
    '';
  };
  # 4. Global Shell Config
  programs.zsh.enable = true;

  services.tailscale.enable = true;
}
