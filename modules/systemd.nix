{
  config,
  pkgs,
  lib,
  ...
}:

{
  systemd.timers."awaken-for-updates" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "update-nixos.service";
      OnCalendar = "05:00";
      WakeSystem = true;
      Persistent = false;
    };
  };

  systemd.services."update-nixos" = {
    script = ''
      set -eu
      [[ $(git status | grep "Changes not staged for commit:") ]]
      nix flake update --commit-lock-file
      nixos-rebuild switch
      nix-collect-garbage --delete-older-than 14d
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
