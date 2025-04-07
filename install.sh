#!/bin/bash

# Create necessary directories
mkdir -p ~/.config/micro/plugins/nativeai

# Download the plugin
curl -o ~/.config/micro/plugins/nativeai/nativeai.lua https://raw.githubusercontent.com/yourusername/nativeai/main/nativeai.lua

# Prompt for OpenRouter API key
echo "Enter your OpenRouter API key:"
read api_key

# Save the API key to the specified path
echo "$api_key" > ~/.openrouter.key
chmod 600 ~/.openrouter.key

echo "NativeAI plugin installed successfully!"
