# Security Testing MCP Server Implementation

## Overview

This MCP server provides comprehensive penetration testing capabilities using Kali Linux tools, designed for educational purposes and authorized security testing.

## Implementation Details

### Container Architecture
- **Base Image**: kalilinux/kali-rolling (full Kali Linux environment)
- **User**: Non-root (mcpuser) with necessary capabilities
- **Network**: Requires host network mode for full tool functionality
- **Security**: Input sanitization, command validation, timeouts

### Tools Implemented

1. **nmap_scan**: Network discovery and port scanning
   - Multiple scan types (basic, quick, comprehensive, stealth, UDP, version, OS)
   - Custom port ranges and timing templates
   - Service detection and OS fingerprinting

2. **nikto_scan**: Web application vulnerability assessment
   - Plugin support for targeted testing
   - Tuning options for specific vulnerability classes
   - Comprehensive web server analysis

3. **sqlmap_test**: Automated SQL injection testing
   - Parameter-specific testing
   - Custom injection techniques
   - Database enumeration capabilities

4. **wpscan_test**: WordPress security assessment
   - Vulnerability database integration
   - Plugin and theme enumeration
   - API token support for latest vulnerability data

5. **dirb_scan**: Web directory/file enumeration
   - Custom wordlist support
   - File extension filtering
   - Multi-threaded scanning

6. **searchsploit_lookup**: Exploit database queries
   - Advanced search filters
   - Exact match options
   - Exploit type categorization

7. **ping_sweep**: Network discovery
   - Single host and range support
   - ICMP and ARP ping methods
   - Network reachability testing

8. **custom_scan**: Advanced custom commands
   - Whitelisted tool execution
   - Flexible parameter passing
   - Expert-level functionality

### Security Controls

- **Input Validation**: Sanitizes dangerous characters and commands
- **Timeout Protection**: Configurable timeouts (default: 5 minutes)
- **User Privileges**: Runs as non-root with minimal required capabilities
- **Tool Whitelisting**: Custom scan function restricts allowed tools
- **Error Handling**: Graceful failure with informative messages

### Configuration Options

Environment variables for customization:
- `SCAN_TIMEOUT`: Maximum execution time (default: 300s)
- `DEFAULT_INTENSITY`: Nmap timing template (default: T3)
- `DIRB_WORDLIST`: Directory wordlist path
- `MAX_THREADS`: Maximum thread count for multi-threaded tools

### Usage Guidelines

This server is intended for:
- Authorized penetration testing engagements
- Educational security training exercises
- Security research in controlled environments
- Bug bounty and vulnerability research

**Critical**: Always obtain proper authorization before testing any systems.

## Technical Notes

- Container requires host network mode (`--network=host`) for optimal functionality
- Raw socket capabilities needed for advanced nmap features
- All commands executed asynchronously with proper timeout handling
- Results formatted for clear presentation in Claude interface
- Exploit database updated during container build

## Advanced Features

- **Flexible Targeting**: Supports IP addresses, hostnames, and URL formats
- **Scan Customization**: Extensive parameter options for each tool
- **Result Formatting**: Structured output with status indicators
- **Error Recovery**: Robust error handling and timeout management
- **Resource Management**: Thread limiting and process control

## Installation Process

The automated installation script (`install.sh`) handles:

1. **Docker Image Building**: Compiles the Kali Linux container with all security tools
2. **MCP Configuration**: Creates the custom catalog and registry entries
3. **Claude Desktop Setup**: Configures the MCP gateway integration
4. **Verification**: Tests that all tools are properly installed
5. **Service Restart**: Prepares Claude Desktop for the new tools

## File Structure

```
security-mcp-server/
├── Dockerfile              # Kali Linux container definition
├── requirements.txt         # Python dependencies
├── security_server.py       # Main MCP server implementation
├── install.sh              # Automated setup script
├── README.md               # User documentation
└── CLAUDE.md               # Implementation details (this file)
```

## Architecture Diagram

```
Claude Desktop
    ↓
MCP Gateway (Docker)
    ↓
Security MCP Server (Kali Container)
    ↓
┌─────────────────────────────────────┐
│ Security Tools:                     │
│ • nmap (network scanning)           │
│ • nikto (web vulnerability)         │
│ • sqlmap (SQL injection)            │
│ • wpscan (WordPress security)       │
│ • dirb (directory bruteforce)       │
│ • searchsploit (exploit database)   │
│ • ping/nmap (network discovery)     │
│ • Custom tool execution             │
└─────────────────────────────────────┘
```

## Security Considerations

### Input Sanitization
- Dangerous shell characters are filtered from all inputs
- Command injection prevention through parameter validation
- Whitelist-based approach for custom tool execution

### Network Security
- Host network mode required for raw socket operations
- Tools restricted to prevent abuse
- Timeout controls prevent resource exhaustion

### User Privileges
- Container runs as non-root user (mcpuser)
- Minimal capabilities granted only for required network operations
- No unnecessary system access or file permissions

## Development Guidelines

### Adding New Tools
1. Install the tool in the Dockerfile
2. Create a new MCP tool function with `@mcp.tool()` decorator
3. Implement proper input validation and error handling
4. Update the catalog with the new tool name
5. Document the tool's purpose and parameters

### Testing
- Each tool should be tested in isolation
- Verify proper error handling for invalid inputs
- Test timeout functionality with long-running operations
- Confirm output formatting is consistent

## Troubleshooting

### Common Issues
1. **Container build fails**: Check Docker daemon and internet connectivity
2. **Tools not appearing**: Verify catalog and registry configuration
3. **Permission errors**: Ensure host network mode is enabled
4. **Scan timeouts**: Adjust `SCAN_TIMEOUT` environment variable

### Debugging
- Check container logs: `docker logs <container_name>`
- Test tools directly: `docker run --rm security-mcp-server nmap --version`
- Verify MCP configuration files exist and are properly formatted

## Future Enhancements

Potential improvements:
- **Additional Tools**: Metasploit, Burp Suite CLI, gobuster
- **Output Formats**: JSON structured results, XML reports
- **Database Integration**: Result storage and historical analysis
- **Scan Scheduling**: Automated periodic assessments
- **Reporting**: PDF generation and executive summaries
- **Integration**: SIEM and vulnerability management platforms

## Legal and Ethical Considerations

This tool is designed for:
- **Educational purposes**: Learning security testing methodologies
- **Authorized testing**: With explicit written permission
- **Security research**: In controlled laboratory environments
- **Bug bounty programs**: Following program guidelines

**Prohibited uses**:
- Testing systems without permission
- Malicious attacks or unauthorized access
- Violation of computer crime laws
- Network disruption or denial of service

Users are solely responsible for ensuring legal and ethical use of these tools.

## Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Implement changes with proper testing
4. Update documentation as needed
5. Submit a pull request with detailed description

## License

This project is released under the MIT License, allowing for educational use and modification while maintaining attribution requirements.