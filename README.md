# terraform-aviatrix-copilot-init

### Description
This module initializes a freshly deployed copilot.

### Compatibility
Module version | Terraform version
:--- | :---
v1.0.0 | >= 1.3

### Usage Example
```hcl
module "copilot_init" {
  source  = "terraform-aviatrix-modules/copilot_init/aviatrix"
  version = "1.0.0"

x
}
```

### Variables
The following variables are required:

key | value
:--- | :---
\<keyname> | \<description of value that should be provided in this variable>

The following variables are optional:

key | default | value 
:---|:---|:---
\<keyname> | \<default value> | \<description of value that should be provided in this variable>

### Outputs
This module will return the following outputs:

key | description
:---|:---
\<keyname> | \<description of object that will be returned in this output>
