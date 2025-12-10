FROM mcr.microsoft.com/dotnet/sdk:9.0

WORKDIR /app

# install powershell modules
RUN pwsh -Command '& { Install-Module Az -AllowClobber -Force -SkipPublisherCheck -Confirm:$false }' && \
    pwsh -Command '& { Install-Module Microsoft.Graph -AllowClobber -Force -SkipPublisherCheck -Confirm:$false }' && \
    pwsh -Command '& { Install-Module MicrosoftTeams -AllowClobber -Force -SkipPublisherCheck -Confirm:$false }' && \
    pwsh -Command '& { Install-Module ExchangeOnlineManagement -AllowClobber -Force -SkipPublisherCheck -Confirm:$false }' && \
    pwsh -Command '& { Install-Module Microsoft.Online.SharePoint.PowerShell -AllowClobber -Force -SkipPublisherCheck -Confirm:$false }' && \
    pwsh -Command '& { Install-Module PnP.PowerShell -AllowClobber -Force -SkipPublisherCheck -Confirm:$false }'

# install bicep
RUN curl -Lo /usr/bin/bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 && \
    chmod 755 /usr/bin/bicep

# install opentofu
RUN curl --proto "=https" --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && \
    chmod +x install-opentofu.sh && \
    ./install-opentofu.sh --install-method deb && \
    rm -f install-opentofu.sh


CMD [ "pwsh" ]
