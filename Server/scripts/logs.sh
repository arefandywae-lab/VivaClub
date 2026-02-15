#!/bin/bash
# Quick log viewer for all services
# Usage: ./logs.sh [service] [lines]
# Example: ./logs.sh web 100
#          ./logs.sh postgres
#          ./logs.sh (all services, last 50 lines)

SERVICE=${1:-""}
LINES=${2:-50}

cd ~/vivaclub

if [ -z "$SERVICE" ]; then
    echo "📝 Showing logs for all services (last $LINES lines)..."
    docker-compose -f docker-compose.prod.yml logs --tail=$LINES -f
else
    echo "📝 Showing logs for $SERVICE (last $LINES lines)..."
    docker-compose -f docker-compose.prod.yml logs --tail=$LINES -f $SERVICE
fi
