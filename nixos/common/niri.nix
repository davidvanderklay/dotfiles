{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  # Noctalia Shell Configuration
  programs.noctalia = {
    enable = true;
    settings = {
      # Noctalia is designed to be minimal.
      # It handles the bar and the launcher automatically.
    };
  };

  # Niri Compositor Configuration
  programs.niri.settings = {
    # --- NVIDIA & INPUT ---
    input = {
      mouse.accel-profile = "flat";
      keyboard.repeat-delay = 250;
      keyboard.repeat-rate = 40;
    };

    # --- COSMETICS ---
    layout = {
      gaps = 12;
      border = {
        enable = true;
        width = 2;
        active-color = "#7aa2f7"; # You can change these to match your theme
        inactive-color = "#414868";
      };
      focus-ring.enable = false; # We use borders instead
    };

    # --- VIM BINDINGS & YOUR GNOME BINDS ---
    binds = with config.lib.niri.actions; {
      # Basic WM Ops
      "Super+Q".action = close-window;
      "Super+F".action = maximize-column;
      "Super+Shift+F".action = fullscreen-window;
      "Super+Space".action = spawn "noctalia-launcher";

      # Your GNOME App Binds
      "Super+U".action = spawn "ghostty";
      "Super+W".action = spawn "zen";
      "Super+R".action = spawn "nautilus";
      "Control+Shift+Escape".action = spawn "gnome-system-monitor";

      # --- VIM MOVEMENT (HJKL) ---
      # Focus windows/columns
      "Super+H".action = focus-column-left;
      "Super+L".action = focus-column-right;
      "Super+K".action = focus-window-or-workspace-up;
      "Super+J".action = focus-window-or-workspace-down;

      # Move windows/columns
      "Super+Shift+H".action = move-column-left;
      "Super+Shift+L".action = move-column-right;
      "Super+Shift+K".action = move-window-up;
      "Super+Shift+J".action = move-window-down;

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

      # Screenshot (Matching your GNOME bind)
      "Super+Shift+S".action = screenshot;
    };

    # --- STARTUP ---
    spawn-at-startup = [
      { command = [ "xwayland-satellite" ]; } # ESSENTIAL FOR NVIDIA GAMING
      {
        command = [
          "swaybg"
          "-m"
          "fill"
          "-i"
          "${../wallpapers/your_wallpaper.png}"
        ];
      }
    ];
  };

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
    wl-clipboard # Wayland clipboard
  ];
}
