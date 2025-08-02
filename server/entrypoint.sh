#!/bin/bash
set -e

# Remove any existing server.pid to prevent startup issues
rm -f /app/tmp/pids/server.pid

# Execute the container's main process
exec "$@"