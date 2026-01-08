#!/bin/bash
set -e

export SPARK_HOME=/opt/spark
export PYTHONPATH="$SPARK_HOME/python:$(ls $SPARK_HOME/python/lib/py4j-*.zip | head -n 1)"

ROLE=${SPARK_ROLE:-driver}

MASTER_HOST=${SPARK_MASTER_HOST:-spark-master}
MASTER_PORT=${SPARK_MASTER_PORT:-7077}
MASTER_URL="spark://${MASTER_HOST}:${MASTER_PORT}"

echo "================================="
echo "Spark role : ${ROLE}"
echo "Python     : $(which python)"
echo "================================="

case "$ROLE" in
  master)
    exec /opt/spark/bin/spark-class \
      org.apache.spark.deploy.master.Master \
      --host "$MASTER_HOST" \
      --port "$MASTER_PORT" \
      --webui-port "${SPARK_MASTER_WEBUI_PORT:-8080}"
    ;;

  worker)
    exec /opt/spark/bin/spark-class \
      org.apache.spark.deploy.worker.Worker \
      "$MASTER_URL" \
      --webui-port "${SPARK_WORKER_WEBUI_PORT:-0}"
    ;;

  driver)
    exec jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --ServerApp.token="${JUPYTER_TOKEN}"
    ;;

  *)
    echo "Unknown SPARK_ROLE: $ROLE"
    exit 1
    ;;
esac
