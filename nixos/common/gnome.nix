{ config, pkgs, lib, inputs, ... }:

{
  # 1. PACKAGES & EXTENSIONS
  home.packages = with pkgs; [
    # Tools to manage GNOME locally if needed
    gnome-tweaks
    gnome-extension-manager 
    
    # Ensure standard apps are here
    nautilus # File Manager
    inputs.zen-browser.packages."${pkgs.system}".default
  ];

  xdg.mimeApps = {
      enable = true;
      defaultApplications = {
          "text/html" = "zen.desktop";
          "x-scheme-handler/http" = "zen.desktop";
          "x-scheme-handler/https" = "zen.desktop";
          "x-scheme-handler/about" = "zen.desktop";
          "x-scheme-handler/unknown" = "zen.desktop";
        };
    };


  # 4. DCONF SETTINGS (The Heavy Lifting)
  dconf.settings = {
    
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
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];

      show-screenshot-ui = ["<Super><Shift>s"];
    };

    "org/gnome/desktop/wm/keybindings" = {
      # Switch to workspace
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-5 = ["<Super>5"];
      switch-to-workspace-6 = ["<Super>6"];
      
      # Move window to workspace
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];
      move-to-workspace-5 = ["<Super><Shift>5"];
      move-to-workspace-6 = ["<Super><Shift>6"];
      
      # Close Window (Like a WM)
      close = ["<Super>q"];
      # --- ADD THIS LINE ---
      toggle-maximized = ["<Super>f"];
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
