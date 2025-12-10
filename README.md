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
