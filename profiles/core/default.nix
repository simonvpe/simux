{ self, config, lib, pkgs, ... }:
let inherit (lib) fileContents;
in
{
  imports = [ ../cachix ];

  time.timeZone = "Europe/Stockholm";

  nix.systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

  environment = {

    systemPackages = with pkgs; [
      #apps.nix-top
      binutils
      bottom
      coreutils
      curl
      direnv
      dnsutils
      dosfstools
      fd
      file
      git
      gptfdisk
      htop
      iputils
      jq
      lsof
      manix
      moreutils
      nix-index
      nload
      nmap
      nodePackages.bitwarden-cli
      ntfs3g
      ripgrep
      skim
      sshfs
      strace
      sysstat
      tree
      usbutils
      utillinux
      vim
      wget
      whois
    ];

    shellAliases = {
      top = "btm";
    };

    pathsToLink = [ "/libexec" ];
  };

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };

  services.earlyoom.enable = true;

  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nixpkgs.config.allowUnfree = true;
}
