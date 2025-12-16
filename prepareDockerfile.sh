#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: ./prepareDockerfile.sh [options]

Options:
  --modules VALUE           Comma-separated list of additional PowerShell modules.
  -m VALUE                  Alias for --modules.
  --dockerfilePath PATH     Output Dockerfile path. Defaults to <script_dir>/Dockerfile.
  --skipModuleAz            Skip installing the Az module (also skips Bicep install).
  --skipModuleGraph         Skip installing the Microsoft.Graph module.
  --skipModuleTeams         Skip installing the MicrosoftTeams module.
  --skipModuleExchange      Skip installing the ExchangeOnlineManagement module.
  --skipModuleSharePoint    Skip installing the Microsoft.Online.SharePoint.PowerShell module.
  --skipModulePnP           Skip installing the PnP.PowerShell module.
  --skipAzureCLiInstallation  Skip installing the Azure CLI.
  --skipOpentofuInstallation  Skip installing OpenTofu.
  -h, --help                Show this help and exit.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE_PATH="$SCRIPT_DIR/Dockerfile"
MODULE_ARGS=()

SKIP_MODULE_AZ=false
SKIP_MODULE_GRAPH=false
SKIP_MODULE_TEAMS=false
SKIP_MODULE_EXCHANGE=false
SKIP_MODULE_SHAREPOINT=false
SKIP_MODULE_PNP=false
SKIP_AZURECLI_INSTALL=false
SKIP_OPENTOFU_INSTALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --modules|-m)
            [[ $# -ge 2 ]] || { usage >&2; exit 1; }
            if [[ -n "$2" ]]; then
                IFS=',' read -ra parsed <<< "$2"
                for entry in "${parsed[@]}"; do
                    MODULE_ARGS+=("$entry")
                done
            fi
            shift 2
            ;;
        --dockerfilePath)
            [[ $# -ge 2 ]] || { usage >&2; exit 1; }
            DOCKERFILE_PATH="$2"
            shift 2
            ;;
        --skipModuleAz)
            SKIP_MODULE_AZ=true
            shift
            ;;
        --skipModuleGraph)
            SKIP_MODULE_GRAPH=true
            shift
            ;;
        --skipModuleTeams)
            SKIP_MODULE_TEAMS=true
            shift
            ;;
        --skipModuleExchange)
            SKIP_MODULE_EXCHANGE=true
            shift
            ;;
        --skipModuleSharePoint)
            SKIP_MODULE_SHAREPOINT=true
            shift
            ;;
        --skipModulePnP)
            SKIP_MODULE_PNP=true
            shift
            ;;
        --skipAzureCLiInstallation)
            SKIP_AZURECLI_INSTALL=true
            shift
            ;;
        --skipOpentofuInstallation)
            SKIP_OPENTOFU_INSTALL=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

contains_module() {
    local needle="$1"
    shift
    for existing in "$@"; do
        if [[ "$existing" == "$needle" ]]; then
            return 0
        fi
    done
    return 1
}

modules_to_install=()
if [[ "$SKIP_MODULE_AZ" == false ]]; then modules_to_install+=("Az"); fi
if [[ "$SKIP_MODULE_GRAPH" == false ]]; then modules_to_install+=("Microsoft.Graph"); fi
if [[ "$SKIP_MODULE_TEAMS" == false ]]; then modules_to_install+=("MicrosoftTeams"); fi
if [[ "$SKIP_MODULE_EXCHANGE" == false ]]; then modules_to_install+=("ExchangeOnlineManagement"); fi
if [[ "$SKIP_MODULE_SHAREPOINT" == false ]]; then modules_to_install+=("Microsoft.Online.SharePoint.PowerShell"); fi
if [[ "$SKIP_MODULE_PNP" == false ]]; then modules_to_install+=("PnP.PowerShell"); fi

trimmed_modules=()
for module in "${MODULE_ARGS[@]}"; do
    trimmed="$(printf '%s' "$module" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$trimmed" ]] && continue
    if [[ ! "$trimmed" =~ ^[A-Za-z0-9][A-Za-z0-9._-]+$ ]]; then
        printf 'Warning: Ignoring invalid module name: %s\n' "$trimmed" >&2
        continue
    fi
    trimmed_modules+=("$trimmed")

done

for module in "${trimmed_modules[@]}"; do
    if ! contains_module "$module" "${modules_to_install[@]}"; then
        modules_to_install+=("$module")
    fi

done

lines=(
    'FROM mcr.microsoft.com/dotnet/sdk:9.0'
    ''
    'WORKDIR /app'
)

if ((${#modules_to_install[@]} > 0)); then
    lines+=('')
    lines+=('# install powershell modules')
    install_commands=()
    for module in "${modules_to_install[@]}"; do
        install_commands+=("pwsh -Command '& { Install-Module $module -AllowClobber -Force -SkipPublisherCheck -Confirm:\$false }'")
    done
    install_command_line=''
    for cmd in "${install_commands[@]}"; do
        if [[ -n "$install_command_line" ]]; then
            install_command_line+=' && \\'
            install_command_line+=$'\n    '
        fi
        install_command_line+="$cmd"
    done
    lines+=("RUN $install_command_line")
fi

if [[ "$SKIP_MODULE_AZ" == false ]]; then
    lines+=('')
    lines+=('# install bicep')
    lines+=('RUN curl -Lo /usr/bin/bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 && \')
    lines+=('    chmod 755 /usr/bin/bicep')
fi

if [[ "$SKIP_AZURECLI_INSTALL" == false ]]; then
    lines+=('')
    lines+=('# install Azure CLI')
    lines+=('RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash')
fi

if [[ "$SKIP_OPENTOFU_INSTALL" == false ]]; then
    lines+=('')
    lines+=('# install opentofu')
        lines+=("RUN curl --proto \"=https\" --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && \\")
    lines+=('    chmod +x install-opentofu.sh && \')
    lines+=('    ./install-opentofu.sh --install-method deb && \')
    lines+=('    rm -f install-opentofu.sh')
fi

lines+=('')
lines+=('')
lines+=("CMD [ \"pwsh\" ]")

mkdir -p "$(dirname "$DOCKERFILE_PATH")"
printf '%s\n' "${lines[@]}" > "$DOCKERFILE_PATH"
