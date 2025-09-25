# Windows Installation Script for Security MCP Server
# Run this in PowerShell

Write-Host "🛡️  SECURITY MCP SERVER - WINDOWS INSTALLATION" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running or not installed!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop and make sure it's running" -ForegroundColor Red
    Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Pull latest changes
Write-Host "📥 Updating repository..." -ForegroundColor Yellow
git pull origin main

# Build Docker image
Write-Host "" 
Write-Host "🔨 Building Kali Linux Docker image (this may take 10-15 minutes)..." -ForegroundColor Yellow
docker build -t security-mcp-server .
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Docker image built successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Docker build failed!" -ForegroundColor Red
    exit 1
}

# Test the image
Write-Host ""
Write-Host "🧪 Testing security tools..." -ForegroundColor Yellow
docker run --rm security-mcp-server nmap --version
docker run --rm security-mcp-server python3 --version
Write-Host "✅ All tools are working" -ForegroundColor Green

# Set up MCP configuration  
Write-Host ""
Write-Host "⚙️  Setting up MCP configuration..." -ForegroundColor Yellow

# Create MCP directories
$mcpPath = "$env:USERPROFILE\.docker\mcp\catalogs"
New-Item -ItemType Directory -Force -Path $mcpPath | Out-Null

# Create custom catalog
$catalogContent = @'
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
      license: MIT
      owner: local
'@

$catalogContent | Out-File -FilePath "$mcpPath\custom.yaml" -Encoding UTF8
Write-Host "✅ Custom catalog created" -ForegroundColor Green

# Update or create registry
$registryPath = "$env:USERPROFILE\.docker\mcp\registry.yaml"
if (Test-Path $registryPath) {
    $registryContent = Get-Content $registryPath -Raw
    if (-not $registryContent.Contains("security:")) {
        "  security:" | Add-Content $registryPath
        '    ref: ""' | Add-Content $registryPath
        Write-Host "✅ Added security server to existing registry" -ForegroundColor Green
    } else {
        Write-Host "✅ Security server already in registry" -ForegroundColor Green
    }
} else {
    $registryContent = @'
registry:
  security:
    ref: ""
'@
    $registryContent | Out-File -FilePath $registryPath -Encoding UTF8
    Write-Host "✅ Created new registry file" -ForegroundColor Green
}

# Configure Claude Desktop
Write-Host ""
Write-Host "🖥️  Configuring Claude Desktop..." -ForegroundColor Yellow

$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"
$mcpWindowsPath = "C:\Users\$env:USERNAME\.docker\mcp"

# Create config directory
New-Item -ItemType Directory -Force -Path (Split-Path $configPath) | Out-Null

# Create Claude Desktop configuration
$configContent = @"
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
        "-v", "$($mcpWindowsPath.Replace('\', '/')):/mcp",
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
"@

$configContent | Out-File -FilePath $configPath -Encoding UTF8
Write-Host "✅ Claude Desktop configured at: $configPath" -ForegroundColor Green

# Kill existing Claude processes
Write-Host ""
Write-Host "🔄 Stopping Claude Desktop..." -ForegroundColor Yellow
Get-Process -Name "Claude*" -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "✅ Claude Desktop processes stopped" -ForegroundColor Green

# Success message
Write-Host ""
Write-Host "🎉 INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ What's been installed:" -ForegroundColor Green
Write-Host "   • Kali Linux Docker image with security tools"
Write-Host "   • 8 penetration testing tools integrated with Claude"
Write-Host "   • MCP server configured and registered" 
Write-Host "   • Claude Desktop configured for security tools"
Write-Host ""
Write-Host "🔧 Available tools in Claude Desktop:" -ForegroundColor Cyan
Write-Host "   • nmap_scan - Network port scanning"
Write-Host "   • nikto_scan - Web vulnerability scanning"
Write-Host "   • sqlmap_test - SQL injection testing"
Write-Host "   • wpscan_test - WordPress security testing"
Write-Host "   • dirb_scan - Directory brute forcing"
Write-Host "   • searchsploit_lookup - Exploit database search"
Write-Host "   • ping_sweep - Network discovery"
Write-Host "   • custom_scan - Advanced custom commands"
Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Start Claude Desktop"
Write-Host "   2. Your security tools will be available!"
Write-Host ""
Write-Host "💡 Example usage:" -ForegroundColor Yellow
Write-Host "   Ask Claude: 'Scan localhost for open ports'"
Write-Host "   Ask Claude: 'Search for Apache exploits'"
Write-Host "   Ask Claude: 'Check my website for vulnerabilities'"
Write-Host ""
Write-Host "⚠️  IMPORTANT REMINDERS:" -ForegroundColor Red
Write-Host "   • Only use on systems you own or have permission to test"
Write-Host "   • This is for educational and authorized testing only"
Write-Host "   • Always comply with local laws and regulations"
Write-Host ""
Write-Host "Happy ethical hacking! 🛡️" -ForegroundColor Green