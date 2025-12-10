#!/bin/bash

echo "Building Docker image..."
docker build -t "pwsh:latest" -f Dockerfile .
