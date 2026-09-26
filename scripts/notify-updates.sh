#!/bin/bash

WAKE_FLAG_FILE="/etc/nixos/logs/notify-on-wake.flag"

UPDATE_CHECK=$(cat $WAKE_FLAG_FILE | grep "System updated while away.")
if [ $? -eq 0 ]; then
    notify-send 'System Updated' "Applications have updated since you last were on." -a "systemd" -u critical
fi

echo "" > $WAKE_FLAG_FILE
