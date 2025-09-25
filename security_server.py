#!/usr/bin/env python3
"""
Security Testing MCP Server - Provides penetration testing tools for educational purposes
"""

import os
import sys
import logging
import subprocess
import asyncio
import re
from datetime import datetime, timezone
from mcp.server.fastmcp import FastMCP

# Configure logging to stderr
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stderr
)
logger = logging.getLogger("security-server")

# Initialize MCP server
mcp = FastMCP("security")

# Configuration
SCAN_TIMEOUT = int(os.environ.get("SCAN_TIMEOUT", "300"))
DEFAULT_INTENSITY = os.environ.get("DEFAULT_INTENSITY", "T3")
DIRB_WORDLIST = os.environ.get("DIRB_WORDLIST", "/usr/share/dirb/wordlists/common.txt")
MAX_THREADS = int(os.environ.get("MAX_THREADS", "10"))

# === UTILITY FUNCTIONS ===

def validate_target(target):
    """Basic target validation"""
    if not target.strip():
        return False, "Target cannot be empty"
    
    # Basic sanitization - remove dangerous characters
    dangerous_chars = [";", "&", "|", "`", "$", "(", ")", "<", ">"]
    for char in dangerous_chars:
        if char in target:
            return False, f"Invalid character '{char}' in target"
    
    return True, "Valid target"

