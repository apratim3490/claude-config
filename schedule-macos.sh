#!/usr/bin/env bash
# Installs a launchd agent to sync claude-config daily at 8:00 UTC.
#
# launchd uses local time, so we convert 8:00 UTC to local time at install.
# NOTE: If your timezone's DST offset changes, re-run this script.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_NAME="com.claude-config.sync"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"

# --- Calculate local time equivalent of 08:00 UTC ---
# Get current UTC offset in seconds, convert to hours
UTC_OFFSET_SEC=$(date +%z | awk '{
    sign = substr($0,1,1)
    h = substr($0,2,2) + 0
    m = substr($0,4,2) + 0
    total = h * 60 + m
    if (sign == "-") total = -total
    print total
}')

TARGET_UTC_HOUR=8
TARGET_UTC_MIN=0

LOCAL_MIN=$(( TARGET_UTC_MIN + (UTC_OFFSET_SEC % 60) ))
LOCAL_HOUR=$(( TARGET_UTC_HOUR + (UTC_OFFSET_SEC / 60) ))

if [ "$LOCAL_MIN" -lt 0 ]; then
  LOCAL_MIN=$(( LOCAL_MIN + 60 ))
  LOCAL_HOUR=$(( LOCAL_HOUR - 1 ))
elif [ "$LOCAL_MIN" -ge 60 ]; then
  LOCAL_MIN=$(( LOCAL_MIN - 60 ))
  LOCAL_HOUR=$(( LOCAL_HOUR + 1 ))
fi

if [ "$LOCAL_HOUR" -lt 0 ]; then
  LOCAL_HOUR=$(( LOCAL_HOUR + 24 ))
elif [ "$LOCAL_HOUR" -ge 24 ]; then
  LOCAL_HOUR=$(( LOCAL_HOUR - 24 ))
fi

echo "8:00 UTC = ${LOCAL_HOUR}:$(printf '%02d' $LOCAL_MIN) local time (current offset)"

# --- Unload existing agent if present ---
if launchctl list "$PLIST_NAME" &>/dev/null; then
  launchctl unload "$PLIST_PATH" 2>/dev/null || true
fi

# --- Write plist ---
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_NAME}</string>

    <key>ProgramArguments</key>
    <array>
        <string>${SCRIPT_DIR}/sync.sh</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>${LOCAL_HOUR}</integer>
        <key>Minute</key>
        <integer>${LOCAL_MIN}</integer>
    </dict>

    <key>StandardOutPath</key>
    <string>${HOME}/Library/Logs/claude-config-sync.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/Library/Logs/claude-config-sync.log</string>

    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
EOF

# --- Load the agent ---
launchctl load "$PLIST_PATH"

echo "Scheduled: ${PLIST_NAME}"
echo "  Runs daily at ${LOCAL_HOUR}:$(printf '%02d' $LOCAL_MIN) local (8:00 UTC)"
echo "  Plist: ${PLIST_PATH}"
echo "  Log:   ~/Library/Logs/claude-config-sync.log"
echo ""
echo "To uninstall: launchctl unload ${PLIST_PATH} && rm ${PLIST_PATH}"
