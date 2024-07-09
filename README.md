# blueproximity
Tool to automatically lock or unlock a user session on a linux-computer based on the presence of a bluetooth device.

This tool is inspired by the blueproximity-project that is outdated since many years. It uses the hcitool-command
to determine the device name based on the bluetooth mac address of a device. If the device is not present, it locks
the screen. Once the device is present again, the screen is unlocked again.

However, the main drawback is, that this script does not allow to analyze the strength of the signal. As long as the
device name can be retrieved, the device is accepted as being present.

## Installation

Please adapt the location of the script to your needs, if desired.

```
git clone git@github.com:rschrenk/blueproximity.git ~/bin/blueproximity
cd ~/bin/blueproximity
chmod a+x bluetooth-lock.sh
./bluetooth-lock.sh
# Upon the first run, a file called "device.txt" is created. Please enter the mac address into that file
# then
# 1.) Test if the device is recognized, you must exit the script with Strg+C
./bluetooth-lock.sh
# 2.) If the device is recognized, install to autostart
./bluetooth-lock.sh --install
# ENJOY
```
