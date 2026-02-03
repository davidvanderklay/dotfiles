{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Import your existing GTK and font settings from your GNOME config
  # so your apps still look dark and clean.

  home.packages = with pkgs; [
    # The Core
    niri
    noctalia # Assuming this is in your nixpkgs or overlay

    # Gaming & Wayland Utilities
    xwayland-satellite # Better Xwayland support for Niri
    wl-clipboard
    swaybg # For wallpaper
    swaylock-effects
    wlogout

    # Your preferred apps (from your GNOME config)
    ghostty
    nautilus
    gnome-system-monitor
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  # Niri Configuration
  programs.niri.settings = {
    # --- INPUT & NVIDIA ---
    input = {
      mouse = {
        accel-speed = 0.0;
        accel-profile = "flat";
      };
      touchpad = {
        tap = true;
        dwt = true;
      };
      keyboard.repeat-delay = 250;
      keyboard.repeat-rate = 40;
    };

    # --- APPEARANCE ---
    layout = {
      gaps = 12;
      center-focused-column = "never";
      default-column-width = {
        proportion = 0.5;
      };
      focus-ring = {
        enable = true;
        width = 2;
        active-color = "#7aa2f7"; # Nice blue
        inactive-color = "#414868";
      };
    };

    # --- WINDOW RULES (Gaming & Fixes) ---
    window-rules = [
      # Disable shadows/blur for games to save frames
      {
        matches = [ { is-active = true; } ];
        add-column-width = 10;
      }
      # Make sure games go fullscreen properly
      {
        matches = [ { title = ".*"; } ]; # Generic catch-all
        exclude-titles = [ "Steam" ];
        draw-border-with-background = false;
      }
    ];

    # --- KEYBINDINGS (Vim-style + Your GNOME Binds) ---
    binds = with config.lib.niri.actions; {
      # Terminal & Apps
      "Super+U".action = spawn "ghostty";
      "Super+W".action = spawn "zen";
      "Super+R".action = spawn "nautilus";
      "Control+Shift+Escape".action = spawn "gnome-system-monitor";

      # WM Basics
      "Super+Q".action = close-window;
      "Super+F".action = maximize-column;
      "Super+Shift+F".action = fullscreen-window;
      "Super+Space".action = spawn "noctalia-launcher"; # Noctalia's app runner

      # --- VIM MOVEMENT (HJKL) ---
      # Focus movement
      "Super+H".action = focus-column-left;
      "Super+L".action = focus-column-right;
      "Super+K".action = focus-window-or-workspace-up;
      "Super+J".action = focus-window-or-workspace-down;

      # Moving windows
      "Super+Shift+H".action = move-column-left;
      "Super+Shift+L".action = move-column-right;
      "Super+Shift+K".action = move-window-up;
      "Super+Shift+J".action = move-window-down;

      # Resizing (Vim-ish)
      "Super+Minus".action = set-column-width "-10%";
      "Super+Equal".action = set-column-width "+10%";

      # --- WORKSPACES (1-6) ---
      "Super+1".action = focus-workspace 1;
      "Super+2".action = focus-workspace 2;
      "Super+3".action = focus-workspace 3;
      "Super+4".action = focus-workspace 4;
      "Super+5".action = focus-workspace 5;
      "Super+6".action = focus-workspace 6;

      "Super+Shift+1".action = move-window-to-workspace 1;
      "Super+Shift+2".action = move-window-to-workspace 2;
      "Super+Shift+3".action = move-window-to-workspace 3;
      "Super+Shift+4".action = move-window-to-workspace 4;
      "Super+Shift+5".action = move-window-to-workspace 5;
      "Super+Shift+6".action = move-window-to-workspace 6;

      # Screenshots (Like your GNOME bind)
      "Super+Shift+S".action = screenshot;
    };

    # Start Noctalia Shell on boot
    spawn-at-startup = [
      { command = [ "noctalia" ]; }
      { command = [ "xwayland-satellite" ]; } # Essential for X11 gaming
    ];
  };

  # --- NVIDIA SPECIFIC ENVIRONMENT VARIABLES ---
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";

    # NVIDIA Fixes
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1"; # Stops the cursor from disappearing
  };

  # Re-use your GTK theme settings
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };
}
