#!/bin/bash
set -e

# ------------------------------
# Environment variables
# ------------------------------
: "${CRON_LOG:=/var/log/cron/cron.log}"
: "${WORKDIR:=/compose}"
: "${CONFIG_FILE:=/app/cron-config.yml}"

echo "Using CRON_LOG: $CRON_LOG"
echo "Using WORKDIR: $WORKDIR"
echo "Using CONFIG_FILE: $CONFIG_FILE"

mkdir -p "$WORKDIR"
mkdir -p "$(dirname "$CRON_LOG")"
touch "$CRON_LOG"

# ------------------------------
# Determine task count
# ------------------------------
task_count=$(yq '.["cron-task"] | length' "$CONFIG_FILE")
echo "Found $task_count cron tasks"

CRON_FILE="/etc/crontabs/root"
mkdir -p /etc/crontabs
echo "" > "$CRON_FILE"

# ------------------------------
# Cron schedule regex
# ------------------------------
CRON_REGEX='^([0-9*/,-]+[[:space:]]+){4}[0-9*/,-]+$'

# ------------------------------
# Loop through tasks
# ------------------------------
i=0
while [ "$i" -lt "$task_count" ]; do
    echo "---- Checking task index $i ----"

    name=$(yq -r ".\"cron-task\"[$i].name" "$CONFIG_FILE")
    schedule=$(yq -r ".\"cron-task\"[$i].CRON_SCHEDULE" "$CONFIG_FILE")
    cmd=$(yq -r ".\"cron-task\"[$i].TASK_CMD" "$CONFIG_FILE")

    # ------------------------------
    # Validate name
    # ------------------------------
    if [ -z "$name" ] || [ "$name" = "null" ]; then
        echo "❌ ERROR: Task $i missing 'name'"
        exit 1
    fi

    case "$name" in
        *[!a-zA-Z0-9_-]*)
            echo "❌ ERROR: Invalid characters in name '$name'"
            exit 1
            ;;
    esac

    # ------------------------------
    # Validate CRON_SCHEDULE
    # ------------------------------
    if [ -z "$schedule" ] || [ "$schedule" = "null" ]; then
        echo "❌ ERROR: Task '$name' missing CRON_SCHEDULE"
        exit 1
    fi

    if ! echo "$schedule" | grep -Eq "$CRON_REGEX"; then
        echo "❌ ERROR: Invalid cron schedule '$schedule' for task '$name'"
        exit 1
    fi

    # ------------------------------
    # Validate TASK_CMD
    # ------------------------------
    if [ -z "$cmd" ] || [ "$cmd" = "null" ]; then
        echo "❌ ERROR: Task '$name' missing TASK_CMD"
        exit 1
    fi

    echo "✔ Task '$name' is valid"

    # ------------------------------
    # Create wrapper for this task
    # ------------------------------
    WRAPPER="/usr/local/bin/run_task_${name}.sh"
    cat <<EOF > "$WRAPPER"
#!/bin/sh
set -e
cd $WORKDIR
export PATH=/usr/local/bin:\$PATH
$cmd
EOF
    chmod +x "$WRAPPER"

    # ------------------------------
    # Add cron entry
    # ------------------------------
    echo "$schedule $WRAPPER >> $CRON_LOG 2>&1" >> "$CRON_FILE"

    i=$((i+1))
done

echo "Cron tasks written to: $CRON_FILE"
cat "$CRON_FILE"

# ------------------------------
# Start cron + log
# ------------------------------
crond -f -l 2 &
tail -F "$CRON_LOG"
