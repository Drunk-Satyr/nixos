#!/bin/bash

WAKE_FLAG_FILE="/etc/nixos/logs/notify-on-wake.flag"

NOTIFY_SEND_BINARY=$@

UPDATE_CHECK=$(cat $WAKE_FLAG_FILE | grep "System updated while away.")
if [ $? -eq 0 ]; then
    $NOTIFY_SEND_BINARY 'System Updated' "Applications have updated since you last were on." -a "systemd" -u critical
fi

echo "" > $WAKE_FLAG_FILE
