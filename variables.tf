variable "controller_public_ip" {
  type        = string
  description = "aviatrix controller public ip address(required)"
}

variable "controller_admin_username" {
  type        = string
  default     = "admin"
  description = "aviatrix controller admin username"
}

variable "controller_admin_password" {
  type        = string
  sensitive   = true
  description = "aviatrix controller admin password"
}

variable "copilot_public_ip" {
  type        = string
  description = "aviatrix copilot public ip address(required)"
}

variable "service_account_email" {
  type = string
}

variable "copilot_service_account_username" {
  type    = string
  default = "copilot_service_account"
}

variable "copilot_service_account_password" {
  type      = string
  sensitive = true
}

variable "configure_syslog" {
  type    = bool
  default = true
}

variable "configure_netflow" {
  type    = bool
  default = true
}

# terraform-docs-ignore
variable "destroy_url" {
  type        = string
  description = "Dummy URL used by terracurl during destroy operations."
  default     = "https://checkip.amazonaws.com"
}
