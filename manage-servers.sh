#!/bin/bash

# Server Management Script for BOP/Imminence MCP Servers
# Usage: ./manage-servers.sh [start|stop|restart|status] [server-name|all]

set -e

# Server definitions: name|directory|start_command|udp_port|http_port|ws_port
# Use "-" for ports that don't exist (e.g., HTTP-only servers have no UDP/WS)
SERVERS=(
    # Full HTTP + WebSocket servers (sorted by UDP port)
    "context-guardian|/Users/macbook/Documents/claude_home/repo/imminenceV2/context-guardian|node src/index.js|3001|8001|9001"
    "quartermaster|/Users/macbook/Documents/claude_home/repo/Quartermaster/quartermaster|node src/index.js|3002|8002|9002"
    "snapshot|/Users/macbook/Documents/claude_home/repo/snapSHOT|node src/index.js|3003|8003|9003"
    "tool-registry|/Users/macbook/Documents/claude_home/repo/Toolee/Tool_Registry|node src/index.js|3004|8004|9004"
    "catasorter|/Users/macbook/Documents/claude_home/repo/Catasorter|node src/index.js|3005|8005|9005"
    "smart-file-organizer|/Users/macbook/Documents/claude_home/repo/smart_file_organizer|MCP_MODE=true node src/server.js|3007|8007|9007"
    "bonzai-bloat-buster|/Users/macbook/Documents/claude_home/repo/bonzai-bloat-buster|node dist/index.js|3008|8008|9008"
    "enterspect|/Users/macbook/Documents/claude_home/repo/EnterSpect|node index.js|3009|8009|9009"
    "neurogenesis-engine|/Users/macbook/Documents/claude_home/repo/neurogenesis-engine|node src/index.js|3010|8010|9010"
    "trinity-coordinator|/Users/macbook/Documents/claude_home/repo/trinitycoordinator|node dist/index.js|3012|8012|9012"
    "claude-code-bridge|/Users/macbook/Documents/claude_home/repo/ClaudeCodeBridge|node build/index.js|3013|8013|9013"
    "project-context|/Users/macbook/Documents/claude_home/repo/project-context|node dist/index.js|3016|8016|9016"
    "knowledge-curator|/Users/macbook/Documents/claude_home/repo/knowledge-curator|node dist/index.js|3017|8017|9017"
    "pk-manager|/Users/macbook/Documents/claude_home/repo/pk-manager|node dist/index.js|3018|8018|9018"
    "intelligentrouter|/Users/macbook/Documents/claude_home/repo/intelligentrouter|node dist/index.js|3020|8020|9020"
    "verifier-mcp|/Users/macbook/Documents/claude_home/repo/verifier-mcp|node dist/index.js|3021|8021|9021"

    # New servers (built Jan 2, 2026)
    "safe-batch-processor|/Users/macbook/Documents/claude_home/repo/safe-batch-processor|node dist/index.js|3022|8022|9022"
    "intake-guardian|/Users/macbook/Documents/claude_home/repo/intake-guardian|node dist/index.js|3023|8023|9023"
    "health-monitor|/Users/macbook/Documents/claude_home/repo/health-monitor|node dist/index.js|3024|8024|9024"
    "synapse-relay|/Users/macbook/Documents/claude_home/repo/synapse-relay|node dist/index.js|3025|8025|9025"
    "filesystem-guardian|/Users/macbook/Documents/claude_home/repo/filesystem-guardian|node dist/index.js|3026|8026|9026"
    "consolidation-engine|/Users/macbook/Documents/claude_home/repo/consolidation-engine|node dist/index.js|3032|8032|9032"

    # Cognitive Architecture servers (built Jan 3-4, 2026)
    "tenets-server|/Users/macbook/Documents/claude_home/repo/tenets-server|node dist/index.js|3027|8027|9027"
    "consciousness-mcp|/Users/macbook/Documents/claude_home/repo/consciousness-mcp|node dist/index.js|3028|8028|9028"
    "skill-builder|/Users/macbook/Documents/claude_home/repo/skill-builder|node dist/index.js|3029|8029|9029"
    "percolation-server|/Users/macbook/Documents/claude_home/repo/percolation-server|node dist/index.js|3030|8030|9030"
    "experience-layer|/Users/macbook/Documents/claude_home/repo/experience-layer|node dist/index.js|3031|8031|9031"

    # NIWS decomposed servers (built Jan 9, 2026)
    "niws-intake|/Users/macbook/Documents/claude_home/repo/niws-intake|node dist/index.js|3033|8033|9033"
    "niws-analysis|/Users/macbook/Documents/claude_home/repo/niws-analysis|node dist/index.js|3034|8034|9034"
    "niws-production|/Users/macbook/Documents/claude_home/repo/niws-production|node dist/index.js|3035|8035|9035"
    "niws-delivery|/Users/macbook/Documents/claude_home/repo/niws-delivery|node dist/index.js|3036|8036|9036"

    # Linus Inspector (built Jan 11, 2026)
    "linus-inspector|/Users/macbook/Documents/claude_home/repo/linus-inspector|node dist/index.js|3037|8037|9037"

    # FFmpeg Video Production Suite (built Jan 21-22, 2026)
    "ffmpeg-clipper|/Users/macbook/Documents/claude_home/repo/ffmpeg-clipper|node dist/index.js|3039|8039|9039"
    "ffmpeg-effects|/Users/macbook/Documents/claude_home/repo/ffmpeg-effects|node dist/index.js|3040|8040|9040"
    "ffmpeg-transitions|/Users/macbook/Documents/claude_home/repo/ffmpeg-transitions|node dist/index.js|3041|8041|9041"
    "ffmpeg-midi|/Users/macbook/Documents/claude_home/repo/ffmpeg-midi|node dist/index.js|3042|8042|9042"
    "ffmpeg-timeline|/Users/macbook/Documents/claude_home/repo/ffmpeg-timeline|node dist/index.js|3043|8043|9043"

    # Edge Adapter (proxies to all servers)
    "bop-gateway|/Users/macbook/Documents/claude_home/repo/bop-gateway|node dist/http/server.js|-|8000|-"

    # HTTP-only servers (no UDP/WS)
    "looker|/Users/macbook/Documents/claude_home/repo/looker-mcp|node dist/index.js|-|8006|-"
    "chronos-synapse|/Users/macbook/Documents/claude_home/repo/Chronos_Synapse|node dist/index.js|-|8011|-"
    "niws-server|/Users/macbook/Documents/claude_home/repo/niws-server|node dist/index.js|-|8015|-"
    "research-bus|/Users/macbook/Documents/claude_home/repo/research-bus|node dist/index.js|-|8019|-"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse server definition
parse_server() {
    local def="$1"
    IFS='|' read -r SERVER_NAME SERVER_DIR SERVER_CMD UDP_PORT HTTP_PORT WS_PORT <<< "$def"
}

# Find server definition by name
find_server() {
    local name="$1"
    for server in "${SERVERS[@]}"; do
        parse_server "$server"
        if [[ "$SERVER_NAME" == "$name" ]]; then
            return 0
        fi
    done
    return 1
}

# Check if port is in use
port_in_use() {
    local port="$1"
    lsof -i ":$port" >/dev/null 2>&1
}

# Get PID using port
get_pid_on_port() {
    local port="$1"
    lsof -t -i ":$port" 2>/dev/null | head -1
}

# Kill process on port
kill_port() {
    local port="$1"
    local pid=$(get_pid_on_port "$port")
    if [[ -n "$pid" ]]; then
        kill "$pid" 2>/dev/null || true
        sleep 0.5
    fi
}

# Stop a server by name
stop_server() {
    local name="$1"

    if ! find_server "$name"; then
        log_error "Unknown server: $name"
        return 1
    fi

    # Early exit: check if server is already stopped
    local any_running=false
    for port in $UDP_PORT $HTTP_PORT $WS_PORT; do
        if [[ "$port" != "-" ]] && port_in_use "$port"; then
            any_running=true
            break
        fi
    done

    if ! $any_running; then
        log_success "$SERVER_NAME already stopped"
        return 0
    fi

    log_info "Stopping $SERVER_NAME..."

    # Try to kill by port (skip "-" ports)
    for port in $UDP_PORT $HTTP_PORT $WS_PORT; do
        if [[ "$port" != "-" ]] && port_in_use "$port"; then
            kill_port "$port"
        fi
    done

    # Also try pkill by directory pattern
    pkill -f "$SERVER_DIR" 2>/dev/null || true

    sleep 1

    # Verify stopped (skip "-" ports)
    local still_running=false
    for port in $UDP_PORT $HTTP_PORT $WS_PORT; do
        if [[ "$port" != "-" ]] && port_in_use "$port"; then
            still_running=true
            log_warning "Port $port still in use"
        fi
    done

    if $still_running; then
        log_error "Failed to fully stop $SERVER_NAME"
        return 1
    else
        log_success "$SERVER_NAME stopped"
    fi
}

# Start a server by name
start_server() {
    local name="$1"

    if ! find_server "$name"; then
        log_error "Unknown server: $name"
        return 1
    fi

    # Early exit: check if server is already running and healthy
    if [[ "$HTTP_PORT" != "-" ]] && port_in_use "$HTTP_PORT"; then
        local health=$(curl -s --max-time 2 "http://localhost:$HTTP_PORT/health" 2>/dev/null || echo "")
        if [[ -n "$health" ]]; then
            log_success "$SERVER_NAME already running (HTTP: $HTTP_PORT)"
            return 0
        fi
        # Port in use but not healthy - will be killed and restarted below
        log_warning "$SERVER_NAME port in use but unhealthy, restarting..."
    fi

    log_info "Starting $SERVER_NAME..."

    # Check if ports are free (skip "-" ports)
    for port in $UDP_PORT $HTTP_PORT $WS_PORT; do
        if [[ "$port" != "-" ]] && port_in_use "$port"; then
            kill_port "$port"
            sleep 1
        fi
    done

    # Start the server
    cd "$SERVER_DIR"

    # Run in background, redirect output to log file
    local log_file="/tmp/${SERVER_NAME}.log"
    nohup bash -c "$SERVER_CMD" > "$log_file" 2>&1 &
    local pid=$!

    # Wait for startup
    sleep 3

    # Verify started by checking HTTP port (if it exists)
    if [[ "$HTTP_PORT" == "-" ]]; then
        # No HTTP port - just report started
        log_success "$SERVER_NAME started (PID: $pid)"
    elif port_in_use "$HTTP_PORT"; then
        log_success "$SERVER_NAME started (PID: $pid, HTTP: $HTTP_PORT)"

        # Test health endpoint
        local health=$(curl -s "http://localhost:$HTTP_PORT/health" 2>/dev/null || echo "")
        if [[ -n "$health" ]]; then
            log_success "Health check passed"
        else
            log_warning "Health endpoint not responding yet"
        fi
    else
        log_error "$SERVER_NAME failed to start"
        log_info "Check logs: $log_file"
        return 1
    fi
}

# Restart a server
restart_server() {
    local name="$1"

    if ! find_server "$name"; then
        log_error "Unknown server: $name"
        return 1
    fi

    # Early exit: check if server is running (any port in use)
    local any_running=false
    for port in $UDP_PORT $HTTP_PORT $WS_PORT; do
        if [[ "$port" != "-" ]] && port_in_use "$port"; then
            any_running=true
            break
        fi
    done

    if ! $any_running; then
        log_success "$SERVER_NAME already stopped (nothing to restart)"
        return 0
    fi

    # Server is running - restart it
    stop_server "$name" || true
    start_server "$name"
}

# Show status of a server
status_server() {
    local name="$1"

    if ! find_server "$name"; then
        log_error "Unknown server: $name"
        return 1
    fi

    echo -e "\n${BLUE}=== $SERVER_NAME ===${NC}"
    echo "Directory: $SERVER_DIR"
    echo "Ports: UDP=$UDP_PORT HTTP=$HTTP_PORT WS=$WS_PORT"

    local running=false

    # Check each port (skip "-" ports)
    for port in $UDP_PORT $HTTP_PORT $WS_PORT; do
        if [[ "$port" == "-" ]]; then
            continue
        elif port_in_use "$port"; then
            local pid=$(get_pid_on_port "$port")
            echo -e "Port $port: ${GREEN}IN USE${NC} (PID: $pid)"
            running=true
        else
            echo -e "Port $port: ${YELLOW}FREE${NC}"
        fi
    done

    # Test health if HTTP port is up (and exists)
    if [[ "$HTTP_PORT" != "-" ]] && port_in_use "$HTTP_PORT"; then
        local health=$(curl -s "http://localhost:$HTTP_PORT/health" 2>/dev/null || echo "")
        if [[ -n "$health" ]]; then
            echo -e "Health: ${GREEN}OK${NC}"
        else
            echo -e "Health: ${RED}NO RESPONSE${NC}"
        fi
    fi

    if $running; then
        echo -e "Status: ${GREEN}RUNNING${NC}"
    else
        echo -e "Status: ${RED}STOPPED${NC}"
    fi
}

# List all servers
list_servers() {
    echo -e "\n${BLUE}=== Available Servers ===${NC}"
    for server in "${SERVERS[@]}"; do
        parse_server "$server"
        echo "  $SERVER_NAME (UDP:$UDP_PORT HTTP:$HTTP_PORT WS:$WS_PORT)"
    done
    echo ""
}

# Process all servers
process_all() {
    local action="$1"
    for server in "${SERVERS[@]}"; do
        parse_server "$server"
        case "$action" in
            start)   start_server "$SERVER_NAME" || true ;;
            stop)    stop_server "$SERVER_NAME" || true ;;
            restart) restart_server "$SERVER_NAME" || true ;;
            status)  status_server "$SERVER_NAME" ;;
        esac
    done
}

