{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.mymod.home.hyprland;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.mymod.home.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager configuration";

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
      default = "239.99";
      description = "Monitor refresh rate (e.g., 239.99)";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
      settings = { };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      settings = {
        "$mainMod" = "SUPER";

        misc = {
          focus_on_activate = true;
          key_press_enables_dpms = true;
        };

        monitor = [
          "${cfg.monitor}, ${cfg.resolution}@${cfg.refreshRate}, 0x0, 1"
        ];

        exec-once = [
          "noctalia-shell"
          "xwayland-satellite"
          "swaybg -c '#000000'"
        ];

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          repeat_delay = 250;
          repeat_rate = 40;
          accel_profile = "flat";
          force_no_accel = true;
          sensitivity = 0;
          touchpad.natural_scroll = false;
        };

        general = {
          gaps_in = 0;
          gaps_out = 0;
          border_size = 2;
          "col.active_border" = "rgb(d1d1d1)";
          "col.inactive_border" = "rgb(333333)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 0;
        };

        animations = {
          enabled = false;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        bind = [
          "$mainMod, Q, killactive,"
          "$mainMod SHIFT, Q, exec, hyprctl dispatch forcekillactive"

          " , F11, fullscreen, 0"
          "$mainMod SHIFT, F, togglefloating,"
          "$mainMod, F, fullscreen, 1"

          "$mainMod, U, exec, ghostty"
          "$mainMod, W, exec, zen"
          "$mainMod, R, exec, nautilus"
          "$mainMod, Space, exec, noctalia-shell ipc call launcher toggle"

          "$mainMod, H, movefocus, l"
          "$mainMod, L, movefocus, r"
          "$mainMod, K, movefocus, u"
          "$mainMod, J, movefocus, d"

          "$mainMod SHIFT, H, movewindow, l"
          "$mainMod SHIFT, L, movewindow, r"
          "$mainMod SHIFT, K, movewindow, u"
          "$mainMod SHIFT, J, movewindow, d"

          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"

          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"

          "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        ];

        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 60;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    gtk = {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style.name = "adwaita-dark";
    };

    dconf.settings."org/freedesktop/appearance".color-scheme = 1;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      XDG_SESSION_TYPE = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      GTK_THEME = "Adwaita:dark";
    };

    home.packages = with pkgs; [
      hypridle
      slurp
      grim
      wl-clipboard
      adwaita-icon-theme
      gnome-themes-extra
      xwayland-satellite
      bibata-cursors
    ];
  };
}
