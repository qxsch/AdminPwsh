Write-Host "Building Docker image..."
docker build -t "adminpwsh:latest" -f Dockerfile .
