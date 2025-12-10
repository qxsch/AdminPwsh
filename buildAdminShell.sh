#!/bin/bash

echo "Building Docker image..."
docker build -t "adminpwsh:latest" -f Dockerfile .
