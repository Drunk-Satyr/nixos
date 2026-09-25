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
      bash /etc/nixos/scripts/update-nixos.sh
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  # systemd.user.services."notify-update" = {
  #   script = ''
  #     ${pkgs.libnotify}/bin/notify-send "Applications have updated since you last were on." -a "System"
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #   };
  #   wantedBy = [ "graphical.target" ];
  # };
}
