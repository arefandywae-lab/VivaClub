#!/bin/bash
# Quick service management script
# Usage: ./manage.sh [command] [service]
# Commands: start, stop, restart, status, logs

COMMAND=$1
SERVICE=$2

cd ~/vivaclub

case $COMMAND in
    start)
        echo "🚀 Starting services..."
        docker-compose -f docker-compose.prod.yml up -d $SERVICE
        ;;
    stop)
        echo "🛑 Stopping services..."
        docker-compose -f docker-compose.prod.yml stop $SERVICE
        ;;
    restart)
        echo "🔄 Restarting services..."
        docker-compose -f docker-compose.prod.yml restart $SERVICE
        ;;
    status)
        echo "📊 Service status:"
        docker-compose -f docker-compose.prod.yml ps
        echo ""
        echo "💻 Resource usage:"
        docker stats --no-stream
        ;;
    logs)
        echo "📝 Showing logs..."
        docker-compose -f docker-compose.prod.yml logs -f --tail=50 $SERVICE
        ;;
    pull)
        echo "📦 Pulling latest images..."
        docker-compose -f docker-compose.prod.yml pull
        ;;
    update)
        echo "🔄 Updating and restarting..."
        docker-compose -f docker-compose.prod.yml pull
        docker-compose -f docker-compose.prod.yml up -d
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|pull|update} [service]"
        echo ""
        echo "Examples:"
        echo "  $0 restart web       # Restart Django"
        echo "  $0 logs postgres     # View PostgreSQL logs"
        echo "  $0 status            # Show all services"
        echo "  $0 update            # Pull and restart all"
        exit 1
        ;;
esac
