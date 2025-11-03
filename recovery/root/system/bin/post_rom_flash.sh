#!/system/bin/sh

sleep 2.5

echo "install /FFiles/DFE.zip" > /cache/recovery/openrecoveryscript
echo "noForceReboot" >> /cache/recovery/openrecoveryscript

sync

reboot recovery
