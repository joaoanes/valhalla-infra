terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.37.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "openstack" {
  auth_url    = var.openstack_auth_url
  user_name   = var.openstack_username
  password    = var.openstack_password
  domain_name = "default" # OVH;s single domain

  tenant_name         = var.openstack_tenant_name
  tenant_id           = var.openstack_tenant_id
  user_domain_name    = var.openstack_user_domain_name
  project_domain_name = var.openstack_project_domain_name

  region = var.openstack_region
}

