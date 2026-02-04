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

  programs.noctalia-shell = {
    enable = true;
    settings = {
      # your noctalia settings here
    };
  };

  # Hyprland Configuration
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$mainMod" = "SUPER";

      monitor = [
        "DP-3, 2560x1440@239.99, 0x0, 1"
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
        touchpad.natural_scroll = false;
      };

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 2;
        "col.active_border" = "rgb(d1d1d1)";
        "col.inactive_border" = "rgb(333333)";
        layout = "dwindle"; # Traditional tiling
      };

      decoration = {
        rounding = 0;
      };

      animations = {
        enabled = false; # Set to true if you want them
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      bind = [
        "$mainMod, Q, killactive,"
        "$mainMod SHIFT, Q, exec, hyprctl dispatch forcekillactive"
        "$mainMod, F, togglefloating,"
        "$mainMod, Shift+F, fullscreen, 0"

        # Apps
        "$mainMod, U, exec, ghostty"
        "$mainMod, W, exec, zen"
        "$mainMod, R, exec, nautilus"
        "$mainMod, Space, exec, noctalia-shell ipc call launcher toggle"

        # Focus (HJKL)
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        # Move Windows (Shift + HJKL)
        "$mainMod SHIFT, H, movewindow, l"
        "$mainMod SHIFT, L, movewindow, r"
        "$mainMod SHIFT, K, movewindow, u"
        "$mainMod SHIFT, J, movewindow, d"

        # Workspaces (1-6)
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"

        # Move to Workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"

        # Screenshot
        "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
      ];

    };
  };

  # Update Hypridle to use hyprctl
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # Theming & GTK (Kept from your original)
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
    WLR_NO_HARDWARE_CURSORS = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    GTK_THEME = "Adwaita:dark";
  };

  home.packages = with pkgs; [
    hypridle
    slurp # Added for screenshots
    grim
    wl-clipboard
    adwaita-icon-theme
    gnome-themes-extra
    xwayland-satellite
  ];
}
