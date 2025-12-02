#!/bin/bash
set -e

# ------------------------------
# Environment variables
# ------------------------------
: "${CRON_SCHEDULE:=* * * * *}"
: "${TASK_CMD:=echo 'Hello from cron'}"
: "${CRON_LOG:=/var/log/cron/cron.log}"
: "${WORKDIR:=/compose}"

echo "Using CRON_SCHEDULE: $CRON_SCHEDULE"
echo "Using TASK_CMD: $TASK_CMD"
echo "Using CRON_LOG: $CRON_LOG"
echo "Using WORKDIR: $WORKDIR"

# ------------------------------
# Prepare directories and log
# ------------------------------
mkdir -p "$WORKDIR"
mkdir -p "$(dirname "$CRON_LOG")"
touch "$CRON_LOG"

# ------------------------------
# Create wrapper script for complex commands
# ------------------------------
WRAPPER="/usr/local/bin/run_task.sh"

cat <<EOF > "$WRAPPER"
#!/bin/sh
set -e
cd $WORKDIR       # your working directory
export PATH=/usr/local/bin:\$PATH
exec /usr/local/bin/dockerd-entrypoint.sh $TASK_CMD
EOF

chmod +x "$WRAPPER"

# ------------------------------
# Write cron job — append output to log
# ------------------------------
mkdir -p /etc/crontabs
echo "$CRON_SCHEDULE sh $WRAPPER >> $CRON_LOG 2>&1" > /etc/crontabs/root

# Start cron in background
crond -f &

# Tail log to terminal in a separate process
tail -F "$CRON_LOG"