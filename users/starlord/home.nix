{ config
, ...
}:
{
  config = {
    programs.git.userName = "Simon Pettersson";
    programs.git.userEmail = "simon@thesourcerer.se";

    programs.ssh.extraConfig = "Include ~/.ssh/config.starlord";
    systemd.user.startServices = "sd-switch";

    age = {
      enable = true;
      uid = 1000;
      identities = [ ".ssh/id_ed25519" ];
      recipients = {
        hyperactivitydrive = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFj4hF3gCgGkoRwfURZOI7wUY/HM/C404Vv7zxmNNlMX simon@thesourcerer.se";
      };
      secrets.".ssh/id_ed25519.starlord".inputPath = "${./secrets}/id_ed25519.starlord.age";
      secrets.".ssh/config.starlord".inputPath = "${./secrets}/ssh.config.starlord.age";
    };

    home.file = {
      ".ssh/id_ed25519.starlord.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpAEQtDJym2oytUzIzKV6/ZNvqKbF+kUIZn+J3CoBK3 starlord@hyperactivitydrive";
    };

    services.ssh-agent = {
      enable = true;
      uid = 1000;
      # TODO: stupid stupi XDG_RUNTIME_DIR!
      sshAuthSock = "/run/user/1000/ssh-agent.sock";
      keys = [
        {
          key = ".ssh/id_ed25519.starlord";
        }
      ];
    };

  };
}
