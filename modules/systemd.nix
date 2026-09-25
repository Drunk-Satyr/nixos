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
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "/etc/nixos/scripts/update-nixos.sh";
    };
  };
}
