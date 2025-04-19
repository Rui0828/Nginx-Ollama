# Nginx-Ollama

A secure proxy for Ollama API using Nginx with OpenResty, providing API key authentication.

## Overview

This project sets up an Nginx reverse proxy with OpenResty to protect your Ollama API endpoints. It adds a layer of security through API key authentication while maintaining all Ollama functionality.

## Features

- API key authentication for Ollama endpoints
- Docker-based deployment for easy setup
- Support for WebSocket connections for streaming responses
- Configurable API keys through a simple text file

## Prerequisites

- Docker and Docker Compose
- Ollama running on your host machine

## Setup

1. Clone this repository
2. Create an `ollama/keys.txt` file with one API key per line
3. Run with Docker Compose:

```bash
docker-compose up -d
```

## Configuration

### API Keys

Add your API keys to `ollama/keys.txt`, with one key per line:

```
your_api_key_1
your_api_key_2
```

### Nginx Configuration

The default configuration exposes Ollama at `/ollama/` and forwards requests to port 11434 on the host machine. You can modify `conf.d/ollama.conf` to change these settings.

## Usage

Send requests to your Ollama instance with an API key header:

```bash
curl -X POST "http://localhost:8080/ollama/api/generate" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_api_key" \
  -d '{"model": "llama2", "prompt": "Hello, world!"}'
```

## License

Apache License 2.0