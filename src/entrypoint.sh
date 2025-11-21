#!/bin/bash
set -e

# Create .env file from ENV_CONTENT environment variable if it exists
if [ -n "$ENV_CONTENT" ]; then
    echo "$ENV_CONTENT" > /app/.env
fi

# Execute the CMD passed to the container
exec "$@"
