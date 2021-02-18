# Valhalla - HotelBragança's Valheim Server infrastructure

This repo contains the terraform files that manage `valheim.hotelbraganca.club:2457`, a Valheim dedicated server.

It uses `terraform-provider-openstack` and the OVH Public Cloud (which it turns out [supports openstack](https://www.openstack.org/marketplace/public-clouds/ovh-group/ovh-public-cloud)) to setup a `s1-8` instance to be a Valheim dedicated server.

Check `variables.tf` and `terraform.tfvars.example` for configuration options, such as _server name_, _server password_, _OVH Openstack Credentials_ (to source your own ones via the OpenStack RC file check the instructions below), the _key file path_ to access the instance, the _OVH Cloud region_ and a bunch of openstack stuff.

## Pre-requisites
1. Created OVH Openstack user, password, tenant id and tenant name. Get and create those [here](https://docs.ovh.com/gb/en/public-cloud/set-openstack-environment-variables/).
2. `terraform` v0.14.6

## Usage
1. Put OVH OpenStack secrets in `terraform.tfvars`
2. Change configuration via changing default values for variables in `variables.tf`
3. Ensure presence of SSH key in `~/.ssh/id-rsa` or change the `key_file_path` tf variable 
4. `terraform init`
5. `terraform apply`
6. Server should be up at the `server_query_port_string` output 

### Using [git-crypt](https://github.com/AGWA/git-crypt) to store state and variables on github. _Just push your secrets to github lmao_
