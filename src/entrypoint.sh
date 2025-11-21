#!/bin/bash
set -e

# Create .env file from ENV_CONTENT environment variable if it exists
if [ -n "$ENV_CONTENT" ]; then
    echo "$ENV_CONTENT" > /app/.env
    # Set restrictive permissions so only the container user can read the secrets
    chmod 600 /app/.env
fi

# Execute the CMD passed to the container
exec "$@"
