{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mymod.home.t3Code;

  # T3 Code updates itself only from a writable AppImage, so the app lives in
  # the home directory rather than the Nix store.
  # T3 keeps its own files in ~/.local/share/t3code, so the app gets its own directory.
  appDir = "${config.xdg.dataHome}/t3code-app";
  appImage = "${appDir}/T3-Code.AppImage";
  # Patched copy of the current AppImage, shared by the app and the t3 CLI.
  currentDir = "${appDir}/current";
  # Written by the launcher, not Home Manager, since it changes with the channel.
  desktopEntry = "${config.xdg.dataHome}/applications/t3code.desktop";

  # Electron's linked and dlopen'd libraries, mirroring nixpkgs' electron-bin.
  linkedLibs = with pkgs; [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libGL
    libdrm
    libgbm
    libsecret
    libxkbcommon
    libxshmfence
    nspr
    nss
    pango
    stdenv.cc.cc
    systemdLibs
    vulkan-loader
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxkbfile
  ];
  dlopenLibs = with pkgs; [
    libGL
    libnotify
    libpulseaudio
    libsecret
    pciutils
    vulkan-loader
  ];
  libDirs = libs: lib.concatMapStringsSep " " (pkg: "${lib.getLib pkg}/lib") libs;

  # Runs the bundled t3 CLI from the patched app. The app rewrites ~/.t3/bin/t3
  # with an AppImage mount launcher unless the file lacks its marker comment,
  # and NixOS cannot run that launcher, so this replaces it.
  t3Cli = pkgs.writeShellScriptBin "t3" ''
    export T3CODE_CLI_PATH="$HOME/.t3/bin/t3"
    export T3CODE_HOME="''${T3CODE_HOME:-$HOME/.t3}"
    export ELECTRON_RUN_AS_NODE=1
    root=${lib.escapeShellArg currentDir}
    if [ ! -x "$root/t3code" ]; then
      echo "T3 Code is not installed yet. Open the T3 Code app once." >&2
      exit 127
    fi
    exec "$root/t3code" "$root/resources/app.asar/apps/server/dist/bin.mjs" "$@"
  '';

  # Matches release tags for the channel the first download should follow.
  tagPattern = if cfg.channel == "stable" then "^v[0-9]+\\.[0-9]+\\.[0-9]+$" else "-nightly\\.";

  # Downloads the newest release on first run, then unpacks and patches each new
  # AppImage so it runs directly. appimage-run's sandbox would block sudo and
  # ssh for everything the app starts. After the in-app updater replaces the
  # file, this stops the copy the updater launched and relaunches the patched one.
  t3CodeLauncher = pkgs.writeShellApplication {
    name = "t3code";
    runtimeInputs = with pkgs; [
      appimage-run
      auto-patchelf
      coreutils
      curl
      jq
      patchelf
      procps
    ];
    text = ''
      dir=${lib.escapeShellArg appDir}
      app=${lib.escapeShellArg appImage}
      entry=${lib.escapeShellArg desktopEntry}
      mkdir -p "$dir" "$(dirname "$entry")"

      if [ ! -e "$app" ]; then
        tag=$(curl -fsSL "https://api.github.com/repos/pingdotgg/t3code/releases?per_page=50" \
          | jq -r --arg pattern ${lib.escapeShellArg tagPattern} \
            '[.[] | select(.tag_name | test($pattern))][0].tag_name')
        curl -fL -o "$app.tmp" \
          "https://github.com/pingdotgg/t3code/releases/download/$tag/T3-Code-''${tag#v}-x86_64.AppImage"
        chmod +x "$app.tmp"
        mv "$app.tmp" "$app"
      fi

      # Each AppImage version gets its own directory, named by the file's mtime.
      # The menu entry comes from the build itself, so its name and icon follow the
      # channel picked in T3's settings.
      prepare() {
        local target old
        target="patched-$(stat -c %Y "$app")"
        old=$(readlink "$dir/current" || true)
        [ "$old" = "$target" ] && return
        rm -rf "''${dir:?}/$target"
        appimage-run -x "$dir/$target" "$app"
        # AppImage-bundled desktop libraries Electron does not need.
        rm -rf "''${dir:?}/''${target:?}/usr"
        auto-patchelf --paths "$dir/$target" \
          --libs ${libDirs linkedLibs} \
          --append-rpaths ${libDirs dlopenLibs} \
          --ignore-missing libc.musl-x86_64.so.1
        ln -sf ${lib.getLib pkgs.vulkan-loader}/lib/libvulkan.so.1 "$dir/$target/libvulkan.so.1"
        ln -sfn "$target" "$dir/current"
        sed -e 's|^Exec=.*|Exec=t3code %U|' \
          -e "s|^Icon=.*|Icon=$dir/current/t3code.png|" \
          -e '/^MimeType=/d' \
          "$dir/current/t3code.desktop" > "$entry.tmp"
        mv "$entry.tmp" "$entry"
        if [ -n "$old" ]; then
          rm -rf "''${dir:?}/$old"
        fi
      }

      while :; do
        prepare
        before=$(stat -c %Y "$app")
        status=0
        APPIMAGE="$app" "$dir/current/t3code" "$@" || status=$?
        [ "$(stat -c %Y "$app")" = "$before" ] && exit "$status"
        # The updater starts the new AppImage itself; replace it with a patched copy.
        pkill -f -- "$app" || true
        rm -rf "''${XDG_CACHE_HOME:-$HOME/.cache}/appimage-run/$(sha256sum "$app" | cut -d " " -f 1)"
        # Relaunch without replaying the original URL.
        set --
      done
    '';
  };

  placeholderEntry = pkgs.writeText "t3code.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=T3 Code
    Exec=t3code %U
    Terminal=false
    Categories=Development;
    StartupWMClass=t3code
  '';
in
{
  options.mymod.home.t3Code = {
    enable = lib.mkEnableOption "T3 Code desktop app and URL handler";

    channel = lib.mkOption {
      type = lib.types.enum [
        "stable"
        "nightly"
      ];
      default = "nightly";
      description = "Release channel for the first download. After that, T3's own update setting decides.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      t3CodeLauncher
      t3Cli
    ];

    home.file.".t3/bin/t3".source = "${t3Cli}/bin/t3";

    # GUI apps started from a shell need the session's Wayland and DBus variables.
    systemd.user.services.dbus-update-activation-environment = {
      Unit = {
        Description = "Update DBus activation environment";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Gives a fresh machine a menu entry until the first launch writes the real one.
    home.activation.t3CodeDesktopEntry = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e ${lib.escapeShellArg desktopEntry} ]; then
        run mkdir -p ${lib.escapeShellArg (builtins.dirOf desktopEntry)}
        run cp ${placeholderEntry} ${lib.escapeShellArg desktopEntry}
        run chmod u+w ${lib.escapeShellArg desktopEntry}
      fi
    '';

    xdg.desktopEntries.t3-code-url-handler = {
      name = "T3 Code URL Handler";
      exec = "t3 %U";
      terminal = false;
      noDisplay = true;
      mimeType = [ "x-scheme-handler/t3code" ];
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications."x-scheme-handler/t3code" = "t3-code-url-handler.desktop";
    };
  };
}
