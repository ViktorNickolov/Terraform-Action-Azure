terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.12.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "StorageRG"
    storage_account_name = "taskboardstorageviktor"
    container_name       = "taskboardstoragecontainer"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "60304656-c868-499f-baa6-9e4960196879"
  features {}
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${random_integer.ri.id}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "sp" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = var.SQL_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.SQL_administrator_login_username
  administrator_login_password = var.SQL_administrator_password
}

resource "azurerm_mssql_database" "db" {
  name           = var.SQL_database_name
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
}

resource "azurerm_mssql_firewall_rule" "fw" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_linux_web_app" "lwa" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.sp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = <<EOT
    Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;
    Initial Catalog=${azurerm_mssql_database.db.name};
    User ID=${azurerm_mssql_server.sqlserver.administrator_login};
    Password=${azurerm_mssql_server.sqlserver.administrator_login_password};
    Trusted_Connection=False;MultipleActiveResultSets=True;
    EOT
  }
}

resource "azurerm_app_service_source_control" "sc" {
  app_id   = azurerm_linux_web_app.lwa.id
  repo_url = var.GitHub_repo_URL
  branch                 = "master"
  use_manual_integration = true
}
