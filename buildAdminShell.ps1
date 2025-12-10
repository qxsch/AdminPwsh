Write-Host "Building Docker image..."
docker build -t "pwsh:latest" -f Dockerfile .
