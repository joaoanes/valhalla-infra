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
  name        = "test"
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
    content = templatefile("support/provision.sh", {
      steam_user_password = random_password.steam_user.result
    })
    destination = "/home/ubuntu/provision.sh"
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
