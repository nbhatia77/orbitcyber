# prodops-tf-m-flex
## Terraform module for creating a FLEX environment

### To instantiate
```terraform

terraform {
  backend "s3" {
    bucket = "prodops-tf-states"
    key    = "derms01/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region     = "us-east-2"
}

module "derms01_env" {
  source = "git@github.com:auto-grid/prodops-tf-m-flex.git"
  env = "derms01"
  region = "us-east-2"
  key_name = "devops_autogrid2013_0910"
  vpc_cidr_first_two = "10.15"
}
```

### Inputs
All input variables can be found in [variables.tf](variables.tf). You'll also find default values and descriptions.

### Outputs
This module doesn't currently output any values
