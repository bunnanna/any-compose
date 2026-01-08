# =====================================
# Stage 1 — uv builder (ONLY place uv exists)
# =====================================
FROM ghcr.io/astral-sh/uv:python3.13-bookworm AS uv-builder

WORKDIR /build

# Copy dependency definitions
COPY pyproject.toml uv.lock ./

# Create venv + install deps (NO pyspark here)
RUN uv sync

# =====================================
# Stage 2 — Spark runtime (CLEAN)
# =====================================
FROM apache/spark:4.0.1

USER root
WORKDIR /app

# -------------------------------------
# System dependencies (python already exists, but ensure venv + tini)
# -------------------------------------
RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    tini \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python
# -------------------------------------
# Copy venv from builder
# -------------------------------------
COPY --from=uv-builder /build/.venv /app/.venv

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:${PATH}"

# -------------------------------------
# Runtime-only Python deps
# (keep Spark/PySpark aligned)
# -------------------------------------
RUN pip install --no-cache-dir \
    jupyterlab \
    ipykernel

# -------------------------------------
# Register kernel (build time)
# -------------------------------------
RUN python -m ipykernel install \
    --name uv-spark \
    --display-name "Python (uv + Spark 4.0.1)"

# -------------------------------------
# Spark / PySpark config
# -------------------------------------
ENV SPARK_HOME=/opt/spark
ENV PYSPARK_PYTHON=/app/.venv/bin/python
ENV PYSPARK_DRIVER_PYTHON=/app/.venv/bin/python

# -------------------------------------
# Entrypoint
# -------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7077 8080 8888 4040

ENTRYPOINT ["tini", "-g", "--", "/entrypoint.sh"]
