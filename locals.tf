locals {
  controller_cid = jsondecode(terracurl_request.controller_login.response)["CID"]

  permission_group = "copilot_permission"
  rbac_permissions = "all_write"
}
