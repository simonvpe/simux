{ config, pkgs, lib, age, ... }:
{
  config = {
    programs.git.userName = "Simon Pettersson";
    programs.git.userEmail = "simpet@netinsight.net";
    programs.ssh.extraConfig = "Include ~/.ssh/config.neti";
    # age = {
    #   enable = true;
    #   uid = 1002;
    #   identities = [ ".ssh/id_ed25519" ];
    #   recipients = {
    #     hyperactivitydrive = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBl0x0lHyufCLVvRnyXoNQ+yokV+EwKFn+qkGpELGdo1 neti@hyperactivitydrive";
    #     battlestation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2olFcrre8xXEGuQIUauzQFiVfDzsGpsv5yLX4691Ud neti@battlestation";
    #   };
    #   secrets.".ssh/id_ed25519.neti".inputPath = "${./secrets}/id_ed25519.neti.age";
    #   secrets.".ssh/id_ed25519.neti.pass".inputPath = "${./secrets}/id_ed25519.neti.pass.age";
    #   secrets.".ssh/config.neti".inputPath = "${./secrets}/ssh.config.neti.age";
    #   secrets.".config/vpn.config".inputPath = "${./secrets}/vpn.config.age";
    # };
    # home.file.".ssh/id_ed25519.neti.pub".source = ../public-keys/id_ed25519.neti.pub;

    # services.ssh-agent = {
    #   enable = true;
    #   uid = 1002;
    #   keys = [
    #     {
    #       key = ".ssh/id_ed25519.neti";
    #       passphrase = ".ssh/id_ed25519.neti.pass";
    #     }
    #   ];
    # };
    # systemd.user.startServices = true;
  };
}
