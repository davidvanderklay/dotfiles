{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # To this:
  programs.noctalia-shell = {
    enable = true;
    settings = {
      # your config here
    };
  };

  # 2. GTK Theming (Top level)
  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  # 3. Qt Theming (Top level)
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # 4. Dconf / Dark Mode Preference (Top level)
  dconf.settings = {
    "org/freedesktop/appearance" = {
      color-scheme = 1; # 1 = Prefer Dark
    };
  };

  # 5. XDG Portals (Crucial for dark mode to "broadcast" to apps)
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # This avoids starting multiple instances
        lock_cmd = "niri msg action power-off-monitors";
        unlock_cmd = "niri msg action power-on-monitors";
        # This ensures the screen turns off before the computer suspends
        before_sleep_cmd = "niri msg action power-off-monitors";
      };

      listener = [
        {
          timeout = 60; # 5 minutes (300 seconds)
          # What to do when the timeout is reached
          on-timeout = "niri msg action power-off-monitors";
          # What to do when you move the mouse/type again
          on-resume = "niri msg action power-on-monitors";
        }
        {
          timeout = 600; # 10 minutes
          # Optional: Actually suspend the PC after 10 mins of inactivity
          # on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  xdg.configFile."niri/config.kdl".text = ''
    prefer-no-csd
    workspace "1"
    workspace "2"
    workspace "3"
    workspace "4"
    workspace "5"
    workspace "6"
    input {
      keyboard {
        repeat-delay 250
        repeat-rate 40
      }
      mouse {
        accel-profile "flat"
      }
      focus-follows-mouse
    }

    layout {
      gaps 0
      border {
        width 2
        active-color "#d1d1d1"    // Pure White
        inactive-color "#333333"  // Dark Grey
      }
      focus-ring {
        off
      }
    }

    hotkey-overlay {
        skip-at-startup
    }

    binds {
      Mod+Q { close-window; }
      Mod+Shift+Q { spawn "sh" "-c" "niri msg --json focused-window | jq .pid | xargs kill -9"; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+Tab { toggle-overview; }
      
      Mod+U { spawn "ghostty"; }
      Mod+W { spawn "zen"; }
      Mod+R { spawn "nautilus"; }
      Mod+Space { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
      
      Mod+H { focus-column-left; }
      Mod+L { focus-column-right; }

      // CHANGE THESE: This allows J and K to move between workspaces too
      Mod+K { focus-window-or-workspace-up; }
      Mod+J { focus-window-or-workspace-down; }

      // Do the same for moving windows/columns
      Mod+Shift+K { move-window-up-or-to-workspace-up; }
      Mod+Shift+J { move-window-down-or-to-workspace-down; }
      
      Mod+Shift+H { move-column-left; }
      Mod+Shift+L { move-column-right; }
      
      Mod+1 { focus-workspace "1"; }
      Mod+2 { focus-workspace "2"; }
      Mod+3 { focus-workspace "3"; }
      Mod+4 { focus-workspace "4"; }
      Mod+5 { focus-workspace "5"; }
      Mod+6 { focus-workspace "6"; }

      Mod+Shift+1 { move-column-to-workspace "1"; }
      Mod+Shift+2 { move-column-to-workspace "2"; }
      Mod+Shift+3 { move-column-to-workspace "3"; }
      Mod+Shift+4 { move-column-to-workspace "4"; }
      Mod+Shift+5 { move-column-to-workspace "5"; }
      Mod+Shift+6 { move-column-to-workspace "6"; }
      
      Mod+Shift+S { screenshot; }

      Mod+Shift+Slash { show-hotkey-overlay; }
    }

    spawn-at-startup "noctalia-shell"
    spawn-at-startup "xwayland-satellite"

    output "DP-3" {
      mode "2560x1440@239.999"  // Must match EXACTLY from niri msg outputs
      background-color "#000000"
    }
  '';

  # Environment variables to force Wayland on Nvidia
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1"; # Stops the cursor from being invisible
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    # Theme Variables
    GTK_THEME = "Adwaita:dark";
  };

  home.packages = with pkgs; [
    hypridle
    xwayland-satellite # Allows Steam/X11 games to run on Niri
    swaybg # Wallpaper support
    grim # Screenshot tool
    wl-clipboard # Wayland clipboard
    adwaita-icon-theme
    gnome-themes-extra
  ];
}
