resource "aws_route53_zone" "root" {
  name = var.route53_domain_name
}

resource "aws_route53_record" "production" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "${var.route53_subdomain}.${var.route53_domain_name}"
  type    = "A"
  ttl     = "60"
  records = [openstack_compute_instance_v2.valhalla.access_ip_v4]
}
