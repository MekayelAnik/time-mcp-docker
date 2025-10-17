#!/bin/bash
set -e
/usr/local/bin/banner.sh

# Default values
readonly DEFAULT_PUID=1000
readonly DEFAULT_PGID=1000
readonly DEFAULT_PORT=8060
readonly DEFAULT_PROTOCOL="SHTTP"
readonly FIRST_RUN_FILE="/tmp/first_run_complete"

# Time MCP default configuration values
readonly DEFAULT_TIMEZONE="UTC"
readonly DEFAULT_LOCALE="en-US"

# Function to trim whitespace using parameter expansion
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

# Validate positive integers
is_positive_int() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]
}

# Validate timezone
is_valid_timezone() {
    local tz="$1"
    # Check if timezone exists in /usr/share/zoneinfo
    [[ -f "/usr/share/zoneinfo/$tz" ]] || [[ "$tz" == "UTC" ]]
}

# Validate locale format
is_valid_locale() {
    local locale="$1"
    # Basic locale format validation (language-COUNTRY or language)
    [[ "$locale" =~ ^[a-z]{2}(-[A-Z]{2})?$ ]]
}

# First run handling
handle_first_run() {
    local uid_gid_changed=0

    # Handle PUID/PGID logic
    if [[ -z "$PUID" && -z "$PGID" ]]; then
        PUID="$DEFAULT_PUID"
        PGID="$DEFAULT_PGID"
        echo "PUID and PGID not set. Using defaults: PUID=$PUID, PGID=$PGID"
    elif [[ -n "$PUID" && -z "$PGID" ]]; then
        if is_positive_int "$PUID"; then
            PGID="$PUID"
        else
            echo "Invalid PUID: '$PUID'. Using default: $DEFAULT_PUID"
            PUID="$DEFAULT_PUID"
            PGID="$DEFAULT_PGID"
        fi
    elif [[ -z "$PUID" && -n "$PGID" ]]; then
        if is_positive_int "$PGID"; then
            PUID="$PGID"
        else
            echo "Invalid PGID: '$PGID'. Using default: $DEFAULT_PGID"
            PUID="$DEFAULT_PUID"
            PGID="$DEFAULT_PGID"
        fi
    else
        if ! is_positive_int "$PUID"; then
            echo "Invalid PUID: '$PUID'. Using default: $DEFAULT_PUID"
            PUID="$DEFAULT_PUID"
        fi
        
        if ! is_positive_int "$PGID"; then
            echo "Invalid PGID: '$PGID'. Using default: $DEFAULT_PGID"
            PGID="$DEFAULT_PGID"
        fi
    fi

    # Check existing UID/GID conflicts
    local current_user current_group
    current_user=$(id -un "$PUID" 2>/dev/null || true)
    current_group=$(getent group "$PGID" | cut -d: -f1 2>/dev/null || true)

    [[ -n "$current_user" && "$current_user" != "node" ]] &&
        echo "Warning: UID $PUID already in use by $current_user - may cause permission issues"

    [[ -n "$current_group" && "$current_group" != "node" ]] &&
        echo "Warning: GID $PGID already in use by $current_group - may cause permission issues"

    # Modify UID/GID if needed
    if [ "$(id -u node)" -ne "$PUID" ]; then
        if usermod -o -u "$PUID" node 2>/dev/null; then
            uid_gid_changed=1
        else
            echo "Error: Failed to change UID to $PUID. Using existing UID $(id -u node)"
            PUID=$(id -u node)
        fi
    fi

    if [ "$(id -g node)" -ne "$PGID" ]; then
        if groupmod -o -g "$PGID" node 2>/dev/null; then
            uid_gid_changed=1
        else
            echo "Error: Failed to change GID to $PGID. Using existing GID $(id -g node)"
            PGID=$(id -g node)
        fi
    fi

    [ "$uid_gid_changed" -eq 1 ] && echo "Updated UID/GID to PUID=$PUID, PGID=$PGID"
    touch "$FIRST_RUN_FILE"
}

