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

AUTOSTART_DIR="${HOME}/.config/autostart"
DESKTOP_FILE="${AUTOSTART_DIR}/bluetooth-lock.sh.desktop"
TEST="0"

if [ "$1" == "--test" ]; then
    echo "TEST MODE"
    TEST="1"
fi

if [ "$1" == "--install" ]; then
    SCRIPT_PATH=$(readlink -f "$0")

    # Autostart-Verzeichnis erstellen, falls nicht vorhanden
    mkdir -p "${AUTOSTART_DIR}"

    # Inhalt der .desktop-Datei
    unlink "${DESKTOP_FILE}"
    echo "[Desktop Entry]" > ${DESKTOP_FILE}
    echo "Type=Application" >> ${DESKTOP_FILE}
    echo "Exec=\"${SCRIPT_PATH}\"" >> ${DESKTOP_FILE}
    echo "Hidden=false" >> ${DESKTOP_FILE}
    echo "NoDisplay=false" >> ${DESKTOP_FILE}
    echo "X-GNOME-Autostart-enabled=true" >> ${DESKTOP_FILE}
    echo "Name=Bluetooth Check" >> ${DESKTOP_FILE}
    echo "X-GNOME-Autostart-Delay=10" >> ${DESKTOP_FILE}
    echo "Comment=Checks Bluetooth device and logs out if not found" >> ${DESKTOP_FILE}
    echo "Installed an autostart-file to ${DESKTOP_FILE}"
fi

if [ ! -f "${DESKTOP_FILE}" ]; then
    echo "In order to run this script automatically on every login, please start it with the following command"
    echo "./bluetooth-lock.sh --install"
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
