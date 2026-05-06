terraform {
  required_version = ">= 1.0"
  backend "azurerm" {
    storage_account_name = "__terraformstorageaccount__"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    access_key           = "__storagekey__"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "gr1" {
  name     = "rg-storage-test-cos"
  location = "West Europe"
}

resource "azurerm_mssql_server" "sql" {
  name                         = "sqldmc12"
  resource_group_name          = azurerm_resource_group.gr1.name
  location                     = azurerm_resource_group.gr1.location
  version                      = "12.0"
  administrator_login          = "__sql_admin_user__"
  administrator_login_password = "__sql_admin_password__"
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "db" {
  name         = "test-db"
  server_id    = azurerm_mssql_server.sql.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "GP_S_Gen5_1"
  # free_offer_enabled = true

  auto_pause_delay_in_minutes = 60
  min_capacity                = 0.5
  geo_backup_enabled          = false

  lifecycle {
    prevent_destroy = true
  }
}
