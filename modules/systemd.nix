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
    path = [
      pkgs.nix
      pkgs.nixos-rebuild
      pkgs.git
      pkgs.coreutils
      pkgs.nvd
      pkgs.systemd
    ];

    script = ''
      ${pkgs.bash}/bin/sh /etc/nixos/scripts/update-nixos.sh
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.services."trigger-notify" = {
    path = [
      pkgs.systemd
      pkgs.coreutils
    ];

    script = ''
      systemctl --user --machine=caro@sheepytower start --wait notify-update.service
    '';

    serviceConfig = {
      Type = "oneshot";
    };

    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];

    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
  };

  systemd.user.services."notify-update" = {
    path = [
      pkgs.libnotify
      pkgs.coreutils
    ];

    script = ''
      ${pkgs.bash}/bin/sh /etc/nixos/scripts/notify-updates.sh
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "caro";
      Environment = "DISPLAY=:0";
    };
  };
}
