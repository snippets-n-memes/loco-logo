# This repo is intended to be used as a tool in a workshop where participants use a slightly altered version to build, test and deploy a .NET application to Azure Container Apps using Codespaces, Terraform and GitHub Actions.

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

## Steps:
### Launching a dotnet environment in Codespaces
1. `dotnet run`
2. https://localhost:<port>/swagger
3. Test
4. Add 'blinky' or other endpoints. Alter 'hello' endpoint. Build, run, test using native dotnet cli tools.
5. Build docker image inside Codespaces container
6. Test usinng native docker tools.
 
__Takeaways__: Notice how quick it is to be working in a dev environment that can do everything we need. Notice that not only is the right version of the dotnet core SDK, targeting pack and runtime installed, but we also have the aspnet runtime as well. Notice that docker is configured and "just works"

### GitHub Action for docker images
1. New Workflow/Action
2. Use a Starter Workflow called ".NET Build and Push"
3. Configure app specifics, trigger workflow with code change, PR to trigger a build and push image to GitHub Packages (ghcr.io)

__Takeaways__: Codespaces + GitHub is all you need to dev, build, automate from a web browser. Build Artifact and Image both consumeable from GitHub for any testing, troubleshooting if need be.

### Codespaces Terraform
1. Create a simple terraform configuration using boilerplate here.
2. Azure intro, show the subscription, state storage container, resource groups to target.
2. Explain Container Apps as managed Kubernetes.
3. Backend configuration, container apps deployment config

__Takeaways__: No need to install Terraform, mess with PATH variable or other environment variables. No reboots, no need to get authorization to run a binary on your machine. Azure Container Apps are a great way to start using containerized workloads now, without the need to become experts in Kubernetes right away. Things that work in your Codespaces dev environment work very much the same way in Container Apps, because the architecture is the same. General Infrastructure as Code introduction.


### GitHub Action for Terraform deployment
1. New Workflow/Action
2. Starter workflow is "Terraform Workflow"
3. Overview of Repo/Org secrets and how they simlify CI/CD
3. Using image built in previous workflow in this workflow. Edit terraform code in Codespaces, push changes to trigger Action. 

__Takeaways__: We have reusable code for our build, publish, consume and deploy steps. How much time have we saved by using Starter Workflows? How easily could we roll back in the case of a post-deployment bug? What would that look like? (just a PR).


### Pulling it all together
1. Uh oh! There's a crippling bug! (Dev, test, deploy all from Codespaces)
2. Code fix via Codespaces. 
3. Terraform updated to reflect our fixed build.
4. Deploy, all triggered inside Codespaces.

__Takeaways__: What you'd have to do as a new dev without Codespaces:
1. install the right .NET SDK, Targetting packs, aspnet and .net core runtimes. (.NET is one of the simler languages to get started with.)
2. Configure access, get Docker installed and running, which could mean WSL, hyper-v setup. 
3. Install and configure Terraform. 
4. Install az cli
5. Install vscode and various extensions for each language

_Time saved taking advantage of Starter Workflows_
