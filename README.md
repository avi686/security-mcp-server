# Security Testing MCP Server

A Model Context Protocol (MCP) server that provides penetration testing tools for educational purposes using Kali Linux security tools.

## Purpose

This MCP server provides a comprehensive interface for AI assistants to perform security testing using popular Kali Linux tools for educational and authorized testing purposes.

## Features

### Current Implementation

- **`nmap_scan`** - Network port scanning and service detection with multiple scan types
- **`nikto_scan`** - Web vulnerability scanning with plugin support
- **`sqlmap_test`** - SQL injection testing with advanced options
- **`wpscan_test`** - WordPress vulnerability scanning with API token support
- **`dirb_scan`** - Directory and file brute forcing with custom wordlists
- **`searchsploit_lookup`** - Exploit database searching with filters
- **`ping_sweep`** - Network discovery and connectivity testing
- **`custom_scan`** - Execute custom commands with whitelisted tools

## Quick Start

1. **Clone and Build:**
   ```bash
   git clone https://github.com/avi686/security-mcp-server.git
   cd security-mcp-server
   docker build -t security-mcp-server .
   ```

2. **Set up MCP Configuration:**
   ```bash
   mkdir -p ~/.docker/mcp/catalogs
   ```

3. **Create custom catalog** (`~/.docker/mcp/catalogs/custom.yaml`):
   ```yaml
   version: 2
   name: custom
   displayName: Custom MCP Servers
   registry:
     security:
       description: "Comprehensive penetration testing tools for educational and authorized use"
       title: "Security Testing Tools"
       type: server
       dateAdded: "2025-09-24T00:00:00Z"
       image: security-mcp-server:latest
       ref: ""
       tools:
         - name: nmap_scan
         - name: nikto_scan
         - name: sqlmap_test
         - name: wpscan_test
         - name: dirb_scan
         - name: searchsploit_lookup
         - name: ping_sweep
         - name: custom_scan
       metadata:
         category: security
         tags:
           - penetration-testing
           - security
           - kali-linux
           - educational
         license: MIT
         owner: local
   ```

4. **Update registry** (`~/.docker/mcp/registry.yaml`):
   ```yaml
   registry:
     security:
       ref: ""
   ```

5. **Configure Claude Desktop** (add to your config):
   ```json
   {
     "mcpServers": {
       "mcp-toolkit-gateway": {
         "command": "docker",
         "args": [
           "run", "-i", "--rm", "--network=host",
           "-v", "/var/run/docker.sock:/var/run/docker.sock",
           "-v", "/path/to/your/home/.docker/mcp:/mcp",
           "docker/mcp-gateway",
           "--catalog=/mcp/catalogs/docker-mcp.yaml",
           "--catalog=/mcp/catalogs/custom.yaml",
           "--config=/mcp/config.yaml",
           "--registry=/mcp/registry.yaml",
           "--tools-config=/mcp/tools.yaml",
           "--transport=stdio"
         ]
       }
     }
   }
   ```

6. **Restart Claude Desktop**

## Usage Examples

In Claude Desktop, you can ask:
- "Scan example.com for open ports using nmap"
- "Check https://testsite.com for web vulnerabilities with nikto"
- "Search for Apache exploits in the database"
- "Test WordPress site at https://myblog.com for vulnerabilities"
- "Brute force directories on https://target.com with custom extensions"
- "Perform SQL injection testing on https://webapp.com/page?id=1"

## Environment Variables

- `SCAN_TIMEOUT`: Maximum scan time in seconds (default: 300)
- `DEFAULT_INTENSITY`: Nmap timing template T1-T5 (default: T3)
- `DIRB_WORDLIST`: Path to directory wordlist (default: common.txt)
- `MAX_THREADS`: Maximum thread count for tools (default: 10)

## Security and Legal Notice

**IMPORTANT**: This tool is for educational purposes and authorized testing only. Users are responsible for:

- Obtaining proper authorization before scanning any systems
- Complying with local laws and regulations
- Using tools ethically and responsibly
- Not using for malicious purposes

The developers assume no responsibility for misuse of these tools.

## License

MIT License