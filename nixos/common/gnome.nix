{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # 1. PACKAGES & EXTENSIONS
  home.packages = with pkgs; [
    # Tools to manage GNOME locally if needed
    gnome-tweaks
    gnome-extension-manager

    # Ensure standard apps are here
    nautilus # File Manager
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    # --- ADD THESE EXTENSIONS ---
    gnomeExtensions.appindicator
    gnomeExtensions.tiling-assistant
    gnomeExtensions.hot-edge
    gnomeExtensions.clipboard-indicator

    # Cool fonts I might need
    # --- The "Must Haves" for Discord/Web ---
    noto-fonts # The standard Google font family
    noto-fonts-cjk-sans # Fixes ▯▯▯ squares for Asian characters
    noto-fonts-color-emoji # Fixes broken/missing emojis 🦜
    liberation_ttf # Free replacement for Times/Arial (Metric compatible)

    # --- Microsoft Fonts (Optional but recommended) ---
    # These are the actual Windows fonts (Arial, Comic Sans, Verdana).
    # NOTE: You must allow 'unfree' packages in your flake for this to work.
    corefonts
    vista-fonts # Consolas, Calibri, etc.
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/about" = "zen-beta.desktop";
      "x-scheme-handler/unknown" = "zen-beta.desktop";
    };
  };

  xdg.configFile."autostart/org.localsend.localsend_app.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=LocalSend
    Exec=localsend --hidden
    Icon=localsend
    Comment=An open source cross-platform alternative to AirDrop
    X-GNOME-Autostart-enabled=true
  '';

  # --- ADD THIS BLOCK ---
  # This generates ~/.config/gtk-3.0/settings.ini which Flutter apps read
  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  # ----------------------
  # 4. DCONF SETTINGS (The Heavy Lifting)
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "tiling-assistant@leleat-on-github"
        "hotedge@jonathan.jdoda.ca"
        "clipboard-indicator@tudmotu.com"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    # --- CLIPBOARD INDICATOR SETTINGS (Optional tweaks) ---
    "org/gnome/shell/extensions/clipboard-indicator" = {
      move-item-first = true;
      history-size = 50;
    };

    # --- MOUSE SETTINGS ---
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0.0; # Adjust if needed
    };

    # --- WORKSPACE BEHAVIOR (Static, 6 desktops) ---
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 6;
    };

    # --- KEYBINDINGS: WORKSPACE SWITCHING (WM Style) ---
    # Unbind default shell shortcuts that conflict (like App switching)
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      switch-to-application-5 = [ ];
      switch-to-application-6 = [ ];

      show-screenshot-ui = [ "<Super><Shift>s" ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      # Switch to workspace
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];

      # --- DISABLE DEFAULT SWIPING ---
      # This stops Ctrl+Alt+Left/Right from switching workspaces
      switch-to-workspace-left = [ ];
      switch-to-workspace-right = [ ];

      # (Optional) This stops Shift+Ctrl+Alt+Left/Right from moving windows to other workspaces
      move-to-workspace-left = [ ];
      move-to-workspace-right = [ ];

      # Move window to workspace
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
      move-to-workspace-5 = [ "<Super><Shift>5" ];
      move-to-workspace-6 = [ "<Super><Shift>6" ];

      # Close Window (Like a WM)
      close = [ "<Super>q" ];
      # --- ADD THIS LINE ---
      toggle-maximized = [ "<Super>f" ];
      # Fullscreen (hide title bar/top bar) - THIS IS THE NEW LINE
      toggle-fullscreen = [ "<Super><Shift>f" ];
    };

    # --- CUSTOM KEYBINDINGS (Terminal, Browser, Files) ---
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
      ];
    };

    # Meta + u -> Terminal (Ghostty)
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>u";
      command = "ghostty";
      name = "Terminal";
    };

    # Meta + w -> Browser (Firefox)
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>w";
      command = "zen"; # Change to google-chrome-stable if you use Chrome
      name = "Browser";
    };

    # Meta + r -> Files (Nautilus/Home)
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>r";
      command = "nautilus";
      name = "File Manager";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Control><Shift>Escape";
      command = "gnome-system-monitor";
      name = "System Monitor";
    };
  };
}
