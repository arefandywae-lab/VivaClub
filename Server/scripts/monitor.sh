#!/bin/bash
# Real-time monitoring script for all VivaClub services
# Usage: ./monitor.sh [service_name]
# Example: ./monitor.sh web  (monitor specific service)
#          ./monitor.sh       (monitor all services)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Service to monitor (default: all)
SERVICE=${1:-""}

# Clear screen
clear

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         VivaClub Real-Time Service Monitor                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to show service status
show_status() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📊 Service Status${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    docker-compose -f ~/vivaclub/docker-compose.prod.yml ps
    echo ""
}

# Function to show resource usage
show_resources() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}💻 Resource Usage${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    echo ""
}

# Function to show recent logs
show_logs() {
    local service=$1
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    if [ -z "$service" ]; then
        echo -e "${YELLOW}📝 Recent Logs (All Services)${NC}"
    else
        echo -e "${YELLOW}📝 Recent Logs ($service)${NC}"
    fi
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to check health
check_health() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}🏥 Health Checks${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Django
    if curl -sf http://localhost:8000/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Django API: Healthy"
    else
        echo -e "${RED}✗${NC} Django API: Down"
    fi
    
    # PostgreSQL
    if docker exec vivaclub_db pg_isready -U vivaclub > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} PostgreSQL: Healthy"
    else
        echo -e "${RED}✗${NC} PostgreSQL: Down"
    fi
    
    # Redis
    if docker exec vivaclub_redis redis-cli ping > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Redis: Healthy"
    else
        echo -e "${RED}✗${NC} Redis: Down"
    fi
    
    # MinIO
    if curl -sf http://localhost:9000/minio/health/live > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} MinIO: Healthy"
    else
        echo -e "${RED}✗${NC} MinIO: Down"
    fi
    
    # LiveKit
    if curl -sf http://localhost:7880 > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} LiveKit: Healthy"
    else
        echo -e "${RED}✗${NC} LiveKit: Down"
    fi
    
    echo ""
}

# Main monitoring loop
if [ "$SERVICE" == "status" ]; then
    # Just show status once
    show_status
    show_resources
    check_health
elif [ -z "$SERVICE" ]; then
    # Monitor all services
    echo -e "${PURPLE}Monitoring all services... (Press Ctrl+C to stop)${NC}"
    echo ""
    show_status
    show_resources
    check_health
    show_logs
    docker-compose -f ~/vivaclub/docker-compose.prod.yml logs -f --tail=50
else
    # Monitor specific service
    echo -e "${PURPLE}Monitoring $SERVICE... (Press Ctrl+C to stop)${NC}"
    echo ""
    show_logs "$SERVICE"
    docker-compose -f ~/vivaclub/docker-compose.prod.yml logs -f --tail=50 $SERVICE
fi
