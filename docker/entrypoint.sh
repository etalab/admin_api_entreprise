#!/bin/bash
set -e
/wait
rm -f /app/tmp/pids/server.pid
exec "$@"
