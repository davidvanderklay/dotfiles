{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.mymod.home.niri;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.mymod.home.niri = {
    enable = lib.mkEnableOption "Niri window manager configuration";

    monitor = lib.mkOption {
      type = lib.types.str;
      default = "DP-3";
      description = "Monitor output name";
    };

    resolution = lib.mkOption {
      type = lib.types.str;
      default = "2560x1440";
      description = "Monitor resolution (e.g., 2560x1440)";
    };

    refreshRate = lib.mkOption {
      type = lib.types.str;
      default = "239.999";
      description = "Monitor refresh rate (e.g., 239.999)";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
      settings = { };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "niri msg action power-off-monitors";
          unlock_cmd = "niri msg action power-on-monitors";
          before_sleep_cmd = "niri msg action power-off-monitors";
        };

        listener = [
          {
            timeout = 60;
            on-timeout = "niri msg action power-off-monitors";
            on-resume = "niri msg action power-on-monitors";
          }
          {
            timeout = 600;
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
          active-color "#d1d1d1"
          inactive-color "#333333"
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
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Tab { toggle-overview; }
        
        Mod+U { spawn "ghostty"; }
        Mod+W { spawn "zen"; }
        Mod+R { spawn "nautilus"; }
        Mod+Space { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
        
        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }

        Mod+K { focus-window-or-workspace-up; }
        Mod+J { focus-window-or-workspace-down; }

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
        Mod+Shift+G { 
          spawn "sh" "-c" "if niri msg outputs | grep -A 3 '(${cfg.monitor})' | grep 'Variable refresh rate' | grep -q 'enabled'; then niri msg output ${cfg.monitor} vrr off && notify-send -t 1000 -u low 'VRR' 'OFF (Desktop Mode)'; else niri msg output ${cfg.monitor} vrr on && notify-send -t 1000 -u low 'VRR' 'ON (Gaming Mode)'; fi"
        }

        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+V { toggle-window-floating; }
        Mod+Shift+P { power-off-monitors; }
        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }
      }

      spawn-at-startup "noctalia-shell"
      spawn-at-startup "xwayland-satellite"

      output "${cfg.monitor}" {
        mode "${cfg.resolution}@${cfg.refreshRate}"
        background-color "#000000"
      }
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
    '';

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      XDG_SESSION_TYPE = "wayland";
      XCURSOR_THEME = "Bibata-Modern-Ice";
      XCURSOR_SIZE = "24";
    };

    home.packages = with pkgs; [
      hypridle
      xwayland-satellite
      swaybg
      wl-clipboard
      libnotify
      bibata-cursors
    ];

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };
}
