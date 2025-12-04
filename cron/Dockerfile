FROM docker:27-dind

# Install cron, bash, and other utilities
RUN apk add --no-cache bash yq

# Create default directories
RUN mkdir -p /var/log/cron /compose

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
