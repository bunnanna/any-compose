FROM apache/spark:latest

# Switch to root so we can write & chmod
USER root

# Copy entrypoint script
COPY entrypoint.sh /opt/spark/work-dir/entrypoint.sh

# Make it executable
RUN chmod +x /opt/spark/work-dir/entrypoint.sh

# Switch back to default Spark user
USER spark

ENTRYPOINT ["/opt/spark/work-dir/entrypoint.sh"]
