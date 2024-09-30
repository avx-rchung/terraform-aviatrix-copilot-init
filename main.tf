#Login, obtain CID.
resource "terracurl_request" "controller_login" {
  name            = "controller_login"
  url             = "https://${var.avx_controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "login",
    "username" : var.avx_controller_admin_username,
    "password" : var.avx_controller_admin_password,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to login to the controller: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }
}

#Create Copilot permission group
resource "terracurl_request" "add_permission_group" {
  name            = "add_permission_group"
  url             = "https://${var.avx_controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "add_permission_group",
    "CID" : local.controller_cid,
    "group_name" : local.permission_group,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to add permission group: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [terracurl_request.controller_login]
}

#Add permissions to RBAC Group
resource "terracurl_request" "add_permissions_to_rbac_group" {
  name            = "add_permission_group"
  url             = "https://${var.avx_controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "add_permissions_to_rbac_group",
    "CID" : local.controller_cid,
    "group_name" : local.permission_group,
    "permissions" : local.rbac_permissions,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to configure rbac: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [terracurl_request.add_permission_group]
}

#Add access account to RBAC Group
resource "terracurl_request" "add_access_accounts_to_rbac_group" {
  name            = "add_permission_group"
  url             = "https://${var.avx_controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "add_access_accounts_to_rbac_group",
    "CID" : local.controller_cid,
    "group_name" : local.permission_group,
    "accounts" : "all",
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to add access accounts to rbac: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [terracurl_request.add_permission_group]
}

#Add copilot service account
resource "terracurl_request" "add_copilot_service_account" {
  name            = "add_account_user"
  url             = "https://${var.avx_controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "add_account_user",
    "CID" : local.controller_cid,
    "username" : var.copilot_service_account_username,
    "email" : var.service_account_email,
    "password" : var.copilot_service_account_password,
    "groups" : local.permission_group,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to create copilot service account: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [terracurl_request.add_permission_group]
}

#Add copilot service account
resource "terracurl_request" "enable_copilot_association" {
  name            = "associate_copilot"
  url             = "https://${var.avx_controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    "action" : "associate_copilot",
    "CID" : local.controller_cid,
    "operation" : "enable",
    "copilot_ip" : var.avx_copilot_public_ip,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to associate copilot: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [
    terracurl_request.add_permission_group,
    terracurl_request.add_copilot_service_account,
  ]
}

#Initialize Copilot
resource "terracurl_request" "copilot_init_simple" {
  name            = "copilot_init_simple"
  url             = "https://${var.avx_copilot_public_ip}/v1/api/single-node"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    "taskserver" : {
      "username" : var.copilot_service_account_username,
      "password" : var.copilot_service_account_password,
    }
  })

  headers = {
    Content-Type = "application/json",
    CID          = local.controller_cid
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    terracurl_request.add_permission_group,
    terracurl_request.add_copilot_service_account,
  ]
}
