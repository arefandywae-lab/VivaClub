#!/bin/bash
set -e

echo ">>> STARTING RAILWAY ENTRYPOINT"
echo ">>> Current Directory: $(pwd)"
echo ">>> User: $(whoami)"
echo ">>> PORT: $PORT"

# Check Python version
echo ">>> Python Version:"
python --version

# Check if daphne is installed
echo ">>> Checking daphne:"
which daphne

# Check environment variables (safely)
if [ -z "$DATABASE_URL" ]; then
    echo ">>> WARNING: DATABASE_URL is not set"
else
    echo ">>> DATABASE_URL is set"
fi

if [ -z "$REDIS_URL" ]; then
    echo ">>> WARNING: REDIS_URL is not set"
else
    echo ">>> REDIS_URL is set"
fi

# Attempt to import settings to check for instant crash
echo ">>> Validating Django Settings..."
python -c "import os; os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings'); from django.conf import settings; print('Settings loaded successfully')" || echo ">>> ERROR: Settings failed to load"

# Start Daphne
echo ">>> Starting Daphne on 0.0.0.0:$PORT..."
exec daphne -v 2 -b 0.0.0.0 -p $PORT config.asgi:application
