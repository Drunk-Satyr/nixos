#!/bin/bash

BASE_NIXOS_DIR="/etc/nixos"
BASE_LOGS_DIR="$BASE_NIXOS_DIR/logs"
JOURNALCTL_LOG_FILE="$BASE_LOGS_DIR/journalctl.log"
FLAKE_LOG_FILE="$BASE_LOGS_DIR/flake.log"
REBUILD_LOG_FILE="$BASE_LOGS_DIR/rebuild.log"
PRUNED_LOG_FILE="$BASE_LOGS_DIR/pruned.log"
LAST_CONFIGURATION_FILE="$BASE_LOGS_DIR/last_configuration"
LATEST_UPDATE_FILE="$BASE_LOGS_DIR/latest-update.log"
ALL_UPDATES_FILE="$BASE_LOGS_DIR/all-updates.log"
UPDATE_NIXOS_FILE="$BASE_LOGS_DIR/update-nixos.log"
NOTIFY_ON_WAKE_FLAG="$BASE_LOGS_DIR/notify-on-wake.flag"
WAS_SLEEPING=0 # defaults to false

log() {
    TIMESTAMP=$(date +%Y/%m/%d-%H:%M:%S)
    logString="[$TIMESTAMP] $@"
    echo $logString
    echo $logString >> $UPDATE_NIXOS_FILE
}

wasSystemAwokenFromSleep() {
    log "Checking sleep state..."
    SLEEP_OUTPUT=$(journalctl -n4 -u sleep.target --since "5 minutes ago" -n 1 --no-tail | grep "Stopped target Sleep.")
    if [ $? -eq 0 ]; then
        $WAS_SLEEPING=1
        log "The device has awoken from sleep within the past 5 minutes, will sleep once script is complete."
    else
        log "The device was already awake, will stay awake once script is complete."
    fi
    log WAS_SLEEPING=$WAS_SLEEPING >> $JOURNALCTL_LOG_FILE
    log journalctl output: $SLEEP_OUTPUT >> $JOURNALCTL_LOG_FILE
}

exitIfDirtyRepo() {
    git status | grep "Changes not staged for commit:" >/dev/null
    if [ $? -eq 0 ]; then
        log "Unstaged commits detected, cancelling automatic update until repo is no longer dirty."

        powerManagement # return system to prior state
    fi
}

updateFlake() {
    log "Attempting to update flake and commit lock file..."
    FLAKE_OUTPUT=$(nix flake update --commit-lock-file 2>&1)
    log $FLAKE_OUTPUT >> /etc/nixos/logs/flake.log

    echo $FLAKE_OUTPUT | grep "Updated" >/dev/null
    if [ $? -eq 0 ]; then
        UPDATE_COUNT=$(echo $FLAKE_OUTPUT | wc -l)
        log "Updated $UPDATE_COUNT flake(s)."
    else
        log "No flakes to update."
    fi
}

rebuildNixos() {
    log "Attempting to build system..."

    REBUILD_OUTPUT=$(nixos-rebuild switch 2>&1)
    log $REBUILD_OUTPUT >> $REBUILD_LOG_FILE

    CURRENT_CONFIGURATION=$(echo $REBUILD_OUTPUT | grep -Po "(?<=The new configuration is /nix/store/).+$") # (?='$)
    LAST_CONFIGURATION=$(cat $LAST_CONFIGURATION_FILE)
    if [ $CURRENT_CONFIGURATION == $LAST_CONFIGURATION ]; then
        log "No change to configuration."
        echo "No system updates while away today." >> $NOTIFY_ON_WAKE_FLAG
    else
        BUILT_PACKAGES=$(echo $REBUILD_OUTPUT | grep "^Building")
        if [ $? -eq 0 ]; then 
            BUILT_COUNT=$(echo $BUILT_PACKAGES | wc -l)
            log "Built $BUILD_COUNT package(s)."
        else
            log "Built no packages."
        fi
        log "Updated from $LAST_CONFIGURATION to $CURRENT_CONFIGURATION"

        nvd diff $(ls -d1v /nix/var/nix/profiles/system-*-link|tail -n 2) > $LATEST_UPDATE_FILE
        log "System updated." >> $ALL_UPDATES_FILE
        cat $LATEST_UPDATE_FILE >> $ALL_UPDATES_FILE
        echo "System updated while away." >> $NOTIFY_ON_WAKE_FLAG
    fi
    echo $CURRENT_CONFIGURATION > $LAST_CONFIGURATION_FILE
}

prunePackages() {
    PRUNED_OUTPUT=$(nix-collect-garbage --delete-older-than 14d 2>&1)
    log $PRUNED_OUTPUT >> $PRUNED_LOG_FILE

    DELETED_PACKAGES_COUNT=$(echo $PRUNED_OUTPUT | grep -o "deleting" | wc -l | awk '{$1--;$1--}1')
    log "Pruned $DELETED_PACKAGES_COUNT unused package(s) over 14 days old."
}

powerManagement() {
    REBOOT_HISTORY=$(journalctl -u reboot.target --since "1 week ago" | grep "systemd")
    REBOOT_DETECTED=$?
    POWEROFF_HISTORY=$(journalctl -u poweroff.target --since "1 week ago" | grep "systemd")
    POWEROFF_DETECTED=$?
    if [ $(date +%u) -eq 7 ]; then
        log "For stability reasons, a full system shutdown is required at least once a week."
        if [ $REBOOT_DETECTED -eq 0 -o $POWEROFF_DETECTED -eq 0 ]; then
            log "System has already been rebooted or shutdown this week."
        else
            log "System has not been powered off or restart for over a week, shutting down."
            systemctl poweroff
        fi
    else
        if [ $WAS_SLEEPING -eq 1 ]; then
            log "Returning system to sleep."
            systemctl suspend
        fi
    fi
}

# ensures all commands are run in the correct place
cd $BASE_NIXOS_DIR

# checks if system just awoke from sleep
wasSystemAwokenFromSleep

# doesn't build when there are uncommitted
# changes in the repository
exitIfDirtyRepo

# update the flake-managed packages
updateFlake

# rebuild the NixOS system
rebuildNixos

# deletes unused packages older than 14 days
prunePackages

# prepareUpdateForWake

# if the system was awoken by the systemd
# service, then return it to sleep, with
# a special exception in the event the
# system has not been fully powered down
# (meaning a shutdown or restart) within
# a week.
powerManagement
