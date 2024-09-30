locals {
  controller_cid = jsondecode(data.http.controller_login.response_body)["CID"]

  permission_group = "copilot_permission"
  rbac_permissions = "all_write"
}
