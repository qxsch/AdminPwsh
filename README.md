# Admin Powershell

## How to use

You can easily run administrative Powershell scripts in a containerized environment.

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


## Customization - Build your own image

Create the Dockerfile and build the image with the following commands:
```pwsh
# install additional modules and skip opentofu installation
prepareDockerfile.ps1 -modules @( "additional.module", "another.module" ) -skipOpentofuInstallation

# modify the Dockerfile as needed

# build the image
buildAdminShell.ps1

# test the newly created image
docker run -it -v '.\:/app' --rm  "adminpwsh:latest"
```