async def run_command(command, timeout=SCAN_TIMEOUT):
    """Run command with timeout and return results"""
    try:
        process = await asyncio.create_subprocess_shell(
            command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        
        stdout, stderr = await asyncio.wait_for(process.communicate(), timeout=timeout)
        
        return {
            'returncode': process.returncode,
            'stdout': stdout.decode('utf-8', errors='ignore'),
            'stderr': stderr.decode('utf-8', errors='ignore')
        }
    except asyncio.TimeoutError:
        try:
            process.terminate()
            await process.wait()
        except:
            pass
        return {
            'returncode': -1,
            'stdout': '',
            'stderr': f'Command timed out after {timeout} seconds'
        }
    except Exception as e:
        return {
            'returncode': -1,
            'stdout': '',
            'stderr': str(e)
        }

# === MCP TOOLS ===

@mcp.tool()
async def nmap_scan(target: str = "", scan_type: str = "basic", ports: str = "", timing: str = "") -> str:
    """Perform network scanning with nmap - supports various scan types and port ranges"""
    logger.info(f"Executing nmap_scan on {target}")
    
    valid, msg = validate_target(target)
    if not valid:
        return f"❌ {msg}"
    
    # Build nmap command
    intensity = timing.strip() if timing.strip() else DEFAULT_INTENSITY
    base_cmd = f"nmap -T{intensity}"
    
    if scan_type == "quick":
        base_cmd += " -F"
    elif scan_type == "comprehensive":
        base_cmd += " -sS -sV -O -A"
    elif scan_type == "stealth":
        base_cmd += " -sS -f"
    elif scan_type == "udp":
        base_cmd += " -sU --top-ports 100"
    elif scan_type == "version":
        base_cmd += " -sV"
    elif scan_type == "os":
        base_cmd += " -O"
    
    if ports.strip():
        base_cmd += f" -p {ports}"
    
    command = f"{base_cmd} {target}"
    
    try:
        result = await run_command(command)
        
        if result['returncode'] == 0:
            return f"🔍 Nmap Scan Results for {target}:\n\n{result['stdout']}"
        else:
            return f"❌ Nmap scan failed:\n{result['stderr']}"
            
    except Exception as e:
        logger.error(f"Nmap error: {e}")
        return f"❌ Error: {str(e)}"

@mcp.tool()
async def nikto_scan(target: str = "", plugins: str = "", tuning: str = "") -> str:
    """Perform web vulnerability scanning with nikto - comprehensive web app security testing"""
    logger.info(f"Executing nikto_scan on {target}")
    
    valid, msg = validate_target(target)
    if not valid:
        return f"❌ {msg}"
    
    # Ensure target has protocol
    if not target.startswith(('http://', 'https://')):
        target = f"http://{target}"
    
    command = f"nikto -h {target} -Format txt"
    
    if plugins.strip():
        command += f" -Plugins {plugins}"
    
    if tuning.strip():
        command += f" -Tuning {tuning}"
    
    try:
        result = await run_command(command)
        
        if result['returncode'] == 0:
            return f"🔒 Nikto Vulnerability Scan for {target}:\n\n{result['stdout']}"
        else:
            return f"❌ Nikto scan failed:\n{result['stderr']}"
            
    except Exception as e:
        logger.error(f"Nikto error: {e}")
        return f"❌ Error: {str(e)}"

@mcp.tool()
async def sqlmap_test(target: str = "", parameter: str = "", technique: str = "", database: str = "") -> str:
    """Test for SQL injection vulnerabilities with sqlmap - automated SQL injection testing"""
    logger.info(f"Executing sqlmap_test on {target}")
    
    valid, msg = validate_target(target)
    if not valid:
        return f"❌ {msg}"
    
    if not target.startswith(('http://', 'https://')):
        target = f"http://{target}"
    
    command = f"sqlmap -u {target} --batch --risk=1 --level=1"
    
    if parameter.strip():
        command += f" -p {parameter}"
    
    if technique.strip():
        command += f" --technique={technique}"
    
    if database.strip():
        command += f" -D {database} --tables"
    
    try:
        result = await run_command(command)
        
        output = result['stdout'] + result['stderr']
        return f"💉 SQLMap Test Results for {target}:\n\n{output}"
            
    except Exception as e:
        logger.error(f"SQLMap error: {e}")
        return f"❌ Error: {str(e)}"

@mcp.tool()
async def wpscan_test(target: str = "", enumerate: str = "vp", api_token: str = "") -> str:
    """Scan WordPress sites for vulnerabilities with wpscan - WordPress security assessment"""
    logger.info(f"Executing wpscan_test on {target}")
    
    valid, msg = validate_target(target)
    if not valid:
        return f"❌ {msg}"
    
    if not target.startswith(('http://', 'https://')):
        target = f"http://{target}"
    
    command = f"wpscan --url {target} --enumerate {enumerate} --format cli"
    
    if api_token.strip():
        command += f" --api-token {api_token}"
    
    try:
        result = await run_command(command)
        
        output = result['stdout'] + result['stderr']
        return f"🌐 WPScan Results for {target}:\n\n{output}"
            
    except Exception as e:
        logger.error(f"WPScan error: {e}")
        return f"❌ Error: {str(e)}"

@mcp.tool()
async def dirb_scan(target: str = "", wordlist: str = "", extensions: str = "", threads: str = "") -> str:
    """Perform directory and file brute forcing with dirb - web content discovery"""
    logger.info(f"Executing dirb_scan on {target}")
    
    valid, msg = validate_target(target)
    if not valid:
        return f"❌ {msg}"
    
    if not target.startswith(('http://', 'https://')):
        target = f"http://{target}"
    
    wordlist_path = wordlist.strip() if wordlist.strip() else DIRB_WORDLIST
    command = f"dirb {target} {wordlist_path}"
    
    if extensions.strip():
        command += f" -X {extensions}"
    
    if threads.strip():
        try:
            thread_count = min(int(threads), MAX_THREADS)
            command += f" -z {thread_count}"
        except ValueError:
            pass
    
    try:
        result = await run_command(command)
        
        if result['returncode'] == 0:
            return f"📁 DIRB Directory Scan for {target}:\n\n{result['stdout']}"
        else:
            return f"❌ DIRB scan failed:\n{result['stderr']}"
            
    except Exception as e:
        logger.error(f"DIRB error: {e}")
        return f"❌ Error: {str(e)}"

@mcp.tool()
async def searchsploit_lookup(search_term: str = "", type_filter: str = "", exact: str = "") -> str:
    """Search for exploits in the exploit database using searchsploit - exploit research tool"""
    logger.info(f"Executing searchsploit_lookup for {search_term}")
    
    if not search_term.strip():
        return "❌ Error: Search term is required"
    
    command = f"searchsploit {search_term}"
    
    if type_filter.strip():
        command += f" --type={type_filter}"
    
    if exact.strip().lower() == "true":
        command += " --exact"
    
    try:
        result = await run_command(command, timeout=30)
        
        if result['returncode'] == 0:
            return f"🔍 Exploit Database Search for '{search_term}':\n\n{result['stdout']}"
        else:
            return f"❌ Searchsploit lookup failed:\n{result['stderr']}"
            
    except Exception as e:
        logger.error(f"Searchsploit error: {e}")
        return f"❌ Error: {str(e)}"

@mcp.tool()
async def ping_sweep(target_range: str = "", count: str = "3") -> str:
    """Perform ping sweep on IP range or single host - network discovery tool"""
    logger.info(f"Executing ping_sweep to {target_range}")
    
    valid, msg = validate_target(target_range)
    if not valid:
        return f"❌ {msg}"
    
    try:
        count_int = int(count) if count.strip() else 3
        count_int = min(count_int, 10)  # Limit to 10 pings max
    except ValueError:
        count_int = 3
    
    # Use nmap for ping sweep if it's a range, regular ping for single host
    if "/" in target_range or "-" in target_range:
        command = f"nmap -sn {target_range}"
    else:
        command = f"ping -c {count_int} {target_range}"
    
    try:
        result = await run_command(command, timeout=60)
        
        output = result['stdout'] + result['stderr']
        return f"🌐 Network Discovery for {target_range}:\n\n{output}"
            
    except Exception as e:
        logger.error(f"Ping sweep error: {e}")
        return f"❌ Error: {str(e)}"

@mcp.tool()
async def custom_scan(tool: str = "", target: str = "", options: str = "") -> str:
    """Execute custom security tool commands - advanced usage for experienced users"""
    logger.info(f"Executing custom_scan with {tool}")
    
    valid, msg = validate_target(target)
    if not valid:
        return f"❌ {msg}"
    
    if not tool.strip():
        return "❌ Error: Tool name is required"
    
    # Whitelist of allowed tools for security
    allowed_tools = ["nmap", "nikto", "sqlmap", "wpscan", "dirb", "curl", "wget", "nc", "telnet"]
    
    if tool not in allowed_tools:
        return f"❌ Error: Tool '{tool}' not in allowed list: {', '.join(allowed_tools)}"
    
    command = f"{tool} {options} {target}".strip()
    
    try:
        result = await run_command(command)
        
        output = result['stdout'] + result['stderr']
        return f"⚡ Custom {tool} execution:\n\n{output}"
            
    except Exception as e:
        logger.error(f"Custom scan error: {e}")
        return f"❌ Error: {str(e)}"

# === SERVER STARTUP ===

if __name__ == "__main__":
    logger.info("Starting Security Testing MCP server...")
    logger.info(f"Scan timeout: {SCAN_TIMEOUT}s")
    logger.info(f"Default intensity: {DEFAULT_INTENSITY}")
    logger.info(f"DIRB wordlist: {DIRB_WORDLIST}")
    logger.info(f"Max threads: {MAX_THREADS}")
    
    try:
        mcp.run(transport='stdio')
    except Exception as e:
        logger.error(f"Server error: {e}", exc_info=True)
        sys.exit(1)