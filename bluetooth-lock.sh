#!/bin/bash

log () {
    echo -e "$1"
    echo -e "$1" >> log.txt
}

current_date_time=$(date)
echo "Start script @ $current_date_time" > log.txt

# MAC-Adresse des Bluetooth-Geräts
if [ ! -f "device.txt" ]; then
    echo "00:00:00:00:00:00" > "device.txt"
fi

BT_DEVICE=`cat device.txt`
if [ "${BT_DEVICE}" == "00:00:00:00:00:00" ]; then
    echo "Please enter the mac address or your bluetooth device in device.txt"
    exit 0
fi

AUTOSTART_FILE="$HOME/.profile"
SCRIPT_PATH=$(readlink -f "$0")
TEST="0"

if [ "$1" == "--install" ]; then
    # Prüfen, ob der Autostart-Eintrag schon existiert
    if ! grep -q "${SCRIPT_PATH}" "${AUTOSTART_FILE}"; then
        echo "Install ${SCRIPT_PATH} to ${AUTOSTART_FILE}"
        echo "bash $SCRIPT_PATH" >> "$AUTOSTART_FILE"
    else
        echo "${SCRIPT_PATH} was already installed to ${AUTOSTART_FILE}"
    fi
    exit 0
fi

if ! grep -q "${SCRIPT_PATH}" "${AUTOSTART_FILE}"; then
    echo "In order to run this script automatically on every login, please start it with the following command"
    echo "./bluetooth-lock.sh --install"
fi

if [ "$1" == "--test" ]; then
    echo "TEST MODE"
    TEST="1"
fi

while true; do
    current_date_time=$(date)
    log "Search for device ${BT_DEVICE} @ ${current_date_time}"
    BT_NAME=`hcitool name $BT_DEVICE`
    log "Detected ${BT_NAME}"
    # Prüfen, ob das Gerät in der Nähe ist
    if [ "" == "${BT_NAME}" ]; then
        # Wenn das Gerät nicht gefunden wurde, Benutzer abmelden
        log "lock session"
        if [ "${TEST}" == "0" ]; then
            loginctl lock-session
        else
            log "(locking prevented as TEST is ${TEST})"
        fi
    else
        log "device present - unlock session"
        if [ "${TEST}" == "0" ]; then
            loginctl unlock-session
        else
            log "(unlocking prevented as TEST is ${TEST})"
        fi
    fi
    sleep 10
done
