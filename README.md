# Time MCP Server
### Multi-Architecture Docker Image for Time Awareness & Timezone Operations

<div align="left">

<img alt="time-mcp" src="https://img.shields.io/badge/Time-MCP-00A4EF?style=for-the-badge&logo=clock&logoColor=white" width="300">

[![Docker Pulls](https://img.shields.io/docker/pulls/mekayelanik/time-mcp.svg?style=flat-square)](https://hub.docker.com/r/mekayelanik/time-mcp)
[![Docker Stars](https://img.shields.io/docker/stars/mekayelanik/time-mcp.svg?style=flat-square)](https://hub.docker.com/r/mekayelanik/time-mcp)
[![License](https://img.shields.io/badge/license-GPL-blue.svg?style=flat-square)](https://raw.githubusercontent.com/MekayelAnik/time-mcp-docker/refs/heads/main/LICENSE)

**[NPM Package](https://www.npmjs.com/package/time-mcp)** • **[GitHub Repository](https://github.com/mekayelanik/time-mcp-docker)** • **[Docker Hub](https://hub.docker.com/r/mekayelanik/time-mcp)**

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [MCP Client Setup](#mcp-client-setup)
- [Available Tools](#available-tools)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)
- [Resources & Support](#resources--support)

---

## Overview

Time MCP Server provides comprehensive time awareness capabilities to AI assistants through the Model Context Protocol. It enables LLMs to accurately handle time-related queries, perform timezone conversions, calculate relative times, and work with timestamps across different locales and timezones.

### Key Features

✨ **Six Powerful Tools** - Current time, relative time, timestamps, and more  
🌍 **Timezone Support** - Convert and display time across 400+ timezones  
📅 **Date Calculations** - Days in month, week of year, ISO week numbers  
⏰ **Relative Time** - Human-readable relative time formatting  
🚀 **Multiple Protocols** - HTTP, SSE, and WebSocket transport support  
🌐 **Locale Support** - Format dates in any locale (en-US, fr-FR, etc.)  
⚡ **High Performance** - Lightweight and optimized for speed  
🎯 **Zero Dependencies** - No external API keys required  
🔧 **Highly Customizable** - Configure default timezone and locale  
📊 **Health Monitoring** - Built-in health check endpoint

### Supported Architectures

| Architecture | Status | Notes |
|:-------------|:------:|:------|
| **x86-64** | ✅ Stable | Intel/AMD processors |
| **ARM64** | ✅ Stable | Raspberry Pi, Apple Silicon |

### Available Tags

| Tag | Stability | Use Case |
|:----|:---------:|:---------|
| `stable` | ⭐⭐⭐ | **Production (recommended)** |
| `latest` | ⭐⭐⭐ | Latest stable features |
| `1.x.x` | ⭐⭐⭐ | Version pinning |
| `beta` | ⚠️ | Testing only |

---

## Quick Start

### Prerequisites

- Docker Engine 23.0+
- Network access (for Docker Hub)
- No API keys required ✨

### Docker Compose (Recommended)

```yaml
services:
  time-mcp:
    image: mekayelanik/time-mcp:stable
    container_name: time-mcp
    restart: unless-stopped
    ports:
      - "8060:8060"
    environment:
      # Optional Configuration
      - TIME_DEFAULT_TIMEZONE=UTC
      - TIME_LOCALE=en-US
      
      # Server Settings
      - PORT=8060
      - PROTOCOL=SHTTP
      - CORS=*
      - PUID=1000
      - PGID=1000
      - TZ=UTC
```

**Deploy:**

```bash
docker compose up -d
docker compose logs -f time-mcp
```

### Docker CLI

```bash
docker run -d \
  --name=time-mcp \
  --restart=unless-stopped \
  -p 8060:8060 \
  -e TIME_DEFAULT_TIMEZONE=UTC \
  -e TIME_LOCALE=en-US \
  -e PORT=8060 \
  -e PROTOCOL=SHTTP \
  mekayelanik/time-mcp:stable
```

### Access Endpoints

| Protocol | Endpoint | Use Case |
|:---------|:---------|:---------|
| **HTTP** | `http://host-ip:8060/mcp` | **Recommended** |
| **SSE** | `http://host-ip:8060/sse` | Real-time streaming |
| **WebSocket** | `ws://host-ip:8060/message` | Bidirectional |
| **Health** | `http://host-ip:8060/healthz` | Monitoring |

> ⏱️ Server ready in 5-10 seconds after container start

---

## Configuration

### Environment Variables

#### Optional Settings

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `TIME_DEFAULT_TIMEZONE` | `UTC` | Default timezone for operations |
| `TIME_LOCALE` | `en-US` | Default locale for formatting |

#### Server Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `PORT` | `8060` | Server port (1-65535) |
| `PROTOCOL` | `SHTTP` | Transport protocol (SHTTP/SSE/WS) |
| `CORS` | _(none)_ | Cross-Origin configuration |
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `UTC` | Container timezone |
| `DEBUG_MODE` | `false` | Enable debug mode |

### Supported Timezones

Time MCP supports all IANA timezone database entries. Common examples:

**Americas:** `America/New_York`, `America/Los_Angeles`, `America/Chicago`  
**Europe:** `Europe/London`, `Europe/Paris`, `Europe/Berlin`  
**Asia:** `Asia/Tokyo`, `Asia/Shanghai`, `Asia/Dubai`, `Asia/Kolkata`  
**Pacific:** `Australia/Sydney`, `Pacific/Auckland`

Full list: [IANA Time Zone Database](https://www.iana.org/time-zones)

### Locale Support

| Locale | Description | Example |
|:-------|:------------|:--------|
| `en-US` | English (US) | 12/31/2024, 11:59 PM |
| `en-GB` | English (UK) | 31/12/2024, 23:59 |
| `fr-FR` | French | 31/12/2024 23:59 |
| `bn-BD` | Bangla (Bangladesh) | ৩১/১২/২০২৪ ২৩:৫৯ |
| `de-DE` | German | 31.12.2024, 23:59 |
| `ja-JP` | Japanese | 2024/12/31 23:59 |
| `zh-CN` | Chinese | 2024/12/31 23:59 |

### Protocol Configuration

```yaml
# HTTP/Streamable HTTP (Recommended)
environment:
  - PROTOCOL=SHTTP

# Server-Sent Events
environment:
  - PROTOCOL=SSE

# WebSocket
environment:
  - PROTOCOL=WS
```

### CORS Configuration

```yaml
# Development - Allow all origins
environment:
  - CORS=*

# Production - Specific domains
environment:
  - CORS=https://example.com,https://app.example.com

# Mixed domains and IPs
environment:
  - CORS=https://example.com,192.168.1.100:3000
```

> ⚠️ **Security:** Never use `CORS=*` in production environments

### Configuration Examples

#### US Eastern Time Setup

```yaml
environment:
  - TIME_DEFAULT_TIMEZONE=America/New_York
  - TIME_LOCALE=en-US
  - TZ=America/New_York
```

#### European Setup

```yaml
environment:
  - TIME_DEFAULT_TIMEZONE=Europe/Paris
  - TIME_LOCALE=fr-FR
  - TZ=Europe/Paris
```

#### Asia Pacific Setup

```yaml
environment:
  - TIME_DEFAULT_TIMEZONE=Asia/Tokyo
  - TIME_LOCALE=ja-JP
  - TZ=Asia/Tokyo
```

---

## MCP Client Setup

### Transport Compatibility

| Client | HTTP | SSE | WebSocket | Recommended |
|:-------|:----:|:---:|:---------:|:------------|
| **VS Code (Cline/Roo-Cline)** | ✅ | ✅ | ❌ | HTTP |
| **Claude Desktop** | ✅ | ✅ | ⚠️* | HTTP |
| **Cursor** | ✅ | ✅ | ⚠️* | HTTP |
| **Windsurf** | ✅ | ✅ | ⚠️* | HTTP |

> ⚠️ *WebSocket support is experimental

### VS Code (Cline/Roo-Cline)

Add to `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "time": {
      "url": "http://host-ip:8060/mcp",
      "transport": "http",
      "autoApprove": [
        "current_time",
        "relative_time",
        "get_timestamp",
        "days_in_month",
        "convert_time",
        "get_week_year"
      ]
    }
  }
}
```

### Claude Desktop

**Config Locations:**
- **Linux:** `~/.config/Claude/claude_desktop_config.json`
- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "time": {
      "transport": "http",
      "url": "http://localhost:8060/mcp"
    }
  }
}
```

### Cursor

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "time": {
      "transport": "http",
      "url": "http://host-ip:8060/mcp"
    }
  }
}
```

### Windsurf (Codeium)

Add to `.codeium/mcp_settings.json`:

```json
{
  "mcpServers": {
    "time": {
      "transport": "http",
      "url": "http://host-ip:8060/mcp"
    }
  }
}
```

### Claude Code

Add to `~/.config/claude-code/mcp_config.json`:

```json
{
  "mcpServers": {
    "time": {
      "transport": "http",
      "url": "http://localhost:8060/mcp"
    }
  }
}
```

### GitHub Copilot CLI

Add to `~/.github-copilot/mcp.json`:

```json
{
  "mcpServers": {
    "time": {
      "transport": "http",
      "url": "http://host-ip:8060/mcp"
    }
  }
}
```

---

## Available Tools

### ⏰ current_time
Get current time in UTC and local timezone with comprehensive details including date, time, timezone offset, and formatted timestamps.

**Use Cases:** Display current time, log timestamps, get timezone information, show current date and time

**Example Prompts:**
- "What time is it now?"
- "Show me the current time in UTC"
- "What's the current date and time?"

---

### 🕐 relative_time
Convert absolute timestamps to human-readable relative time expressions (e.g., "2 hours ago", "in 3 days").

**Use Cases:** Display relative timestamps in UI, show "time ago" for posts, calculate time differences, user-friendly time display

**Example Prompts:**
- "How long ago was January 1, 2024?"
- "Show relative time for 2 hours ago"
- "When is 5 days from now in relative terms?"

---

### 📅 get_timestamp
Convert human-readable dates and times to Unix timestamps (milliseconds since epoch).

**Use Cases:** Convert dates to timestamps, database timestamp storage, API timestamp parameters, event scheduling

**Example Prompts:**
- "Get timestamp for December 25, 2024"
- "Convert 'tomorrow at 3pm' to timestamp"
- "What's the Unix timestamp for New Year 2025?"

---

### 📆 days_in_month
Calculate the number of days in any month, accounting for leap years.

**Use Cases:** Calendar calculations, date range validation, monthly scheduling, billing period calculations

**Example Prompts:**
- "How many days are in February 2024?"
- "Days in current month"
- "How many days in December?"

---

### 🌍 convert_time
Convert time between different timezones with full timezone information and DST handling.

**Use Cases:** International meeting scheduling, multi-timezone coordination, travel time planning, global event timing

**Example Prompts:**
- "Convert 3pm EST to Tokyo time"
- "What time is 9am UTC in Los Angeles?"
- "Show 2pm London time in Sydney"

---

### 📊 get_week_year
Get the week number and ISO week number for any date, useful for weekly planning and reporting.

**Use Cases:** Weekly reporting and analytics, project week tracking, ISO week calculations, calendar week identification

**Example Prompts:**
- "What week of the year is it?"
- "Get week number for December 25, 2024"
- "What's the ISO week for today?"

---

## Advanced Usage

### Production Configuration

```yaml
services:
  time-mcp:
    image: mekayelanik/time-mcp:stable
    container_name: time-mcp
    restart: unless-stopped
    ports:
      - "8060:8060"
    environment:
      - TIME_DEFAULT_TIMEZONE=UTC
      - TIME_LOCALE=en-US
      - PORT=8060
      - PROTOCOL=SHTTP
      - CORS=https://app.example.com
      - PUID=1000
      - PGID=1000
      - TZ=UTC
    
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M
    
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "8060"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
```

### Reverse Proxy Setup

#### Nginx

```nginx
server {
    listen 80;
    server_name time.example.com;
    
    location / {
        proxy_pass http://localhost:8060;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60;
        proxy_send_timeout 60;
        proxy_read_timeout 60;
    }
}
```

#### Traefik

```yaml
services:
  time-mcp:
    image: mekayelanik/time-mcp:stable
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.time-mcp.rule=Host(`time.example.com`)"
      - "traefik.http.routers.time-mcp.entrypoints=websecure"
      - "traefik.http.routers.time-mcp.tls.certresolver=myresolver"
      - "traefik.http.services.time-mcp.loadbalancer.server.port=8060"
```

### Multiple Instances for Different Regions

```yaml
services:
  time-mcp-utc:
    image: mekayelanik/time-mcp:stable
    container_name: time-utc
    ports:
      - "8060:8060"
    environment:
      - TIME_DEFAULT_TIMEZONE=UTC
      - TIME_LOCALE=en-US
      - PORT=8060
  
  time-mcp-us:
    image: mekayelanik/time-mcp:stable
    container_name: time-us
    ports:
      - "8061:8060"
    environment:
      - TIME_DEFAULT_TIMEZONE=America/New_York
      - TIME_LOCALE=en-US
      - TZ=America/New_York
      - PORT=8060
  
  time-mcp-eu:
    image: mekayelanik/time-mcp:stable
    container_name: time-eu
    ports:
      - "8062:8060"
    environment:
      - TIME_DEFAULT_TIMEZONE=Europe/Paris
      - TIME_LOCALE=fr-FR
      - TZ=Europe/Paris
      - PORT=8060
```

### Using Environment File

Create `.env` file:

```bash
TIME_DEFAULT_TIMEZONE=UTC
TIME_LOCALE=en-US
PORT=8060
PROTOCOL=SHTTP
CORS=https://example.com
TZ=UTC
```

Then use in docker-compose.yml:

```yaml
services:
  time-mcp:
    image: mekayelanik/time-mcp:stable
    env_file: .env
    ports:
      - "${PORT}:${PORT}"
```

---

## Troubleshooting

### Pre-Flight Checklist

- ✅ Docker 23.0+
- ✅ Port 8060 available
- ✅ Network connectivity
- ✅ Latest stable image
- ✅ Valid timezone and locale

### Common Issues

**Container Won't Start**
```bash
# Check logs for detailed error
docker logs time-mcp

# Pull latest image
docker pull mekayelanik/time-mcp:stable

# Restart container
docker restart time-mcp
```

**Connection Refused**
```bash
# Verify container is running
docker ps | grep time-mcp

# Check port binding
docker port time-mcp

# Test health endpoint
curl http://localhost:8060/healthz
```

**Invalid Timezone Error**
```yaml
# Use valid IANA timezone names
environment:
  - TIME_DEFAULT_TIMEZONE=UTC  # ✅ Valid
  # Not: TIME_DEFAULT_TIMEZONE=PST  # ❌ Invalid
```

**Invalid Locale Error**
```yaml
# Use valid locale format (language-COUNTRY or language)
environment:
  - TIME_LOCALE=en-US  # ✅ Valid
  - TIME_LOCALE=en     # ✅ Valid
  # Not: TIME_LOCALE=English  # ❌ Invalid
```

**Port Already in Use**
```bash
# Check what's using the port
sudo lsof -i :8060

# Use a different port
docker run -p 8061:8060 mekayelanik/time-mcp:stable
```

**CORS Errors**
```yaml
# Development - allow all
environment:
  - CORS=*

# Production - specific origins
environment:
  - CORS=https://yourdomain.com
```

**Debug Mode**
```yaml
# Enable verbose debugging
environment:
  - DEBUG_MODE=verbose

# Then check logs
docker logs -f time-mcp
```

### Health Check Testing

```bash
# Basic health check
curl http://localhost:8060/healthz

# Test MCP endpoint
curl http://localhost:8060/mcp

# View running configuration
docker logs time-mcp | grep "CONFIGURATION"
```

### Validation Messages

```bash
# ✅ Success messages
🌍 Default Timezone: UTC
🌐 Locale: en-US
🚀 Launching Time MCP Server with protocol: SHTTP/streamableHttp on port: 8060

# ⚠️ Warning messages
⚠️  Warning: Invalid TIME_DEFAULT_TIMEZONE: 'PST'
   Using default: UTC
```

---

## Performance Tips

### Optimize for Speed

```yaml
environment:
  - TIME_DEFAULT_TIMEZONE=UTC
  - TIME_LOCALE=en-US
```

### Resource Limits

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 256M
    reservations:
      cpus: '0.25'
      memory: 128M
```

---

## Security Best Practices

1. **Network Security**
   - Never use `CORS=*` in production
   - Use HTTPS with reverse proxy
   - Implement rate limiting

2. **Container Security**
   - Run as non-root user (default PUID/PGID)
   - Keep Docker image updated
   - Use specific version tags for production

3. **Monitoring**
   - Set up logging and alerting
   - Track health check status
   - Monitor resource usage

4. **Access Control**
   - Use reverse proxy authentication
   - Implement IP whitelisting if needed
   - Monitor access logs

---

## Use Case Examples

### Meeting Scheduler
Configure for global meeting coordination with UTC default and multiple locale support.

**Example queries:**
- "What time is 3pm EST in all major timezones?"
- "Convert 9am Tokyo time to New York and London"
- "Schedule a meeting for 2pm UTC - show in all timezones"

### Event Platform
Configure for event timing and countdowns with appropriate timezone settings.

**Example queries:**
- "How many days until December 31, 2024?"
- "Show relative time for event in 3 hours"
- "Get timestamp for event start time"

### International Business
Configure for global business operations with UTC default for consistency.

**Example queries:**
- "What are business hours in Tokyo when it's 9am in New York?"
- "Convert deadline from PST to all international offices"
- "Calculate time difference between Sydney and London"

---

## Resources & Support

### Documentation
- 📦 [Official NPM Package](https://www.npmjs.com/package/time-mcp)
- 🐙 [GitHub Repository](https://github.com/yokingma/time-mcp)
- 📘 [Smithery Listing](https://smithery.ai/server/@yokingma/time-mcp)
- 🐳 [Docker Hub](https://hub.docker.com/r/mekayelanik/time-mcp)

### Time Resources
- 🌍 [IANA Time Zone Database](https://www.iana.org/time-zones)
- 📅 [ISO 8601 Standard](https://en.wikipedia.org/wiki/ISO_8601)
- ⏰ [World Time Zones](https://www.timeanddate.com/time/zones/)

### MCP Resources
- 📘 [MCP Protocol Specification](https://modelcontextprotocol.io)
- 🎓 [MCP Documentation](https://modelcontextprotocol.io/docs)
- 💬 [MCP Community](https://discord.gg/mcp)

### Getting Help

**Docker Image Issues:**
- [GitHub Issues](https://github.com/mekayelanik/time-mcp-docker/issues)
- [Discussions](https://github.com/mekayelanik/time-mcp-docker/discussions)

**General Questions:**
- Check logs: `docker logs time-mcp`
- Test health: `curl http://localhost:8060/healthz`
- Visit [Smithery](https://smithery.ai/server/@yokingma/time-mcp)

### Updating

```bash
# Docker Compose
docker compose pull
docker compose up -d

# Docker CLI
docker pull mekayelanik/time-mcp:stable
docker stop time-mcp
docker rm time-mcp
# Re-run your docker run command
```

### Version Pinning

```yaml
# Use specific version
services:
  time-mcp:
    image: mekayelanik/time-mcp:1.0.3

# Or use stable tag (recommended)
services:
  time-mcp:
    image: mekayelanik/time-mcp:stable
```

---

## License

GPL License - See [LICENSE](https://raw.githubusercontent.com/MekayelAnik/time-mcp-docker/refs/heads/main/LICENSE) for details.

**Disclaimer:** Unofficial Docker image for [time-mcp](https://www.npmjs.com/package/time-mcp). No API keys or external services required. All time calculations performed locally.

---

## Acknowledgments

- Original NPM package by [@yokingma](https://github.com/yokingma)
- Built with [Model Context Protocol](https://modelcontextprotocol.io)
- Timezone data from [IANA Time Zone Database](https://www.iana.org/time-zones)

---

<div align="center">

[Report Bug](https://github.com/mekayelanik/time-mcp-docker/issues) • [Request Feature](https://github.com/mekayelanik/time-mcp-docker/issues) • [Contribute](https://github.com/mekayelanik/time-mcp-docker/pulls)

**⭐ Star this project if you find it useful!**

</div>