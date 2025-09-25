# Use Kali Linux rolling as base
FROM kalilinux/kali-rolling

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    nmap \
    nikto \
    sqlmap \
    wpscan \
    dirb \
    exploitdb \
    exploitdb-bin-sploits \
    exploitdb-papers \
    net-tools \
    iputils-ping \
    curl \
    wget \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Create virtual environment and install Python dependencies
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the server code
COPY security_server.py .

# Create non-root user with necessary capabilities
RUN useradd -m -u 1000 mcpuser && \
    chown -R mcpuser:mcpuser /app && \
    chown -R mcpuser:mcpuser /opt/venv

# Set capabilities for network tools (required for raw sockets)
RUN setcap cap_net_raw+ep /usr/bin/nmap

# Update exploit database (ignore errors)
RUN searchsploit -u || true

# Switch to non-root user
USER mcpuser

# Ensure virtual environment is active
ENV PATH="/opt/venv/bin:$PATH"

# Run the server
CMD ["python3", "security_server.py"]