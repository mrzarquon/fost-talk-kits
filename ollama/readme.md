Simple example for working with ollama running on a local host.

[More indepth example here](https://github.com/docker/sbx-kits-contrib/tree/main/claude-ollama)

The ollama instance is assumed to be running with the model of your choice at port localhost:11434

This spec.yaml file pre-installs the claude code tools (not using the default claude instance), so we can test this with a shell VM.

1) You have allow the Sandbox VM to access the host on port 11434 with the command `sbx policy allow network localhost:11434`

2) The Sandbox Guest has to be allowed to talk to `host.docker.internal`, which is enabled in spec.yaml

3) For Anthropic, we need to pass it the base URL and a token to use (this can be empty), we use the spec.yaml to define those environment variables that the token injects into the environment, using these environment values
```
ANTHROPIC_AUTH_TOKEN=ollama
ANTHROPIC_BASE_URL=http://host.docker.internal:11434
```

4) Start / create a new with `sbx run shell --name my-test-sandbox --kit ./ollama <your project folder>`

5) The Sandbox will take a few minutes to launch as it is auto-installing the claude tools, once complete, you will have a prompt available to you. You can test the connectivity with a curl command:

```
agent@testing:llm-proxy$ curl http://host.docker.internal:11434/v1/messages \
  -H "Content-Type: application/json" \
  -d '{
    "model": "ai/smollm2",
    "max_tokens": 32,
    "messages": [{"role": "user", "content": "Say hello"}]
  }'
{"id":"chatcmpl-Z2XYK2kqk1DojsVQK9wbTkmndD9bpNaw","type":"message","role":"assistant","content":[{"type":"text","text":"Hello, I'm sorry if I'm not familiar with this, but I'm here to assist you with any questions or requests you may have. What is the"}],"model":"model.gguf","stop_reason":"max_tokens","stop_sequence":null,"usage":{"cache_read_input_tokens":24,"input_tokens":8,"output_tokens":32}}

```

[This based off the guide to work Docker Model Runner](https://docs.docker.com/guides/claude-code-sandbox-model-runner/)