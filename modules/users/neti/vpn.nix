{ config, pkgs, lib, ... }:
with pkgs.lib;
let cfg = config.services.vpn;
    inherit (pkgs) openfortivpn writeScriptBin nodePackages crudini;
    inherit (pkgs) fetchFromGitHub bash coreutils systemd writeScript;
    inherit (nodePackages) bitwarden-cli;
    inherit (builtins) toString;
    inherit (lib) mkOption;
    path = "PATH=${systemd}/bin:${coreutils}/bin:${crudini}/bin:/run/wrappers/bin";
in
{
  options.services.vpn.package = mkOption {
      type = types.package;
      default = openfortivpn;
  };

  options.services.vpn.pppdIFName = mkOption {
    type = types.str;
    default = "ppp0";
  };

  options.services.vpn.cfgPath = mkOption {
    type = types.str;
    default = "/tmp/cfg";
  };

  options.services.vpn.configFile = mkOption {
    type = types.str;
    description = "The openfortivpn config to use";
  };

  options.services.vpn.timeoutSec = mkOption {
    type = types.int;
    default = 100;
  };

  config = {
    # home.packages = [ cfg.package ];

    systemd.user.services.vpn = {
      Unit = {
        Description = "Neti VPN";
        After = [ "networking.target" ];
      };
      Service = rec {
        Type = "exec";
        Restart = "always";
        TimeoutSec = toString cfg.timeoutSec;
        PrivateTmp = "yes";
        ExecStartPre = toString (writeScript "preExec" ''
          #!${bash}/bin/bash
          export ${path}
          cp ${cfg.configFile} ${cfg.cfgPath}
          crudini --set ${cfg.cfgPath} "" use-resolvconf 1
          crudini --set ${cfg.cfgPath} "" pppd-ifname ${cfg.pppdIFName}
        '');
        ExecStart = toString (writeScript "exec" ''
          #!${bash}/bin/bash
          export ${path}
          sudo ${cfg.package}/bin/openfortivpn -c ${cfg.cfgPath}
        '');
        ExecStartPost = toString (writeScript "postExec" ''
          #!${bash}/bin/bash
          export ${path}
          while ! test -d "/sys/class/net/${cfg.pppdIFName}"; do
            echo "waiting for ${cfg.pppdIFName}" >&2
            sleep 1
          done
          sudo resolvectl dnssec ppp0 false
          sudo resolvectl reset-server-features
        '');
      };
      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };

  };
}
