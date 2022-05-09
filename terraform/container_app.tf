locals {
  location = "eastus"
}

resource "azurerm_resource_group" "rg" {
  name = "container_app_rg2"
  location = local.location
}

resource "azurerm_log_analytics_workspace" "laws" {
  name                = "container-apps-workspace"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}



resource "azapi_resource" "container_app_environment" {
  name = "test"  
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
          targetPort = 80
          external = true
        }
      }
      template = {
        containers = [
          {
            image = "ghcr.io/snippets-n-memes/loco-logo:20220506.1"
            name = "loco-logo-container"
          }
        ]
      }
    }
  })
}