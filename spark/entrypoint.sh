#!/bin/bash
set -e

# Default values
SPARK_MASTER_HOST=${SPARK_MASTER_HOST:-spark-master}
SPARK_MASTER_PORT=${SPARK_MASTER_PORT:-7077}
SPARK_MASTER_URL="spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT}"

echo "*** Starting Spark Node in mode: $SPARK_MODE"

if [ "$SPARK_MODE" = "master" ]; then
    /opt/spark/bin/spark-class org.apache.spark.deploy.master.Master \
        --host "$SPARK_MASTER_HOST" \
        --port "$SPARK_MASTER_PORT" \
        --webui-port "${SPARK_MASTER_WEBUI_PORT:-8080}"

elif [ "$SPARK_MODE" = "worker" ]; then
    /opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker \
        "$SPARK_MASTER_URL" \
        --webui-port "${SPARK_WORKER_WEBUI_PORT:-0}"

else
    echo "ERROR: SPARK_MODE must be master or worker"
    exit 1
fi