# Main
ACTION="${1:-help}"
TARGET="${2:-}"

case "$ACTION" in
    start)
        if [[ -z "$TARGET" ]]; then
            log_error "Usage: $0 start [server-name|all]"
            list_servers
            exit 1
        elif [[ "$TARGET" == "all" ]]; then
            process_all start
        else
            start_server "$TARGET"
        fi
        ;;
    stop)
        if [[ -z "$TARGET" ]]; then
            log_error "Usage: $0 stop [server-name|all]"
            list_servers
            exit 1
        elif [[ "$TARGET" == "all" ]]; then
            process_all stop
        else
            stop_server "$TARGET"
        fi
        ;;
    restart)
        if [[ -z "$TARGET" ]]; then
            log_error "Usage: $0 restart [server-name|all]"
            list_servers
            exit 1
        elif [[ "$TARGET" == "all" ]]; then
            process_all restart
        else
            restart_server "$TARGET"
        fi
        ;;
    status)
        if [[ -z "$TARGET" || "$TARGET" == "all" ]]; then
            process_all status
        else
            status_server "$TARGET"
        fi
        ;;
    list)
        list_servers
        ;;
    help|*)
        echo "Server Management Script for BOP/Imminence MCP Servers"
        echo ""
        echo "Usage: $0 [command] [server-name|all]"
        echo ""
        echo "Commands:"
        echo "  start   [name|all]  Start server(s)"
        echo "  stop    [name|all]  Stop server(s)"
        echo "  restart [name|all]  Restart server(s)"
        echo "  status  [name|all]  Show server status"
        echo "  list                List available servers"
        echo "  help                Show this help"
        echo ""
        list_servers
        ;;
esac
