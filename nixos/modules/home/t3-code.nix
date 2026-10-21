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
  appDir = "${config.xdg.dataHome}/t3code";
  appImage = "${appDir}/T3-Code-Nightly.AppImage";
  # Extracted copy of the current AppImage, shared by the app and the t3 CLI.
  currentDir = "${appDir}/current";

  # Runs the bundled t3 CLI from the extracted app through nix-ld. The app
  # rewrites ~/.t3/bin/t3 with an AppImage mount launcher unless the file lacks
  # its marker comment, and appimage-run cannot mount, so this replaces it.
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

  # Downloads the newest nightly on first run, extracts each new AppImage, and
  # relaunches after the in-app updater replaces the file. The updater's own
  # relaunch dies with the appimage-run sandbox.
  t3CodeLauncher = pkgs.writeShellApplication {
    name = "t3code";
    runtimeInputs = with pkgs; [
      appimage-run
      coreutils
      curl
      jq
    ];
    text = ''
      dir=${lib.escapeShellArg appDir}
      app=${lib.escapeShellArg appImage}
      mkdir -p "$dir"

      if [ ! -e "$app" ]; then
        tag=$(curl -fsSL "https://api.github.com/repos/pingdotgg/t3code/releases?per_page=50" \
          | jq -r '[.[] | select(.tag_name | test("-nightly\\."))][0].tag_name')
        curl -fL -o "$app.tmp" \
          "https://github.com/pingdotgg/t3code/releases/download/$tag/T3-Code-''${tag#v}-x86_64.AppImage"
        chmod +x "$app.tmp"
        mv "$app.tmp" "$app"
      fi

      extract() {
        local stamp old
        stamp=$(stat -c %Y "$app")
        [ "$(cat "$dir/current/.stamp" 2>/dev/null)" = "$stamp" ] && return
        rm -rf "$dir/extract.tmp"
        appimage-run -x "$dir/extract.tmp" "$app"
        echo "$stamp" > "$dir/extract.tmp/.stamp"
        old=$(readlink "$dir/current" || true)
        mv "$dir/extract.tmp" "$dir/app-$stamp"
        ln -sfn "app-$stamp" "$dir/current"
        if [ -n "$old" ] && [ "$old" != "app-$stamp" ]; then
          rm -rf "''${dir:?}/$old"
        fi
      }

      while :; do
        extract
        before=$(stat -c %Y "$app")
        status=0
        APPIMAGE="$app" appimage-run -w "$dir/current" -- "$@" || status=$?
        [ "$(stat -c %Y "$app")" = "$before" ] && exit "$status"
        # Relaunch the updated app without replaying the original URL.
        set --
      done
    '';
  };
in
{
  options.mymod.home.t3Code.enable = lib.mkEnableOption "T3 Code desktop app and URL handler";

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

    xdg.desktopEntries.t3-code-nightly = {
      name = "T3 Code (Nightly)";
      exec = "t3code %U";
      icon = "${currentDir}/t3code.png";
      terminal = false;
      categories = [ "Development" ];
      settings.StartupWMClass = "t3code";
    };

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
