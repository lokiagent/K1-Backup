#!/bin/sh

case "$1" in
  start)
    echo "Starting K1 Backup..."
    /usr/data/K1-Backup/backup.sh -r origin -b "$BRANCH" "$IFS" &
    ;;
  stop)
    echo "Stopping K1 Backup..."
    pkill -f "backup"
    ;;
  restart)
    echo "Restarting K1 Backup..."
    pkill -f "backup"
    sleep 1
    /usr/data/K1-Backup/backup.sh -r origin -b "$BRANCH" "$IFS" &
    ;;
  *)
    Usage: $0 {start|stop|restart}
    exit 1
    ;;
esac
exit 0
