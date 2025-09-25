#!/bin/bash

echo "🛡️  Setting up Security Testing MCP Server..."

# Check if we're in the right directory
if [ ! -f "Dockerfile" ] || [ ! -f "security_server.py" ]; then
    echo "❌ Please run this script from the security-mcp-server directory"
    echo "💡 Run: git clone https://github.com/avi686/security-mcp-server.git && cd security-mcp-server"
    exit 1
fi

# Build Docker image
echo "🔨 Building Docker image..."
if docker build -t security-mcp-server .; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Docker build failed"
    exit 1
fi

# Set up MCP configuration
echo "⚙️  Setting up MCP configuration..."
mkdir -p ~/.docker/mcp/catalogs

# Create custom catalog
cat << 'EOF' > ~/.docker/mcp/catalogs/custom.yaml
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
    readme: ""
    toolsUrl: ""
    source: ""
    upstream: ""
    icon: ""
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
        - nmap
        - nikto
        - sqlmap
        - wpscan
      license: MIT
      owner: local
EOF

echo "✅ Custom catalog created at ~/.docker/mcp/catalogs/custom.yaml"

# Update registry
if [ -f ~/.docker/mcp/registry.yaml ]; then
    if ! grep -q "security:" ~/.docker/mcp/registry.yaml; then
        echo "  security:" >> ~/.docker/mcp/registry.yaml
        echo "    ref: \"\"" >> ~/.docker/mcp/registry.yaml
        echo "✅ Added security server to existing registry"
    else
        echo "✅ Security server already in registry"
    fi
else
    cat << 'EOF' > ~/.docker/mcp/registry.yaml
registry:
  security:
    ref: ""
EOF
    echo "✅ Created new registry file"
fi

# Configure Claude Desktop
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    MCP_PATH="/Users/$USER/.docker/mcp"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CONFIG_PATH="$HOME/.config/Claude/claude_desktop_config.json"
    MCP_PATH="/home/$USER/.docker/mcp"
else
    echo "⚠️  Windows detected. Please manually configure Claude Desktop."
    echo "📝 Config file location: %APPDATA%\\Claude\\claude_desktop_config.json"
    echo "📂 MCP path: C:\\Users\\$USERNAME\\.docker\\mcp"
    echo ""
    echo "Add this to your Claude Desktop config:"
    echo '{
  "mcpServers": {
    "mcp-toolkit-gateway": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm", "--network=host",
        "-v", "/var/run/docker.sock:/var/run/docker.sock",
        "-v", "C:\\Users\\$USERNAME\\.docker\\mcp:/mcp",
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
}'
    exit 1
fi

mkdir -p "$(dirname "$CONFIG_PATH")"

cat << EOF > "$CONFIG_PATH"
{
  "mcpServers": {
    "mcp-toolkit-gateway": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "--network=host",
        "-v", "/var/run/docker.sock:/var/run/docker.sock",
        "-v", "$MCP_PATH:/mcp",
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
EOF

echo "✅ Claude Desktop config updated at: $CONFIG_PATH"

# Test the setup
echo "🧪 Testing setup..."

# Test that tools are available in the container
echo "🔍 Testing security tools in container..."
if docker run --rm security-mcp-server nmap --version > /dev/null 2>&1; then
    echo "✅ nmap is available"
else
    echo "❌ nmap test failed"
fi

if docker run --rm security-mcp-server nikto -Version > /dev/null 2>&1; then
    echo "✅ nikto is available"
else
    echo "❌ nikto test failed"
fi

if docker run --rm security-mcp-server searchsploit -h > /dev/null 2>&1; then
    echo "✅ searchsploit is available"
else
    echo "❌ searchsploit test failed"
fi

# Kill Claude Desktop processes to prepare for restart
echo "🔄 Preparing Claude Desktop restart..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    killall "Claude" 2>/dev/null || true
    echo "✅ Claude Desktop processes terminated (macOS)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    pkill -f claude 2>/dev/null || true
    echo "✅ Claude Desktop processes terminated (Linux)"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. 🔄 Start Claude Desktop"
echo "2. 🛡️  Your security testing tools will be available!"
echo ""
echo "🔧 Available tools:"
echo "   • nmap_scan - Network scanning"
echo "   • nikto_scan - Web vulnerability scanning"
echo "   • sqlmap_test - SQL injection testing"
echo "   • wpscan_test - WordPress scanning"
echo "   • dirb_scan - Directory brute forcing"
echo "   • searchsploit_lookup - Exploit database search"
echo "   • ping_sweep - Network discovery"
echo "   • custom_scan - Advanced custom commands"
echo ""
echo "💡 Example usage in Claude Desktop:"
echo '   "Scan my local server 192.168.1.100 for open ports"'
echo '   "Check my website at https://example.com for vulnerabilities"'
echo '   "Search for WordPress exploits in the database"'
echo ""
echo "⚠️  IMPORTANT: Use only on authorized systems for educational purposes!"
echo "📖 See README.md for more detailed usage instructions"