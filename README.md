# Valhalla - HotelBragança's Valheim Server infrastructure

This repo contains the terraform files that manage `valheim.hotelbraganca.club:2457`, a Valheim dedicated server.

It uses `terraform-provider-openstack` and the OVH Public Cloud (which it turns out [supports openstack](https://www.openstack.org/marketplace/public-clouds/ovh-group/ovh-public-cloud)) to setup a `s1-8` instance to be a Valheim dedicated server, and changes a route53 record using the `aws` provider with that instance's public IP while configuring an `s3` bucket for backups.

After setting up the instance, we provision it by downloading necessary dependencies and the Valheim server binaries, installing a `systemd` service (so we can use `systemd` to manage the running server), and using `run.sh` to run the server with our configuration (password, server name, etc). We also install a backup script that tars the world files and sends them to the created backup `s3` bucket. It also deploys the elastic stack, elasticsearch, kibana, logstash and filebeat.

Check `variables.tf` and `terraform.tfvars.example` for configuration options, such as _server name_, _server password_, _OVH Openstack Credentials_ (to source your own ones via the OpenStack RC file check the instructions below), the _key file path_ to access the instance, the _OVH Cloud region_ and a bunch of openstack stuff.

## Pre-requisites
1. Created OVH Openstack user, password, tenant id and tenant name. Get and create those [here](https://docs.ovh.com/gb/en/public-cloud/set-openstack-environment-variables/).
2. `terraform` v0.14.6
2. `aws-cli` configured with a profile (tf variable `aws_profile`) with `Route53` access.

## Usage
1. Put OVH OpenStack secrets in `terraform.tfvars`
2. Change configuration via changing default values for variables in `variables.tf`
3. Ensure presence of SSH key in `~/.ssh/id-rsa` or change the `key_file_path` tf variable
4. `terraform init`
5. `terraform apply`
6. Server should be up at the `server_query_port_string` output. Ain't terraform great?

## Can I use this?
Sure, go ahead. You might want to change the default variables in `variables.tf` to suit your settings. If the Route53 setup is unnecessary for you, remove the `route53.tf` file and remove the AWS provider lines in `provider.tf`. I'm guessing you can also use other cloud services with OpenStack APIs, but I haven't tested with anything other than OVH.

If you don't want/need all this terraform automation, the brunt of the work installing Valheim Dedicated Server on Ubuntu 18.04 is done by `support/provision.sh`, which you can use as an example. Just remove the line that calls `elastic.sh`, you probably don't need that.

### Using [git-crypt](https://github.com/AGWA/git-crypt) to store state and variables on github. _Just push your secrets to github lmao_
