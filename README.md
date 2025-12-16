# Admin Powershell

## How to use

You can easily run administrative Powershell scripts in a containerized environment.

This gives you 2 main benefits:
 * No installation and maintenance of modules on your host system required
 * Isolation from your host system (Credentials are kept in the container session only --rm esures no leftovers)

Use the following command to start an admin powershell:
```sh
docker run -it -v '.\:/app' --rm  "ghcr.io/qxsch/adminpwsh:latest"
```

## Features

* Latest Powershell version
* Commonly used modules for administration
  * Infrastructure as Code
    * bicep
    * Opentofu (Terraform)
  * [Az Module](https://learn.microsoft.com/en-us/powershell/azure/)
  * [Graph Module](https://learn.microsoft.com/en-us/powershell/microsoftgraph/)
  * [ExchangeOnlineManagement Module](https://learn.microsoft.com/powershell/module/exchange/)
  * [MicrosoftTeams Module](https://learn.microsoft.com/powershell/module/teams/)
  * [SharePoint Online Management Shell](https://learn.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online)
  * [PNP.Powershell Module](https://pnp.github.io/powershell/)
  * [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)


## Helpful function to put into your profile
Put the following content into your [Powershell Profile](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/creating-profiles?view=powershell-7.5):
```pwsh
function AdminPwsh {
    param (
        [string] $Directory = (Get-Location)
    )
    $Directory = (Resolve-Path -Path $Directory -ErrorAction Stop).Path
    if(-not (Test-Path -Path $Directory -PathType Container)) {
        throw "The specified path '$Directory' is not a valid directory."
    }
    
    $mountPath = ( $Directory + ":/app" )
    Write-Host "Starting AdminPwsh container with mounted directory: $Directory"
    docker run -it -v "$mountPath" --rm  "ghcr.io/qxsch/adminpwsh:latest"
}
```

## Customization - Build your own image

### On Windows with PowerShell
Create the Dockerfile and build the image with the following commands:
```pwsh
# example: install additional modules
prepareDockerfile.ps1 -modules @( "additional.module", "another.module" )

# modify the Dockerfile as needed

# build the image
buildAdminShell.ps1

# test the newly created image
docker run -it -v '.\:/app' --rm  "adminpwsh:latest"
```

### On Linux with Bash
Create the Dockerfile and build the image with the following commands:
```bash
# example: install additional modules
./prepareDockerfile.sh --modules "additional.module,another.module"

# modify the Dockerfile as needed

# build the image
./buildAdminShell.sh

# test the newly created image
docker run -it -v '.\:/app' --rm  "adminpwsh:latest"
```


### `prepareDockerfile.ps1` options

| Parameter | Description | Default |
| --- | --- | --- |
| `-modules` | Additional PowerShell modules to install. Invalid names are ignored and duplicates are skipped. | `@()` |
| `-dockerfilePath` | Custom output path for the generated Dockerfile. | `Dockerfile` in repo root |
| `-skipModuleAz` | Do not install the Az module (also prevents automatic Bicep install). | `False` |
| `-skipModuleGraph` | Skip installing Microsoft.Graph. | `False` |
| `-skipModuleTeams` | Skip installing MicrosoftTeams. | `False` |
| `-skipModuleExchange` | Skip installing ExchangeOnlineManagement. | `False` |
| `-skipModuleSharePoint` | Skip installing Microsoft.Online.SharePoint.PowerShell. | `False` |
| `-skipModulePnP` | Skip installing PnP.PowerShell. | `False` |
| `-skipOpentofuInstallation` | Do not install OpenTofu/Terraform tooling. | `False` |
| `-skipAzureCliInstallation` | Do not install Azure CLI tooling. | `False` |

By default all common admin modules plus Bicep and OpenTofu are present; combine the switches above to trim the image or focus on the tooling you need.

