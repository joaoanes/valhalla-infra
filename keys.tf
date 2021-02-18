resource "openstack_compute_keypair_v2" "local" {
  name       = "local"
  public_key = file(var.key_file_path)
}
