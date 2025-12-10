param(
    [string[]]$modules = @(
    ),

    [string]$dockerfilePath = "",


    [switch]$skipModuleAz,
    [switch]$skipModuleGraph,
    [switch]$skipModuleTeams,
    [switch]$skipModuleExchange,
    [switch]$skipModuleSharePoint,
    [switch]$skipModulePnP,

    [switch]$skipOpentofuInstallation
)

if([string]::IsNullOrEmpty($dockerfilePath)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $dockerfilePath = Join-Path $scriptDir "Dockerfile"
}

$lines = @(
    'FROM mcr.microsoft.com/dotnet/sdk:9.0',
    '',
    'WORKDIR /app'
)

# preparing modules to install
$modulesToInstall = @()
if(-not $skipModuleAz) { $modulesToInstall += "Az" }
if(-not $skipModuleGraph) { $modulesToInstall += "Microsoft.Graph" }
if(-not $skipModuleTeams) { $modulesToInstall += "MicrosoftTeams" }
if(-not $skipModuleExchange) { $modulesToInstall += "ExchangeOnlineManagement" }
if(-not $skipModuleSharePoint) { $modulesToInstall += "Microsoft.Online.SharePoint.PowerShell" }
if(-not $skipModulePnP) { $modulesToInstall += "PnP.PowerShell" }
if($modules.Count -gt 0) {
    foreach($module in $modules) {
        $module = $module.Trim()
        if(-not($module -match '^[a-zA-Z0-9][a-z0-9A-Z._-]+$')) {
            Write-Warning "Ignoring invalid module name: '$module'"
            continue
        }
        if(-not $modulesToInstall.Contains($module)) {
            $modulesToInstall += $module
        }
    }
}

#installing powershell modules
if($modulesToInstall.Count -gt 0) {
    $lines += ''
    $lines += '# install powershell modules'
    $installCommands = @()
    foreach($module in $modulesToInstall) {
        $installCommands += "pwsh -Command '& { Install-Module $module -AllowClobber -Force -SkipPublisherCheck -Confirm:`$false }'"
    }
    $installCommandLine = $installCommands -join " && \`n    "
    $lines += "RUN $installCommandLine"
}

# always install bicep, when Az module is installed
if(-not $skipModuleAz) {
    $lines += ''
    $lines += '# install bicep'
    $lines += 'RUN curl -Lo /usr/bin/bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 && \'
    $lines += '    chmod 755 /usr/bin/bicep'
}

# install opentofu
if(-not $skipOpentofuInstallation) {
    $lines += ''
    $lines += '# install opentofu'
    $lines += 'RUN curl --proto "=https" --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && \'
    $lines += '    chmod +x install-opentofu.sh && \'
    $lines += '    ./install-opentofu.sh --install-method deb && \'
    $lines += '    rm -f install-opentofu.sh'
}


$lines += ''
$lines += ''
$lines += 'CMD [ "pwsh" ]'

( $lines -join "`n" ) | Set-Content -Path $dockerfilePath -Encoding UTF8

