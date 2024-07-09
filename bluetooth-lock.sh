#!/bin/bash

# MAC-Adresse des Bluetooth-Geräts
if [ ! -f "device.txt" ]; then
    echo "00:00:00:00:00:00" > "device.txt"
fi

BT_DEVICE=`cat device.txt`
if [ "$BT_DEVICE" == "00:00:00:00:00:00" ]; then
    echo "Please enter the mac address or your bluetooth device in device.txt"
    exit 0
fi

AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/bluetooth-lock.desktop"

if [ "$1" == "--install" ]; then
    SCRIPT_PATH=$(readlink -f "$0")

    # Autostart-Verzeichnis erstellen, falls nicht vorhanden
    mkdir -p "$AUTOSTART_DIR"

    # Inhalt der .desktop-Datei
    echo -e "[Desktop Entry]\n" \
            "Type=Application\n" \
            "Exec=$SCRIPT_PATH\n" \
            "Hidden=false\n" \
            "NoDisplay=false\n" \
            "X-GNOME-Autostart-enabled=true\n" \
            "Name=Bluetooth Check\n" \
            "Comment=Checks Bluetooth device and logs out if not found" > "$DESKTOP_FILE"
    echo "Installed an autostart-file to $DESKTOP_FILE"
fi

if [ ! -f "$DESKTOP_FILE" ]; then
    echo "In order to run this script automatically on every login, please start it with the following command"
    echo "./bluetooth-lock.sh --install"
fi

while true; do
    BT_NAME=`hcitool name $BT_DEVICE`
    echo "Detected $BT_NAME"
    # Prüfen, ob das Gerät in der Nähe ist
    if [ "" == "$BT_NAME" ]; then
        # Wenn das Gerät nicht gefunden wurde, Benutzer abmelden
        #pkill -KILL -u $USER
        echo "lock session"
        loginctl lock-session
    else
        echo "device present"
        echo "unlock session"
        loginctl unlock-session
    fi
    sleep 10
done
