#!/bin/bash

# Private AI Setup Dream Guide - Open WebUI Only Setup
# Written by Ugo Emekauwa (uemekauw@cisco.com, uemekauwa@gmail.com)
# GitHub Repository: https://github.com/ugo-emekauwa/private-ai-setup-dream-guide
# Summary: This script sets up an environment with Open WebUI only.
## Open WebUI serves as a frontend user-friendly GUI interface for interacting with AI models.

# Setup the Script Variables
echo "Setting up the Script Variables..."
set -o nounset
TARGET_HOST=127.0.0.1
OPEN_WEBUI_DEFAULT_MODEL="Private AI Model"
OPEN_WEBUI_CONTAINER_IMAGE="ghcr.io/open-webui/open-webui:cuda"
OPEN_WEBUI_CONTAINER_HOST_PORT=3000
OPEN_WEBUI_CONTAINER_SPECIFIC_TARGET_HOST="host.docker.internal"
STOP_AND_REMOVE_PREEXISTING_PRIVATE_AI_CONTAINERS=true

# Start the Open WebUI Only Setup
echo "Starting the Open WebUI Only Setup..."

# Stop and Remove Preexisting Private AI Containers
if $STOP_AND_REMOVE_PREEXISTING_PRIVATE_AI_CONTAINERS; then
    echo "Stopping Preexisting Private AI Containers..."
    sudo docker stop open-webui-1 vllm-chat-model-1 vllm-chat-model-2 sglang-vision-model-1 vllm-reasoning-model-1 sd-webui-forge-1 2>/dev/null
    echo "Removing Preexisting Private AI Containers..."
    sudo docker rm open-webui-1 vllm-chat-model-1 vllm-chat-model-2 sglang-vision-model-1 vllm-reasoning-model-1 sd-webui-forge-1 2>/dev/null
fi

# Pause for clearing of the GPU vRAM
echo "Waiting for Clearing of the GPU vRAM, if Needed..."
sleep 5

# Setup the Open WebUI Container
echo "Setting up the Open WebUI Container..."
sudo docker run -d \
    --name open-webui-1 \
    -p $OPEN_WEBUI_CONTAINER_HOST_PORT:8080 \
    --gpus all \
    -e WEBUI_AUTH="false" \
    -e WEBUI_NAME="Private AI" \
    -e OPENAI_API_BASE_URLS="" \
    -e OPENAI_API_KEY="" \
    -e DEFAULT_MODELS="$OPEN_WEBUI_DEFAULT_MODEL" \
    -e RAG_EMBEDDING_MODEL="sentence-transformers/paraphrase-MiniLM-L6-v2" \
    -e ENABLE_OLLAMA_API="false" \
    --add-host=host.docker.internal:host-gateway \
    -v open-webui:/app/backend/data \
    --restart always \
    $OPEN_WEBUI_CONTAINER_IMAGE
if [[ $? -eq 0 ]]; then
    sleep 20
    echo "The Open WebUI Container has Started. The Private AI Interface Is Now Available At http://$TARGET_HOST:$OPEN_WEBUI_CONTAINER_HOST_PORT"
else
    echo "ERROR: The Open WebUI Container Failed to Start!"
    exit 1
fi

# End the Open WebUI Only Setup
echo "The Open WebUI Only Setup has Completed."
