#Get latest tag so we can track version: https://hub.docker.com/r/alpine/ollama/tags
FROM alpine/ollama:0.12.10

# Set a single environment variable
ENV OLLAMA_MODELS=/models

EXPOSE 11434
CMD ["serve"]