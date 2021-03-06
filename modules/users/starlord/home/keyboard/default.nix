{ pkgs, ... }:

pkgs.writeTextFile {
  name = "keyboard";
  executable = true;
  text = ''
    #!/usr/bin/env bash
    set -o pipefail -o nounset -o errexit

    readonly state="/run/user/$(id -u)/keyboard"

    if [[ -n "''${1:-}" ]] ;then
        setxkbmap $1 -print | xkbcomp -I$HOME/.xkb -w 0 - $DISPLAY
        printf '%s\n' $1 > ''${state}
    else
        if [[ -f "''${state}" ]]; then
            case "$(< ''${state})" in
                evorak) "$0" svorak ;;
                svorak) "$0" evorak ;;
            esac
        else
            "$0" evorak
        fi
    fi
  '';
}
