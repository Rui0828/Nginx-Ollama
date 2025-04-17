# Nginx-Ollama

## Overview

Nginx-Ollama combines the powerful Nginx web server with Ollama's local LLM capabilities to create a production-ready environment for serving AI models. This setup enables:

- Load balancing across multiple Ollama instances
- SSL/TLS termination for secure connections
- Rate limiting to prevent abuse
- Simple API access from various clients and applications
- API key authentication for secure access control

## Prerequisites

- Docker and Docker Compose
- Ollama installed on your server(s)
- Basic understanding of Nginx configuration
- SSL certificates (if enabling HTTPS)

## Setup Instructions

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/Nginx-Ollama.git
   cd Nginx-Ollama
   ```

2. Configure your environment:
   - Edit the Nginx configuration files in the `nginx/conf` directory
   - Update the Docker Compose file to match your environment

3. Start the services:
   ```
   docker-compose up -d
   ```

## Configuration

### Nginx Configuration

The main Nginx configuration handles routing requests to your Ollama instances. Edit `nginx/conf/nginx.conf` to customize:

- Upstream server definitions
- SSL settings
- Rate limiting
- Access controls

### Ollama Settings

Ensure your Ollama instances are properly configured and running the models you need.

## Authentication System

### API Key Authentication

This project implements API key authentication to secure access to the Ollama API endpoints:

1. **How it works:**
   - Each request to the Ollama API must include an `X-API-Key` header
   - The Nginx server validates this key against a predefined list of authorized keys
   - Requests without a valid key receive a 403 Forbidden response

2. **Configuration:**
   - API keys are stored in `/etc/nginx/ollama/keys.txt` (one key per line)
   - Authentication is handled by the Lua script at `/etc/nginx/ollama/check_key.lua`
   - The Nginx configuration in `conf.d/ollama.conf` applies this authentication to all Ollama endpoints

3. **Managing API Keys:**
   - To add a new key: Simply add a new line to the `keys.txt` file
   - To revoke a key: Remove the corresponding line from `keys.txt`
   - After modifying keys, reload the Nginx configuration:
     ```
     docker exec nginx-container nginx -s reload
     ```

4. **Example API Request with Authentication:**
   ```bash
   curl -X POST http://your-nginx-server/ollama/api/generate \
     -H "Content-Type: application/json" \
     -H "X-API-Key: your-api-key-here" \
     -d '{"model": "llama2", "prompt": "Hello, world!"}'
   ```