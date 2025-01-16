#Login, obtain CID.
data "http" "controller_login" {
  url      = "https://${var.controller_public_ip}/v2/api"
  insecure = true
  method   = "POST"
  request_headers = {
    "Content-Type" = "application/json"
  }
  request_body = jsonencode({
    action   = "login",
    username = var.controller_admin_username,
    password = var.controller_admin_password,
  })
  retry {
    attempts     = 30
    min_delay_ms = 10000
  }
  lifecycle {
    postcondition {
      condition     = jsondecode(self.response_body)["return"]
      error_message = "Failed to login to the controller: ${jsondecode(self.response_body)["reason"]}"
    }
  }
}

#Add copilot service account
resource "terracurl_request" "add_copilot_service_account" {
  name            = "add_account_user"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    action   = "add_account_user",
    CID      = local.controller_cid,
    username = var.copilot_service_account_username,
    email    = var.service_account_email,
    password = var.copilot_service_account_password,
    groups   = "admin",
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  timeout = 300

  destroy_url    = var.destroy_url
  destroy_method = "GET"

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to create copilot service account: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [
    data.http.controller_login
  ]
}

#Add copilot service account
resource "terracurl_request" "enable_copilot_association" {
  name            = "associate_copilot"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    action     = "associate_copilot",
    CID        = local.controller_cid,
    operation  = "enable",
    copilot_ip = var.copilot_public_ip,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  destroy_url    = var.destroy_url
  destroy_method = "GET"

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to associate copilot: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [
    terracurl_request.add_copilot_service_account,
  ]
}

#Configure Syslog to Copilot
resource "terracurl_request" "configure_syslog" {
  count           = var.configure_syslog ? 1 : 0
  name            = "configure_syslog"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    action   = "enable_remote_syslog_logging",
    CID      = local.controller_cid,
    name     = "Copilot",
    server   = var.copilot_public_ip,
    port     = "5000",
    protocol = "UDP",
    index    = "9",
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  destroy_url    = var.destroy_url
  destroy_method = "GET"

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to configure copilot as syslog server: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [
    terracurl_request.add_copilot_service_account,
  ]
}

#Configure Netflow to Copilot
resource "terracurl_request" "configure_netflow" {
  count           = var.configure_netflow ? 1 : 0
  name            = "configure_syslog"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    action    = "enable_netflow_agent",
    CID       = local.controller_cid,
    server_ip = var.copilot_public_ip,
    port      = "31283",
    version   = "9",
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  destroy_url    = var.destroy_url
  destroy_method = "GET"

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to configure copilot as syslog server: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [
    terracurl_request.add_copilot_service_account,
  ]
}

#Initialize Copilot
resource "terracurl_request" "copilot_init_simple" {
  name            = "copilot_init_simple"
  url             = "https://${var.copilot_public_ip}/v1/api/single-node"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    taskserver = {
      username = var.copilot_service_account_username,
      password = var.copilot_service_account_password,
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

  destroy_url    = var.destroy_url
  destroy_method = "GET"

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    terracurl_request.configure_netflow,
    terracurl_request.configure_syslog,
    terracurl_request.enable_copilot_association
  ]
}
