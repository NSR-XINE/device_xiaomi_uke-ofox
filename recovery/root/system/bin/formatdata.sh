#!/system/bin/sh

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

LOGMSG "---$SCRIPT_NAME start---"

MARKER="/persist/recovery/.format_cleanup_marker"

mkdir -p /persist/recovery
touch "$MARKER"

LOGMSG "Post-format cleanup marker set"

LOGMSG "---$SCRIPT_NAME end---"
