resource "random_password" "steam_user" {
  length           = 16
  special          = true
  override_special = "_%@"
}

data "openstack_compute_flavor_v2" "s1-8" {
  name = "s1-8"
}

data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 18.04"
  most_recent = true

  properties = {
    key = "value"
  }
}

resource "openstack_compute_instance_v2" "server" {
  name        = "valhalla-staging"
  flavor_id   = data.openstack_compute_flavor_v2.s1-8.id
  flavor_name = data.openstack_compute_flavor_v2.s1-8.name
  image_name  = data.openstack_images_image_v2.ubuntu.name
  image_id    = data.openstack_images_image_v2.ubuntu.id
  region      = var.openstack_region
  key_pair    = openstack_compute_keypair_v2.local.name

  metadata          = {}
  tags              = []
  availability_zone = "nova" #OVH default AZ

  security_groups = ["default"]

  network {
    name = "Ext-Net" # OVH public network
  }

  connection {
    host        = openstack_compute_instance_v2.server.access_ip_v4
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "file" {
    source      = "support/valhalla.service"
    destination = "/home/ubuntu/valhalla.service"
  }

  provisioner "file" {
    source      = "support/elasticsearch.yml"
    destination = "/home/ubuntu/elasticsearch.yml"
  }

  provisioner "file" {
    source      = "support/filebeat.yml"
    destination = "/home/ubuntu/filebeat.yml"
  }

  provisioner "file" {
    content = templatefile("support/kibana.yml", {
      instance_address = openstack_compute_instance_v2.server.access_ip_v4
    })
    destination = "/home/ubuntu/kibana.yml"
  }

  provisioner "file" {
    source      = "support/02-beats-input.conf"
    destination = "/home/ubuntu/02-beats-input.conf"
  }

  provisioner "file" {
    source      = "support/10-syslog-filter.conf"
    destination = "/home/ubuntu/10-syslog-filter.conf"
  }

  provisioner "file" {
    source      = "support/30-elasticsearch-output.conf"
    destination = "/home/ubuntu/30-elasticsearch-output.conf"
  }


  provisioner "file" {
    source      = "support/crontab"
    destination = "/home/ubuntu/crontab"
  }

  provisioner "file" {
    content = templatefile("support/backup.sh", {
      aws_region        = var.aws_region
      route53_subdomain = var.route53_subdomain
    })
    destination = "/home/ubuntu/backup.sh"
  }

  provisioner "file" {
    content = templatefile("support/provision.sh", {
      steam_user_password = random_password.steam_user.result
      aws_region          = var.aws_region
      route53_subdomain   = var.route53_subdomain
    })
    destination = "/home/ubuntu/provision.sh"
  }

  provisioner "file" {
    content = templatefile("support/elastic.sh", {
      instance_address = openstack_compute_instance_v2.server.access_ip_v4
    })
    destination = "/home/ubuntu/elastic.sh"
  }

  provisioner "file" {
    content = templatefile("support/run.sh", {
      server_name     = var.server_name
      world_name      = var.server_world_name
      server_password = var.server_password
    })
    destination = "/home/ubuntu/run.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/provision.sh",
      "sudo /home/ubuntu/provision.sh"
    ]
  }

}

output "ssh_string" {
  value = "ssh ubuntu@${openstack_compute_instance_v2.server.access_ip_v4} -i ${var.key_file_path}"
}

output "server_query_port_string" {
  value = "${var.route53_subdomain}-staging.${var.route53_domain_name}:2457"
}