# Validate and set PORT
validate_port() {
    # Ensure PORT has a value
    PORT=${PORT:-$DEFAULT_PORT}
    
    # Check if PORT is a positive integer
    if ! is_positive_int "$PORT"; then
        echo "Invalid PORT: '$PORT'. Using default: $DEFAULT_PORT"
        PORT="$DEFAULT_PORT"
    elif [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        echo "Invalid PORT: '$PORT'. Using default: $DEFAULT_PORT"
        PORT="$DEFAULT_PORT"
    fi
    
    # Check if port is privileged
    if [ "$PORT" -lt 1024 ] && [ "$(id -u)" -ne 0 ]; then
        echo "Warning: Port $PORT is privileged and might require root"
    fi
}

# Build MCP server command
build_mcp_server_cmd() {
    # Start with the base command
    MCP_SERVER_CMD="npx -y time-mcp"
    
    # Build environment variable arguments array
    TIME_ENV_ARGS=()
    
    # Add default timezone configuration (optional)
    if [[ -n "${TIME_DEFAULT_TIMEZONE:-}" ]]; then
        TIME_ENV_ARGS+=(env "TIME_DEFAULT_TIMEZONE=$TIME_DEFAULT_TIMEZONE")
    fi
    
    # Add locale configuration (optional)
    if [[ -n "${TIME_LOCALE:-}" ]]; then
        TIME_ENV_ARGS+=(env "TIME_LOCALE=$TIME_LOCALE")
    fi
    
    # Combine env args with the base command
    if [[ ${#TIME_ENV_ARGS[@]} -gt 0 ]]; then
        MCP_SERVER_CMD="${TIME_ENV_ARGS[@]} $MCP_SERVER_CMD"
    fi
}

# Validate CORS patterns
validate_cors() {
    CORS_ARGS=()
    ALLOW_ALL_CORS=false
    local cors_value

    if [[ -n "${CORS:-}" ]]; then
        IFS=',' read -ra CORS_VALUES <<< "$CORS"
        for cors_value in "${CORS_VALUES[@]}"; do
            cors_value=$(trim "$cors_value")
            [[ -z "$cors_value" ]] && continue

            if [[ "$cors_value" =~ ^(all|\*)$ ]]; then
                ALLOW_ALL_CORS=true
                CORS_ARGS=(--cors)
                echo "Caution! CORS allowing all origins - security risk in production!"
                break
            elif [[ "$cors_value" =~ ^/.*/$ ]] ||
                 [[ "$cors_value" =~ ^https?:// ]] ||
                 [[ "$cors_value" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]] ||
                 [[ "$cors_value" =~ ^https?://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]] ||
                 [[ "$cors_value" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(:[0-9]+)?$ ]]
            then
                CORS_ARGS+=(--cors "$cors_value")
            else
                echo "Warning: Invalid CORS pattern '$cors_value' - skipping"
            fi
        done
    fi
}

# Generate client configuration example
generate_client_config_example() {
    echo ""
    echo "=== TIME MCP TOOL LIST ==="
    echo "To enable auto-approval in your MCP client, add this to your configuration:"
    echo ""
    echo "\"TOOL LIST\": ["
    echo "  \"current_time\","
    echo "  \"relative_time\","
    echo "  \"get_timestamp\","
    echo "  \"days_in_month\","
    echo "  \"convert_time\","
    echo "  \"get_week_year\""
    echo "]"
    echo ""
    echo "=== END TOOL LIST ==="
    echo ""
}

# Validate Time MCP environment variables
validate_time_env() {
    # Validate timezone if set (optional)
    if [[ -n "${TIME_DEFAULT_TIMEZONE:-}" ]]; then
        if ! is_valid_timezone "$TIME_DEFAULT_TIMEZONE"; then
            echo "⚠️  Warning: Invalid TIME_DEFAULT_TIMEZONE: '$TIME_DEFAULT_TIMEZONE'."
            echo "   Using default: $DEFAULT_TIMEZONE"
            export TIME_DEFAULT_TIMEZONE="$DEFAULT_TIMEZONE"
        fi
    else
        # Set default timezone if not provided
        export TIME_DEFAULT_TIMEZONE="$DEFAULT_TIMEZONE"
    fi

    # Validate locale if set (optional)
    if [[ -n "${TIME_LOCALE:-}" ]]; then
        if ! is_valid_locale "$TIME_LOCALE"; then
            echo "⚠️  Warning: Invalid TIME_LOCALE: '$TIME_LOCALE'."
            echo "   Expected format: en-US, fr-FR, etc."
            echo "   Using default: $DEFAULT_LOCALE"
            export TIME_LOCALE="$DEFAULT_LOCALE"
        fi
    else
        # Set default locale if not provided
        export TIME_LOCALE="$DEFAULT_LOCALE"
    fi

    return 0
}

# Display Time MCP configuration summary
display_config_summary() {
    echo ""
    echo "=== TIME MCP SERVER CONFIGURATION ==="
    
    # Show timezone configuration
    echo "🌍 Default Timezone: ${TIME_DEFAULT_TIMEZONE:-$DEFAULT_TIMEZONE}"
    
    # Show locale configuration
    echo "🌐 Locale: ${TIME_LOCALE:-$DEFAULT_LOCALE}"
    
    # Show system timezone if set
    if [[ -n "${TZ:-}" ]]; then
        echo "⏰ System TZ: $TZ"
    fi
    
    # Always show server configuration
    echo "📡 Server:"
    echo "   - Port: $PORT"
    echo "   - Protocol: $PROTOCOL_DISPLAY"
    
    echo "=========================================="
    echo ""
}

# Main execution
main() {
    # Trim all input parameters
    [[ -n "${PUID:-}" ]] && PUID=$(trim "$PUID")
    [[ -n "${PGID:-}" ]] && PGID=$(trim "$PGID")
    [[ -n "${PORT:-}" ]] && PORT=$(trim "$PORT")
    [[ -n "${PROTOCOL:-}" ]] && PROTOCOL=$(trim "$PROTOCOL")
    [[ -n "${CORS:-}" ]] && CORS=$(trim "$CORS")
    
    # Trim Time MCP specific environment variables
    [[ -n "${TIME_DEFAULT_TIMEZONE:-}" ]] && TIME_DEFAULT_TIMEZONE=$(trim "$TIME_DEFAULT_TIMEZONE")
    [[ -n "${TIME_LOCALE:-}" ]] && TIME_LOCALE=$(trim "$TIME_LOCALE")

    # First run handling
    if [[ ! -f "$FIRST_RUN_FILE" ]]; then
        handle_first_run
    fi

    # Validate configurations
    validate_port
    validate_cors
    
    # Validate Time MCP environment
    if ! validate_time_env; then
        echo "❌ Time MCP Server cannot start due to configuration errors."
        exit 1
    fi

    # Build MCP server command with environment variables
    build_mcp_server_cmd

    # Generate client configuration example
    generate_client_config_example

    # Protocol selection
    local PROTOCOL_UPPER=${PROTOCOL:-$DEFAULT_PROTOCOL}
    PROTOCOL_UPPER=${PROTOCOL_UPPER^^}

    case "$PROTOCOL_UPPER" in
        "SHTTP"|"STREAMABLEHTTP")
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --streamableHttpPath /mcp --outputTransport streamableHttp "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="SHTTP/streamableHttp"
            ;;
        "SSE")
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --ssePath /sse --outputTransport sse "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="SSE/Server-Sent Events"
            ;;
        "WS"|"WEBSOCKET")
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --messagePath /message --outputTransport ws "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="WS/WebSocket"
            ;;
        *)
            echo "Invalid PROTOCOL: '$PROTOCOL'. Using default: $DEFAULT_PROTOCOL"
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --streamableHttpPath /mcp --outputTransport streamableHttp "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="SHTTP/streamableHttp"
            ;;
    esac

    # Display configuration summary
    display_config_summary

    # Debug mode handling
    case "${DEBUG_MODE:-}" in
        [1YyTt]*|[Oo][Nn]|[Yy][Ee][Ss]|[Ee][Nn][Aa][Bb][Ll][Ee]*)
            echo "DEBUG MODE: Installing nano and pausing container"
            apk add --no-cache nano 2>/dev/null || echo "Warning: Failed to install nano"
            echo "Container paused for debugging. Exec into container to investigate."
            exec tail -f /dev/null
            ;;
        *)
            # Normal execution
            echo "🚀 Launching Time MCP Server with protocol: $PROTOCOL_DISPLAY on port: $PORT"
            
            # Check for npx availability
            if ! command -v npx &>/dev/null; then
                echo "❌ Error: npx not available. Cannot start server."
                exit 1
            fi

            # Display the actual command being executed for debugging
            if [[ "${DEBUG_MODE:-}" == "verbose" ]]; then
                echo "🔧 DEBUG - Final command: ${CMD_ARGS[*]}"
            fi

            if [ "$(id -u)" -eq 0 ]; then
                echo "👤 Running as user: node (PUID: $PUID, PGID: $PGID)"
                exec su-exec node "${CMD_ARGS[@]}"
            else
                if [ "$PORT" -lt 1024 ]; then
                    echo "❌ Error: Cannot bind to privileged port $PORT without root"
                    exit 1
                fi
                echo "👤 Running as current user"
                exec "${CMD_ARGS[@]}"
            fi
            ;;
    esac
}

# Run the script with error handling
if main "$@"; then
    exit 0
else
    echo "❌ Time MCP Server failed to start"
    exit 1
fi