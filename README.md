## ASCII art in an API


2 Methods of deployment

+ deploy.sh script uses Azure CLI to deploy.
+ terraform, using azurerm and azapi providers, which essentially wraps the Azure API with a terraform/bicep blend.

### Git and Devconainters (Codespaces)

HTTPS with Git Credential manager should automatically be forwarded to the Codespace/Devcontainer. 

For ssh key configuration inside the container:

Linux
```bash
eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/id_rsa
docker ps
docker cp ~/.ssh/id_rsa <container id>:/home/vscode/.ssh
```

Windows
```powershell
# Make sure you're running as an Administrator
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
Get-Service ssh-agent
ssh-add $HOME/.ssh/github_rsa
docker cp "$env.USERPROFILE"/.ssh/id_rsa <container id>:/home/vscode/.ssh
```

macOS
```
ssh-add $HOME/.ssh/github_rsa
```

## Terraform

### state management
```tf
terraform {
  backend "azurerm" {
    resource_group_name  = "<STATE RESOURE GROUP>"
    storage_account_name = "<SA NAME>
    container_name       = "<CONTAINER NAME>"
    key                  = "<GITHUB_USERNAME>"
  }
}
```

### azurerm Terraform provider
```tf
locals {
  location = "eastus"
}

resource "azurerm_resource_group" "rg" {
  name = "<NAME>"
  location = local.location
}

resource "azurerm_log_analytics_workspace" "laws" {
  name                = "<NAME>"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
```

### AzAPI Terraform provider
```tf

resource "azapi_resource" "container_app_environment" {
  name = "<NAME>"  
  location = local.location
  parent_id = azurerm_resource_group.rg.id
  type = "Microsoft.App/managedEnvironments@2022-01-01-preview"
  body = jsonencode({
    properties = {
        appLogsConfiguration = {
            destination = "log-analytics"
            logAnalyticsConfiguration = {
                customerId = azurerm_log_analytics_workspace.laws.workspace_id
                sharedKey = azurerm_log_analytics_workspace.laws.primary_shared_key
            }
        }
    }
  })
}

resource "azapi_resource" "container_app" {
  name = "loco-logo"  
  location = local.location
  parent_id = azurerm_resource_group.rg.id
  type = "Microsoft.App/containerApps@2022-01-01-preview"
  body = jsonencode({
    properties = {
      managedEnvironmentId = azapi_resource.container_app_environment.id
      configuration = {
        ingress = {
          targetPort = <PORT>
          external = true
        }
      }
      template = {
        containers = [
          {
            image = <IMAGE TAG>
            name = <NAME>
          }
        ]
      }
    }
  })
}
```
