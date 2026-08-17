{ ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 6;
  system.primaryUser = "geolan";
  users.users.geolan.home = "/Users/geolan";

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "geolan"
      ];
    };

    optimise.automatic = true;

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    enableZshIntegration = true;

    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    taps = [
      "homebrew/services"
      "anomalyco/tap"
      "jackielii/tap"
    ];

    brews = [
      "imagemagick"
      "jupytext"
      "ghostscript"
      "gh"
      "anomalyco/tap/opencode"
    ];

    casks = [
      "docker-desktop"
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
      "heroic"
      "obsidian"
      "t3-code@nightly"
      "stremio"
      "iloader"
      "codex"
      "silhouette-studio"
      "jackielii/tap/skhd-zig"
    ];
  };

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
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

  programs.zsh.enable = true;
  services.tailscale.enable = true;

  home-manager.users.geolan = import ../../profiles/darwin.nix;
}
