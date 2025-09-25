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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Update exploit database
RUN searchsploit -u

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the server code
COPY security_server.py .

# Create non-root user with necessary capabilities
RUN useradd -m -u 1000 mcpuser && \
    chown -R mcpuser:mcpuser /app

# Set capabilities for network tools (required for raw sockets)
RUN setcap cap_net_raw+ep /usr/bin/nmap

# Switch to non-root user
USER mcpuser

# Run the server
CMD ["python3", "security_server.py"]