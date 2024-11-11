# terraform-aviatrix-copilot-init

### Description
This module initializes a freshly deployed copilot.

### Compatibility
Module version | Terraform version
:--- | :---
v1.0.3 | >= 1.3

### Usage Example
```hcl
module "copilot_init" {
  source  = "terraform-aviatrix-modules/copilot-init/aviatrix"
  version = "1.0.3"

  controller_public_ip         = "1.2.3.4"
  controller_admin_password    = "mysecretpassword"
  copilot_public_ip            = "2.3.4.5"
  service_account_email            = "admin@domain.com"
  copilot_service_account_password = "mysecretpassword"
}
```

### Variables
The following variables are required:

key | value
:--- | :---
controller_public_ip | Public IP of the controller
controller_admin_password | Admin password for the controller
copilot_public_ip | Public IP of Copilot
service_account_email | Email address for the service account
copilot_service_account_password | Desired password for the service account

The following variables are optional:

key | default | value 
:---|:---|:---
controller_admin_username | Admin username for the controller | admin
copilot_service_account_username | Service account name for Copilot | copilot_service_account
configure_syslog | Enable configuration of syslog | true
configure_netflow | Enable configuration of netflow | true

### Outputs
This module will return the following outputs:

key | description
:---|:---
copilot_init_simple_result | Result of the copilot initialization
