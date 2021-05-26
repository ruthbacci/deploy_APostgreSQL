#https://registry.terraform.io/modules/Azure/postgresql/azurerm/latest

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
backend "remote" {
   organization = "bacciworld"
   workspaces {
     name = "deploy_APostgreSQL"
   }
 }
}


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-apostgresql" {
  name     = "rg-me-weu-apostgresql"
  location = "West Europe"
}

module "postgresql" {
  source = "Azure/postgresql/azurerm"
  resource_group_name = azurerm_resource_group.rg-apostgresql.name
  location            = azurerm_resource_group.rg-apostgresql.location

  server_name                  = "pgsqlmeweademo"
  sku_name                     = "GP_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  administrator_login          = "admins"
  administrator_password       = "AzureR0cks!"
  server_version               = "9.5"
  ssl_enforcement_enabled      = true
  db_names                     = ["my_db1", "my_db2"]
  db_charset                   = "UTF8"
  db_collation                 = "English_United States.1252"

  firewall_rule_prefix = "firewall-"
  firewall_rules = [
    { name = "test1", start_ip = "10.0.0.5", end_ip = "10.0.0.8" },
    { start_ip = "127.0.0.0", end_ip = "127.0.1.0" },
  ]

  #vnet_rule_name_prefix = "postgresql-vnet-rule-"
  #vnet_rules = [
  #  { name = "subnet1", subnet_id = "<subnet_id>" }
  #]

  tags = {
    Environment = "Demo",
    CostCenter  = "Ruthi IT",
  }

  postgresql_configurations = {
    backslash_quote = "on",
  }
    depends_on = [azurerm_resource_group.rg-apostgresql]
}