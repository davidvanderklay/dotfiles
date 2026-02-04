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

  xdg.configFile."niri/config.kdl".text = ''
    input {
      keyboard {
        repeat-delay 250
        repeat-rate 40
      }
      mouse {
        accel-profile "flat"
      }
      focus-follows-mouse
      warp-mouse-to-focus
    }

    layout {
      gaps 12
      border {
        width 2
        active-color "#d1d1d1"    // Pure White
        inactive-color "#333333"  // Dark Grey
      }
      focus-ring {
        off
      }
    }

    binds {
      Mod+Q { close-window; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      
      Mod+U { spawn "ghostty"; }
      Mod+W { spawn "zen"; }
      Mod+R { spawn "nautilus"; }
      Mod+Space { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
      
      Mod+H { focus-column-left; }
      Mod+L { focus-column-right; }
      Mod+K { focus-window-up; }
      Mod+J { focus-window-down; }
      
      Mod+Shift+H { move-column-left; }
      Mod+Shift+L { move-column-right; }
      Mod+Shift+K { move-window-up; }
      Mod+Shift+J { move-window-down; }
      
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      
      Mod+Shift+1 { move-column-to-workspace 1; }
      Mod+Shift+2 { move-column-to-workspace 2; }
      Mod+Shift+3 { move-column-to-workspace 3; }
      Mod+Shift+4 { move-column-to-workspace 4; }
      Mod+Shift+5 { move-column-to-workspace 5; }
      Mod+Shift+6 { move-column-to-workspace 6; }
      
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
  };

  home.packages = with pkgs; [
    xwayland-satellite # Allows Steam/X11 games to run on Niri
    swaybg # Wallpaper support
    grim # Screenshot tool
    wl-clipboard # Wayland clipboard
  ];
}
