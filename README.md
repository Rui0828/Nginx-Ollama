# Nginx-Ollama

A containerized Nginx reverse proxy setup using OpenResty for managing Ollama services.

## Features

- **OpenResty-based**: Built on OpenResty (Alpine) for enhanced performance and Lua scripting capabilities
- **Configurable Proxy**: Easily configurable reverse proxy for Ollama API services
- **Docker Compose Ready**: Simple deployment with Docker Compose
- **Rate Limiting Support**: Built-in rate limiting configuration (commented out by default)
- **Large File Support**: Configured to handle large model files up to 100MB
- **Timezone Support**: Pre-configured for Asia/Taipei timezone

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/Rui0828/Nginx-Ollama.git
   cd Nginx-Ollama
   ```

2. Create your Nginx configuration files in the `conf.d` directory:
   ```bash
   mkdir -p conf.d
   ```

3. Add your server configurations to `conf.d/` (see Configuration section below)

4. Start the services:
   ```bash
   docker-compose up -d
   ```

5. Access your services through `http://localhost:8080`

## Configuration

### Directory Structure
```
├── Dockerfile
├── docker-compose.yml
├── nginx.conf
├── conf.d/                        # Your server configurations go here
└── other_tools/ollama/
    ├── check_key.lua              # API key authentication & authorization
    ├── admin_keys.txt             # Admin keys (git-ignored)
    ├── admin_keys.txt.example     # Admin keys example
    ├── inference_keys.txt         # Inference-only keys (git-ignored)
    └── inference_keys.txt.example # Inference-only keys example
```

### Adding Server Configurations

The project includes a pre-configured Ollama proxy with API key authentication. The main configuration is in `conf.d/ollama.conf` which proxies requests to `http://host.docker.internal:11434` through the `/ollama/` path.

#### Example Usage

```bash
# Using X-API-Key header
curl -H "X-API-Key: your-secret-key" http://localhost:8080/ollama/api/tags

# Using Authorization Bearer token
curl -H "Authorization: Bearer your-secret-key" http://localhost:8080/ollama/api/tags

# Using query parameter
curl "http://localhost:8080/ollama/api/tags?api_key=your-secret-key"
```

#### OpenAI API SDK Compatibility

For using OpenAI API SDK or compatible clients, use the `/v1` endpoint:

```bash
# OpenAI API compatible endpoint
curl -H "Authorization: Bearer your-secret-key" \
     -H "Content-Type: application/json" \
     -d '{"model": "llama2", "messages": [{"role": "user", "content": "Hello!"}]}' \
     http://localhost:8080/ollama/v1/chat/completions
```

**Python Example with OpenAI SDK:**
```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8080/ollama/v1",
    api_key="your-secret-key"
)

response = client.chat.completions.create(
    model="llama2",
    messages=[
        {"role": "user", "content": "Hello, how are you?"}
    ]
)
print(response.choices[0].message.content)
```

## API Key Authentication

This setup includes a two-tier API key authentication system for securing access to your Ollama services.

### Permission Levels

| Level | Allowed Operations |
|-------|-------------------|
| **Admin** | All operations, including model management (`pull`, `push`, `create`, `copy`, `delete`, `blobs`) |
| **Inference** | Inference (`generate`, `chat`, `embed`) and read-only info (`tags`, `ps`, `show`, `version`) |

### Setup

Copy the example files and add your keys:

```bash
cp other_tools/ollama/admin_keys.txt.example other_tools/ollama/admin_keys.txt
cp other_tools/ollama/inference_keys.txt.example other_tools/ollama/inference_keys.txt
```

Edit each file with one key per line. The actual key files are git-ignored.

### Supported Authentication Methods

The system supports multiple ways to provide your API key:

1. **X-API-Key Header** (recommended):
   ```bash
   curl -H "X-API-Key: your-key" http://localhost:8080/ollama/api/tags
   ```

2. **Authorization Bearer Token**:
   ```bash
   curl -H "Authorization: Bearer your-key" http://localhost:8080/ollama/api/tags
   ```

3. **Query Parameter**:
   ```bash
   curl "http://localhost:8080/ollama/api/tags?api_key=your-key"
   ```

### Managing API Keys

After modifying key files, restart the container:
```bash
docker-compose restart nginx
```

### CORS Handling

The authentication system automatically allows `OPTIONS` preflight requests to pass through without authentication, ensuring proper CORS support for web applications.

### Error Responses

- **401 Unauthorized**: Invalid or missing API key
- **403 Forbidden**: Inference key attempted a model management operation

## Configuration

### Rate Limiting

To enable rate limiting, uncomment the following line in `nginx.conf`:
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=50r/s;
```

Then add to your server block:
```nginx
limit_req zone=api burst=20 nodelay;
```

## Docker Configuration

### Environment Variables

The container uses the following configuration:
- **Timezone**: Asia/Taipei
- **Exposed Port**: 80 (mapped to 8080 on host)
- **Log Location**: `/var/log/nginx/`

### Volumes

- `./conf.d:/etc/nginx/conf.d` - Server configurations
- `./other_tools:/etc/nginx/other_tools` - Additional tools

## Performance Settings

The configuration includes optimized settings for handling AI model requests:

- **Worker Processes**: Auto-scaled based on CPU cores
- **Worker Connections**: 8192 per worker
- **Client Max Body Size**: 100MB
- **Proxy Timeouts**: 600 seconds for large model operations
- **Keep-Alive**: 65 seconds

## Development

### Building the Image

```bash
docker build -t nginx-ollama .
```

### Running with Custom Configuration

```bash
docker run -d \
  -p 8080:80 \
  -v $(pwd)/conf.d:/etc/nginx/conf.d \
  -v $(pwd)/other_tools:/etc/nginx/other_tools \
  nginx-ollama
```

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

For issues and questions, please open an issue in the repository.