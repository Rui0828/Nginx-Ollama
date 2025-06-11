# Nginx‑Ollama (With OpenAI SDK Support)

A secure proxy for Ollama API using Nginx with OpenResty, providing API key authentication and OpenAI SDK compatibility.

## 📌 Overview

This project sets up an Nginx reverse proxy with OpenResty to protect your Ollama API endpoints. It supports:

- API key authentication via a simple text file
- Compatibility with OpenAI SDK (`/chat/completions`, `/completions`, etc.)
- Traditional Ollama API support (`/api/...`)
- WebSocket support for streaming responses
- Dockerized deployment

---

## ⚙️ Setup

1. Clone this repository.
2. Create `ollama/keys.txt` and add your API keys (one per line):
    ```
    your_api_key_1
    your_api_key_2
    ```
3. Start the proxy using Docker Compose:
    ```bash
    docker-compose up -d
    ```

## 🔐 Authentication

All requests must include an API key. You can pass the key using the appropriate header based on the client:

- **OpenAI SDK style:**  
  Use `Authorization: Bearer YOUR_KEY`

- **Direct API calls:**
  Use `X-API-Key: YOUR_KEY` 

---

## 🚀 Example Usage

### 1. Using OpenAI SDK or OpenAI-style requests

#### Python OpenAI SDK Example

```python
from openai import OpenAI

client = OpenAI(
    api_key="your_api_key",
    base_url="http://localhost:8080/ollama/"
)

response = client.chat.completions.create(
    model="llama3.2",
    messages=[{"role": "user", "content": "Tell me a joke"}],
    temperature=0.7,
    max_tokens=150,
    stop=["\n"]
)

print(response.choices[0].message.content)
```

#### Curl Example (OpenAI-Compatible)
```bash
curl http://localhost:8080/ollama/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_api_key" \
  -d '{
    "model": "llama3.2",
    "messages": [{"role":"user","content":"Tell me a joke"}],
    "temperature": 0.7,
    "max_tokens": 150,
    "stop": ["\n"]
  }'
```

### 2.  Using Native Ollama API (/api/generate)
```bash
curl http://localhost:8080/ollama/api/generate \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_api_key" \
  -d '{
    "model": "llama3.2",
    "prompt": "Write a short poem.",
    "stream": false,
    "options": {
      "temperature": 0.7,
      "top_p": 0.9,
      "num_predict": 100
    }
  }'
```

## ✅ Feature Compatibility Table

This table outlines which Ollama options are supported when using the OpenAI SDK format (via automatic Lua transformation):

| Ollama Option               | OpenAI SDK Support | Notes                                                           |
|----------------------------|--------------------|------------------------------------------------------------------|
| `temperature`              | ✅ Yes              | Directly supported                                              |
| `top_k`                    | ✅ Yes              | Directly supported                                              |
| `top_p`                    | ✅ Yes              | Directly supported                                              |
| `presence_penalty`         | ✅ Yes              | Mapped directly                                                 |
| `frequency_penalty`        | ✅ Yes              | Mapped directly                                                 |
| `stop`                     | ✅ Yes              | Mapped directly                                                 |
| `max_tokens` → `num_predict` | ✅ Yes (via Lua)   | Converted via Lua script to `options.num_predict`               |
| `seed`                     | ❌ No               | Must be sent manually via native Ollama API only                |
| `min_p`, `typical_p`       | ❌ No               | Not available in OpenAI spec                                    |
| `repeat_penalty`           | ❌ No               | Only supported in native Ollama `options`                       |
| `num_keep`                 | ❌ No               | Not mapped or exposed                                           |
| `repeat_last_n`           | ❌ No               | Not available in OpenAI style                                   |
| `mirostat`, `mirostat_tau`, `mirostat_eta` | ❌ No        | Not supported                                                   |
| `num_ctx`                  | ❌ No               | Could be approximated using `max_tokens`, but not mapped        |
| `num_batch`, `num_gpu`, `main_gpu` | ❌ No        | Performance-only settings, must be passed via native `options`  |
| `numa`, `use_mmap`         | ❌ No               | Hardware-related flags                                          |
| `penalize_newline`         | ❌ No               | Not part of OpenAI SDK spec                                     |

> ✅ Options marked as "Yes" are automatically converted to Ollama-compatible format using the built-in `openai_to_ollama.lua` rewrite hook in Nginx.

---

## 🛠 Developer Notes

This proxy includes a Lua middleware that transparently rewrites OpenAI-style JSON bodies into Ollama-compatible format, specifically transforming:

- `max_tokens` → `options.num_predict`
- Flat parameters (`temperature`, `top_p`, etc.) → nested `options`

This allows any client using the OpenAI SDK (e.g. LangChain, LlamaIndex, etc.) to communicate with Ollama models directly.

---

## 📄 License

Apache License 2.0
