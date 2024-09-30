variable "avx_controller_public_ip" {
  type        = string
  description = "aviatrix controller public ip address(required)"
}

variable "avx_controller_admin_username" {
  type        = string
  default     = "admin"
  description = "aviatrix controller admin username"
}

variable "avx_controller_admin_password" {
  type        = string
  sensitive   = true
  description = "aviatrix controller admin password"
}

variable "avx_copilot_public_ip" {
  type        = string
  description = "aviatrix copilot public ip address(required)"
}

variable "account_email" {
  type = string
}

variable "copilot_service_account_username" {
  type    = string
  default = "copilot_service_account"
}

variable "copilot_service_account_password" {
  type = string
}
