variable "openstack_auth_url" {
  type    = string
  default = "https://auth.cloud.ovh.net/v3/"
}

variable "openstack_identity_version" {
  type    = string
  default = "3"
}

variable "openstack_user_domain_name" {
  type    = string
  default = "default"
}

variable "openstack_project_domain_name" {
  type    = string
  default = "default"
}

variable "openstack_region" {
  type    = string
  default = "SBG5" //strasbourg
}

variable "openstack_tenant_id" {
  sensitive = true
  type      = string
}

variable "openstack_tenant_name" {
  sensitive = true
  type      = string
}

variable "openstack_username" {
  sensitive = true
  type      = string
}

variable "openstack_password" {
  sensitive = true
  type      = string
}

variable "server_name" {
  type    = string
  default = "HotelBragança Look Away Please"
}

variable "key_file_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "server_password" {
  type = string
  # https://github.com/hashicorp/terraform/pull/27401
  # this should be sensitive, waiting for patch
}

variable "server_world_name" {
  type    = string
  default = "mc"
}

variable "route53_domain_name" {
  type    = string
  default = "hotelbraganca.club"
}

variable "route53_subdomain" {
  type    = string
  default = "valhalla"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_profile" {
  type    = string
  default = "valhalla"
}
