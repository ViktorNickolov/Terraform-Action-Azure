variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Resource group location"
}

variable "app_service_plan_name" {
  type        = string
  description = "Service plan name"
}

variable "app_service_name" {
  type        = string
  description = "App service name"
}

variable "SQL_server_name" {
  type        = string
  description = "SQL server name"
}

variable "SQL_database_name" {
  type        = string
  description = "SQL database name"
}

variable "SQL_administrator_login_username" {
  type        = string
  description = "Administrator username"
}

variable "SQL_administrator_password" {
  type        = string
  description = "Administrator password"
}

variable "firewall_rule_name" {
  type        = string
  description = "Firewall rule name"
}

variable "GitHub_repo_URL" {
  type        = string
  description = "URL"
}